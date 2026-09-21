import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// SHA-512 Hash helper
async function sha512Hex(message: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(message);
  const hashBuffer = await crypto.subtle.digest("SHA-512", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY") || "";

    const payload = await req.json();
    const {
      order_id: orderIdMidtrans,
      status_code: statusCode,
      gross_amount: grossAmount,
      signature_key: signatureKey,
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
      payment_type: paymentType,
      transaction_id: transactionId,
      settlement_time: settlementTime,
    } = payload;

    if (!orderIdMidtrans || !signatureKey) {
      return new Response(JSON.stringify({ error: "Invalid notification payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // SHA-512 Signature verification
    const expectedSignature = await sha512Hex(orderIdMidtrans + statusCode + grossAmount + midtransServerKey);
    if (expectedSignature !== signatureKey) {
      console.error("Signature Mismatch!", { expectedSignature, signatureKey });
      return new Response(JSON.stringify({ error: "Invalid signature" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch payment_transactions entry
    const { data: tx, error: txError } = await adminClient
      .from("payment_transactions")
      .select("*, orders(*)")
      .eq("order_id_midtrans", orderIdMidtrans)
      .single();

    if (txError || !tx) {
      return new Response(JSON.stringify({ error: "Transaction reference not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const orderId = tx.order_id;
    const order = tx.orders;

    // Idempotency check: if transaction is already processed settlement/capture, skip duplicate processing
    if (tx.transaction_status === "settlement" || tx.transaction_status === "capture") {
      return new Response(JSON.stringify({ status: "OK", message: "Notification already processed" }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    let paymentStatus = "PENDING";
    let orderStatus = "PENDING_PAYMENT";
    let isSuccess = false;

    if (transactionStatus === "capture") {
      if (fraudStatus === "accept") {
        paymentStatus = "PAID";
        orderStatus = "PAID";
        isSuccess = true;
      }
    } else if (transactionStatus === "settlement") {
      paymentStatus = "PAID";
      orderStatus = "PAID";
      isSuccess = true;
    } else if (transactionStatus === "cancel" || transactionStatus === "deny" || transactionStatus === "expire") {
      paymentStatus = "FAILED";
      orderStatus = "CANCELLED";
    } else if (transactionStatus === "pending") {
      paymentStatus = "PENDING";
      orderStatus = "PENDING_PAYMENT";
    } else if (transactionStatus === "refund") {
      paymentStatus = "REFUNDED";
      orderStatus = "REFUNDED";
    }

    // Update payment_transactions
    await adminClient.from("payment_transactions").update({
      transaction_id: transactionId,
      payment_type: paymentType,
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
      raw_response: payload,
      paid_at: isSuccess ? (settlementTime || new Date().toISOString()) : null,
      updated_at: new Date().toISOString(),
    }).eq("id", tx.id);

    // Update orders status
    await adminClient.from("orders").update({
      payment_status: paymentStatus,
      order_status: orderStatus,
      updated_at: new Date().toISOString(),
    }).eq("id", orderId);

    // Insert or update payment entry
    await adminClient.from("payments").insert({
      order_id: orderId,
      payment_method: "MIDTRANS",
      amount: Number(grossAmount),
      status: paymentStatus,
      paid_at: isSuccess ? (settlementTime || new Date().toISOString()) : null,
    });

    if (isSuccess) {
      // 1. Generate Queue Number
      const { data: queueNum } = await adminClient.rpc("generate_queue_number", {
        p_branch_id: order.branch_id,
        p_order_id: orderId,
        p_order_type: order.order_type,
      });

      // 2. Deduct inventory stock safely
      await adminClient.rpc("deduct_stock_on_order", { p_order_id: orderId });

      // 3. Dispatch notifications for Cashier & Kitchen
      await adminClient.from("notifications").insert([
        {
          user_id: order.user_id,
          title: "Pembayaran Berhasil",
          message: `Pesanan #${order.order_number} telah dibayar (Antrean: ${queueNum}).`,
          type: "ORDER_PAID",
          reference_id: orderId,
        },
        {
          role_target: "KASIR",
          title: "Pesanan Baru Masuk",
          message: `Pesanan Baru #${order.order_number} (${order.order_type}) - Antrean: ${queueNum}`,
          type: "NEW_ORDER",
          reference_id: orderId,
        },
        {
          role_target: "DAPUR",
          title: "Pesanan Baru Dapur",
          message: `Tiket Baru #${order.order_number} (${order.order_type}) - Antrean: ${queueNum}`,
          type: "NEW_KITCHEN_ORDER",
          reference_id: orderId,
        },
      ]);
    }

    return new Response(JSON.stringify({ status: "OK", message: "Notification handled successfully" }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err: any) {
    console.error("Webhook processing error:", err);
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

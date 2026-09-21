import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY") || "";
    const isProduction = Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true";

    if (!midtransServerKey) {
      return new Response(JSON.stringify({ error: "Midtrans Server Key is not configured in secrets" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Authenticate user with anon key & token
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized access" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { order_id, customer_name, customer_email, customer_phone } = body;

    if (!order_id) {
      return new Response(JSON.stringify({ error: "order_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Use Service Role Client to fetch and recalculate trusted order data
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);

    const { data: order, error: orderError } = await adminClient
      .from("orders")
      .select("*, order_items(*)")
      .eq("id", order_id)
      .single();

    if (orderError || !order) {
      return new Response(JSON.stringify({ error: "Order not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Server-side recalculation to prevent frontend price manipulation
    let computedSubtotal = 0;
    const itemDetails = [];

    for (const item of order.order_items) {
      const itemSubtotal = Number(item.price_snapshot) * item.quantity;
      computedSubtotal += itemSubtotal;
      itemDetails.push({
        id: item.product_id,
        price: Math.round(Number(item.price_snapshot)),
        quantity: item.quantity,
        name: item.product_name.substring(0, 50),
      });
    }

    // Fetch tax & service settings
    const { data: taxSetting } = await adminClient.from("settings").select("value").eq("key", "tax_rate").single();
    const { data: serviceSetting } = await adminClient.from("settings").select("value").eq("key", "service_charge_rate").single();

    const taxRate = taxSetting ? parseFloat(taxSetting.value) : 0.10;
    const serviceRate = serviceSetting ? parseFloat(serviceSetting.value) : 0.05;

    const discountAmount = Number(order.discount_amount) || 0;
    const taxableBase = Math.max(0, computedSubtotal - discountAmount);
    const computedTax = Math.round(taxableBase * taxRate);
    const computedService = Math.round(taxableBase * serviceRate);
    const computedGrandTotal = taxableBase + computedTax + computedService;

    // Add tax & service charge item lines if applicable
    if (computedTax > 0) {
      itemDetails.push({ id: "TAX", price: computedTax, quantity: 1, name: "PB1 Tax (10%)" });
    }
    if (computedService > 0) {
      itemDetails.push({ id: "SERVICE", price: computedService, quantity: 1, name: "Service Charge (5%)" });
    }
    if (discountAmount > 0) {
      itemDetails.push({ id: "DISCOUNT", price: -Math.round(discountAmount), quantity: 1, name: "Promo Discount" });
    }

    // Update order snapshot with verified totals
    await adminClient.from("orders").update({
      subtotal: computedSubtotal,
      discount_amount: discountAmount,
      tax_amount: computedTax,
      service_charge: computedService,
      grand_total: computedGrandTotal,
      payment_status: "PENDING",
      order_status: "PENDING_PAYMENT",
      updated_at: new Date().toISOString()
    }).eq("id", order_id);

    const midtransOrderId = `${order.order_number}-${Date.now()}`;
    const snapUrl = isProduction
      ? "https://app.midtrans.com/snap/v1/transactions"
      : "https://app.sandbox.midtrans.com/snap/v1/transactions";

    const authHeaderString = "Basic " + btoa(midtransServerKey + ":");

    const snapPayload = {
      transaction_details: {
        order_id: midtransOrderId,
        gross_amount: computedGrandTotal,
      },
      item_details: itemDetails,
      customer_details: {
        first_name: customer_name || "Guest",
        email: customer_email || "customer@example.com",
        phone: customer_phone || "08123456789",
      },
      callbacks: {
        finish: `${req.headers.get("origin") || "http://localhost"}/user/order-detail.html?id=${order_id}`,
      }
    };

    const midtransRes = await fetch(snapUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeaderString,
      },
      body: JSON.stringify(snapPayload),
    });

    const snapData = await midtransRes.json();

    if (!midtransRes.ok) {
      return new Response(JSON.stringify({ error: snapData.error_messages || "Midtrans Snap Error" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Record payment_transaction entry
    await adminClient.from("payment_transactions").insert({
      order_id: order_id,
      order_id_midtrans: midtransOrderId,
      gross_amount: computedGrandTotal,
      transaction_status: "pending",
      currency: "IDR",
      raw_response: snapData,
    });

    return new Response(JSON.stringify({
      token: snapData.token,
      redirect_url: snapData.redirect_url,
      order_id_midtrans: midtransOrderId,
      grand_total: computedGrandTotal
    }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

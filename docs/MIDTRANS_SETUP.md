# Panduan Integrasi Midtrans Snap (Midtrans Setup Guide)
## Sistem Pemesanan Kafe & POS - Mie Gacoan

Panduan konfigurasi portal pengembang Midtrans Snap, pengelolaan Server Key, dan pendaftaran URL Webhook.

---

## 1. Mendaftar Akun Midtrans Sandbox
1. Buka [dashboard.sandbox.midtrans.com](https://dashboard.sandbox.midtrans.com) dan buat akun pengembang baru.
2. Masuk ke **SETTINGS** -> **Access Keys**.
3. Dapatkan nilai berikut:
   - **Merchant ID** (contoh: `G123456789`)
   - **Client Key** (contoh: `SB-Mid-client-xxxx`)
   - **Server Key** (contoh: `SB-Mid-server-yyyy`)

---

## 2. Pengaturan Penting Keamanan
> [!CAUTION]
> **KUNCI RAHASIA SERVER (MIDTRANS SERVER KEY) TIDAK BOLEH BERADA DI FRONTEND!**
> Jangan pernah memasukkan `MIDTRANS_SERVER_KEY` ke dalam berkas HTML, CSS, JavaScript, repository Git, atau localStorage. Server Key wajib disimpan sebagai *Edge Function Environment Secret* pada Supabase.

---

## 3. Konfigurasi URL Notification Webhook di Midtrans
1. Di portal Midtrans Dashboard, buka **SETTINGS** -> **Configuration**.
2. Masukkan URL webhook Supabase Edge Function pada kolom **Payment Notification URL**:

```text
https://YOUR-PROJECT-REF.supabase.co/functions/v1/midtrans-webhook
```

3. Atur opsi berikut:
   - **Finish Redirect URL**: `https://your-domain.com/user/order-detail.html`
   - **Unfinished Redirect URL**: `https://your-domain.com/user/cart.html`
   - **Error Redirect URL**: `https://your-domain.com/user/cart.html`
4. Simpan konfigurasi (*Save Configuration*).

---

## 4. Pengujian Transaksi di Mode Sandbox
Anda dapat melakukan pengujian transaksi menggunakan kredensial kartu simulator atau QRIS simulator dari Midtrans:

| Metode Pembayaran | Nomor Kartu / Panduan Simulator | OTP / PIN Simulator |
| :--- | :--- | :--- |
| **Kartu Kredit Test** | `4811 1111 1111 1111` (CVV: `123`, Exp: `12/28`) | `112233` |
| **QRIS / GoPay** | Pindai QR Code di layar simulator Midtrans | Aplikasi Simulator |
| **BCA Virtual Account** | `77777 + Nomor HP` | Simulator VA Midtrans |
| **Bank Mandiri Bill** | Bill Key Simulator | Simulator Mandiri |

---

## 5. Beralih ke Lingkungan Produksi (Production Mode)
1. Ajukan verifikasi akun bisnis di [dashboard.midtrans.com](https://dashboard.midtrans.com).
2. Setelah disetujui, perbarui rahasia Supabase CLI:

```bash
supabase secrets set MIDTRANS_SERVER_KEY="Mid-server-PRODUCTION-KEY"
supabase secrets set MIDTRANS_CLIENT_KEY="Mid-client-PRODUCTION-KEY"
supabase secrets set MIDTRANS_IS_PRODUCTION="true"
```

3. Perbarui `MIDTRANS_CLIENT_KEY` di `js/config.js`.

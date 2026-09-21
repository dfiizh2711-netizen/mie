# Architecture & Integration Specification
## Sistem Manajemen Kafe, POS, KDS & Reservasi - Mie Gacoan

---

## 1. Topologi Arsitektur Terintegrasi

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        FRONTEND APPLICATION LAYER                      │
│                                                                        │
│   [ USER APP ]       [ CASHIER POS ]       [ KITCHEN KDS ]  [ ADMIN ]  │
│   user/*.html        cashier/*.html        kitchen/*.html   admin/*.html│
└───────┬────────────────────┬──────────────────────┬─────────────┬──────┘
        │                    │                      │             │
        │ Supabase SDK JS v2 │ Realtime WebSockets  │ Realtime    │
        ▼                    ▼                      ▼             ▼
┌────────────────────────────────────────────────────────────────────────┐
│                       SUPABASE PLATFORM ENGINE                         │
│                                                                        │
│  ┌─────────────────────────┐         ┌──────────────────────────────┐  │
│  │     Supabase Auth       │         │   Supabase Realtime Engine   │  │
│  │ (JWT & User Metadata)   │         │ (Postgres Changes Broadcast) │  │
│  └────────────┬────────────┘         └──────────────▲───────────────┘  │
│               │                                     │                  │
│               ▼                                     │                  │
│  ┌──────────────────────────────────────────────────┴───────────────┐  │
│  │              PostgreSQL Database Engine (16+ Tables)             │  │
│  │         - 100% Strict Row Level Security (RLS) Policies          │  │
│  │         - Stored Functions: generate_queue_number(), deduct_stock│  │
│  └──────────────────────────────────▲───────────────────────────────┘  │
└─────────────────────────────────────┼──────────────────────────────────┘
                                      │ Invokes via Service Role
                                      │
┌─────────────────────────────────────┴──────────────────────────────────┐
│                    SUPABASE EDGE FUNCTIONS (DENO)                      │
│                                                                        │
│  1. create-midtrans-transaction                                        │
│     - Validasi ulang harga dari database (Anti-Tampering)              │
│     - Membuat Snap Token tanpa mengekspos Midtrans Server Key           │
│                                                                        │
│  2. midtrans-webhook                                                   │
│     - Verifikasi Signature SHA-512                                     │
│     - Idempotent Processing                                            │
│     - Pembaruan Status, Penerbitan Nomor Antrean & Pengurangan Stok    │
└─────────────────────────────────────▲──────────────────────────────────┘
                                      │ HTTPS Webhook Notifications
                                      │
┌─────────────────────────────────────┴──────────────────────────────────┐
│                   MIDTRANS PAYMENT GATEWAY ENGINE                      │
│                                                                        │
│   Snap API Payment Core (QRIS, GoPay, ShopeePay, BCA VA, Credit Card)  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Alur Transaksi Pembayaran & Keamanan Key Isolation

1. **Inisiasi Pembayaran**: Pelanggan menekan tombol "Bayar Pesanan" pada `user/checkout.html`.
2. **Permintaan Token Snap**: Kode frontend memanggil Supabase Edge Function `create-midtrans-transaction` dengan membawa Header Autentikasi JWT.
3. **Validasi Ulang Server-Side**: Edge Function mengambil rincian item pesanan dari database PostgreSQL, menghitung ulang subtotal, diskon promo, pajak PB1 (10%), dan service charge (5%). Total harga dihitung secara tepercaya tanpa mengandalkan angka dari frontend.
4. **Respon Snap Token**: Edge Function berkomunikasi langsung dengan API Midtrans Snap menggunakan `MIDTRANS_SERVER_KEY` (yang hanya ada di rahasia lingkungan Deno), lalu mengembalikan `token` Snap ke frontend.
5. **Widget Pop-up Snap**: Frontend menampilkan widget bayar Midtrans Snap kepada pelanggan.
6. **Notifikasi Webhook**: Setelah pembayaran selesai, Midtrans mengirimkan notifikasi HTTPS POST ke Edge Function `midtrans-webhook`.
7. **Verifikasi Signature SHA-512**: Edge Function menghitung hash `SHA512(order_id + status_code + gross_amount + ServerKey)` dan mencocokkannya dengan `signature_key` dari Midtrans.
8. **Pengolahan Idempoten**: Edge Function memperbarui status transaksi di database, memanggil fungsi RPC `generate_queue_number()` untuk menerbitkan nomor antrean unik (`D001` atau `T001`), serta mengurangi stok inventaris via `deduct_stock_on_order()`.
9. **Siaran Realtime WebSockets**: Supabase Realtime secara otomatis menyiarkan peristiwa perubahan data ke layar Kasir, Display Dapur (KDS), dan Struk Pelanggan tanpa perlu memuat ulang halaman.

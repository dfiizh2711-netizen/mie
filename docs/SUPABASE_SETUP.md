# Panduan Penyiapan Supabase (Supabase Setup Guide)
## Sistem Manajemen Kafe & POS - Mie Gacoan

Panduan langkah demi langkah untuk mengonfigurasi proyek Supabase, menjalankan migrasi database, menyebarkan kebijakan RLS, dan memasang Edge Functions.

---

## 1. Persyaratan Awal (Prerequisites)
- Akun Supabase aktif ([supabase.com](https://supabase.com))
- Supabase CLI terpasang pada komputer lokal (`npm i -g supabase`)
- Deno runtime untuk pengujian Edge Function lokal

---

## 2. Langkah 1: Eksekusi Migrasi SQL Database

Jalankan skrip migrasi berurutan melalui **Supabase SQL Editor** atau perintah CLI:

### 2.1 Skema Database (`20260921000000_schema.sql`)
Buka berkas `supabase/migrations/20260921000000_schema.sql` dan jalankan pada SQL Editor. Ini akan membuat:
- 20 tabel utama (profiles, branches, tables, categories, products, reservations, orders, dll.)
- Fungsi pemicu registrasi profil otomatis (`handle_new_user()`)
- Fungsi pencegahan reservasi ganda (`check_reservation_conflict()`)
- Generator nomor antrean aman harian (`generate_queue_number()`)
- Pengurang stok aman atomic (`deduct_stock_on_order()`)

### 2.2 Kebijakan Keamanan RLS (`20260921000001_rls.sql`)
Jalankan `supabase/migrations/20260921000001_rls.sql`. Ini akan mengaktifkan Row Level Security pada seluruh 20 tabel dan memasang kebijakan hak akses 4 peran (`USER`, `KASIR`, `DAPUR`, `ADMIN`).

### 2.3 Data Awal / Seed (`seed.sql`)
Jalankan `supabase/seed.sql` untuk mengisi data cabang awal, 10 meja makan, 5 kategori menu, 15+ produk makanan/minuman dengan tautan aset `.webp`, stok awal, dan voucher promo.

---

## 3. Langkah 2: Konfigurasi Supabase Realtime
1. Buka **Supabase Dashboard** -> **Database** -> **Publications**.
2. Pastikan publikasi `supabase_realtime` mengaktifkan tabel berikut:
   - `orders`
   - `kitchen_orders`
   - `queue_numbers`
   - `reservations`
   - `notifications`

---

## 4. Langkah 3: Penyebaran Supabase Edge Functions

### 4.1 Mengatur Kunci Rahasia Lingkungan (Secrets)
Jalankan perintah CLI berikut untuk menyimpan rahasia Midtrans:

```bash
supabase secrets set MIDTRANS_SERVER_KEY="SB-Mid-server-YOUR-SERVER-KEY"
supabase secrets set MIDTRANS_CLIENT_KEY="SB-Mid-client-YOUR-CLIENT-KEY"
supabase secrets set MIDTRANS_IS_PRODUCTION="false"
```

### 4.2 Menyebarkan Edge Functions
```bash
supabase functions deploy create-midtrans-transaction --no-verify-jwt
supabase functions deploy midtrans-webhook --no-verify-jwt
```

---

## 5. Langkah 4: Menghubungkan Frontend

Perbarui berkas `js/config.js` pada proyek Anda dengan URL & Anon Key Supabase:

```javascript
window.APP_CONFIG = {
  SUPABASE_URL: "https://your-project-ref.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  MIDTRANS_CLIENT_KEY: "SB-Mid-client-YOUR-CLIENT-KEY",
  DEFAULT_BRANCH_ID: "b0000000-0000-0000-0000-000000000001"
};
```

# Testing & Quality Assurance Document
## Sistem Pemesanan Kafe & POS - Mie Gacoan

Dokumen panduan pengujian otomatis dan verifikasi manual End-to-End (E2E) untuk memastikan keandalan sistem sebelum penyebaran produksi.

---

## 1. Pengujian Otomatis (Automated Audit Suite)

Jalankan perintah berikut di terminal untuk mengeksekusi pengujian otomatis:

```bash
node scripts/full-audit.js
```

### Hasil Verifikasi Skrip Otomatis:
- **`scripts/verify-assets.js`**: Memverifikasi keberadaan 100% berkas gambar produk `.webp` dan `hero-banner.png`.
- **`scripts/verify-schema.js`**: Memverifikasi 20 tabel skema PostgreSQL dan aturan RLS pada `supabase/migrations/`.
- **`scripts/verify-security.js`**: Memindai seluruh kode frontend (`user/`, `cashier/`, `kitchen/`, `admin/`, `js/`) untuk memastikan tidak ada kebocoran `MIDTRANS_SERVER_KEY` atau `SUPABASE_SERVICE_ROLE_KEY`.

---

## 2. Skenario Pengujian Manual E2E

### 2.1 Skenario 1: Pesanan Pelanggan Dine-In (Mandiri)
1. Buka `user/home.html` -> Klik "Register" -> Buat akun pelanggan baru.
2. Pada Beranda, pilih mode **Dine In** -> Klik "Pilih Meja" -> Pilih **Table 03**.
3. Buka `user/menu.html` -> Tambahkan **Mie Hompimpa (Lvl 2)** & **Es Gobak Sodor** ke keranjang.
4. Buka `user/cart.html` -> Masukkan kode promo `GACOAN10` -> Verifikasi potongan diskon 10%.
5. Klik "Lanjut Checkout" (`user/checkout.html`) -> Pilih pembayaran **Midtrans Snap** -> Klik "Bayar Sekarang".
6. Widget Midtrans Snap terbuka -> Selesaikan pembayaran dengan simulator QRIS / Kartu Kredit.
7. Diarahkan otomatis ke `user/order-detail.html` -> Verifikasi status pembayaran `PAID` & nomor antrean diterbitkan (`D001`).

### 2.2 Skenario 2: Alur Operasional POS Kasir & Display Dapur (KDS)
1. Buka `cashier/dashboard.html` di jendela penjelajah kedua -> Login sebagai `KASIR`.
2. Verifikasi pesanan `D001` otomatis muncul di tabel pesanan realtime tanpa memuat ulang halaman.
3. Klik "Konfirmasi Dapur" -> Pesanan dikirim ke dapur.
4. Buka `kitchen/dashboard.html` di jendela penjelajah ketiga -> Login sebagai `DAPUR`.
5. Verifikasi tiket `D001` muncul pada kolom **TIKET BARU (NEW)**.
6. Klik "MULAI MASAK" -> Tiket berpindah ke kolom **SEDANG DIMASAK (PREPARING)**.
7. Verifikasi layar Kasir & Pelanggan secara bersamaan memperbarui status menjadi `PREPARING`.
8. Klik "TANDAI SIAP SAJI" pada KDS -> Tiket berpindah ke kolom **SIAP SAJI (READY)**.
9. Verifikasi layar panggilan antrean Kasir (`cashier/queue.html`) menampilkan nomor `D001`.

### 2.3 Skenario 3: Input Pesanan Manual Walk-in Kasir (Take Away)
1. Buka `cashier/manual-order.html` -> Pilih mode **Take Away**.
2. Pilih produk **Mie Suit** & **Teh Manis Dingin**.
3. Pilih metode bayar **CASH** -> Masukkan nominal uang tunai -> Klik "Proses Pesanan & Terima Cash".
4. Verifikasi nomor antrean `T001` dibuat otomatis, kembalian dihitung dengan benar, dan tiket langsung dikirim ke KDS Dapur.

### 2.4 Skenario 4: Reservasi Meja & Uji Pencegahan Double Booking
1. Buka `user/reservation.html` -> Pilih tanggal besok pukul 19:00 -> Pilih **Table 05** -> Kirim reservasi.
2. Coba kirim reservasi kedua untuk **Table 05** pada tanggal dan jam yang sama persis.
3. Verifikasi sistem menolak pengajuan kedua dengan pesan kesalahan: `"Table is already reserved for this date and time"`.
4. Buka `cashier/reservations.html` -> Kasir menyetujui reservasi pertama -> Status berubah menjadi `CONFIRMED`.

### 2.5 Skenario 5: Manajemen Inventaris & Log Audit Admin
1. Buka `admin/inventory.html` -> Login sebagai `ADMIN`.
2. Catat penambahan barang masuk (*Stock In*) 50 pcs untuk **Mie Hompimpa**.
3. Verifikasi stok bertambah pada tabel inventaris.
4. Buka `admin/audit-logs.html` -> Verifikasi riwayat aksi penambahan stok tercatat lengkap beserta timestamp & ID actor.

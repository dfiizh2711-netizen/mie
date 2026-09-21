# Dokumen Pemetaan Acuan Desain (Design Reference Mapping)

Dokumen ini memetakan seluruh tangkapan layar acuan desain dari folder `reference design/` ke halaman aplikasi, komponen UI, sistem warna, tipografi, serta aset gambar yang digunakan.

---

## 1. Sistem Warna & Tipografi Acuan

### Palet Warna CSS Variables
```css
:root {
  --primary-pink: #e91e63;         /* Warna Merah Muda Khas Gacoan */
  --primary-pink-hover: #d81b60;   /* State Hover Tombol Pink */
  --primary-pink-light: #fce4ec;   /* Background Accent Light */
  --secondary-cyan: #00bcd4;       /* Warna Aksens Biru Muda/Tosca */
  --accent-orange: #ff9800;        /* Aksens Oranye / Peringatan / Nomor Meja */
  --accent-green: #4caf50;         /* Aksens Hijau / Status Sukses / Pembayaran Berhasil */
  --accent-red: #f44336;           /* Aksens Merah / Error / Batal */
  --accent-purple: #9c27b0;        /* Aksens Ungu / Pilihan Takeaway */

  --bg-dark: #0f172a;              /* Latar Belakang POS Staff, KDS Dapur, Admin (Slate 900) */
  --bg-card-dark: #1e293b;         /* Kartu Gelap POS, KDS, Admin (Slate 800) */
  --bg-light: #f8f9fa;             /* Latar Belakang Aplikasi Pelanggan Seluler */
  --bg-card-light: #ffffff;        /* Kartu Putih Pelanggan */

  --text-primary: #1f2937;         /* Teks Utama (Gray 800) */
  --text-secondary: #6b7280;       /* Teks Sekunder / Subtitle (Gray 500) */
  --text-muted: #9ca3af;           /* Teks Muted / Placeholder */
  --text-light: #f9fafb;           /* Teks Terang untuk Mode Gelap */

  --border-color: #e5e7eb;         /* Garis Batas Kartu Light */
  --border-color-dark: #334155;    /* Garis Batas Kartu Dark */

  --font-family: 'Inter', system-ui, -apple-system, sans-serif;
}
```

### Tipografi Hierarchy
- **Title Banner / Headings**: Bold/ExtraBold (700-900), ukuran 1.25rem – 2.2rem.
- **Subheadings & Product Titles**: SemiBold/Bold (600-700), ukuran 1.0rem – 1.125rem.
- **Body & Description**: Medium/Regular (400-500), ukuran 0.875rem – 0.95rem.
- **Badges & Micro Labels**: Bold/ExtraBold (700-900), uppercase, letter spacing 0.5px.

---

## 2. Tabel Pemetaan Gambar Acuan ke Halaman Aplikasi

| Berkas Gambar Acuan (`reference design/`) | Halaman Aplikasi Terkait | Komponen UI Utama | Aset yang Digunakan |
| :--- | :--- | :--- | :--- |
| `tampilan awal.jpeg`<br>`tampilan awal_sacrol1.jpeg`<br>`tampilan awal_scrol2.jpeg` | `user/home.html` | Hero Banner, Pemilih Mode Makan (Dine-In/Take-Away), Selector Meja, Chip Kategori, Grid Produk Unggulan | `asset/hero-banner.png`<br>`asset/mie gacoan.webp`<br>`asset/miesuit.webp` |
| `tampilan kedua .jpeg`<br>`tampilan kedua_scrol1.jpeg` s/d `scrol12.jpeg` | `user/menu.html` | Bar Pencarian, Tab Kategori Menu, Grid Kartu Produk, Control Qty, Floating Cart Bar Bottom Sheet | `asset/miehompimpa.webp`<br>`asset/pangsitgoreng.webp`<br>`asset/siomay.webp`<br>`asset/lemontea.webp` |
| `tampilan klik pencarian .jpeg` | `user/menu.html` | State Modal Pencarian Realtime & Highlight Filter | `asset/airmineral.webp`<br>`asset/esgobaksodor.webp` |
| `tampilan setelah kilk pay (krtika belum ini data diri).jpeg`<br>`tampilan setelah klik continue to payment.jpeg`<br>`tampilan setelah klik continue to payment scrol1.jpeg` | `user/checkout.html` | Form Data Diri Pelanggan, Ringkasan Item Pesanan, Opsi Pembayaran (Midtrans / Tunai / QRIS) | Icon Pembayaran Midtrans Snap |
| `tampilan setelah loading payment.jpeg`<br>`tampilan setelah loading payment_scrol1(pay withother phone).jpeg`<br>`tampilan setelah loading payment_scrol1(paywith the same phone).jpeg`<br>`tampilan loading setelah klik continue payment.jpeg` | `user/payment.html` | Layar Iframe Midtrans Snap, Loader Verifikasi Pembayaran, Instruksi Bayar | Midtrans Snap Widget Script |
| `tampilan setelah klik pay (ketika sudah mengisi data ) verifikasi pembayaran.jpeg` | `user/order-detail.html` | Struk Digital, Nomor Antrean (`D001`/`T001`), Status Pembayaran `PAID`, Timeline Status Dapur | QR Code Generator, Struk Print Action |
| `tampilan order history_order.jpeg` | `user/orders.html` | Papan Riwayat Pesanan Pelanggan (Aktif & Selesai) dengan Status Badge | Status Badge CSS |
| `tampilan order history_reservation.jpeg` | `user/reservation-detail.html` & `user/reservation.html` | Form Reservasi Meja (Tanggal, Jam, Jumlah Tamu) & Tiket Reservasi | Meja Layout Selector |
| `tampilan setelah klik add promos ro vouchers.jpeg` | `user/cart.html` | Drawer Voucher & Form Aplikasi Kode Promo (`GACOAN20`) | Icon Voucher Promo |
| `tampilan setelah klik garis3.jpeg` | All User Pages (`user/*.html`) | Mobile Navigation Drawer Menu (Home, Menu, Orders, Reservation, Profile, Logout) | Navigation Links & User Avatar |
| `tampilan setelah klik language.jpeg` | `user/profile.html` & Settings | Modal Pemilih Bahasa & Preferensi Sistem | Flag Icons |
| `tampilan setelah klik priivacy policy.jpeg` s/d `scrol4.jpeg` | `user/profile.html` | Modal / Halaman Kebijakan Privasi & Syarat Ketentuan | Text Document Content |

---

## 3. Aturan Tata Letak & Responsi
- **Ukuran Layar Pelanggan (Mobile First)**: Diatur menggunakan wadah `.user-container` dengan `max-width: 480px` centered margin auto untuk mensimulasikan tampilan native app seluler secara elegan di semua perangkat desktop & ponsel (320px - 430px).
- **Ukuran Layar Staf/POS/KDS/Admin**: Diatur menggunakan wadah `.dashboard-container` dengan `width: 100%` responsif penuh untuk layar monitor tablet, laptop, dan TV display dapur (768px - 1920px+).

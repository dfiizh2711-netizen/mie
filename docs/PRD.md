# Product Requirements Document (PRD)
## Sistem Manajemen Kafe, POS, KDS & Reservasi - Mie Gacoan

---

## 1. Pendahuluan & Tujuan Sistem
Sistem ini dirancang sebagai platform terpadu serbaguna untuk restoran/kafe modern (studi kasus **Mie Gacoan Sidoarjo Pabean**). Platform ini mengintegrasikan seluruh operasional restoran meliputi:
- Pemesanan Mandiri Pelanggan (Mandiri Dine-In & Take-Away)
- Pembayaran Online Terverifikasi (Midtrans Snap & QRIS)
- Terminal Kasir Point-of-Sale (POS Kasir Walk-In & Tunai)
- Display Dapur Realtime (Kitchen Display System - KDS)
- Sistem Reservasi Meja (Pencegahan *Double Booking*)
- Manajemen Stok & Inventaris Realtime
- Laporan Keuangan Eksekutif & Log Audit Keamanan

---

## 2. Spesifikasi Peran Pengguna (Role Specifications)

### 2.1 Pelanggan (`USER`)
- Registrasi akun, Login, Logout, dan pengelolahan profil.
- Pemilihan mode transaksi: **Dine In** (pilih nomor meja) atau **Take Away** (penerbitan otomatis nomor antrean `T001`).
- Jelajah katalog menu dengan filter kategori, pencarian realtime, dan pemilihan level pedas (Lvl 1 - 8).
- Manajemen keranjang belanja, penerapan kode promo/voucher (`GACOAN10`, `HEMAT5K`), dan catatan pesanan.
- Pembayaran mandiri via Midtrans Snap (QRIS, E-Wallet, Transfer Bank, Kartu Kredit).
- Pelacakan status pesanan secara realtime tanpa perlu muat ulang halaman.
- Reservasi meja makan online untuk tanggal & jam mendatang.

### 2.2 Kasir (`KASIR`)
- Papan pemantau transaksi realtime (Menunggu Pembayaran, Dibayar, Diproses, Siap, Selesai).
- Verifikasi pembayaran tunai/manual di kasir dan pencetakan struk.
- Input pesanan manual di tempat (*Walk-in customer order*) dengan pemilih meja instan.
- Layar tampilan nomor panggilan antrean (*Queue Monitor Board*).
- Konfirmasi dan check-in reservasi meja pelanggan.

### 2.3 Staf Dapur (`DAPUR`)
- Tampilan Kitchen Display System (KDS) 3 kolom Kanban (**BARU**, **SEDANG DIMASAK**, **SIAP SAJI**).
- Notifikasi suara dan visual instan saat pesanan baru dibayar.
- Pengukur waktu (*timer*) durasi persiapan tiket dapur.
- Perubahan status tiket sekali klik (`START PREPARING`, `MARK READY`).

### 2.4 Pentadbir / Pengelola (`ADMIN`)
- Dashboard eksekutif: Omzet harian, jumlah transaksi, barang laris, dan peringatan stok menipis.
- CRUD Master Data: Kategori, Produk (harga, stok, ketersediaan, tautan aset `.webp`).
- CRUD Promosi & Voucher diskon.
- Manajemen Stok & Log Transaksi Masuk/Keluar/Barang Rusak (*Wastage*).
- Manajemen Pengguna & Penetapan Peran (`USER`, `KASIR`, `DAPUR`, `ADMIN`).
- Generator Laporan Penjualan Keuangan & Ekspor CSV.
- Log Audit Keamanan untuk melacak aktivitas sensitif.

---

## 3. Matriks Alur Status Pesanan & State Machine
```text
CART (Keranjang)
  │
  ▼
PENDING_PAYMENT (Menunggu Bayar) ──► EXPIRED / CANCELLED (Batal)
  │
  ▼ (Terbayar via Midtrans/Cash)
PAID / CONFIRMED (Dibayar & Dikonfirmasi)
  │
  ▼ (Staf Dapur Klik MULAI MASAK)
PREPARING (Sedang Disiapkan Dapur)
  │
  ▼ (Staf Dapur Klik TANDAI SIAP)
READY (Siap Diambil / Diantar ke Meja)
  │
  ▼ (Kasir / Pelanggan Selesaikan)
COMPLETED (Selesai)
```

---

## 4. Spesifikasi Teknis & Batasan
- **Frontend**: HTML5, CSS3 Custom Variables, Vanilla JavaScript (ES6+), Supabase JS SDK v2. Tanpa framework berat (No React/Vue/Angular).
- **Backend & Database**: Supabase PostgreSQL 15+, Supabase Auth, Supabase Realtime WebSockets, Supabase Edge Functions (Deno Runtime).
- **Payment Gateway**: Midtrans Snap API sandbox/production. Kunci rahasia server terlindung 100% pada rahasia lingkungan Edge Function.

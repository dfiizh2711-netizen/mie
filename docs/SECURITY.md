# Security & Role Access Control Matrix
## Sistem Pemesanan Kafe & POS - Mie Gacoan

---

## 1. Kebijakan Keamanan Tingkat Baris (Row Level Security - RLS)

Sistem mengabaikan model keamanan berbasis `USING (true)` yang berisiko pada tabel sensitif. Setiap permintaan dari frontend wajib menyertakan token JWT Supabase Auth yang diverifikasi oleh mesin PostgreSQL RLS.

---

## 2. Matriks Hak Akses Peran Pengguna (Role Permission Matrix)

| Tabel Database | `USER` (Pelanggan) | `KASIR` (Kasir POS) | `DAPUR` (Staf Dapur) | `ADMIN` (Pengelola) |
| :--- | :--- | :--- | :--- | :--- |
| `profiles` | Baca/Ubah Sendiri | Baca Semua | Tidak Ada | Kelola Penuh |
| `branches` | Baca Aktif | Baca | Baca | Kelola Penuh |
| `tables` | Baca | Baca & Ubah Status | Baca | Kelola Penuh |
| `categories` | Baca Aktif | Baca | Baca | Kelola Penuh |
| `products` | Baca Aktif | Baca | Baca | Kelola Penuh (Harga/Stok) |
| `reservations` | Buat & Baca Milik Sendiri | Kelola & Konfirmasi | Baca | Kelola Penuh |
| `orders` | Buat & Baca Milik Sendiri | Ubah Status & Terima Cash | Ubah Status Dapur | Kelola Penuh |
| `order_items` | Buat & Baca Milik Sendiri | Baca | Baca | Kelola Penuh |
| `queue_numbers` | Baca | Tambah / Kelola | Baca | Kelola Penuh |
| `payments` | Baca Struk Sendiri | Tambah Bayar Cash | Tidak Ada | Kelola Penuh |
| `payment_transactions` | Tidak Ada | Tidak Ada | Tidak Ada | Kelola Penuh |
| `kitchen_orders` | Tidak Ada | Baca | Ubah Status Masak | Kelola Penuh |
| `inventory` | Tidak Ada | Baca Stok | Baca Stok | Kelola Penuh (Edit Stok) |
| `promotions` | Baca Promo Aktif | Baca | Tidak Ada | Kelola Penuh |
| `audit_logs` | Tidak Ada | Tidak Ada | Tidak Ada | Baca Log Audit |
| `settings` | Baca | Baca | Baca | Kelola Penuh |

---

## 3. Aturan Batas Hak Akses Penting
1. **Perubahan Harga Produk**: Hanya peran `ADMIN` yang diizinkan menambah, mengubah, atau menghapus master harga produk pada tabel `products`. Peran `KASIR` dan `DAPUR` otomatis ditolak oleh RLS jika mencoba mengubah `base_price`.
2. **Penerbitan Nomor Antrean**: Penerbitan nomor antrean (`D001` / `T001`) dijalankan di dalam prosedur tersimpan PostgreSQL `generate_queue_number()` bertipe `SECURITY DEFINER` dengan penguncian baris (`FOR UPDATE`) untuk mencegah kondisi balapan (*race condition*) atau nomor ganda saat banyak pesanan masuk bersamaan.
3. **Pencatatan Log Audit**: Setiap pembatalan pesanan, perubahan harga, atau pengisian stok otomatis mencatat jejak di tabel `audit_logs` beserta ID pengguna yang melakukan aksi tersebut.

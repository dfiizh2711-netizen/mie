# Prompt Antigravity — Redesign UI Mie Gacoan

Anda adalah senior product designer dan frontend engineer. Redesign antarmuka aplikasi restoran Mie Gacoan pada repository yang sedang dibuka, dengan referensi situs live https://mie-liart.vercel.app/ dan screenshot yang diberikan pengguna. Fokus pekerjaan ini adalah **perbaikan visual, tata letak, konsistensi komponen, dan responsive design**. Jangan mengubah sistem dan fungsi yang sudah berjalan.

## Tujuan utama

Buat tampilan aplikasi yang terasa seperti produk restoran modern dan production-ready. UI harus lebih presisi, rapi, mudah dipindai, memiliki spacing yang konsisten, memakai hierarki visual yang jelas, dan bekerja baik pada desktop, tablet, serta mobile. Pertahankan identitas Mie Gacoan melalui kombinasi warna pink-magenta, navy gelap, putih, dan aksen oranye. Gunakan bahasa antarmuka yang sudah ada dan jangan mengganti isi bisnis tanpa alasan.

Aplikasi ini memiliki empat area pengguna: customer, kasir/POS, dapur/KDS, dan admin. Semua area harus terasa berasal dari satu design system, tetapi customer boleh memiliki pengalaman yang lebih ringan dan food-ordering oriented, sedangkan POS, KDS, dan Admin boleh tetap menggunakan tampilan operasional dark theme yang fokus pada efisiensi kerja.

## Batasan penting: jangan merusak fungsi

Sebelum mengedit, audit repository dan petakan semua route, halaman, komponen, event handler, state, API call, autentikasi, role permission, localStorage/sessionStorage, format data, validasi form, realtime update, tombol aksi, modal, dropdown, filter, checkout, pembayaran, cetak antrean, dan reservasi.

Pertahankan seluruh route dan URL yang sudah ada. Jangan mengubah nama field, struktur data, endpoint, query, kredensial, role, aturan akses, atau alur bisnis. Jangan mengganti framework, database, library inti, atau mekanisme autentikasi kecuali benar-benar diperlukan untuk memperbaiki tampilan. Jangan menghapus fitur walaupun halaman tersebut terlihat kosong pada screenshot. Jangan mengganti tombol fungsional dengan elemen dekoratif. Semua tombol seperti tambah menu, checkout, pilih meja, terima cash, mulai masak, ubah status, edit, nonaktifkan, input mutasi stok, login, registrasi, dan booking harus tetap bekerja persis seperti sebelumnya.

Jika struktur kode saat ini masih berupa HTML/CSS/JavaScript terpisah, lakukan refactor visual secara aman hanya jika tidak mengubah behavior. Prioritaskan perubahan pada CSS, layout wrapper, reusable component, design token, dan icon treatment. Setelah setiap perubahan besar, pastikan console tidak menghasilkan error dan alur utama masih dapat digunakan.

## Audit visual dari kondisi saat ini

Kondisi saat ini memperlihatkan beberapa inkonsistensi. Homepage dan halaman customer menggunakan kontainer sekitar 480px yang terpusat walaupun dibuka pada viewport desktop 1366px, sehingga area kosong navy terlalu lebar. Beberapa halaman customer memiliki header, kartu, tombol, dan bottom navigation yang belum memiliki aturan spacing yang seragam. Halaman menu menampilkan product card dua kolom dengan gambar yang pada beberapa tampilan gagal dimuat atau memiliki area kosong; pertahankan sumber data dan fallback, tetapi buat image container dan fallback state tetap rapi.

POS dan Admin sudah menggunakan dark navy dashboard, tetapi header, navigation bar, tabel, badge, tombol, dan kartu KPI perlu distandarkan. Beberapa judul dan teks memiliki kontras rendah. Halaman KDS membutuhkan prioritas visual tinggi untuk nomor antrean, timer, status, item pesanan, dan tombol mulai/proses/selesai. Gunakan screenshot sebagai acuan masalah yang harus diperbaiki, bukan sebagai batasan desain yang harus disalin mentah-mentah.

## Design system yang harus dibuat

Buat satu sumber token CSS atau konfigurasi tema yang dipakai lintas halaman. Gunakan nama token semantik, bukan warna hard-coded berulang. Rekomendasi awal:

- Primary magenta: `#E91E63` atau nilai yang paling dekat dengan brand saat ini.
- Primary hover/pressed: versi lebih gelap dari magenta.
- Navy background internal: sekitar `#0F172A`.
- Surface internal: sekitar `#1E293B`.
- Surface customer: putih atau off-white yang sangat ringan.
- Text utama dark theme: putih atau slate terang.
- Text sekunder: slate yang tetap memenuhi kontras aksesibilitas.
- Success: emerald/green.
- Warning: amber/orange.
- Danger: red.
- Info: blue.

Validasi kontras untuk teks dan status. Gunakan satu skala spacing berbasis 4 atau 8 pixel. Gunakan radius yang konsisten, misalnya 12px untuk card dan 8px untuk control, dengan pengecualian yang jelas untuk pill badge. Gunakan shadow tipis dan border halus; hindari glow berlebihan. Gunakan satu keluarga font sans-serif yang modern dan mudah dibaca. Heading, label, body, angka KPI, dan caption harus memiliki skala tipografi yang jelas.

Gunakan icon library yang sudah tersedia di repository jika ada. Jika tidak ada, pilih satu library icon yang konsisten. Jangan menjadikan emoji sebagai icon utama pada navigasi atau action penting. Icon harus memiliki ukuran, stroke/fill, alignment, dan warna yang konsisten. Sediakan hover, focus-visible, active, disabled, loading, empty, error, dan success state untuk komponen yang relevan.

## Aturan layout dan responsive

Gunakan container yang adaptif. Pada desktop, customer tidak boleh tetap terkunci pada lebar mobile secara tidak proporsional; gunakan max-width yang masuk akal untuk pengalaman ordering, misalnya 960–1200px untuk halaman dengan grid, atau lebar yang lebih kecil hanya pada layar checkout/detail. Pada mobile, gunakan padding 16px dan hindari horizontal overflow.

Untuk customer, pertahankan bottom navigation pada mobile dengan safe-area padding. Pada tablet dan desktop, ubah menjadi header navigation atau layout yang tetap nyaman tanpa menampilkan bar mobile secara aneh di tengah layar. Hero, promo, kategori, dan product grid harus mengikuti grid responsif: satu kolom di mobile, dua kolom pada tablet, dan tiga sampai empat kolom pada desktop sesuai ruang.

Untuk POS dan Admin, gunakan app shell konsisten dengan topbar dan sidebar atau navigation yang dapat berubah menjadi drawer pada tablet/mobile. Tabel desktop harus tetap mudah dibaca. Pada mobile, tabel boleh memiliki horizontal scroll yang diberi indikasi jelas atau berubah menjadi stacked card, tetapi tidak boleh memotong data penting. Tombol action utama harus mudah ditemukan dan tidak bertabrakan dengan header.

Untuk KDS, gunakan tiga kolom status pada desktop: Ticket Baru, Sedang Dimasak, dan Siap Saji. Pada tablet/mobile, kolom dapat berubah menjadi tab atau vertical sections. Nomor antrean dan timer harus paling menonjol. Status harus dapat dipahami tanpa hanya mengandalkan warna.

## Halaman yang harus ditata ulang

Perbarui root landing page tanpa mengubah link: tampilkan brand MIE GACOAN, deskripsi sistem ordering/POS/KDS/reservasi, CTA customer yang paling dominan, CTA login/registrasi, serta portal staff untuk Kasir/POS, Dapur KDS, dan Admin. Buat hierarchy yang lebih baik dan responsive.

Perbarui seluruh customer flow, termasuk home, menu, kategori menu, cart, checkout, profil, login/registrasi, pemilihan meja, promo, reservasi, dan riwayat pesanan jika tersedia. Home harus memiliki header brand, hero/banner yang proporsional, benefit strip, tipe pesanan, promo cards, kategori, product recommendations, reservasi, dan bottom navigation. Menu harus memiliki filter kategori yang jelas, search bila sudah tersedia, product card dengan rasio gambar konsisten, nama, deskripsi singkat, harga, dan tombol tambah. Cart harus membedakan empty state dan populated state dengan jelas, menjaga ringkasan pembayaran tetap mudah dipindai, serta membuat CTA checkout sticky hanya pada tempat yang tepat.

Perbarui POS dashboard, manual order, order management, reservation management, dan layar antrean. KPI cards harus konsisten, tabel memiliki zebra/row hover yang halus, badge status memiliki semantic color, dan primary action memiliki hierarchy yang jelas. Manual order harus memisahkan area katalog dengan area current order tanpa membuat panel kanan terlalu kosong atau terpotong.

Perbarui KDS dashboard agar lebih cepat dipahami dalam kondisi operasional. Gunakan header ringkas, status columns yang jelas, ticket card yang konsisten, timer yang terlihat, dan tombol status yang besar serta mudah ditekan. Jangan mengubah realtime behavior atau status transition.

Perbarui seluruh Admin area, termasuk dashboard, products, categories, inventory, promos, orders, users/staff, reports, settings, dan audit logs jika route tersebut tersedia. Gunakan app shell admin yang sama pada semua route. Navigation aktif harus konsisten. Tabel products, inventory, orders, dan users harus memakai komponen tabel yang sama, dengan variasi kolom sesuai kebutuhan. Sediakan responsive behavior yang masuk akal untuk dropdown role, edit/nonaktifkan, quick stock adjustment, dan tombol tambah data.

## Implementasi teknis yang diharapkan

Mulai dengan membaca source code, bukan langsung menulis ulang halaman. Temukan komponen yang dapat dipakai ulang seperti AppShell, Header, Sidebar, BottomNav, Card, Button, Badge, Modal, Input, Select, Table, EmptyState, Toast, ProductCard, StatusCard, dan LoadingSkeleton. Buat atau refactor komponen tersebut agar semua halaman memakai pola yang sama.

Gunakan CSS responsive dengan breakpoint yang konsisten. Hindari fixed width yang menyebabkan halaman tidak fleksibel, absolute positioning untuk layout utama, overflow tersembunyi yang memotong konten, dan inline style yang berulang. Pertahankan image URL/data yang sudah dipakai aplikasi. Tambahkan object-fit, aspect-ratio, alt text, loading state, serta fallback visual yang tidak merusak layout ketika gambar gagal dimuat.

Jangan mengarang data baru untuk menggantikan data aplikasi. Data dummy hanya boleh dipakai untuk visual fallback yang sudah disediakan sistem. Jangan mengubah teks harga, order, role, status, atau label bisnis yang berasal dari data.

## Proses kerja wajib

Pertama, buat audit singkat route dan komponen yang ditemukan. Kedua, implementasikan design tokens dan komponen shared. Ketiga, perbarui app shell customer, POS, KDS, dan Admin. Keempat, lakukan responsive pass pada viewport sekitar 375px, 768px, 1024px, dan 1366px. Kelima, jalankan build, lint, atau test yang tersedia. Keenam, uji alur utama secara manual: buka root, masuk ke customer, lihat menu, tambah produk, buka cart, checkout, login/registrasi, buka POS, input manual order, buka KDS, ubah status ticket, buka Admin, edit role, ubah stok, dan buka transaksi.

Jika terdapat konflik antara desain baru dan fungsi lama, fungsi lama harus menang. Jika ada keputusan visual yang belum jelas, pilih solusi yang paling sederhana, accessible, responsive, dan konsisten dengan design system ini. Jangan berhenti hanya setelah landing page terlihat bagus; semua route yang ada harus mendapatkan treatment visual yang konsisten.

## Acceptance criteria

Hasil akhir dianggap selesai apabila seluruh route lama masih dapat dibuka dan link internal tidak rusak. Tidak ada perubahan pada autentikasi, permission, API, database, event handler, format data, dan alur bisnis. Tampilan tidak memiliki horizontal overflow pada mobile. Tidak ada teks penting yang memiliki kontras rendah. Semua tombol dan form utama tetap berfungsi. Customer terlihat rapi pada mobile sekaligus wajar pada desktop. POS, KDS, dan Admin memakai shell, spacing, table, badge, button, dan state yang konsisten. Product image error tidak lagi membuat card rusak. Empty state, loading state, error state, hover, focus, disabled, dan active state terlihat disengaja. Build/lint/test yang tersedia berhasil tanpa error baru.

Setelah selesai, tampilkan ringkasan file yang diubah, route yang diperbarui, keputusan design system, serta hasil verifikasi responsive dan functional. Jangan menghapus atau mengubah fitur yang tidak terkait dengan redesign UI.

## Referensi

Gunakan situs live sebagai sumber konteks route dan fungsi: https://mie-liart.vercel.app/
Gunakan screenshot yang dilampirkan pengguna sebagai referensi kondisi visual awal. Screenshot tersebut mencakup landing page, customer home/menu/cart, POS dashboard/manual order/reservation, KDS dashboard, serta Admin products/inventory/orders/users.

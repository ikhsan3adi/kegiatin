Assalamu’alaikum, Pak. Apakah terdengar?
Ya, terdengar. Gimana?
Baik, Pak. Ini ada beberapa pertanyaan yang sudah kami kumpulkan.
1. Konfirmasi Presensi & Mode Offline
Jadi yang pertama terkait konfirmasi. Berarti saat presensi dengan keyword model offline,
data yang tersimpan hanya anggota yang sudah RSSPP?
Untuk yang offline itu sebenarnya lebih ke riwayat dan data-data yang diisi. Jadi bentuknya
lebih ke penyimpanan lokal (seperti TWA). Kalau offline, datanya tetap ada, tetapi
mekanisme sinkronisasinya yang berbeda.
Jadi misalnya saat offline, aplikasi tidak bisa menarik data dari server. Pertanyaannya,
bagaimana agar data yang ada tetap tersimpan di lokal, lalu ketika sudah online, data baru
bisa disinkronkan dengan server?
Jawaban:
Paham. Jadi kalau offline, data disimpan di lokal. Nanti ketika online, baru dilakukan
sinkronisasi dengan data di server.

2. Desain / Warna Aplikasi
Untuk desain atau warna aplikasi, apakah ada request khusus dari mitra?
Jawaban:
Tidak ada request khusus, hanya saja jangan menggunakan warna merah.

3. Sistem Login (NPA, Passport, OTP)
Apakah anggota login menggunakan NPA + Passport atau NPA + OTP?
Jawaban:
Kemungkinan akan ada perubahan. Awalnya ingin terpusat berdasarkan daerah, tetapi
akhirnya aplikasi dibuat agar bisa digunakan di berbagai jenjang.
Jadi kemungkinan tidak perlu sinkronisasi dengan data existing. Cukup register saja:
- Jika anggota → masukkan NPA
- Jika non-anggota → tetap bisa daftar tanpa NPA

1. Struktur Organisasi / Divisi
Apakah di Persis ada pembagian divisi yang mempengaruhi sistem?
Jawaban:
Tidak. Fokusnya lebih ke pengelolaan pekerjaan.
Role hanya:

•  Admin
•  Peserta

Peserta dibagi menjadi:

•  Anggota (punya NPA, bisa isi cabang)
•  Non-anggota (tidak perlu isi NPA/cabang)

5. Nama Aplikasi
Apakah nama aplikasi ditentukan mitra?
Jawaban:
Belum ada. Boleh dari tim sebagai rekomendasi.

6. Cakupan Aplikasi

Awalnya aplikasi hanya untuk Bukatan Bandung, tetapi sekarang:
•  Bisa digunakan di mana saja (daerah/cabang manapun)
•  Tim sebagai publisher
•  Tidak perlu repot sinkronisasi data anggota

7. Penyimpanan Data (Arsitektur Sistem)
Pilihan:

•  A: Backend API + database (server)
•  B: Database only (langsung dari HP)

Diskusi:
Kalau database only (lokal), tidak bisa share data kegiatan.
Contoh:

•  Pimpinan daerah membuat kegiatan
•  Peserta ingin join
•  Semua orang harus bisa melihat kegiatan tersebut

Berarti:

•  Data harus ada di server
•  Harus ada API

Kesimpulan:

•  Tetap pakai server (backend + database)
•  Database lokal hanya untuk:

  o  Cache
  o  History
  o  Akses offline

8. Mekanisme Offline (Local First)
Jika menggunakan konsep local-first:

•  Data dari server disimpan juga di lokal
•  Saat offline → tetap bisa diakses
•  Saat online → disinkronkan kembali

9. Dokumen Analisis (SRS)
Apakah ada dokumen tambahan untuk analisis requirement (goals, user requirement, FR,
NFR)?
Jawaban:
Tidak ada tambahan. Gunakan dokumen yang sudah diberikan.
Penjelasan:

•  Sistem ini seperti pengelolaan kegiatan yang sebelumnya dilakukan via Google Form
•  Kendala Google Form:

  o  Sulit membandingkan data pendaftar dan kehadiran

Saran:

•  Buat flowchart dari pemahaman sistem
•  Dari flowchart → diturunkan menjadi user requirement

10. Sistem Kegiatan & Reservasi
Kegiatan:

•  Bisa single event

•  Bisa series

Admin:

•  Membuat & memposting kegiatan

Peserta:

•  Harus punya akun untuk melihat & ikut kegiatan

Aplikasi:

•  Bisa digunakan umum (tidak hanya anggota Persis)

11. Sistem Akun (Anggota & Non-Anggota)

•  Semua user bebas daftar
•  Saat registrasi:

o  Anggota → isi NPA + cabang
o  Non-anggota → tanpa NPA

12. Fitur History & Absensi (QR Code)
Apakah non-anggota tidak memiliki history atau QR absensi?
Jawaban:
Tetap ada:

•  Semua user punya history
•  Semua bisa ikut kegiatan
•  Sistem bisa melacak siapa anggota / non-anggota

_
13. Validasi NPA (Opsional API)
Jika memungkinkan:

•  Saat user memasukkan NPA → sistem cek ke API
•

Jika valid:

o  Nama & email otomatis terisi

Tujuan:

•  Mempermudah input data anggota

14. Verifikasi Akun

•  Non-anggota → wajib verifikasi email
•  Tetap bisa mengisi data tambahan (WTP)

15. Next Step
Arahan dari Pak:

•  Buat flowchart sistem terlebih dahulu
•  Share desain (misalnya Figma)
•  Akan dikonfirmasi ke mitra

16. Server
Server akan disediakan oleh pihak mitra.

Penutup:
Terima kasih atas meeting-nya, Pak.
Semoga aplikasi yang dikembangkan dapat bermanfaat ke depannya.
Wassalamu’alaikum.

## Goals

A. Goals
| Kode Goal | Pernyataan Goal                                      | Masalah yang Dihadapi                                                                                                                         | Indikator Keberhasilan (Measurable)                                                                                                        |
| --------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| G-01      | Digitalisasi Administrasi Kegiatan                   | Proses pencatatan kehadiran dan pembuatan laporan masih bersifat manual sehingga data berisiko tercecer dan sulit direkapitulasi.             | Rekapitulasi kehadiran dan laporan setiap agenda dapat dihasilkan secara otomatis oleh sistem dengan tingkat akurasi 100%.                 |
| G-02      | Kelancaran Operasional di Lokasi Minim Sinyal        | Sistem presensi sering mengalami kegagalan fungsi saat kegiatan berlangsung di lokasi yang sulit sinyal internet (blank spot).                | Fitur pindai QR tetap berfungsi 100% meskipun perangkat dalam kondisi offline, dan data tersinkronisasi segera setelah koneksi tersedia.   |
| G-03      | Penyediaan Rekam Jejak Partisipasi                   | Peserta tidak memiliki dokumentasi resmi mengenai histori partisipasi mereka, sehingga terkadang mereka lupa kegiatan apa yang sudah diikuti. | Setiap peserta dapat mengakses histori kegiatan yang sudah diikuti, mencakup materi dalam kegiatan tersebut.                               |
| G-04      | Sentralisasi Dokumentasi dan Materi                  | Materi kajian sering hilang karena hanya didistribusikan melalui aplikasi pesan instan tanpa pengarsipan yang sistematis.                     | Seluruh materi digital tersedia dalam repositori aplikasi yang dapat diakses kembali oleh peserta berdasarkan sesi kegiatan masing-masing. |
| G-05      | Validasi Identitas Anggota Terintegrasi              | Panitia kesulitan memvalidasi status keanggotaan resmi secara cepat saat pelaksanaan agenda organisasi.                                       | Proses verifikasi identitas pengguna menggunakan database Nomor Pokok Anggota (NPA) berjalan dengan tingkat keberhasilan 100% saat login.  |
| G-06      | Digitalisasi Informasi Kegiatan Yang Diselenggarakan | Terkadang ada acara yang tidak diperuntukan untuk umum                                                                                        | Acara tidak ditampilkan di dashboard peserta jika dia diundang oleh pengurus.                                                              |

B. Stakeholder
| Stakeholder       | Peran                                                        | Kepentingan / Interest                                                                                                                           |     |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | --- |
| Pengurus          | Pengelola operasional dan administrator sistem.              | Mempermudah pengelolaan jadwal kegiatan, otomatisasi rekapitulasi kehadiran (presensi), serta pengarsipan materi kajian agar tidak hilang.       |     |
| Peserta Umum      | Pengguna akhir sebagai partisipan kegiatan.                  | Memperoleh kemudahan dalam proses absensi melalui QR Code, memantau riwayat partisipasi pribadi, serta mengakses materi digital secara terpusat. |     |
| Anggota           | Partisipan yang termasuk kedalam organisasi dan memiliki NPA | Memperoleh kemudahan dalam proses absensi melalui QR Code, memantau riwayat partisipasi pribadi, serta mengakses materi digital secara terpusat. |     |
| Pimpi Daerah (PD) | Pengawas dan pengambil kebijakan organisasi.                 | Memperoleh data akurat mengenai keaktifan kader secara real-time untuk kebutuhan evaluasi organisasi dan pengembangan dakwah.                    |     |

## Business Rules

| Kode Rule | Business Rule                                                                                                                | Dampak pada Sistem                                                                                       |
| --------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| BR-01     | Untuk anggota wajib memasukan NPA (Nomor Pokok Anggota) jika login sebagai anggota.                                          | Sistem harus bisa membedakan partisipan sebagai anggota atau non-anggota.                                |
| BR-02     | Fitur membuat acara dan memindai absen hanya diperuntukkan bagi Pengurus (Admin).                                            | Sistem harus menyembunyikan menu manajemen acara bagi pengguna yang berstatus Anggota biasa.             |
| BR-03     | Proses absen harus tetap berjalan lancar meskipun di lokasi kegiatan tidak ada sinyal.                                       | Sistem harus menyimpan data kehadiran ke dalam memori internal HP jika koneksi internet terputus.        |
| BR-04     | Semua data yang tersimpan di HP harus dikirim ke database pusat saat internet tersedia kembali.                              | Sistem harus mengirim data dari memori lokal ke server secara otomatis segera setelah mendeteksi sinyal. |
| BR-05     | Hanya peserta dengan status "Reserved" (baik mendaftar manual atau Invite Only) yang memiliki QR Code untuk melakukan absen. | Sistem harus mengecek daftar pendaftar dan menolak absen jika nama peserta tidak ditemukan.              |
| BR-06     | Sesi absen dibuka dan ditutup secara manual oleh Admin melalui kontrol status acara (Open/Closed for Attendance).            | Sistem harus mengunci tombol absen jika waktu kegiatan belum mulai atau sesi sebelumnya belum selesai.   |
| BR-07     | File materi atau dokumen kajian hanya boleh diambil oleh peserta yang hadir.                                                 | Sistem harus mengaktifkan tombol unduh materi hanya jika status kehadiran peserta sudah terverifikasi.   |

## User Requirements

| ID    | Referensi Goal | Deskripsi Requirement                                                                                                                                         | Aktor          |
| ----- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| UR-01 | G-05           | Sistem harus memungkinkan pengguna untuk melakukan login menggunakan Nomor Pokok Anggota (NPA) untuk anggota dan tanpa (NPA) untuk non-anggota.               | Semua Pengguna |
| UR-02 | G-01           | Admin harus dapat membuat dan mengelola dua tipe kegiatan, yaitu Kegiatan Sekali Selesai (Single Event) dan Kegiatan Rutin (Series Event) .                   | Admin          |
| UR-03 | G-01           | Admin harus dapat mengatur jadwal, sesi pertemuan, serta target peserta untuk setiap kegiatan yang dibuat.                                                    | Admin          |
| UR-04 | G-01           | Peserta harus dapat melakukan Reservasi pada kegiatan yang tersedia agar terdaftar dalam sistem.                                                              | Peserta        |
| UR-05 | G-02           | Admin harus dapat melakukan pemindaian QR Code peserta untuk mencatat kehadiran meskipun perangkat dalam kondisi tanpa sinyal (Offline).                      | Admin          |
| UR-06 | G-02           | Sistem harus secara otomatis melakukan sinkronisasi data kehadiran dari penyimpa lokal ke pusat data saat koneksi internet tersedia.                          | Sistem         |
| UR-07 | G-01           | Peserta harus dapat menampilkan QR Code unik pada aplikasi untuk ditunjukkan kepada Admin sebagai bukti kehadiran.                                            | Peserta        |
| UR-08 | G-03           | Peserta harus dapat melihat rekam jejak partisipasi pribadi melalui fitur Histori Giat untuk memantau keaktifan mereka.                                       | Peserta        |
| UR-09 | G-04           | Admin harus dapat mengunggah materi (PDF/Link) dan dokumentasi foto setelah sesi kegiatan berakhir.                                                           | Admin          |
| UR-10 | G-04           | Peserta dapat mengakses dan mengunduh materi digital melalui menu Histori Giat selamanya, selama data kehadiran mereka di acara tersebut sudah terverifikasi. | Peserta        |
| UR-11 | G-01           | Admin harus dapat melihat dan mengunduh rekapitulasi laporan kehadiran secara otomatis untuk kebutuhan evaluasi organisasi.                                   | Admin          |
| UR-12 | G-06           | Admin dapat mengatur acara yang diselenggarakan menjadi untuk "umum" atau "hanya yang diundang"                                                               | Admin          |
| UR-13 | G-01           | Admin dapat mengekspor laporan kehadiran dan statistik acara dalam format dokumen (PDF/Excel) untuk diberikan kepada Pimpi Daerah (PD).                       | Admin          |

## System Requirements

A. Functional Requirement
| Kode  | Referensi UR | Deskripsi (Teknis)                                                                                                          | Input                                                                | Output / Reaksi Sistem                                          |
| ----- | ------------ | --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------- |
| FR-01 | UR-01        | Sistem harus dapat memvalidasi email pengguna melalui link verifikasi sebelum akun aktif.                                   | Nama, Email, Password, Tipe Pengguna (Anggota/Umum), NPA (Opsional). | Akun pengguna baru, Status Login, Pesan Verifikasi Email.       |
| FR-02 | UR-01        | Sistem harus menyediakan pilihan tipe pengguna: Anggota (dengan input NPA) dan Umum.                                        |                                                                      |                                                                 |
| FR-03 | UR-01        | Sistem harus mendukung autentikasi biometrik atau persistent login agar user tidak perlu login ulang saat offline.          |                                                                      |                                                                 |
| FR-04 | UR-02        | Admin dapat membuat kegiatan baru dengan parameter: Judul, Deskripsi, Lokasi, Kuota, dan Visibilitas (Publik/Private).      | Judul Kegiatan, Deskripsi, Waktu, Lokasi, Kuota, Visibilitas.        | Data kegiatan tersimpan, Notifikasi Berhasil Simpan/Ubah/Hapus. |
| FR-05 | UR-02        | Sistem harus mendukung pembuatan Series Event (kegiatan rutin) dengan beberapa sesi dalam satu induk kegiatan.              | Nama Sesi, Tanggal/Jam Sesi, ID Kegiatan Induk.                      | Daftar sesi kegiatan rutin yang terstruktur.                    |
| FR-06 | UR-09        | Admin dapat mengunggah dokumen materi (PDF) atau link dokumentasi setelah kegiatan selesai.                                 | File (PDF/Gambar), Deskripsi Materi, ID Kegiatan.                    | Tautan materi terunggah, Notifikasi Berhasil Upload.            |
| FR-07 | UR-04        | Peserta dapat melakukan RSVP pada kegiatan yang dibuka untuk mendapatkan QR Code unik.                                      | ID Peserta, ID Kegiatan yang dipilih.                                | Tiket RSVP, QR Code unik tersimpan di perangkat.                |
| FR-08 | UR-04        | Sistem harus menyimpan QR Code RSVP di local storage (Hive) agar bisa diakses peserta tanpa internet.                       | Data QR Code Peserta, ID Sesi Kegiatan.                              | Status kehadiran sementara (Pending Sync), Log kehadiran lokal. |
| FR-09 | UR-05        | Sistem harus memungkinkan Admin memindai QR Code dalam kondisi Offline.                                                     | Data QR Code Peserta, ID Sesi Kegiatan.                              | Hasil scan                                                      |
| FR-10 | UR-04        | Sistem harus menolak scan jika QR Code tidak terdaftar dalam list RSVP kegiatan tersebut.                                   | Data QR Code Peserta, ID Sesi Kegiatan.                              | hasil scan                                                      |
| FR-11 | UR-05        | Sistem harus otomatis melakukan sinkronisasi data presensi dari Hive ke MongoDB saat perangkat mendeteksi koneksi internet. |                                                                      |                                                                 |
| FR-12 | UR-13        | Admin dapat mengekspor daftar kehadiran peserta ke dalam format Excel atau PDF.                                             | Format File (PDF/Excel), ID Kegiatan.                                | Dokumen laporan (PDF/Excel) yang siap diunduh/dibagikan.        |
| FR-13 | UR-10        | Peserta dapat melihat histori kegiatan yang pernah diikuti beserta status kehadirannya secara offline.                      | ID Peserta (Session Login).                                          | Daftar riwayat kegiatan yang pernah diikuti.                    |
| FR-14 | UR-11        | Sistem harus menampilkan grafik statistik jumlah peserta per kegiatan di dashboard admin.                                   | ID Kegiatan, Periode Waktu.                                          | Grafik jumlah peserta, Ringkasan total kehadiran.               |
| FR-15 | UR- 10       | Peserta dapat mengakses dan mengunduh materi digital pada histori kegiatan                                                  | ID Kegiatan (Validasi status kehadiran).                             | File materi/dokumentasi kegiatan yang dapat dibuka.             |

B. Non-Functional Requirement
| Kode   | Referensi FR | Kategori       | Deskripsi                                                                                                                             | Metrik Pengujian                                                                                             |
| ------ | ------------ | -------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| NFR-01 | FR-09        | Performance    | Proses validasi QR Code terhadap local cache harus selesai dalam waktu singkat agar tidak menghambat antrean peserta saat check-in.    | Waktu respons scan QR (validasi + feedback UI) < 2 detik pada perangkat dengan spesifikasi minimum.          |
| NFR-02 | FR-11        | Performance    | Proses sinkronisasi batch data kehadiran dari Hive ke server harus efisien dan tidak mengganggu penggunaan aplikasi.                  | Sinkronisasi 100 record kehadiran selesai dalam < 30 detik pada koneksi 3G (minimum 256 kbps).               |
| NFR-03 | FR-08, FR-09 | Reliability    | Data kehadiran yang direkam secara offline tidak boleh hilang sebelum berhasil disinkronkan ke server atau di-flag untuk manual review. | Zero data loss: 100% record offline berhasil tersinkronisasi atau ter-flag sebagai CONFLICT untuk review.    |
| NFR-04 | FR-01        | Security       | Token autentikasi harus disimpan secara aman di perangkat dan memiliki mekanisme expiry untuk mencegah penyalahgunaan sesi.           | Access token berlaku maksimal 15 menit. Refresh token berlaku 7 hari. Token disimpan di secure storage.      |
| NFR-05 | FR-07        | Security       | QR Token RSVP harus unik per peserta per event dan tidak dapat dipalsukan atau digunakan ulang di sesi berbeda.                       | QR Token menggunakan signed token (JWT/UUID v4), satu token per RSVP, single-use per sesi.                   |
| NFR-06 | FR-09, FR-13 | Availability   | Fitur inti (scan QR, tampilkan QR, lihat riwayat) harus berfungsi penuh tanpa koneksi internet selama data lokal tersedia.            | Semua fitur offline berfungsi 100% tanpa koneksi internet. Tidak ada loading spinner atau error network.     |
| NFR-07 | Semua FR     | Compatibility  | Aplikasi harus mendukung perangkat Android yang umum digunakan oleh anggota organisasi.                                               | Minimum Android 8.0 (API 26). Target SDK: Android 14 (API 34).                                              |
| NFR-08 | FR-11        | Data Integrity | Mekanisme conflict resolution harus memastikan tidak ada duplikasi data kehadiran setelah sinkronisasi selesai.                       | Duplicate attendance record (kombinasi userId + sessionId yang sama) terdeteksi dan ditolak 100% oleh server. |

## Domain Requirements

| Kode  | Deskripsi                                                                                                                                                               | Sumber                              |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| DR-01 | Nomor Pokok Anggota (NPA) bersifat opsional saat registrasi. Format dan aturan validasi NPA mengikuti ketentuan organisasi Pemuda Persis.                                | Stakeholder (perlu konfirmasi format) |
| DR-02 | Satu peserta hanya boleh memiliki satu RSVP aktif per event. Untuk Series Event, satu RSVP berlaku untuk seluruh sesi dalam rangkaian tersebut.                          | Aturan bisnis UC-02                 |
| DR-03 | Event harus memiliki minimal satu sesi sebelum dapat di-publish. Single Event secara otomatis memiliki satu sesi eksplisit.                                              | Domain rule (canPublish)            |
| DR-04 | Data kehadiran bersifat immutable setelah sync_status menjadi SYNCED. Admin tidak dapat mengubah record kehadiran yang sudah tersinkronisasi untuk menjaga audit trail.   | BR-06, Audit trail                  |
| DR-05 | Akses materi digital (download/view) hanya diberikan kepada peserta yang status kehadirannya sudah terverifikasi (PRESENT atau LATE) pada sesi terkait.                   | BR-07, UC-05                        |
| DR-06 | Struktur organisasi Pemuda Persis terdiri dari jenjang: Pimpinan Daerah (PD), Pimpinan Cabang (PC), dan Unit. Field cabang/unit pada profil anggota mengikuti hierarki ini. | Stakeholder (perlu konfirmasi jenjang) |
| DR-07 | Batas waktu toleransi keterlambatan presensi dan kebijakan penentuan status kehadiran (PRESENT/LATE/ABSENT) mengikuti ketentuan masing-masing event dari organisasi.       | Stakeholder (perlu konfirmasi)      |

## Use Case List

[Ada di]([PY4_2C_D3_C6]_ETS_Topik_AplikasiManajemenKegiatan.md)?

## MosCow

| Must Have                 | Deskripsi                                                   | Referensi |
| ------------------------- | ----------------------------------------------------------- | --------- |
| Autentikasi Pengguna      | Login dan registrasi untuk Anggota dan Umum.                | UR-01     |
| Manajemen Kegiatan (CRUD) | Admin dapat membuat, mengubah, dan menghapus data kegiatan. | UR-03     |
| Offline QR Scanning       | Kemampuan memindai QR kehadiran tanpa koneksi internet.     | UR-05     |
| RSVP Peserta              | Fitur pendaftaran kegiatan untuk mendapatkan QR Code.       | UR-04     |

| Should Have             | Deskripsi                                                             | Referensi |
| ----------------------- | --------------------------------------------------------------------- | --------- |
| Series Event Management | Pengaturan sesi rutin untuk satu rangkaian kegiatan.                  | UR-02     |
| Laporan Daftar Hadir    | Tampilan daftar hadir bagi Admin untuk verifikasi.                    | UR-11     |
| Riwayat Kegiatan        | Peserta dapat melihat daftar kegiatan yang pernah diikuti.            | UR-08     |
| Data Synchronization    | Mekanisme sinkronisasi otomatis data lokal (Hive) ke cloud (MongoDB). | UR-06     |

| Could Have                 | Deskripsi                                                        | Referensi |
| -------------------------- | ---------------------------------------------------------------- | --------- |
| Manajemen Materi/Dokumen   | Fitur upload materi oleh admin dan download oleh peserta.        | UR-10     |
| Statistik & Visualisasi    | Grafik statistik jumlah peserta di dashboard admin.              | UR-11     |
| Auto-fill NPA via API      | Pengisian nama otomatis saat input NPA.                          | -         |
| Ekspor Laporan (PDF/Excel) | Fitur mengunduh laporan kehadiran untuk administrasi organisasi. | UR-13     |

| Won't Have            | Deskripsi                                                       | Referensi |
| --------------------- | --------------------------------------------------------------- | --------- |
| Payment Gateway       | Pembayaran tiket kegiatan atau iuran anggota di dalam aplikasi. | -         |
| Live Streaming        | Integrasi video streaming langsung untuk kajian online.         | -         |
| Social Media Internal | Fitur posting status atau komentar antar anggota.               | -         |
| Chat Engine           | Fitur chatting antar peserta di dalam aplikasi.                 | -         |

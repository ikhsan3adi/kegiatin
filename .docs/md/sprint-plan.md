# Sprint Plan - Kegiatin

> Aplikasi Manajemen Kegiatan PD Pemuda Persis Kab. Bandung
> Kelompok C6 | Proyek 4

## Ikhtisar Sprint

| Sprint | Fokus                          | MoSCoW Coverage                       |
| ------ | ------------------------------ | ------------------------------------- |
| 1      | Foundation + Auth + Event Core | Must: Auth, Event CRUD                |
| 2      | RSVP + QR Flow End-to-End      | Must: RSVP. Should: Series Event      |
| 3      | Attendance + Offline + Sync    | Must: Offline QR. Should: Data Sync   |
| 4      | History + Polish + Testing     | Should: Riwayat, Laporan Daftar Hadir |

---

## Sprint 1: Foundation + Auth + Event Core

**Tujuan:** Infrastruktur berjalan, user bisa register/login, admin bisa CRUD event.

### Backlog

| #   | Item                                                        | Prioritas |
| --- | ----------------------------------------------------------- | --------- |
| 1   | Setup monorepo: Flutter project + NestJS project            | Must Have |
| 2   | Flutter: Riverpod + go_router + Hive CE + dio + theme       | Must Have |
| 3   | NestJS: MongoDB + Mongoose + config + global pipes/guards   | Must Have |
| 4   | Auth backend: Register (Anggota/Umum) + Login (JWT)         | Must Have |
| 5   | Auth frontend: Login page + Register page + token storage   | Must Have |
| 6   | Data model: User, Event, Session (Mongoose schema)          | Must Have |
| 7   | Data model: User, Event, Session (Freezed + Hive)           | Must Have |
| 8   | Event CRUD backend: Create, Read, Update, Delete + validasi | Must Have |
| 9   | Event CRUD frontend: Form, List, Detail page                | Must Have |
| 10  | Single Event = 1 sesi eksplisit, Series = multi-sesi        | Must Have |
| 11  | Desain UI/UX: Auth flow + Event screens                     | Must Have |
| 12  | Setup branch strategy + PR workflow                         | Must Have |

### Definition of Done
- User bisa register akun (Anggota dengan NPA opsional, Umum dengan email)
- User bisa login dan mendapat JWT token yang tersimpan di device
- Admin bisa membuat Single Event (1 sesi) dan Series Event (multi-sesi)
- Admin bisa melihat daftar event dan detail event
- Admin bisa edit dan hapus event berstatus DRAFT
- API endpoint ter-protect oleh JWT guard dan role guard

### Risiko
- Setup code generation pipeline (freezed + riverpod_generator + json_serializable) bisa memakan waktu jika belum familiar
- Google OAuth di-skip di sprint ini, fokus email/password dulu

---

## Sprint 2: RSVP + QR Flow End-to-End

**Tujuan:** Peserta bisa RSVP dan menampilkan QR offline. Admin bisa lihat daftar peserta.

### Backlog

| #   | Item                                                        | Prioritas   |
| --- | ----------------------------------------------------------- | ----------- |
| 1   | RSVP backend: Endpoint create RSVP + generate QR token      | Must Have   |
| 2   | RSVP frontend: Tombol RSVP di detail event + konfirmasi     | Must Have   |
| 3   | QR display: Tampilkan QR dari local Hive (offline-ready)    | Must Have   |
| 4   | QR storage: Simpan QR token ke Hive saat RSVP               | Must Have   |
| 5   | Admin: View daftar peserta RSVP per event                   | Must Have   |
| 6   | Event lifecycle: DRAFT -> PUBLISHED -> ONGOING -> COMPLETED | Should Have |
| 7   | Session management: Tambah/edit/hapus sesi (Series Event)   | Should Have |
| 8   | Local cache: Background sync daftar peserta RSVP ke Hive    | Should Have |
| 9   | Desain UI/UX: RSVP flow + QR display + session management   | Should Have |

### Definition of Done
- Peserta bisa RSVP ke event yang berstatus PUBLISHED
- QR Code unik ditampilkan di app peserta dan bisa diakses tanpa internet (dari Hive)
- Admin bisa melihat daftar peserta yang sudah RSVP per event
- Event status bisa berubah sesuai lifecycle (DRAFT -> PUBLISHED -> ONGOING -> COMPLETED)
- Admin bisa tambah/edit/hapus sesi pada Series Event yang belum COMPLETED

### Risiko
- QR rendering library (qr_flutter) perlu divalidasi compatibility dengan Hive CE storage
- Background sync daftar peserta perlu mekanisme debounce agar tidak boros bandwidth

---

## Sprint 3: Attendance + Offline + Sync

**Tujuan:** Admin bisa scan QR secara offline, data tersinkronisasi otomatis saat online.

### Backlog

| #   | Item                                                                            | Prioritas   |
| --- | ------------------------------------------------------------------------------- | ----------- |
| 1   | QR scan: Admin scan QR peserta via kamera (mobile_scanner)                      | Must Have   |
| 2   | Validasi offline: Cek QR terhadap local cache Hive                              | Must Have   |
| 3   | Record attendance: Simpan ke Hive dengan sync_status PENDING                    | Must Have   |
| 4   | Deferred validation: Accept PENDING_VALIDATION jika QR tidak di cache + offline | Must Have   |
| 5   | Sync engine: Auto-sync attendance saat device online                            | Should Have |
| 6   | Sync backend: POST /attendance/sync (bulk validation)                           | Should Have |
| 7   | Conflict resolution: Duplicate -> reject, Invalid QR -> no-show                 | Should Have |
| 8   | Connectivity detection: Trigger sync saat network available                     | Should Have |
| 9   | Admin: Rekap daftar hadir per sesi (read-only screen)                           | Should Have |
| 10  | API lookup fallback: Jika QR tidak di cache + device online                     | Should Have |
| 11  | Desain UI/UX: Scan screen + attendance list + sync indicator                    | Should Have |

### Definition of Done
- Admin bisa scan QR peserta dan mencatat kehadiran tanpa internet
- QR yang ada di local cache langsung divalidasi dan di-record
- QR yang tidak ada di cache saat offline diterima sebagai PENDING_VALIDATION
- Saat device online, data attendance otomatis tersinkronisasi ke server
- Server mendeteksi dan menolak duplicate attendance (userId + sessionId)
- QR yang invalid saat deferred validation otomatis di-mark sebagai ABSENT
- Admin bisa melihat rekap daftar hadir per sesi

### Risiko
- Sprint ini adalah yang paling kompleks secara teknis (offline + sync + conflict resolution)
- Perlu testing menyeluruh untuk edge case: scan saat transisi online/offline, batch sync gagal di tengah
- Jika beban terlalu berat, conflict resolution UI bisa di-defer ke Sprint 4

---

## Sprint 4: History + Polish + Testing

**Tujuan:** Peserta bisa lihat riwayat kegiatan. Aplikasi stabil dan teruji.

### Backlog

| #   | Item                                                          | Prioritas   |
| --- | ------------------------------------------------------------- | ----------- |
| 1   | Peserta: Histori kegiatan + status kehadiran                  | Should Have |
| 2   | Histori offline: Cache riwayat di Hive, akses tanpa internet  | Should Have |
| 3   | Admin: Laporan daftar hadir per event (screen)                | Should Have |
| 4   | Role-based dashboard: Tampilan berbeda Admin vs Peserta       | Should Have |
| 5   | Error handling: Loading states, empty states, retry mechanism | Must Have   |
| 6   | Unit test: Use Cases + Repository (mock dengan mocktail)      | Must Have   |
| 7   | Integration test: Auth flow + RSVP flow + Scan flow           | Should Have |
| 8   | Bug fixing dan polish UI                                      | Must Have   |
| 9   | Dokumentasi: README, setup guide, API documentation           | Must Have   |

### Definition of Done
- Peserta bisa melihat daftar kegiatan yang pernah diikuti beserta status kehadiran
- Riwayat kegiatan bisa diakses offline dari cache Hive
- Dashboard menampilkan konten yang sesuai role (Admin: kelola event, Peserta: riwayat + RSVP)
- Semua screen memiliki loading state, empty state, dan error state yang proper
- Minimal 1 unit test per Use Case dan 1 per Repository
- Tidak ada crash atau unhandled exception pada happy path dan common error path

### Risiko
- Testing dari nol di sprint terakhir bisa kekurangan waktu
- Sebaiknya test infrastructure (mock setup, test helpers) disiapkan sejak Sprint 1

---

## Fitur di Luar Sprint (Could Have / Backlog)

Fitur-fitur berikut tidak masuk ke 4 sprint utama. Dikerjakan jika ada waktu tersisa atau sebagai enhancement pasca-sprint.

| Fitur                      | Referensi | Catatan                                      |
| -------------------------- | --------- | -------------------------------------------- |
| Upload materi/dokumentasi  | UR-09/10  | Archive module sudah di-design di arsitektur |
| Statistik & visualisasi    | UR-11     | Grafik jumlah peserta di dashboard admin     |
| Auto-fill NPA via API      | -         | Integrasi API NPA organisasi                 |
| Ekspor laporan (PDF/Excel) | UR-13     | Server-side report generation                |
| Google OAuth login         | UR-01     | Tambahan di atas email/password              |
| Push notification (FCM/WS) | UC-01/04  | Delivery mechanism TBD                       |
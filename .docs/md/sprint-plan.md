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

## Sprint 3: Attendance + Offline + Sync + PCD Scanner

**Tujuan:** Admin bisa scan QR secara offline, data tersinkronisasi otomatis saat online. PCD Document Scanner terintegrasi untuk materi kegiatan.

### Backlog

| #   | Item                                                                            | Prioritas   | Status |
| --- | ------------------------------------------------------------------------------- | ----------- | ------ |
| 1   | QR scan: Admin scan QR peserta via kamera (`mobile_scanner`)                    | Must Have   | ✅ Done |
| 2   | Validasi offline: Cek QR terhadap local cache Hive                              | Must Have   | ✅ Done |
| 3   | Record attendance: Simpan ke Hive dengan sync_status PENDING                    | Must Have   | ✅ Done |
| 4   | Deferred validation: Accept PENDING_VALIDATION jika QR tidak di cache + offline | Must Have   | ✅ Done |
| 5   | Sync engine: Auto-sync attendance saat device online                            | Should Have | ✅ Done |
| 6   | Sync backend: POST /attendance/sync (bulk validation)                           | Should Have | ✅ Done |
| 7   | Conflict resolution: Duplicate -> reject, Invalid QR -> absent                  | Should Have | ✅ Done |
| 8   | Connectivity detection: Trigger sync saat network available                     | Should Have | ✅ Done |
| 9   | Admin: Rekap daftar hadir per sesi (read-only screen)                           | Should Have | ✅ Done |
| 10  | API lookup fallback: Jika QR tidak di cache + device online                     | Should Have | ✅ Done |
| 11  | API Search Users: Dukungan pencarian anggota untuk Invite Only Event            | Should Have | ✅ Done |
| 12  | PCD: Integrasi `google_mlkit_document_scanner`                                  | Must Have   | ✅ Done |
| 13  | PCD: Image Enhancement Pipeline (Histogram Eq + Unsharp Mask di Isolate)        | Must Have   | ✅ Done |
| 14  | PCD: Enhancement Preview UI (3 Mode Toggle)                                     | Must Have   | ✅ Done |
| 15  | PCD: Upload Materi Bottom Sheet (Scan + File + Link)                            | Must Have   | ✅ Done |
| 16  | Session Capacity Check: Implement Soft Warning UI jika kapasitas fisik penuh    | Should Have | ⏳ Sprint 4 |

### Definition of Done
- Admin bisa scan QR peserta dan mencatat kehadiran tanpa internet
- QR yang ada di local cache langsung divalidasi dan di-record
- Saat device online, data attendance otomatis tersinkronisasi ke server
- Server mendeteksi dan menolak duplicate attendance (userId + sessionId)
- Admin bisa scan dokumen materi fisik dengan deteksi tepi dan perataan otomatis
- Hasil scan dokumen dapat ditingkatkan kualitasnya (enhancement) sebelum digunakan

---

## Sprint 4: Archive + Riwayat + Profile + Polish + Testing

**Tujuan:** Fitur materi (archive) berjalan end-to-end, peserta bisa lihat riwayat kegiatan, modul server pendukung (profile, uploads) selesai, UI/UX di-polish, dan sistem teruji.

### Backlog

#### Phase 1: Critical Fixes
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 1   | PCD Fix: Mencegah over-processing (set default `original` untuk ML Kit)     | Must Have |
| 2   | QR Scan Fix: Tangani error agar lebih user-friendly (jangan expose failure) | Must Have |
| 3   | Konfirmasi Dialog: Saat Admin melakukan Publish, Start, dan Selesai Event   | Must Have |
| 4   | Konfirmasi Dialog: Saat Peserta melakukan RSVP                              | Must Have |

#### Phase 2: Server Backend (Profile & Uploads)
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 5   | Server: Implementasi `profile.module` (GET/PATCH `/profile/me`)             | Must Have |
| 6   | Server: Implementasi `GET /profile/history` (sesuai schema `ActivityRecord`)| Must Have |
| 7   | Server: Implementasi `uploads.module` (POST `/uploads/image` multipart)     | Must Have |

#### Phase 3: Server Backend (Archive)
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 8   | OpenAPI: Desain endpoint Archive (POST, GET, DELETE materi per session)     | Must Have |
| 9   | Server: Implementasi `archives.module` sesuai desain OpenAPI terbaru        | Must Have |

#### Phase 4: Flutter (Archive & Riwayat)
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 10  | Data Layer: `ArchiveModel` + DataSource + Repository + Use Cases            | Must Have |
| 11  | UI: Sambungkan Upload Materi Bottom Sheet ke endpoint Archive sesungguhnya  | Must Have |
| 12  | UI: Tampilkan daftar materi di halaman Detail Event                         | Must Have |
| 13  | Data Layer: `ActivityRecord` model + History DataSource                     | Must Have |
| 14  | UI: Halaman Riwayat Peserta (menampilkan histori + status kehadiran)        | Must Have |
| 15  | UI: Akses materi dari Riwayat (hanya untuk peserta yang hadir/terlambat)    | Should Have |
| 16  | UI: Hapus pilihan sesi saat upload materi untuk Single Event                | Should Have |

#### Phase 5: PCD & UX Polish
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 17  | Fitur: Gunakan Smart Camera (`CameraMode.photo`) untuk upload Banner Event  | Should Have |
| 18  | UI: Sembunyikan section "Sesi" di Detail Event untuk tipe Single Event      | Should Have |
| 19  | UI: Pindahkan Daftar Hadir & Peserta ke sub-halaman agar scroll tidak dalam | Should Have |
| 20  | UI: Konsistensi heading dan hapus hardcoded colors (gunakan colorScheme)    | Should Have |
| 21  | UI: Fitur pencarian kegiatan di halaman QR Scan (menggunakan `GET /events`) | Should Have |

#### Phase 6: Testing & Docs
| #   | Item                                                                        | Prioritas |
| --- | --------------------------------------------------------------------------- | --------- |
| 22  | Unit test: PCD pipeline (`ImageEnhancer`) dan Use Cases                     | Must Have |
| 23  | Audit: Pastikan ada loading/empty/error states di semua screen              | Must Have |
| 24  | Dokumentasi: README dan panduan setup                                       | Must Have |

### Definition of Done
- Admin dapat mengunggah materi (via scan PCD, file, atau link) yang terhubung ke server.
- Peserta dapat melihat daftar kegiatan yang pernah diikuti beserta status kehadirannya.
- Endpoint profil, histori, dan upload gambar di server telah berfungsi.
- Semua tindakan destruktif/kritis (seperti membatalkan RSVP atau merilis kegiatan) memunculkan dialog konfirmasi.
- Tidak ada crash atau unhandled exception pada skenario happy path maupun common error path.

---

## Fitur di Luar Sprint (Could Have / Backlog)

Fitur-fitur berikut tidak masuk ke 4 sprint utama. Dikerjakan jika ada waktu tersisa atau sebagai enhancement pasca-sprint.

| Fitur                      | Referensi | Catatan                                      |
| -------------------------- | --------- | -------------------------------------------- |
| Statistik & visualisasi    | UR-11     | Grafik jumlah peserta di dashboard admin     |
| Auto-fill NPA via API      | -         | Integrasi API NPA organisasi                 |
| Ekspor laporan (PDF/Excel) | UR-13     | Server-side report generation                |
| Google OAuth login         | UR-01     | Tambahan di atas email/password              |
| Push notification (FCM/WS) | UC-01/04  | Delivery mechanism TBD                       |
| Caching Dashboard          | -         | Untuk menghindari fetch ulang yang berlebihan|
| Soft Warning Kapasitas Sesi| -         | Peringatan bila jumlah RSVP mendekati batas  |
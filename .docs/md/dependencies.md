# Kegiatin - Dart/Flutter Dependencies

> Versi terbaru per 21 April 2026. Semua versi diverifikasi dari pub.dev.
> Target: Flutter latest (Dart SDK ^3.11.5).

## Catatan Penting: Hive CE

Package `hive` dan `hive_flutter` original sudah **tidak di-maintain** (terakhir update 3-4 tahun lalu, versi 4.0.0-dev tidak pernah rilis stabil). Gunakan **`hive_ce`** (Community Edition) sebagai pengganti:

- `hive_ce` = drop-in replacement untuk `hive` (API sama, aktif di-maintain, support Dart 3 + WASM)
- `hive_ce_flutter` = pengganti `hive_flutter` (init Flutter, path provider)
- `hive_ce` sudah support IsolatedHive, DevTools extension, dan automatic type adapter generation

---

## 1. Core Architecture (Wajib)

Package yang membentuk fondasi arsitektur Clean Architecture + Riverpod + offline-first.

| Package               | Versi     | Type           | Fungsi                                                  | Layer         |
| --------------------- | --------- | -------------- | ------------------------------------------------------- | ------------- |
| `flutter_riverpod`    | `^3.3.1`  | dependency     | State management + DI                                   | Presentation  |
| `riverpod_annotation` | `^4.0.2`  | dependency     | Code-gen annotations untuk `@riverpod`                  | Presentation  |
| `riverpod_generator`  | `^4.0.3`  | dev_dependency | Generate `@riverpod` providers                          | Presentation  |
| `freezed_annotation`  | `^3.1.0`  | dependency     | Annotations untuk freezed (immutable models)            | Domain + Data |
| `freezed`             | `^3.2.5`  | dev_dependency | Immutable models + union types + copyWith               | Domain + Data |
| `json_annotation`     | `^4.11.0` | dependency     | Annotations untuk json_serializable                     | Data          |
| `json_serializable`   | `^6.13.1` | dev_dependency | JSON fromJson/toJson generation                         | Data          |
| `build_runner`        | `^2.13.1` | dev_dependency | Orchestrate code generation (freezed + json + riverpod) | Dev           |
| `hive_ce`             | `^2.19.3` | dependency     | Local database (offline-first, NoSQL key-value)         | Data          |
| `hive_ce_flutter`     | `^2.3.4`  | dependency     | Flutter bindings untuk Hive CE (init, path)             | Data          |
| `go_router`           | `^17.2.2` | dependency     | Declarative routing + deep linking + redirect           | Presentation  |
| `dio`                 | `^5.9.2`  | dependency     | HTTP client (interceptors, retry, error handling)       | Data          |
| `google_fonts`        | `^8.0.2`  | dependency     | Typography via Google Fonts (Material Theme Builder)    | Core          |

### Catatan Riverpod v3

Riverpod `^3.3.1` memiliki breaking change penting:
- `StateProvider` dan `StateNotifierProvider` dipindahkan ke `package:flutter_riverpod/legacy.dart`
- Gunakan `NotifierProvider` dan `AsyncNotifierProvider` sebagai pengganti
- `@riverpod` code-gen (via `riverpod_generator`) adalah cara yang direkomendasikan

---

## 2. Fitur Spesifik (Penting)

Package yang mendukung fitur inti aplikasi: QR, offline, notifikasi.

| Package                       | Versi     | Type       | Fungsi                                    | Kapan Dipakai                               |
| ----------------------------- | --------- | ---------- | ----------------------------------------- | ------------------------------------------- |
| `mobile_scanner`              | `^7.2.0`  | dependency | QR/barcode scanner via camera (ML Kit)    | Admin scan QR peserta                       |
| `qr_flutter`                  | `^4.1.0`  | dependency | Render QR code sebagai widget             | Peserta tampilkan QR RSVP                   |
| `connectivity_plus`           | `^7.1.1`  | dependency | Deteksi status koneksi internet           | Trigger sync saat online, NetworkInfo       |
| `flutter_local_notifications` | `^21.0.0` | dependency | Notifikasi lokal terjadwal                | Pengingat kegiatan, status sync             |
| `firebase_messaging`          | `^16.2.0` | dependency | Push notification via FCM                 | Notifikasi event baru, perubahan jadwal     |
| `firebase_core`               | `^3.13.0` | dependency | Firebase initialization (wajib untuk FCM) | Setup Firebase                              |
| `shared_preferences`          | `^2.5.5`  | dependency | Key-value storage sederhana               | Simpan JWT token, settings, onboarding flag |
| `image_picker`                | `^1.2.1`  | dependency | Ambil foto dari kamera/galeri             | Upload dokumentasi kegiatan                 |

---

## 3. Pendukung (Quality of Life)

Package yang meningkatkan kualitas kode, UX, dan developer experience.

| Package                | Versi     | Type           | Fungsi                                               | Kapan Dipakai                                      |
| ---------------------- | --------- | -------------- | ---------------------------------------------------- | -------------------------------------------------- |
| `fpdart`               | `^1.2.0`  | dependency     | `Either<L,R>`, Option, Task (functional programming) | Error handling di Use Cases (`Either<Failure, T>`) |
| `mocktail`             | `^1.0.5`  | dev_dependency | Mocking untuk unit testing                           | Mock Repository, DataSource di test                |
| `path_provider`        | `^2.1.5`  | dependency     | Akses direktori sistem (temp, docs, cache)           | Simpan file materi offline, Hive path              |
| `permission_handler`   | `^12.0.1` | dependency     | Runtime permission request                           | Kamera (QR scan), notifikasi, storage              |
| `cached_network_image` | `^3.4.1`  | dependency     | Cache + display network image                        | Foto profil, dokumentasi kegiatan                  |
| `shimmer`              | `^3.0.0`  | dependency     | Loading placeholder effect                           | Skeleton loader saat data loading                  |
| `url_launcher`         | `^6.3.2`  | dependency     | Buka URL eksternal di browser                        | Materi bertipe link, buka Google Maps              |

---

## 4. Yang Tidak Perlu (Hindari)

| Package                            | Alasan Skip                                                                   |
| ---------------------------------- | ----------------------------------------------------------------------------- |
| `get` (GetX)                       | Riverpod sudah cukup. GetX terlalu opiniated, mencampur DI + routing + state  |
| `hive` / `hive_flutter` (original) | Tidak di-maintain. Gunakan `hive_ce` + `hive_ce_flutter`                      |
| `hive_generator`                   | Hive CE sudah support automatic type adapter, tidak butuh code-gen terpisah   |
| `dartz`                            | `fpdart` lebih aktif, Dart 3 ready, API lebih lengkap                         |
| `equatable`                        | `freezed` sudah handle `==` dan `hashCode` secara otomatis                    |
| `provider`                         | Riverpod sudah handle DI. Provider adalah pendahulu, bukan pelengkap          |
| `qr_code_scanner`                  | Tidak di-maintain. Gunakan `mobile_scanner` yang aktif                        |
| `intl`                             | Dart 3 memiliki `DateTimeFormat` native. Tambah hanya jika butuh localization |

---

## 5. Konfigurasi pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Architecture
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0

  # Local Database (Offline-First)
  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4

  # Networking
  dio: ^5.9.2

  # Routing
  go_router: ^17.2.2

  # Theme
  google_fonts: ^8.0.2

  # QR
  mobile_scanner: ^7.2.0
  qr_flutter: ^4.1.0

  # Connectivity & Sync
  connectivity_plus: ^7.1.1

  # Notifications
  flutter_local_notifications: ^21.0.0
  firebase_core: ^3.13.0
  firebase_messaging: ^16.2.0

  # Storage
  shared_preferences: ^2.5.5
  path_provider: ^2.1.5

  # Media
  image_picker: ^1.2.1
  cached_network_image: ^3.4.1

  # Functional Programming
  fpdart: ^1.2.0

  # Permissions
  permission_handler: ^12.0.1

  # UX
  shimmer: ^3.0.0
  url_launcher: ^6.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.13.1
  freezed: ^3.2.5
  json_serializable: ^6.13.1
  riverpod_generator: ^4.0.3

  # Testing
  mocktail: ^1.0.5

  # Linting
  flutter_lints: ^5.0.0
```

---

## 6. Perintah Setup

```bash
# Install semua dependency
flutter pub get

# Jalankan code generation (freezed + json_serializable + riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate saat file berubah)
dart run build_runner watch --delete-conflicting-outputs

# Analisis kode
flutter analyze

# Jalankan test
flutter test
```

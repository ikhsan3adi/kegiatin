---
title: "Flowchart Sistem - Aplikasi Manajemen Kegiatan PD Pemuda Persis"
author: "Ikhsan Satriadi"
puppeteer:
  # landscape: true
  format: "A3"
---

## Flowchart - Aplikasi Manajemen Kegiatan PD Pemuda Persis

### 1. Alur Umum Registrasi & Login

```mermaid
flowchart TB
    A[Start] --> B[Registrasi]
    B --> C{Pilih Tipe}
    C -->|Anggota| D[Input NPA + Data Diri]
    D -.-> D1{Cek API NPA?}
    D1 -.->|Valid| D2[Auto-fill Nama]
    D1 -.->|Invalid/Skip| D3[Manual Input]
    D2 --> F[Verifikasi Email]
    D3 --> F
    C -->|Non-Anggota| E[Input Data Diri]
    E --> F[Verifikasi Email]
    F --> G{Email Terverifikasi?}
    G -->|Ya| H[Create Account]
    G -->|Tidak| I[Resend Email]
    I --> F
    H --> J[Login]
    J --> K{Role?}
    K -->|Admin| L[Dashboard Admin]
    K -->|Peserta| M[Dashboard Peserta]
```

---

### 2. Alur Admin (Pengurus)

```mermaid
flowchart TB
    A1[Buka App] --> A
    A1[Buka App] --> A2{Device Online?}

    A[Dashboard Admin] --> B{Menu Utama}
    
    B -->|Kelola Kegiatan| C[Create Event]
    C --> D{Pilih Tipe}
    D -->|Single| E[Set 1 Sesi]
    D -->|Series| F[Set Multi Sesi]
    E --> G1{Pilih Visibilitas}
    F --> G1
    G1 -->|Private/Invite Only| G2[Invite Peserta/Anggota]
    G1 -->|Open Regis| G[Publish Event]
    G2 --> G
    G --> H[Notifikasi ke Peserta]

    
    B -->|Lihat Event| M0[Browse Events]
    M0 --> M01[View Detail Event]
    M01 -->|Presensi| M02{Pilih Sesi}
    M01 -->|Materi| R[Upload Materi/Dokumentasi]
    R --> S[Simpan ke Server]
    M02 -->|Series Event| M03[Pilih Sesi/Pertemuan]
    M02 -->|Single Event| M04[Auto-select Sesi]
    M03 --> M[Buka Menu Presensi]
    M04 --> M
    M --> M4
    
    subgraph OFFLINE_4["OFFLINE FEATURE #1: Local Cache Peserta"]
        direction TB
        A2 -->|Ya| A3[Background Sync Daftar Peserta RSVP]
        A2 -->|Tidak| A4[Use Existing Cache]
        A3 --> A5[Simpan ke Hive\nCache: QR Token + Profil Peserta]
        A4 --> A5
    end

    subgraph OFFLINE_1["OFFLINE FEATURE #2: Presensi QR"]
        direction TB
        A5 --> M4
        M4[Scan QR Code Peserta] --> N{QR Valid di Local Cache?}
        N -->|Ya| O[Record Kehadiran ke Hive]
        N -->|Tidak| P{Tidak ada di Cache + Device Online?}
        P -->|Ya| P1[API Lookup ke Server]
        P1 -->|Valid| O
        P1 -->|Invalid| P2[Reject: QR Invalid]
        P -->|"Tidak (Offline)"| P3[Accept dengan PENDING_VALIDATION]
        P3 --> O
        O --> Q[Sync Kehadiran ke Server\nResolve Conflict & Invalid QR]
    end
    
    B -->|Kelola Sesi| I[Session Management]
    I --> J{Tambah/Edit/Hapus Sesi}
    J --> K[Update Jadwal]
    K --> L[Notifikasi Perubahan]
```

---

### 3. Alur Peserta (Anggota/Non-Anggota)

```mermaid
flowchart TB
    A[Dashboard Peserta] --> B{Menu Utama}
    
    B -->|Lihat Kegiatan| C[Browse Events]
    C --> D[View Detail Event]
    D --> E{Sudah RSVP?}
    E -->|Belum| F[Click RSVP]
    E -->|Sudah| G1[Display QR Code]
    F --> H[Generate QR Token]
    H --> G1

    G1 --> Z[Save QR ke Local Storage]
    Z --> Z1{Device Online?}
    Z1 -->|Ya| Z2[Display QR from Cloud]
    Z1 -->|Tidak| Z3[Display QR from Hive]
    Z2 --> Z4[QR Ready for Scan]
    Z3 --> Z4
    
    Z4 --> J[Admin Scan]
    
    B --> R[Histori Kegiatan]
    R --> V{Device Online?}
    V -->|Ya| W[Fetch dari Server]
    V -->|Tidak| X[Load dari Local Hive]
    W --> Y[Display History]
    X --> Y
    Y --> Z5[Detail Kegiatan]
    Z5 --> S{Sudah Presensi?}
    S -->|Ya| T[Akses Materi]
    S -->|Tidak| U[Materi Locked]

    subgraph OFFLINE_2["OFFLINE FEATURE #3: History/Riwayat"]
        direction TB
        R
        V
        W
        X
        Y
    end
    
    subgraph OFFLINE_3["OFFLINE FEATURE #4: Simpan QR RSVP"]
        direction TB
        Z
        Z1
        Z2
        Z3
        Z4
    end
```

---

### 4. Alur Sinkronisasi Data (Offline-First)

**Empat Penerapan Offline:**

1. **Local Cache Peserta** - Admin sync daftar peserta RSVP untuk validasi scan offline
2. **Presensi QR** - Kehadiran tercatat lokal dulu, sync saat online
3. **History/Riwayat** - Data riwayat tersimpan lokal, bisa diakses tanpa internet
4. **Simpan QR RSVP** - QR disimpan di device peserta, bisa ditunjukkan tanpa internet

```mermaid
flowchart TB
    subgraph SYNC_1["Sync: Presensi QR & Attendance"]
        A[Scan QR → Record ke Hive] --> B{Device Online?}
        B -->|Ya| C[Kirim ke Server]
        B -->|Tidak| E[Pending - Tetap Tercatat\nAuto Sync saat Online]
        E --> C
        C --> F{Sync Sukses?}
        F -->|Ya| G[Status: SYNCED]
        F -->|Conflict| H[Manual Resolve]
        F -->|Invalid/Fake QR| I[Tandai No-Show di Local Cache]
        G --> O[End]
        H --> O
        I --> O
    end
```

```mermaid
flowchart TB
    subgraph SYNC_2["Sync: History & Riwayat Kegiatan"]
        I[Akses Histori] --> J{Device Online?}
        J -->|Ya| K[Fetch dari Server]
        J -->|Tidak| L[Load dari Hive Local]
        K --> M[Update Local Cache]
        L --> N[Display History]
        M --> N
    end
```

---

### 5. State Event Lifecycle

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Create
    DRAFT --> PUBLISHED: Publish
    PUBLISHED --> ONGOING: Sesi Mulai
    ONGOING --> COMPLETED: Selesai
    PUBLISHED --> CANCELLED: Cancel
    DRAFT --> [*]: Delete
    COMPLETED --> [*]: Archive
    CANCELLED --> [*]: Done
```

---

### Catatan untuk Review

#### Asumsi Sistem (Berdasarkan Transkrip):
1. **Verifikasi Email:** Wajib untuk semua user (anggota & non-anggota)
2. **NPA:** Opsional untuk anggota (bisa diisi atau tidak)
3. **Offline-First (4 Fitur):** 
   - **Local Cache Peserta** - Admin sync daftar peserta RSVP saat **buka app** (background, jika online). Admin **browse event** → view detail → **pilih sesi** (khusus Series) → presensi. Jika QR tidak di cache saat scan, gunakan **deferred validation** (accept pending, validasi ulang saat sync)
   - **Presensi QR** - Data kehadiran tersimpan lokal, sync saat online. Resolusi konflik: valid/duplicate/invalid (auto no-show)
   - **History/Riwayat** - Data riwayat tersimpan lokal, bisa diakses tanpa internet
   - **Simpan QR RSVP** - QR tersimpan di device peserta, bisa ditunjukkan tanpa internet
4. **Validasi NPA (Opsional):** Saat registrasi anggota, sistem bisa cek API NPA untuk auto-fill nama (fitur nice-to-have)

#### Core Features:
- **Admin:** Kelola kegiatan, sesi, **presensi QR (offline)**, upload materi
- **Peserta:** RSVP, **check-in QR (offline)**, akses materi pasca-kegiatan, **lihat history (offline)**
- **Sync:** Otomatis sync untuk attendance dan history saat device online
- **Deferred Validation:** Kehadiran bisa tercatat meski QR belum di cache, akan divalidasi ulang saat sync

---
puppeteer:
  landscape: true
  format: "A3"
---

# PROJECT TIMELINE MATA KULIAH PROYEK 4

**Kelas:** 2C | **Kelompok:** C6

|  No   |    NIM    | Nama                   | Role                |
| :---: | :-------: | :--------------------- | :------------------ |
|   1   | 241511073 | Fairuz Sheva Muhammad  | Flutter Developer   |
|   2   | 241511074 | Fatimah Hawwa Alkhansa | UI/UX & Flutter Dev |
|   3   | 241511080 | Ikhsan Satriadi        | Backend Developer   |
|   4   | 241511087 | Qlio Amanda Febriany   | Project Manager     |

---

## Timeline Detail (Berdasarkan Modul/Layer)

| Task / Modul                   | Detail Aktivitas                                                               | Week 1  | Week 2  | Week 3  | Week 4  | Week 5  | Week 6  | Week 7  | PIC     |
| :----------------------------- | :----------------------------------------------------------------------------- | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :------ |
| **Planning & Design**          |
| ERD & Data Model               | Finalisasi ERD (Event, Session, RSVP, Attendance, User) dan mapping tabel Hive |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | Ikhsan  |
| UI/UX Design                   | Figma: wireframe, high-fidelity design, prototype Admin & Peserta              | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | Fatimah |
| Requirement Finalization       | Finalisasi UC docs, acceptance criteria, test cases berdasarkan                |    🟦    |    🟦    | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | Qlio    |
| **Foundation & Setup**         |
| Backend Foundation             | API docs (Swagger), MongoDB connection, auth middleware, project structure     | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | Ikhsan  |
| Mobile Foundation              | Init Flutter project, Clean Architecture, Riverpod setup, navigation           | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | Fairuz  |
| Local Database Layer           | Setup Hive, entity models, repository pattern, local data source               | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | Fairuz  |
| **Backend API Development**    |
| Auth Module API                | API register/login (Anggota/Non-Anggota), email verification, NPA validation   | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | $\cdot$ | Ikhsan  |
| Event & Session API            | CRUD Event (Single/Series), multi-sesi, visibility Open/Private, invite        | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | Ikhsan  |
| RSVP & Attendance API          | RSVP flow, QR token generation, attendance record, deferred validation         | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | Ikhsan  |
| Sync Module API                | Background sync endpoint, conflict resolution, batch attendance upload         | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    | $\cdot$ | Ikhsan  |
| **Mobile Feature Development** |
| Auth Flow UI                   | Screen login, register, email verification, role selection                     | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | $\cdot$ | Fatimah |
| Event Management UI            | Screen create event, event list, event detail, session management              | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | Fatimah |
| RSVP & QR UI                   | RSVP form, QR code display, QR scanner screen, offline QR save                 | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | $\cdot$ | Fatimah |
| Offline Logic & Cache          | Local cache peserta, deferred validation logic, background sync handler        | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    |    🟨    | Fairuz  |
| Archive & Portfolio UI         | Materi download, dokumentasi foto, history kegiatan, statistik                 | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    |    🟨    | Fatimah |
| Notification Service           | FCM setup, local notification, reminder event                                  | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    | Fairuz  |
| **Integration & Testing**      |
| API Integration                | Connect mobile to backend, endpoint integration, error handling                | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    |    🟨    | All     |
| Unit & Widget Testing          | Testing repository, use cases, UI components                                   | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟦    | Fairuz  |
| UAT & Bug Fixing               | User Acceptance Test dengan stakeholder, feedback iteration                    | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    | Qlio    |
| Documentation                  | Laporan akhir Proyek 4, README setup, API documentation                        | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ | $\cdot$ |    🟨    |    🟦    | Qlio    |

---

## Legend

| Emoji | Status                                                               |
| :---: | :------------------------------------------------------------------- |
|   🟦   | **Active** - Development utama                                       |
|   🟨   | **Testing/Review/Integration** - UAT, bug fix, atau parallel support |
|   🟩   | **Done** - Task selesai                                              |
|       | **Kosong** - Tidak ada aktivitas                                     |

---

## Use Case to Modul Mapping

| Use Case                    | Backend (API) | Mobile (UI + Logic) | Week Integration |
| :-------------------------- | :-----------: | :-----------------: | :--------------: |
| UC-01: Create Event         |    Ikhsan     |       Fatimah       |      Week 5      |
| UC-02: RSVP Event           |    Ikhsan     |       Fatimah       |      Week 5      |
| UC-03: Offline QR Check-in  |    Ikhsan     |       Fairuz        |      Week 6      |
| UC-04: Session Management   |    Ikhsan     |       Fatimah       |      Week 5      |
| UC-05: Digital Archive      |    Ikhsan     |       Fatimah       |      Week 6      |
| UC-06: Sync Manager         |    Ikhsan     |       Fairuz        |      Week 6      |
| UC-07: Account Registration |    Ikhsan     |       Fatimah       |      Week 4      |

---

## PIC Responsibility Summary

| PIC     | Primary Role           | Modul yang Dikerjakan                                                                                   |
| :------ | :--------------------- | :------------------------------------------------------------------------------------------------------ |
| Ikhsan  | Backend Developer      | Semua API (Auth, Event, RSVP, Attendance, Sync), Database MongoDB, ERD                                  |
| Fairuz  | Mobile Core Developer  | Project setup, Clean Architecture, Riverpod, Hive/repository, offline logic, sync handler, notification |
| Fatimah | Mobile UI/UX Developer | Figma design, semua UI screen (auth, event, RSVP, QR, archive, portfolio)                               |
| Qlio    | Project Manager        | Requirement, UAT coordination, documentation, stakeholder management                                    |

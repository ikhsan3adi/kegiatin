# Kegiatin

Offline-first event management application for PD Pemuda Persis Kab. Bandung. This repository contains the Flutter mobile client and the NestJS backend server.

## Tech Stack

### Frontend (Flutter Client)
- Framework: Flutter 3.41.+
- State Management: Riverpod v3
- Local Database: Hive CE
- Routing: GoRouter
- HTTP Client: Dio
- QR Operations: mobile_scanner & qr_flutter
- Models: Freezed + JSON Serializable

### Backend (NestJS Server)
- Framework: NestJS v11
- Database: PostgreSQL (v17)
- ORM: DrizzleORM
- Authentication: Passport.js + JSON Web Tokens (JWT)

## Project Structure

```
kegiatin/
├── lib/                     # Flutter mobile application
│   ├── core/               # Constants, theme, network, errors
│   ├── domain/             # Entities, enums, usecases (Pure Dart)
│   ├── data/               # Models, remote/local datasources, repository impls
│   └── presentation/       # Pages, widgets, controllers, providers
├── server/                  # NestJS backend server
│   ├── src/                # NestJS controllers, services, modules
│   │   └── db/             # Drizzle schemas and database config
│   ├── drizzle/            # Database migration SQL files
│   └── docker-compose.yml  # Local services (PostgreSQL 17)
├── .docs/                   # Design specifications, requirements, flowcharts
└── .env.example             # Template for Flutter app local environment
```

## Offline-First Strategy

The application uses Hive CE for local storage, syncing to the PostgreSQL server when online.

### Offline Capabilities
1. Local Cache Peserta: RSVP attendee list cached in Hive for offline QR validation.
2. Presensi QR: Attendance recorded to Hive first, synced when online.
3. History: Activity history cached locally.
4. QR RSVP: QR token stored on device, displayable without internet.

## Domain Rules

- Single Event has 1 explicit session. Series Event has N sessions.
- Event must have at least 1 session to publish.
- 1 RSVP per user per event. For Series Event, 1 RSVP covers all sessions.
- Attendance is immutable after syncStatus = SYNCED.
- Material access requires verified attendance (PRESENT or LATE).

## Getting Started

### 1. Prerequisites
- Flutter SDK 3.41.+
- Node.js v20+ or Bun
- Docker (Optional)

### 2. Backend Setup (NestJS Server)

1. Navigate to the server folder:
   ```bash
   cd server
   ```

2. Start the database using Docker Compose:
   ```bash
   docker compose up -d
   ```

3. Setup environment variables:
   ```bash
   cp .env.example .env
   ```

4. Install dependencies:
   ```bash
   npm install
   ```

5. Push database schemas:
   ```bash
   npm run db:push
   ```

6. Start the development server:
   ```bash
   npm run start:dev
   ```

### 3. Frontend Setup (Flutter Client)

1. Return to the project root and configure the environment:
   ```bash
   cp .env.example .env
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## Development Commands

Run commands in this sequence after changing models or providers: Code Generation -> Static Analysis -> Unit Testing.

| Task                      | Command                                                    |
| ------------------------- | ---------------------------------------------------------- |
| Get Packages              | `flutter pub get`                                          |
| Run Code Gen (One-time)   | `dart run build_runner build --delete-conflicting-outputs` |
| Run Code Gen (Watch Mode) | `dart run build_runner watch --delete-conflicting-outputs` |
| Format Dart Code          | `dart format .`                                            |
| Analyze Code              | `flutter analyze`                                          |
| Run Client Tests          | `flutter test`                                             |
| Run Server Tests          | `npm run test` (in `/server`)                              |

## Project Documentation

Documentation files located in the `.docs/` directory:
- [OpenAPI 3.0 API Reference](./.docs/openapi.yaml)

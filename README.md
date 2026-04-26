# Kegiatin

Offline-first event management app for PD Pemuda Persis Kab. Bandung.

## Tech Stack

- **Frontend:** Flutter + Riverpod + GoRouter
- **Backend:** NestJS + MongoDB (Mongoose)
- **Local DB:** Hive CE

## Prerequisites

- Flutter SDK 3.41+ (Dart SDK ^3.11+)
- Node.js 20+ or Bun
- MongoDB (local or Atlas)

## Project Structure

```
kegiatin/
├── lib/                    # Flutter app
│   ├── core/              # Constants, theme, network, errors
│   ├── data/              # Models, datasources, repositories
│   ├── domain/            # Entities, enums, usecases
│   └── presentation/      # Pages, widgets, controllers
├── server/                 # NestJS backend
│   ├── src/modules/auth/  # Auth module
│   ├── .env
│   └── ...
├── .env
└── .docs/                  # Documentation (OpenAPI, specs)
```

## `.env` Configuration (Flutter)

```bash
cp .env.example .env
```

Update `.env` if server URL differs:

```env
BASE_URL=http://localhost:3000/api

# BASE_URL=http://10.0.2.2:3000/api # Android emulator
```

## Running the Server

```bash
cd server

# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your MongoDB URI and JWT secrets

# Run development server
npm run start:dev
```

**Server Environment Variables: `server/.env`**

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/kegiatin

JWT_ACCESS_SECRET=your_access_secret
JWT_REFRESH_SECRET=your_refresh_secret
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d

# ...
```

Server runs at `http://localhost:3000`

## Running the Flutter App

```bash
# Install dependencies
flutter pub get

# Generate code (freezed, riverpod, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
# dart run build_runner watch --delete-conflicting-outputs

# Run app
flutter run
```

**Development Commands:**

```bash
# Analyze code
flutter analyze

# Run tests
flutter test
```

## Code Generation

After modifying any model or provider, run:

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs
```

```bash
# Watch mode (auto-regenerate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

# Kegiatin Backend Server

The backend server for Kegiatin is built with NestJS, using PostgreSQL as the primary database and DrizzleORM for object-relational mapping.

## Technology Stack
- **Framework**: NestJS v11
- **Database**: PostgreSQL (v17)
- **ORM**: DrizzleORM
- **Auth**: JWT (Access and Refresh token flow)
- **Validation**: `class-validator` & `class-transformer`

## Core Modules
- `auth`: Handles user registration, login, token refresh, and logout.
- `events`: Manages organizational events, sessions, status transitions (draft, published, ongoing, completed, cancelled).
- `rsvp`: Manages participant RSVPs (confirms/cancels RSVPs, invite-only validation).
- `attendance`: Validates and records attendance scans (syncs offline presensi queue).
- `archives`: Session-specific documentation uploads (materials, photographs, evaluations).
- `profile`: User self-management (profile details, history of activities).
- `uploads`: Handles image/document uploads (limited to JPEG, PNG, WEBP, and under 5MB).
- `users`: User search and admin capabilities.

## Environment Variables
Create a `.env` file in this directory based on the `.env.example` file:
```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/kegiatin

# JWT Configuration
JWT_ACCESS_SECRET=your_jwt_access_secret
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_SECRET=your_jwt_refresh_secret
JWT_REFRESH_EXPIRATION=7d

# Application Configuration
PORT=3000
BASE_URL=http://localhost:3000
```

## Running the Server

1. **Docker Database Setup**:
   Start PostgreSQL:
   ```bash
   docker compose up -d
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Database Migrations & Push**:
   Apply schemas to the database:
   ```bash
   npm run db:push
   ```

4. **Start Development Server**:
   ```bash
   npm run start:dev
   ```

5. **Start Production Server**:
   ```bash
   npm run build
   npm run start:prod
   ```

## Development Commands

- `npm run db:generate`: Generate migration SQL files using Drizzle Kit.
- `npm run db:migrate`: Run database migrations.
- `npm run db:studio`: Launch Drizzle Studio database viewer.
- `npm run test`: Run backend unit tests.

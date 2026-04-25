---
trigger: always_on
glob:
description: 'Kegiatin - Aplikasi Manajemen Kegiatan PD Pemuda Persis Kab. Bandung'
---

# AI Rules for Kegiatin - Flutter App

> Aplikasi Manajemen Kegiatan PD Pemuda Persis Kab. Bandung
> Kelompok C6 | Proyek 4

## Persona & Tools
* **Role:** Expert Flutter Developer for an offline-first event management app.
* **Context:** This app manages organizational events with offline QR attendance, local-first data, and background sync.
* **Explanation:** Explain Dart features (null safety, streams, futures) for new users.
* **Tools:** ALWAYS run `dart format`. Use `dart fix` for cleanups. Use `flutter analyze` with `flutter_lints` to catch errors early.
* **Dependencies:** Add with `flutter pub add`. Explain why a package is needed. Refer to `.docs/md/dependencies.md` for reference.

## Architecture & Structure
* **Entry:** Standard `lib/main.dart` with `ProviderScope` and `MaterialApp.router`.
* **Pattern:** Clean Architecture - strict **layer-first** separation (NOT feature-first).
* **Layers:**
  * **Presentation (`lib/presentation/`):** Pages, Widgets, Controllers (Riverpod providers).
  * **Domain (`lib/domain/`):** Entities, Enums, Use Cases, Repository interfaces (pure Dart, no Flutter/external deps).
  * **Data (`lib/data/`):** Models (freezed + json_serializable), DataSources (remote + local), Repository implementations.
  * **Core (`lib/core/`):** Constants, Errors (Failure classes), Extensions, Network, Theme, Utils.
* **Why layer-first:** Avoids cross-feature dependency issues. All entities in one place (`domain/entities/`). Flat structure, fast navigation for this project's scale.
* **SOLID:** Strictly enforced.
* **Dependency Rule:** Inner layers (Domain) must NOT depend on outer layers (Data, Presentation). Domain is pure Dart.

```
presentation/ --> domain/ <-- data/
   (outer)       (core)     (outer)
```

* **State Management:**
  * **Pattern:** Riverpod v3 - required for all app state.
  * **Code-gen:** Use `@riverpod` annotation (via `riverpod_annotation` + `riverpod_generator`). This is the recommended approach.
  * **App State:** `AsyncNotifierProvider` for async data.
  * **DI:** Riverpod handles DI natively via providers. No manual DI or `provider` package needed.
  * **DEPRECATED:** Do NOT use `StateProvider` or `StateNotifierProvider`. These are legacy (moved to `flutter_riverpod/legacy.dart` in Riverpod v3).

## Offline-First Architecture
* **Strategy:** Local data (Hive CE) is the primary source. Cloud (MongoDB via REST API) for sync.
* **Four offline areas:**
  1. **Local Cache Peserta** - Admin syncs RSVP attendee list for offline QR validation.
  2. **Presensi QR** - Attendance recorded locally first, synced when online.
  3. **History/Riwayat** - Activity history cached locally, accessible offline.
  4. **QR RSVP Peserta** - QR token stored on device, displayable without internet.
* **Sync Status:** Every syncable record has `SyncStatus` enum: `PENDING`, `SYNCING`, `SYNCED`, `CONFLICT`.
* **Conflict Resolution:** Duplicate attendance (userId + sessionId) rejected by server. Invalid QR from deferred validation auto-marked as ABSENT.
* **Notifications:** Stored **client-local only** (Hive box). NOT stored in server database. Delivery mechanism TBD (FCM or WebSocket).

## Domain Enums (Source of Truth)
Always use these enum values consistently:

| Enum               | Values                                                    |
| ------------------ | --------------------------------------------------------- |
| `UserRole`         | `ADMIN`, `MEMBER`                                         |
| `EventType`        | `SINGLE`, `SERIES`                                        |
| `EventStatus`      | `DRAFT`, `PUBLISHED`, `ONGOING`, `COMPLETED`, `CANCELLED` |
| `EventVisibility`  | `OPEN`, `INVITE_ONLY`                                     |
| `SessionStatus`    | `SCHEDULED`, `ONGOING`, `COMPLETED`, `POSTPONED`          |
| `RsvpStatus`       | `CONFIRMED`, `CANCELLED`, `WAITLIST`                      |
| `AttendanceStatus` | `PRESENT`, `LATE`, `ABSENT`                               |
| `SyncStatus`       | `PENDING`, `SYNCING`, `SYNCED`, `CONFLICT`                |
| `ArchiveType`      | `MATERIAL`, `PHOTO`, `EVALUATION`                         |
| `NotificationType` | `EVENT_CREATED`, `SESSION_UPDATED`, `REMINDER`            |

**Key domain rules:**
* Single Event = 1 session eksplisit. Series Event = multi-session.
* Event must have >= 1 session to publish (`canPublish` rule).
* 1 RSVP per user per event. For Series Event, 1 RSVP covers all sessions.
* Attendance is immutable after `syncStatus = SYNCED`.
* Materi access requires verified attendance (PRESENT or LATE) on that session.

## Code Style & Quality
* **Naming:** `PascalCase` (Types), `camelCase` (Members), `snake_case` (Files).
* **Conciseness:** Functions <20 lines. Avoid verbosity.
* **Null Safety:** NO `!` operator. Use `?` and flow analysis (e.g. `if (x != null)`).
* **Async:** Use `async/await` for Futures. Catch all errors with `try-catch`.
* **Error Handling:** Use `fpdart` `Either<Failure, T>` in Use Cases. Failure is a sealed class with subtypes: `ServerFailure`, `CacheFailure`, `NetworkFailure`, `AuthFailure`.
* **Logging:** Use `dart:developer` `log()` locally. NEVER use `print`.
* **Immutable Models:** Use `freezed` for domain entities and data models. Use `json_serializable` for JSON serialization.

## Flutter Best Practices
* **Build Methods:** Keep pure and fast. No side effects. No network calls.
* **Isolates:** Use `compute()` for heavy tasks like JSON parsing.
* **Lists:** `ListView.builder` or `SliverList` for performance.
* **Immutability:** `const` constructors everywhere possible. `StatelessWidget` preference.
* **Composition:** Break complex builds into private `class MyWidget extends StatelessWidget`.

## Routing (GoRouter)
Use `go_router` exclusively for declarative routing + deep linking + redirect.

```dart
final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => Home()),
  GoRoute(path: 'details/:id', builder: (_, s) => Detail(id: s.pathParameters['id']!)),
]);
MaterialApp.router(routerConfig: _router);
```

## Data Layer

### JSON & Models
* **JSON:** Use `json_serializable` with default `camelCase` to match the `openapi.yaml` definition. Do NOT use `FieldRename.snake`.
* **Immutable Models:** Use `freezed` for both entities and DTOs. Models in `data/models/` extend entity behavior with serialization.

```dart
@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required EventType type,
    required EventStatus status,
    required EventVisibility visibility,
    required String location,
    required String contactPerson,
    String? imageUrl,
    required String createdBy,
    @Default([]) List<SessionModel> sessions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
}
```

### Local Database (Hive CE)
* Use `hive_ce` and `hive_ce_flutter` (NOT the original unmaintained `hive` package).
* Hive CE supports automatic type adapter generation - no need for `hive_generator`.
* DataSources split: `*_remote_datasource.dart` (API via dio) and `*_local_datasource.dart` (Hive CRUD).
* Repository Impl decides data source (offline-first logic via `NetworkInfo`).

### HTTP Client (dio)
* Use `dio` for all HTTP calls.
* Configure interceptors for: JWT token injection, token refresh on 401, error transformation.
* Base URL and timeout in `core/constants/api_constants.dart`.

## Visual Design (Material 3)
* **Aesthetics:** Premium, custom look. Avoid default blue.
* **Theme Source:** Generated via Material Theme Builder. Seed color: `#068A50` (Persis green).
* **ColorScheme:** Use `Theme.of(context).colorScheme.*`. NEVER hardcode `Color(0xff...)` or `Colors.xxx` in widgets.
* **Modes:** Support Light & Dark modes (`ThemeMode.system`).
* **Typography:** `google_fonts` via `createTextTheme()` utility.
* **Layout:** `LayoutBuilder` for responsiveness. `OverlayPortal` for popups.
* **Design Tokens:** For custom values beyond `ColorScheme`, define `ThemeExtension<T>` subclasses. Access via `Theme.of(context).extension<MyTokens>()!`.

## Layout Best Practices

### Rows and Columns
* **`Expanded`:** Fill remaining space along main axis.
* **`Flexible`:** Shrink to fit, but not necessarily grow. Don't combine with `Expanded` in same parent.
* **`Wrap`:** For widgets that would overflow, wrap to next line.

### General Content
* **`SingleChildScrollView`:** Fixed-size content larger than viewport.
* **`ListView` / `GridView`:** Always use `.builder` constructor for long lists.
* **`FittedBox`:** Scale/fit a single child within its parent.
* **`LayoutBuilder`:** Responsive layout decisions based on available space.

## Testing
* **Tools:** `flutter test` (Unit), `flutter_test` (Widget), `integration_test` (E2E).
* **Mocks:** Use `mocktail` for mocking. NOT `mockito`.
* **Pattern:** Arrange-Act-Assert (AAA).
* **Priority:** Unit test Use Cases and Repository implementations first.

## Accessibility (A11Y)
* **Contrast:** 4.5:1 minimum for text.
* **Semantics:** Label all interactive elements specifically.
* **Scale:** Test dynamic font sizes (up to 200%).

## Commands Reference
* **Install deps:** `flutter pub get`
* **Build Runner:** `dart run build_runner build --delete-conflicting-outputs`
* **Watch Mode:** `dart run build_runner watch --delete-conflicting-outputs`
* **Test:** `flutter test`
* **Analyze:** `flutter analyze`

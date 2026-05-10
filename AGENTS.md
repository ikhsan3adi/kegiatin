# AGENTS.md

## Project

Offline-first event management app for PD Pemuda Persis Kab. Bandung. Flutter client + NestJS server.

## Flutter Version

Flutter 3.41.7 (Dart SDK ^3.11.5).

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # dev mode
flutter analyze
flutter test
dart format .
```

Order matters after changing models/providers: **codegen -> analyze -> test**.

## Architecture

**Layer-first** (NOT feature-first). All files go under these top-level dirs:

```
lib/
  core/          # constants, errors, extensions, network, theme, utils
  domain/        # entities, enums, usecases, repository interfaces (pure Dart)
  data/          # models (freezed), datasources (remote+local), repository impls
  presentation/  # pages, widgets, controllers, providers (Riverpod DI / wiring)
```

Dependency rule: `presentation/ -> domain/ <- data/`. Domain must not import from data or presentation.

### Presentation conventions

- **Layer-first stays strict:** under `presentation/` use only `controllers/`, `pages/`, `widgets/`, and `providers/` (dependency injection / Riverpod provider wiring). Do not introduce parallel “layers” per role.
- **Admin vs peserta is UI scope, not a layer:** express role-specific screens with **folder + naming** under `pages/` (e.g. `pages/admin/`, `pages/peserta/`), not by duplicating entire `controllers/` or `widgets/` trees per role without rules.
- **File and class names align:** for scoped screens use `{scope}_{feature}_page.dart` with a matching `ScopeFeaturePage` class (e.g. `peserta_dashboard_page.dart` → `PesertaDashboardPage`). Prefer scope prefix over UI-only labels (“Beranda”, “Acara”) in **type names**; labels stay in UI strings.
- **One public widget per file** when practical; avoid orphan or duplicate placeholder widgets in the same file as another page.
- **Splitting `providers/`:** keep DI in [`presentation/providers/`](lib/presentation/providers/) as [`core_providers.dart`](lib/presentation/providers/core_providers.dart) (prefs, Hive, network, Dio), [`auth_providers.dart`](lib/presentation/providers/auth_providers.dart), [`event_providers.dart`](lib/presentation/providers/event_providers.dart), re-exported from [`providers.dart`](lib/presentation/providers/providers.dart). Split by **technical domain**, not by admin vs peserta folders.
- **Riverpod:** document `keepAlive` for long-lived DI and auth-related providers; default `@riverpod` for screen-scoped async notifiers unless there is an explicit reason.
- **Controllers:** prefer the suffix **`Controller`** on `@riverpod` / `@Riverpod` notifier classes (e.g. `EventListController`, `CreateEventController`). Group **event-related** UI notifiers under [`presentation/controllers/event/`](lib/presentation/controllers/event/) (list/detail/create/publish/start/complete). Auth stays under [`presentation/controllers/auth/`](lib/presentation/controllers/auth/).

## Key Technical Decisions

- **State management:** Riverpod v3 with `@riverpod` code-gen. Do NOT use legacy `StateProvider` / `StateNotifierProvider`.
- **Local DB:** Hive CE (`hive_ce` + `hive_ce_flutter`), not the unmaintained original `hive`. Hive CE has automatic type adapter generation.
- **HTTP:** `dio` with interceptors for JWT injection and token refresh.
- **Models:** `freezed` + `json_serializable`. Run `build_runner` after any model change.
- **Error handling:** `fpdart` `Either<Failure, T>` in use cases. `Failure` is a sealed class.
- **Routing:** `go_router` with `MaterialApp.router`.
- **QR:** `mobile_scanner` (scan), `qr_flutter` (render). NOT `qr_code_scanner` (unmaintained).
- **Testing mocks:** `mocktail`, NOT `mockito`.
- **Notifications:** Client-local only (Hive box). Not stored server-side. Delivery mechanism TBD (FCM vs WebSocket).
- **Backend DB:** PostgreSQL with **DrizzleORM** and **UUIDv7** for primary keys.

## Offline-First

Four offline areas drive the data layer design:
1. **Local Cache Peserta** - RSVP attendee list cached in Hive for offline QR validation
2. **Presensi QR** - Attendance recorded to Hive first, synced when online
3. **History** - Activity history cached locally
4. **QR RSVP** - QR token stored on device, displayable without internet

Every syncable record carries a `SyncStatus` enum: `PENDING -> SYNCING -> SYNCED | CONFLICT`.

## Domain Rules an Agent Needs

- Single Event = 1 explicit session. Series Event = N sessions.
- Event needs >= 1 session to publish.
- 1 RSVP per user per event. Series RSVP covers all sessions.
- Attendance is **immutable** after `syncStatus = SYNCED`.
- Material access requires verified attendance (PRESENT or LATE).

## Enums (source of truth for code generation)

Defined in `lib/domain/enums/`. See `.agents/rules/rules_4k.md` section "Domain Enums" for the canonical table.

## Project Docs

All design documents live in `.docs/` (tracked in git):

| File                          | Content                                                                                |
| ----------------------------- | -------------------------------------------------------------------------------------- |
| `md/architecture.md`          | Full architecture spec: Clean Architecture, API contract, ER diagram, offline strategy |
| `md/sprint-plan.md`           | Sprint backlog with assignee, DoD, and risks per sprint                                |
| `md/dependencies.md`          | Approved Flutter packages with pinned versions                                         |
| `md/requirements.md`          | Goals, Business Rules, UR, FR, NFR, DR, MoSCoW                                        |
| `md/flowchart.md`             | System flowcharts (Mermaid) for all actor flows                                        |
| `md/spesifikasi-topik.md`     | Use cases, ER diagram, event lifecycle, sync sequence                                  |
| `md/transkrip-meeting.md`     | Stakeholder meeting transcript (raw)                                                   |
| `md/timeline-legacy.md`       | Legacy timeline (superseded by sprint-plan.md)                                         |
| `openapi.yaml`                | OpenAPI 3.0.3 spec - source of truth for all API endpoints                             |
| `brand/persis.json`           | Material Theme Builder export (seed: #068A50)                                          |

## Gotchas

- `.gitignore` excludes `.fvm/` `*.g.dart` and `*.freezed.dart` and `.ignore/` (team scratch dir). Do not commit FVM cache.
- `lib/main.dart` is currently the default counter app scaffold. It will be replaced with `ProviderScope` + `MaterialApp.router` during Sprint 1.
- Server (NestJS) is planned under `server/` in this repo (monorepo).
- Theme seed color: `#068A50` (Persis green). Generated via Material Theme Builder.

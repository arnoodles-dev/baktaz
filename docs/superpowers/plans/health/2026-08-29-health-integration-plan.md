# Health Data Integration Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement health data integration across Flutter client (`baktaz_flutter`) and Serverpod backend (`baktaz_server`) supporting Apple HealthKit (iOS) and Android Health Connect. The feature includes device management, health integration connections, step synchronization state, and dual entry points (Home CTA + Account tile).

**Architecture:** Full-stack Clean Architecture with Serverpod 2.x data models & RPC endpoints, reactive Flutter state controllers (`CubitSignal<S>`), `fpdart` `TaskResult<T>` error handling, typed `go_router` navigation, and DESIGN.md compliant UI components. Health data flows: HealthKit/Health Connect → `SyncStepsService` → `HealthRepository` → Serverpod endpoints → DB.

**Tech Stack:** Dart 3.x, Flutter, Serverpod 2.x, PostgreSQL, `health`, `permission_handler`, `bloc_signals_flutter`, `fpdart`, `alchemist`, `go_router`.

**Spec:** `docs/superpowers/specs/health_data_integration_spec.md`

---

## Grilling Decisions

| Decision | Value |
|----------|-------|
| Home CTA Navigation | B — Home → Account tab → `/account/health` |
| Platform Switching | Mandatory explicit confirmation; mid-day switch rule; server enforcement |
| HealthPage Purpose | Adaptive screen; diagnostic checklist on every visit |
| SyncStepsService | Delete stub; StepsRepository delegates to HealthRepository; single path |
| Test Coverage | home_cubit standard (~8 tests/cubit); unit tests on CI, device integration manual only |
| Home Button Behavior | **Option A**: Adaptive button — when connected triggers inline sync (`getTodaySteps()` + `syncSteps()`), when NOT connected shows "Connect Health" CTA → `/account/health` |

---

## Global Constraints

- **Repository Contracts:** All Flutter repository methods MUST return `TaskResult<T>` (`Either<Failure, T>`). Never throw exceptions.
- **Error Handling:** Pattern B error handling enforced (state holds continuous values, side effects handled via events).
- **Health Provider Rules:**
  - One active/authoritative health provider per user for canonical step totals
  - Never aggregate HealthKit + Health Connect totals
  - Store device-level integration state separate from account state
  - Validate actual step-data access after permission grants
  - Handle "no step data" separately from "service unavailable"
- **Testing Sequence:** Testing (`2026-08-29-04-testing.md`) occurs ONLY after implementation (00-03) and code generation are 100% completed across all packages.
- **Codegen Order:** Slang → build_runner → serverpod generate (strict sequence)

---

## Sub-Plans Roadmap

The implementation plan is broken down into 5 sequential sub-plans. Each sub-plan is bite-sized, self-contained, and independently testable.

| Step | Sub-Plan Document | Focus & Scope |
|---|---|---|
| 0 | [`2026-08-29-00-server-models.md`](./2026-08-29-00-server-models.md) | Serverpod `.spy.yaml` models (`UserDevice`, `HealthIntegration`, `StepSync`, extend `DailyStepTelemetry`), codegen, and DB migrations. |
| 1 | [`2026-08-29-01-server-endpoints.md`](./2026-08-29-01-server-endpoints.md) | Serverpod repositories (`UserDeviceRepository`, `HealthIntegrationRepository`, `StepSyncRepository`), RPC endpoints (`HealthEndpoint`), and connection/getStatus logic. |
| 2 | [`2026-08-29-02-flutter-core.md`](./2026-08-29-02-flutter-core.md) | `baktaz_flutter` domain enums, repository interfaces (`IHealthRepository`, `IUserDeviceRepository`), Cubits (`HealthCubit`, `HealthSyncCubit`), and `@TypedGoRoute` definitions. |
| 3 | [`2026-08-29-03-flutter-ui.md`](./2026-08-29-03-flutter-ui.md) | `HealthPage` screen, `HealthConnectionCard`, `HealthSyncStatusTile`, Home CTA banner, Account tile, and routing integration. |
| 4 | [`2026-08-29-04-testing.md`](./2026-08-29-04-testing.md) | Unit tests (100% Cubits/Repos), Widget & Golden tests (80% UI baselines via `alchemist`), and Serverpod integration tests (`withServerpod`). |

---

## File Manifest

### Server (`baktaz_server`)

| Action | Path |
|---|---|
| Create | `lib/src/features/health/domain/model/user_device.spy.yaml` |
| Create | `lib/src/features/health/domain/model/health_integration.spy.yaml` |
| Create | `lib/src/features/health/domain/model/step_sync.spy.yaml` |
| Create | `lib/src/features/health/domain/model/health_connection_status.spy.yaml` |
| Modify | `lib/src/features/home/domain/model/daily_step_telemetry.spy.yaml` (add `sourceDeviceId` field) |
| Create | `lib/src/features/health/domain/interface/i_user_device_repository.dart` |
| Create | `lib/src/features/health/domain/interface/i_health_integration_repository.dart` |
| Create | `lib/src/features/health/data/repository/user_device_repository.dart` |
| Create | `lib/src/features/health/data/repository/health_integration_repository.dart` |
| Create | `lib/src/features/health/endpoint/health_endpoint.dart` |

### Flutter (`baktaz_flutter`)

| Action | Path |
|---|---|
| Create | `lib/features/health/domain/enum/health_provider_type.dart` |
| Create | `lib/features/health/domain/enum/health_connection_state.dart` |
| Create | `lib/features/health/domain/enum/health_sync_status.dart` |
| Create | `lib/features/health/domain/interface/i_user_device_repository.dart` |
| Create | `lib/features/health/domain/interface/i_health_repository.dart` |
| Create | `lib/features/health/domain/entity/user_device.dart` |
| Create | `lib/features/health/domain/entity/health_integration.dart` |
| Create | `lib/features/health/domain/entity/health_connection_status.dart` |
| Create | `lib/features/health/domain/entity/step_sync.dart` |
| Create | `lib/features/health/domain/cubit/health/health_state.dart` |
| Create | `lib/features/health/domain/cubit/health/health_cubit.dart` |
| Create | `lib/features/health/data/service/health_service.dart` |
| Create | `lib/features/health/data/service/i_health_service.dart` |
| Create | `lib/features/health/data/repository/user_device_repository.dart` |
| Create | `lib/features/health/data/repository/health_repository.dart` |
| Create | `lib/features/health/presentation/views/health_page.dart` |
| Create | `lib/features/health/presentation/widgets/health_connection_card.dart` |
| Create | `lib/features/health/presentation/widgets/health_sync_status_tile.dart` |
| Create | `lib/features/health/presentation/widgets/health_connect_cta_banner.dart` |
| Modify | `lib/features/home/presentation/widgets/home_daily_step_hero_card.dart` (add CTA banner when not connected) |
| Modify | `lib/features/account/presentation/views/account_page.dart` (add Health tile) |
| Modify | `lib/app/router/app_router.dart` (add Health route) |

---

## Codegen Order

**CRITICAL:** Execute in exact order. Each step must complete before the next.

1. **Step 0.1:** `cd baktaz_server && fvm dart run serverpod_cli:serverpod generate`
2. **Step 0.2:** `cd baktaz_server && fvm dart run serverpod_cli:serverpod create-migration --tag health_feature_models`
3. **Step 1.1:** `cd baktaz_flutter && fvm dart run slang`
4. **Step 1.2:** `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

---

## Testing Plan

### Flutter Unit Tests (`baktaz_flutter/test/`)

| Test | Path |
|---|---|
| HealthCubit | `test/unit/health/health_cubit_test.dart` |
| HealthRepository | `test/unit/health/health_repository_test.dart` |
| UserDeviceRepository | `test/unit/health/user_device_repository_test.dart` |

### Flutter Widget Tests (`baktaz_flutter/test/widget/health/`)

| Test | Path |
|---|---|
| HealthConnectionCard | `test/widget/health/health_connection_card_test.dart` |
| HealthSyncStatusTile | `test/widget/health/health_sync_status_tile_test.dart` |
| HealthConnectCTABanner | `test/widget/health/health_connect_cta_banner_test.dart` |

### Flutter Golden Tests

| Test | Path |
|---|---|
| HealthPage | `test/widget/health/goldens/health_page_macos/` |
| HealthConnectionCard | `test/widget/health/goldens/health_connection_card_macos/` |

### Server Tests (`baktaz_server/test/`)

| Test | Path |
|---|---|
| HealthEndpoint | `test/features/health/health_endpoint_test.dart` |

---

## Verification Steps

After each sub-plan, run verification commands:

**Sub-Plan 0 (Server Models):**
```bash
cd baktaz_server && fvm dart analyze
cd baktaz_client && fvm dart analyze
```

**Sub-Plan 1 (Server Endpoints):**
```bash
cd baktaz_server && fvm dart test test/features/health/
```

**Sub-Plan 2 (Flutter Core):**
```bash
cd baktaz_flutter && fvm dart analyze
```

**Sub-Plan 3 (Flutter UI):**
```bash
cd baktaz_flutter && fvm flutter test test/unit/health/
```

**Sub-Plan 4 (Testing):**
```bash
cd baktaz_flutter && fvm flutter test
cd baktaz_server && fvm dart test
```

---

## Execution Guide

### Recommended Workflow (Subagent-Driven)

1. Execute sub-plan [`2026-08-29-00-server-models.md`](./2026-08-29-00-server-models.md).
2. Execute sub-plan [`2026-08-29-01-server-endpoints.md`](./2026-08-29-01-server-endpoints.md).
3. Execute sub-plan [`2026-08-29-02-flutter-core.md`](./2026-08-29-02-flutter-core.md).
4. Execute sub-plan [`2026-08-29-03-flutter-ui.md`](./2026-08-29-03-flutter-ui.md).
5. Execute sub-plan [`2026-08-29-04-testing.md`](./2026-08-29-04-testing.md).

Run verification commands after each sub-plan before proceeding to the next step.

---

## Dependencies

### Flutter (`baktaz_flutter/pubspec.yaml`)

Add to `dependencies`:
```yaml
health: ^11.1.0
permission_handler: ^11.3.0
```

Add to `ios` (for HealthKit):
```ruby
# Runner/Info.plist additions
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
```

Add to `android` (for Health Connect):
```xml
<!-- AndroidManifest.xml additions -->
<uses-permission android:name="android.permission.permission_health.READ_STEPS"/>
<uses-permission android:name="android.permission.permission_health.WRITE_STEPS"/>
```

---

## Entry Points

### Home Page CTA
When user has no active health integration, display `HealthConnectCTABanner` on `HomePage` above `HomeDailyStepHeroCard`. Tapping navigates to `/account/health`.

When user IS connected, home page shows inline sync button that calls `HealthRepository.getTodaySteps()` + `StepsRepository.syncSteps()` without navigation.

### Account Page Tile
Add `AccountMenuTile` with icon `Icons.favorite_health` to `AccountPage` menu list. Label: `context.l10n.healthTitle`. Navigates to `/account/health`.

### Health Page
Accessible via `/account/health` route (under account shell). Shows:
- List of connected devices (`HealthConnectionCard` per device)
- Sync status for each device (`HealthSyncStatusTile`)
- "Connect Health" CTA button when not connected
- Disconnect options on each connected device card

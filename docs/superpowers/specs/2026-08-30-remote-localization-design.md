# Serverpod OTA Remote Localization Specification

**Feature Version:** `1.0.0`  
**Status:** Proposed / Implementation Ready  
**Target Platform:** Serverpod (Dart Backend) + PostgreSQL + Redis + Flutter  
**Flutter Localization:** Slang  
**Supported Locale:** `en`  

---

## 1. Executive Summary

This feature provides a server-controlled **Over-The-Air (OTA) Remote Localization Override** mechanism for the Flutter application.

The primary goal is to allow the team to change user-facing English strings remotely **without requiring a new Flutter binary build or App Store / Google Play release**.

The design intentionally differs from generic remote config services or external localization tools:

- **Firebase Remote Config is explicitly discarded** for localization.
- Slang remains the **canonical source of localization** and is bundled (`en.i18n.json`) with the Flutter application.
- Serverpod stores only **immutable remote releases** and audit logs, not individual mutable override records.
- `AppLocalizationCubit` reads local cached Serverpod OTA overrides directly, falling back seamlessly to bundled Slang `en.i18n.json` strings if no override exists.
- The public Flutter endpoint is **unauthenticated and read-only** (`requireLogin => false`) because the returned data is intentionally public.
- Background sync failures are logged/reported to Crashlytics via `FailureHandler` and fail silently (`return false`), preserving local cached overrides / Slang fallback without interrupting app launch.

---

## 2. Goals & Key Requirements

- **Zero Startup Latency:** App startup must never wait on network calls. Local cached overrides or bundled Slang translations must render instantly.
- **Direct OTA Overrides:** Serverpod backend serves active override release payloads directly to `baktaz_flutter`. Firebase Remote Config is completely removed from the localization pipeline.
- **Validation Against Canonical Catalog (`en.i18n.json`):**
  - All override keys must exist in canonical `en.i18n.json`.
  - All variable placeholders (regex `\{(\w+)\}`) in overrides must match canonical variables defined in `en.i18n.json`.
- **Silent Background Sync & Crashlytics Failure Reporting:** Background OTA sync failures report via `FailureHandler` (Crashlytics) and fail silently without throwing or crashing the application.
- **Seeding via `bin/seed.dart`:** Initial localization release seeding logic is implemented in `baktaz_server/lib/src/app/utils/seeding_utils.dart` (`seedRemoteLocalization`) and executed in `baktaz_server/bin/seed.dart` using the Serverpod session CLI pattern.

---

## 3. System Architecture & Layer Breakdown

### 3.1 Architecture Diagram

```text
+-------------------------------------------------------------------+
|                        baktaz_flutter                             |
|                                                                   |
|  +------------------------+      +-----------------------------+  |
|  | AppLocalizationCubit   | ---> | LocalStorageRepository      |  |
|  +------------------------+      | (SharedPreferences Cache)   |  |
|               |                  +-----------------------------+  |
|               | (Startup: Instant)                                |
|               v                                                   |
|  +------------------------+                                       |
|  | Slang en.i18n.json      |                                       |
|  +------------------------+                                       |
|               |                                                   |
|               | (Async Background Sync)                           |
|               v                                                   |
|  +----------------------------------+                             |
|  | RemoteLocalizationRepository     |                             |
|  | - Handles network errors silently |                             |
|  | - Reports errors via FailureHandler|                            |
|  +----------------------------------+                             |
+-----------------------|-------------------------------------------+
                        | RPC: RemoteLocalizationEndpoint.get(version)
                        v
+-------------------------------------------------------------------+
|                        baktaz_server                              |
|                                                                   |
|  +------------------------------+                                 |
|  | RemoteLocalizationEndpoint   | (Unauthenticated, Read-Only)    |
|  +------------------------------+                                 |
|               |                                                   |
|               v                                                   |
|  +-------------------------------------------------------------+  |
|  | RemoteLocalizationRepository                                |  |
|  | - Local Session Cache (session.caches.local)               |  |
|  | - Validates keys & variables \{(\w+)\} vs en.i18n.json       |  |
|  +-------------------------------------------------------------+  |
|               |                                                   |
|         +-----+-----+                                             |
|         |           |                                             |
|         v           v                                             |
|   +----------+  +------------+                                    |
|   | Postgres |  | Redis      |                                    |
|   +----------+  +------------+                                    |
+-------------------------------------------------------------------+
```

### 3.2 Serverpod Layer Breakdown (`baktaz_server`)

- **Endpoint Layer (`lib/src/features/remote_localization/endpoint/remote_localization_endpoint.dart`)**:
  - Endpoint using `@unauthenticatedClientCall` / `requireLogin => false`.
  - Methods: `get(Session session, int clientVersion)` and `seed(Session session)`.
- **Domain Layer (`lib/src/features/remote_localization/domain/`)**:
  - Models: `RemoteLocalizationRelease`, `RemoteLocalizationAuditLog`, `RemoteLocalizationResponse` in `domain/model/`.
  - Interface: `IRemoteLocalizationRepository` in `domain/interface/i_remote_localization_repository.dart`.
- **Data Layer (`lib/src/features/remote_localization/data/repository/remote_localization_repository.dart`)**:
  - `@LazySingleton(as: IRemoteLocalizationRepository)` implementation.
  - Handles `session.caches.local` caching, SHA-256 checksums, `en.i18n.json` key & `\{(\w+)\}` variable validation, database releases, rollbacks, and seeding.
- **Utility (`lib/src/app/utils/seeding_utils.dart`) & CLI (`bin/seed.dart`)**:
  - `seedRemoteLocalization(Session session)` called via `bin/seed.dart`.

### 3.3 Flutter Layer Breakdown (`baktaz_flutter`)

- **Presentation Layer (`lib/core/domain/cubit/app_localization/app_localization_cubit.dart`)**:
  - `CubitSignal<I18n>`, depends on `IRemoteLocalizationRepository` and `FailureHandler`.
- **Domain Layer (`lib/core/domain/interface/`)**:
  - `IRemoteLocalizationRepository` (`getCachedOverrides()`, `syncRemoteLocalization()`).
  - `ILocalStorageRepository` methods (`getOtaLocalizationVersion`, `setOtaLocalizationVersion`, `getOtaLocalizationOverrides`, `setOtaLocalizationOverrides`).
- **Data Layer (`lib/core/data/repository/`)**:
  - `RemoteLocalizationRepository` using `Client`, `ILocalStorageRepository`, `FailureHandler`.
  - `LocalStorageRepository` managing `SharedPreferences` keys.

---

## 4. Domain Data Models (Serverpod Spy Models)

Serverpod models are strictly:

### 4.1 RemoteLocalizationRelease (`remote_localization_release.spy.yaml`)

```yaml
class: RemoteLocalizationRelease
table: remote_localization_release
fields:
  version: int
  publishedBy: String
  publishedAt: DateTime
  active: bool
  notes: String?
  payloadJson: String
  checksum: String
indexes:
  remote_localization_release_version_idx:
    fields: version
    unique: true
```

### 4.2 RemoteLocalizationAuditLog (`remote_localization_audit_log.spy.yaml`)

```yaml
class: RemoteLocalizationAuditLog
table: remote_localization_audit_log
fields:
  timestamp: DateTime
  author: String
  action: String
  details: String
  previousValue: String?
  newValue: String?
```

### 4.3 RemoteLocalizationResponse (`remote_localization_response.spy.yaml`)

```yaml
class: RemoteLocalizationResponse
fields:
  version: int
  updated: bool
  checksum: String?
  overridesJson: String?
```

---

## 5. Remote Payload Format & Client Negotiation

Public endpoint returns JSON payload with version negotiation:

```json
{
  "version": 12,
  "updated": true,
  "checksum": "sha256:abc123hash...",
  "overridesJson": "{\"auth.loginButton\":\"Sign in\",\"auth.welcome\":\"Welcome back!\"}"
}
```

If `clientVersion` matches active release version:
```json
{
  "version": 12,
  "updated": false,
  "checksum": "sha256:abc123hash...",
  "overridesJson": null
}
```

---

## 6. Key & Variable Validation Against `en.i18n.json`

Before publishing a release, `baktaz_server` validates the release override payload against the canonical `en.i18n.json` translation catalog:

1. **Key Validation:**
   - The override key (e.g. `auth.loginButton`) must exist in `en.i18n.json`.
   - Unknown keys cause publication to fail with a `ValidationException`.

2. **Variable Placeholder Validation:**
   - Placeholders are extracted using regex `\{(\w+)\}` from both canonical string in `en.i18n.json` and the remote override string.
   - Example canonical: `"Welcome, {name}! You have {count} notifications."` -> Variables: `['name', 'count']`.
   - Valid override: `"Hello {name}! {count} alerts."` -> Variables: `['name', 'count']` (Matches).
   - Invalid override: `"Hello {user}!"` -> Variables mismatch (Missing `count`, unexpected `user`). Rejection occurs.

---

## 7. Flutter Client Architecture & Failure Handling

### 7.1 Startup & Sync Pipeline

```text
App Launch
    │
    ▼
AppLocalizationCubit.init()
    │
    ├── 1. Read cached OTA overrides from LocalStorageRepository (SharedPreferences)
    │
    ├── 2. Apply cached overrides to Slang resolver (fallback to en.i18n.json)
    │
    ├── 3. Instant UI render (zero startup blocking)
    │
    └── 4. Asynchronous Background Sync
             │
             ├── Call RemoteLocalizationEndpoint.get(currentVersion)
             │
             ├── On Success: Update local version & cached overrides in SharedPreferences
             │
             └── On Error: Catch exception, log/report via FailureHandler (Crashlytics),
                          and return false silently without affecting UI/launch.
```

### 7.2 Discarding Firebase Remote Config

Firebase Remote Config is **completely removed** from the localization domain:
- `AppLocalizationCubit` depends strictly on `IRemoteLocalizationRepository` and `FailureHandler`.
- No `RemoteConfigService` is injected into `AppLocalizationCubit`.

---

## 8. Database Seeding via `bin/seed.dart`

Database seeding logic is implemented cleanly in `baktaz_server`:

- **Location:** `baktaz_server/lib/src/app/utils/seeding_utils.dart`
- **Function:** `Future<void> seedRemoteLocalization(Session session)`
- **Execution:** Invoked inside `baktaz_server/bin/seed.dart` using the Serverpod session CLI pattern:

```dart
// baktaz_server/lib/src/app/utils/seeding_utils.dart
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_localization/domain/interface/i_remote_localization_repository.dart';
import 'package:serverpod/serverpod.dart';

Future<void> seedRemoteLocalization(Session session) async {
  final repo = getIt<IRemoteLocalizationRepository>();
  await repo.seedInitialRelease(session);
}
```

```dart
// baktaz_server/bin/seed.dart
import 'package:baktaz_server/src/app/utils/seeding_utils.dart';
// ...
await seedRemoteLocalization(session);
```

---

## 9. Design Decisions Summary

| Decision | Choice | Rationale |
|---|---|---|
| **Remote Config Engine** | Serverpod OTA RPC | Firebase Remote Config discarded for localization |
| **Canonical Source** | `en.i18n.json` (Slang) | Bundled with Flutter binary |
| **Validation Source** | `en.i18n.json` | Key & placeholder regex `\{(\w+)\}` validation |
| **Public Endpoint** | `RemoteLocalizationEndpoint` | Unauthenticated read-only (`requireLogin => false`), methods `get` & `seed` |
| **Client Startup** | Instant | Synchronous local cache / Slang read; zero network wait |
| **Sync Strategy** | Asynchronous background | Syncs new releases for next app launch |
| **Failure Handling** | Silent + Crashlytics | Network errors report to `FailureHandler` and fail silently |
| **Backend Seeding** | `bin/seed.dart` | `seedRemoteLocalization` in `seeding_utils.dart` |
| **Server Caching** | Local Session Cache | Cached via `session.caches.local` |
| **Releases** | Monotonic & Immutable | Rollbacks activate existing immutable version |

# Health Server Endpoints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Serverpod repositories (`UserDeviceRepository`, `HealthIntegrationRepository`) and RPC endpoint (`HealthEndpoint`) for health device management, connection status, and step sync coordination. All endpoints enforce authentication via `Session` and apply business rules from the spec.

**Architecture:** Repository pattern with `session.caches.local` for caching. Endpoint requires authentication (`requireLogin = true`), derives user ID from `session.auth.authenticatedUserId`, and enforces one-authoritative-provider rule. Repositories return typed domain models, never raw maps.

**Tech Stack:** Dart 3.x, Serverpod 2.x, `injectable`, `build_runner`, `@LazySingleton` DI.

**Spec:** `docs/superpowers/specs/health_data_integration_spec.md`

---

## Global Constraints

- All endpoint methods MUST set `requireLogin = true` (default).
- User ID derived from `session.auth.authenticatedUserId` — never accept client-provided userId.
- One `isAuthoritative = true` HealthIntegration per user (enforce on connect/swap).
- Reject manual step entries (`wasUserEntered = true`).
- Monotonic step updates: `max(existing, new)` for `DailyStepTelemetry`.
- Cache invalidation via `session.caches.local` when active integration changes.
- DI via `@LazySingleton(as: Interface)` with `injectable` + `build_runner`.

---

### Task 1: Create Serverpod Repository Interfaces & Implementations

**Files:**
- Create: `baktaz_server/lib/src/features/health/domain/interface/i_user_device_repository.dart`
- Create: `baktaz_server/lib/src/features/health/domain/interface/i_health_integration_repository.dart`
- Create: `baktaz_server/lib/src/features/health/data/repository/user_device_repository.dart`
- Create: `baktaz_server/lib/src/features/health/data/repository/health_integration_repository.dart`

**Interfaces:**
- Consumes: `Session`, models from sub-plan 00.
- Produces: `UserDeviceRepository`, `HealthIntegrationRepository` registered via `@LazySingleton(as: I*)`.

- [ ] **Step 1: Implement `IUserDeviceRepository` interface**

```dart
abstract interface class IUserDeviceRepository {
  Future<UserDevice?> getDevice(Session session, UuidValue userId, String deviceId);
  Future<List<UserDevice>> getUserDevices(Session session, UuidValue userId);
  Future<UserDevice> registerDevice(Session session, UuidValue userId, String deviceId, String deviceName, String platform);
  Future<void> updateLastSeen(Session session, UuidValue userId, String deviceId);
  Future<void> deactivateDevice(Session session, UuidValue userId, String deviceId);
}
```

- [ ] **Step 2: Implement `IHealthIntegrationRepository` interface**

```dart
abstract interface class IHealthIntegrationRepository {
  Future<HealthIntegration?> getIntegration(Session session, UuidValue userId, String deviceId);
  Future<List<HealthIntegration>> getUserIntegrations(Session session, UuidValue userId);
  Future<HealthIntegration> connectIntegration(Session session, UuidValue userId, String deviceId, String provider, {required bool isAuthoritative});
  Future<void> disconnectIntegration(Session session, UuidValue userId, String deviceId);
  Future<void> setAuthoritative(Session session, UuidValue userId, String deviceId);
  Future<HealthConnectionStatus> getConnectionStatus(Session session, UuidValue userId);
  Future<void> recordStepSync(Session session, UuidValue userId, String deviceId, int stepCount, String syncSource, {required bool wasUserEntered});
}
```

- [ ] **Step 3: Implement `UserDeviceRepository` with `@LazySingleton(as: IUserDeviceRepository)`**

Use `session.db` for CRUD operations. Cache device list in `session.caches.local` with key `health:devices:{userId}`.

- [ ] **Step 4: Implement `HealthIntegrationRepository` with `@LazySingleton(as: IHealthIntegrationRepository)`**

Enforce single authoritative provider: when `setAuthoritative` called, first demote all existing authoritative integrations for the user, then promote the target. Reject `wasUserEntered = true` step syncs. Invalidate connection status cache on changes.

---

### Task 2: Create `HealthEndpoint`

**Files:**
- Create: `baktaz_server/lib/src/features/health/endpoint/health_endpoint.dart`

- [ ] **Step 1: Implement `HealthEndpoint` with authentication and validation**

```dart
class HealthEndpoint extends Endpoint {
  Future<HealthConnectionStatus> getConnectionStatus(Session session) async { ... }
  Future<HealthIntegration> connectProvider(Session session, String deviceId, String deviceName, String platform, String provider, {required bool isAuthoritative}) async { ... }
  Future<void> disconnectProvider(Session session, String deviceId) async { ... }
  Future<void> syncSteps(Session session, String deviceId, int stepCount, String syncSource, {required bool wasUserEntered}) async { ... }
  Future<List<UserDevice>> getUserDevices(Session session) async { ... }
  Future<void> registerDevice(Session session, String deviceId, String deviceName, String platform) async { ... }
}
```

Requirements:
- All methods derive `userId` from `session.auth.authenticatedUserId`.
- Reject `wasUserEntered = true` in `syncSteps`.
- Validate step range (0 ≤ stepCount ≤ 100,000).
- Apply monotonic `max(existing, new)` for `DailyStepTelemetry` updates.
- Invalidate `session.caches.local` for active challenge leaderboards on step sync.

- [ ] **Step 2: Run build_runner to register DI bindings**

Run: `cd baktaz_server && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify endpoint compiles cleanly**

Run: `cd baktaz_server && fvm dart analyze`
Expected: `No issues found!`

---

## Verification Checkpoint

After completing this sub-plan:
- [ ] Repository interfaces created and DI-registered
- [ ] `HealthEndpoint` implements all 6 RPC methods
- [ ] Authentication enforced on all methods
- [ ] Single-authoritative-provider rule enforced
- [ ] Manual entry rejection working
- [ ] Step range validation in place
- [ ] Cache invalidation working
- [ ] `dart analyze` passes cleanly

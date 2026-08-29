# Steps Server Endpoints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Serverpod repositories (`UserDeviceRepository`, `StepIntegrationRepository`) and RPC endpoint (`StepsEndpoint`) for steps device management, connection status, and step sync coordination. All endpoints enforce authentication via `Session` and apply business rules from the spec.

**Architecture:** Repository pattern with `session.caches.local` for caching. Endpoint requires authentication (`requireLogin = true`), derives user ID from `session.auth.authenticatedUserId`, and enforces one-authoritative-provider rule. Repositories return typed domain models, never raw maps.

**Tech Stack:** Dart 3.x, Serverpod 2.x, `injectable`, `build_runner`, `@LazySingleton` DI.

**Spec:** `docs/superpowers/specs/Steps/Index.md`

---

## Global Constraints

- All endpoint methods MUST set `requireLogin = true` (default).
- User ID derived from `session.auth.authenticatedUserId` — never accept client-provided userId.
- One `isAuthoritative = true` StepIntegration per user (enforce on connect/swap).
- Monotonic step updates with out-of-order protection using `syncedAt` timestamps.
- Anti-cheat bounds: Soft reject flag at 100,000 steps, hard reject above 500,000 steps.
- Cache invalidation via `session.caches.local` when active integration changes.
- DI via `@LazySingleton(as: Interface)` with `injectable` + `build_runner`.

---

### Task 1: Create Serverpod Repository Interfaces & Implementations

**Files:**
- Create: `baktaz_server/lib/src/features/steps/domain/interface/i_user_device_repository.dart`
- Create: `baktaz_server/lib/src/features/steps/domain/interface/i_step_integration_repository.dart`
- Create: `baktaz_server/lib/src/features/steps/data/repository/user_device_repository.dart`
- Create: `baktaz_server/lib/src/features/steps/data/repository/step_integration_repository.dart`

**Interfaces:**
- Consumes: `Session`, models from sub-plan 00.
- Produces: `UserDeviceRepository`, `StepIntegrationRepository` registered via `@LazySingleton(as: I*)`.

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

- [ ] **Step 2: Implement `IStepIntegrationRepository` interface**

```dart
abstract interface class IStepIntegrationRepository {
  Future<StepIntegration?> getIntegration(Session session, UuidValue userId, String deviceId);
  Future<List<StepIntegration>> getUserIntegrations(Session session, UuidValue userId);
  Future<StepIntegration> connectIntegration(Session session, UuidValue userId, String deviceId, String provider, {required bool isAuthoritative});
  Future<void> disconnectIntegration(Session session, UuidValue userId, String deviceId);
  Future<void> setAuthoritative(Session session, UuidValue userId, String deviceId);
  Future<StepConnectionStatus> getConnectionStatus(Session session, UuidValue userId);
  Future<void> recordStepSync(Session session, UuidValue userId, String deviceId, int stepCount, DateTime syncedAt, String syncSource);
}
```

- [ ] **Step 3: Implement `UserDeviceRepository` with `@LazySingleton(as: IUserDeviceRepository)`**

Use `session.db` for CRUD operations. Cache device list in `session.caches.local` with key `steps:devices:{userId}`.

- [ ] **Step 4: Implement `StepIntegrationRepository` with `@LazySingleton(as: IStepIntegrationRepository)`**

Enforce single authoritative provider: when `setAuthoritative` called, demote existing authoritative integrations for the user, then promote the target. Apply anti-cheat checks (soft flag at 100k, hard reject at >500k). Invalidate connection status cache on changes.

---

### Task 2: Create `StepsEndpoint`

**Files:**
- Create: `baktaz_server/lib/src/features/steps/endpoint/steps_endpoint.dart`

- [ ] **Step 1: Implement `StepsEndpoint` with authentication and validation**

```dart
class StepsEndpoint extends Endpoint {
  Future<StepConnectionStatus> getConnectionStatus(Session session) async { ... }
  Future<StepIntegration> connectProvider(Session session, String deviceId, String deviceName, String platform, String provider, {required bool isAuthoritative}) async { ... }
  Future<void> disconnectProvider(Session session, String deviceId) async { ... }
  Future<void> syncSteps(Session session, String deviceId, int stepCount, DateTime syncedAt, String syncSource) async { ... }
  Future<List<UserDevice>> getUserDevices(Session session) async { ... }
  Future<void> registerDevice(Session session, String deviceId, String deviceName, String platform) async { ... }
}
```

Requirements:
- All methods derive `userId` from `session.auth.authenticatedUserId`.
- Require `DateTime syncedAt` in `syncSteps` for out-of-order sync protection.
- Anti-cheat range validation: 0 ≤ stepCount ≤ 500,000 (hard reject > 500k; soft flag if > 100k).
- Apply latest-sync update strategy using `syncedAt`.
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
- [ ] `StepsEndpoint` implements all RPC methods with `DateTime syncedAt` parameter
- [ ] Authentication enforced on all methods
- [ ] Single-authoritative-provider rule enforced
- [ ] Anti-cheat validation (soft flag at 100k, hard reject at 500k+) in place
- [ ] Cache invalidation working
- [ ] `dart analyze` passes cleanly

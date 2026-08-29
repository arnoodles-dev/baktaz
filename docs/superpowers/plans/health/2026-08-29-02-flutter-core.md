# Health Flutter Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `baktaz_flutter` domain and data layers for the Health feature: enums, repository interfaces, domain entities, Cubits, services, and typed route definitions. This sub-plan creates the complete business logic layer before UI implementation.

**Architecture:** Clean Architecture with feature-first organization under `lib/features/health/`. Domain layer defines interfaces and entities. Data layer implements repositories and health service integration. Presentation layer uses `CubitSignal<S>` with `@freezed` states. All repository methods return `TaskResult<T>`.

**Tech Stack:** Dart 3.x, Flutter, `bloc_signals_flutter`, `fpdart`, `freezed`, `go_router`.

**Spec:** `docs/superpowers/specs/health_data_integration_spec.md`

---

## Global Constraints

- Repository contracts: All methods MUST return `TaskResult<T>` (`Either<Failure, T>`). Never throw exceptions.
- Error handling: Pattern B (side effects via events, not state).
- Cubit pattern: Extend `CubitSignal<S>`, single-action methods, `safeRun` for async.
- i18n: No hardcoded user-facing strings — use `context.l10n.*`.
- Generated code: Use `@freezed` for entities, `build_runner` for codegen.

---

### Task 1: Create Domain Enums

**Files:**
- Create: `lib/features/health/domain/enum/health_provider_type.dart`
- Create: `lib/features/health/domain/enum/health_connection_state.dart`
- Create: `lib/features/health/domain/enum/health_sync_status.dart`

- [ ] **Step 1: Implement enums**

```dart
// health_provider_type.dart
enum HealthProviderType {
  healthkit,  // iOS Apple HealthKit
  healthconnect,  // Android Health Connect
}

extension HealthProviderTypeX on HealthProviderType {
  String get name;  // 'healthkit' | 'healthconnect'
  bool get supportsiOS;
  bool get supportsAndroid;
}

// health_connection_state.dart
enum HealthConnectionState {
  pending,
  connected,
  disconnected,
  error,
  noData,
}

// health_sync_status.dart
enum HealthSyncStatus {
  synced,
  pending,
  error,
  noData,
  neverSynced,
}
```

---

### Task 2: Create Domain Entities

**Files:**
- Create: `lib/features/health/domain/entity/user_device.dart`
- Create: `lib/features/health/domain/entity/health_integration.dart`
- Create: `lib/features/health/domain/entity/health_connection_status.dart`
- Create: `lib/features/health/domain/entity/step_sync.dart`

- [ ] **Step 1: Implement `@freezed` entities with server model mapping**

```dart
// user_device.dart
@freezed
class UserDevice with _$UserDevice {
  const factory UserDevice({
    required String id,
    required String deviceId,
    required String deviceName,
    required String platform,
    String? osVersion,
    String? appVersion,
    required bool isActive,
    required DateTime lastSeenAt,
  }) = _UserDevice;

  factory UserDevice.fromServer(ServerUserDevice device) => ...;
}

// health_integration.dart
@freezed
class HealthIntegration with _$HealthIntegration {
  const factory HealthIntegration({
    required String id,
    required String deviceId,
    required HealthProviderType provider,
    required HealthConnectionState status,
    DateTime? lastSyncAt,
    String? lastError,
    required bool permissionsGranted,
    required bool isAuthoritative,
  }) = _HealthIntegration;

  factory HealthIntegration.fromServer(ServerHealthIntegration integration) => ...;
}

// health_connection_status.dart
@freezed
class HealthConnectionStatus with _$HealthConnectionStatus {
  const factory HealthConnectionStatus({
    required bool hasActiveIntegration,
    HealthProviderType? provider,
    required bool isAuthoritative,
    DateTime? lastSyncAt,
    HealthSyncStatus? syncStatus,
    required List<UserDevice> connectedDevices,
    String? errorMessage,
  }) = _HealthConnectionStatus;
}

// step_sync.dart
@freezed
class StepSync with _$StepSync {
  const factory StepSync({
    required String id,
    required String integrationId,
    required DateTime syncedAt,
    required int stepCount,
    required HealthProviderType syncSource,
    required bool wasUserEntered,
    required bool isValid,
    String? validationNotes,
  }) = _StepSync;
}
```

---

### Task 3: Create Repository Interfaces

**Files:**
- Create: `lib/features/health/domain/interface/i_user_device_repository.dart`
- Create: `lib/features/health/domain/interface/i_health_repository.dart`

> **Note:** Per grilling decisions, `StepsRepository.syncSteps()` calls `HealthRepository.getTodaySteps()` — no direct dependency on `IHealthRepository` in HomeCubit. Single data flow path: HomeCubit → StepsRepository → HealthRepository.getTodaySteps() → HealthService → HealthKit/Health Connect.

- [ ] **Step 1: Implement repository interfaces**

```dart
// i_user_device_repository.dart
abstract interface class IUserDeviceRepository {
  TaskResult<List<UserDevice>> getUserDevices();
  TaskResult<UserDevice> registerDevice(String deviceId, String deviceName, String platform);
  TaskResult<void> updateLastSeen(String deviceId);
  TaskResult<void> deactivateDevice(String deviceId);
}

// i_health_repository.dart
abstract interface class IHealthRepository {
  TaskResult<HealthConnectionStatus> getConnectionStatus();
  TaskResult<HealthIntegration> connectProvider(String deviceId, String deviceName, String platform, HealthProviderType provider, {required bool isAuthoritative});
  TaskResult<void> disconnectProvider(String deviceId);
  TaskResult<void> syncSteps(String deviceId, int stepCount, HealthProviderType syncSource, {required bool wasUserEntered});
}
```

---

### Task 4: Create Health Service (Platform Abstraction)

**Files:**
- Create: `lib/features/health/data/service/i_health_service.dart`
- Create: `lib/features/health/data/service/health_service.dart`

- [ ] **Step 1: Implement health service interface and implementation**

```dart
// i_health_service.dart
abstract interface class IHealthService {
  /// Check if health data is available on this platform
  Future<bool> isAvailable();
  
  /// Request health permissions
  Future<bool> requestPermissions();
  
  /// Check if permissions are granted
  Future<bool> hasPermissions();
  
  /// Read today's step count
  Future<int> getTodaySteps();
  
  /// Read steps for a specific date
  Future<int> getStepsForDate(DateTime date);
  
  /// Get health provider type for current platform
  HealthProviderType get providerType;
}

// health_service.dart
class HealthService implements IHealthService {
  // Uses `health` package for platform-specific implementation
  // TODO(username): HealthKit implementation for iOS
  // TODO(username): Health Connect implementation for Android
  // TODO(username): Error handling for unavailable/unauthorized states
}
```

Register as `@LazySingleton(as: IHealthService)` in `injection.dart`.

---

### Task 5: Create Repository Implementations

**Files:**
- Create: `lib/features/health/data/repository/user_device_repository.dart`
- Create: `lib/features/health/data/repository/health_repository.dart`

- [ ] **Step 1: Implement repositories with `TaskResult.tryCatch`**

```dart
// user_device_repository.dart
@LazySingleton(as: IUserDeviceRepository)
class UserDeviceRepository implements IUserDeviceRepository {
  UserDeviceRepository({required Serverpod serverpod});
  
  @override
  TaskResult<List<UserDevice>> getUserDevices() => TaskResult.tryCatch(() async {
    final devices = await serverpod.health.getUserDevices();
    return devices.map(UserDevice.fromServer).toList();
  });
  // ... other methods
}

// health_repository.dart
@LazySingleton(as: IHealthRepository)
class HealthRepository implements IHealthRepository {
  HealthRepository({
    required Serverpod serverpod,
    required IHealthService healthService,
  });
  
  @override
  TaskResult<HealthConnectionStatus> getConnectionStatus() => TaskResult.tryCatch(() async {
    final status = await serverpod.health.getConnectionStatus();
    return HealthConnectionStatus(
      hasActiveIntegration: status.hasActiveIntegration,
      provider: status.provider == 'healthkit' ? HealthProviderType.healthkit : HealthProviderType.healthconnect,
      // ... map remaining fields
    );
  });
  // ... other methods
}
```

---

### Task 6: Create Health Cubit & State

**Files:**
- Create: `lib/features/health/domain/cubit/health/health_state.dart`
- Create: `lib/features/health/domain/cubit/health/health_cubit.dart`

- [ ] **Step 1: Implement `@freezed` state and Cubit**

```dart
// health_state.dart
@freezed
class HealthState with _$HealthState {
  const factory HealthState({
    required HealthConnectionStatus? connectionStatus,
    required QueryStatus queryStatus,
    required List<UserDevice> devices,
    HealthIntegration? activeIntegration,
    String? error,
  }) = _HealthState;
  
  const HealthState._();
  
  bool get isConnected => connectionStatus?.hasActiveIntegration ?? false;
  bool get isLoading => queryStatus == QueryStatus.loading;
}

enum QueryStatus { initial, loading, loaded, error }

// health_cubit.dart
@injectable
class HealthCubit extends CubitSignal<HealthState> {
  HealthCubit({
    required IHealthRepository healthRepository,
    required IUserDeviceRepository deviceRepository,
  }) : super(const HealthState()) {
    _healthRepository = healthRepository;
    _deviceRepository = deviceRepository;
  }
  
  final IHealthRepository _healthRepository;
  final IUserDeviceRepository _deviceRepository;
  
  Future<void> loadConnectionStatus() async { ... }
  Future<void> connectProvider(HealthProviderType provider, {required bool isAuthoritative}) async { ... }
  Future<void> disconnectProvider(String deviceId) async { ... }
  Future<void> syncSteps() async { ... }
}
```

---

### Task 7: Create Typed Route Definition

**Files:**
- Modify: `lib/app/router/app_router.dart` (add `@TypedGoRoute` for health)

- [ ] **Step 1: Add health route definition**

```dart
// Add to app_router.dart
@TypedGoRoute(
  path: '/health',
  name: 'health',
)
class HealthRoute extends GoRouteData {
  const HealthRoute();
  
  static const String name = 'health';
  static const String path = '/health';
}

extension AppRouterHealthExtension on AppRouter {
  // BuildEntry for HealthRoute
}
```

---

### Task 8: Run Codegen

- [ ] **Step 1: Run Slang for i18n**

Run: `cd baktaz_flutter && fvm dart run slang`

- [ ] **Step 2: Run build_runner for freezed/codegen**

Run: `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Verify compilation**

Run: `cd baktaz_flutter && fvm dart analyze`
Expected: `No issues found!`

---

## Verification Checkpoint

After completing this sub-plan:
- [ ] All domain enums created and exported
- [ ] All `@freezed` entities created with `fromServer` mapping
- [ ] Repository interfaces defined with `TaskResult<T>` return types
- [ ] `HealthService` implemented with platform abstraction and TODO stubs
- [ ] Repository implementations registered via `@LazySingleton`
- [ ] `HealthCubit` implemented with single-action methods
- [ ] Typed route definition added to `app_router.dart`
- [ ] Slang and build_runner completed successfully
- [ ] `dart analyze` passes cleanly

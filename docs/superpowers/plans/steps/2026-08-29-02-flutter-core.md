# Steps Flutter Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `baktaz_flutter` domain and data layers for the Steps feature: enums, repository interfaces, domain entities, Cubits, services, and typed route definitions. This sub-plan creates the complete business logic layer before UI implementation.

**Architecture:** Clean Architecture with feature-first organization under `lib/features/steps/`. Domain layer defines interfaces and entities. Data layer implements repositories and steps service integration. Presentation layer uses `CubitSignal<S>` with `@freezed` states. All repository methods return `TaskResult<T>`.

**Tech Stack:** Dart 3.x, Flutter, `bloc_signals_flutter`, `fpdart`, `freezed`, `go_router`.

**Spec:** `docs/superpowers/specs/Steps/Index.md`

---

## Global Constraints

- Repository contracts: All methods MUST return `TaskResult<T>` (`Either<Failure, T>`). Never throw exceptions.
- Error handling: Pattern B (side effects via events, not state).
- Cubit pattern: Extend `CubitSignal<S>`, single-action methods, `safeRun` for async.
- i18n: No hardcoded user-facing strings — use `context.i18n.steps.*`.
- Generated code: Use `@freezed` for entities, `build_runner` for codegen.

---

### Task 1: Create Domain Enums

**Files:**
- Create: `lib/features/steps/domain/enum/step_provider_type.dart`
- Create: `lib/features/steps/domain/enum/step_integration_status.dart`
- Create: `lib/features/steps/domain/enum/step_connection_diagnostic.dart`
- Create: `lib/features/steps/domain/enum/step_sync_status.dart`

- [ ] **Step 1: Implement enums**

```dart
// step_provider_type.dart
enum StepProviderType {
  healthkit,  // iOS Apple HealthKit
  healthconnect,  // Android Health Connect
}

extension StepProviderTypeX on StepProviderType {
  String get name;  // 'healthkit' | 'healthconnect'
  bool get supportsiOS;
  bool get supportsAndroid;
}

// step_integration_status.dart
enum StepIntegrationStatus {
  pending,
  connected,
  disconnected,
  error,
  noData,
}

// step_connection_diagnostic.dart (canonical diagnostic enum)
enum StepConnectionDiagnostic {
  supported,
  notInstalled,
  permissionDenied,
  permissionDeniedPermanently,
  permissionRestricted,
  authorized,
  connected,
  serviceUnavailable,
  serviceDegraded,
  noDataFound,
  error,
}

// step_sync_status.dart
enum StepSyncStatus {
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
- Create: `lib/features/steps/domain/entity/user_device.dart`
- Create: `lib/features/steps/domain/entity/step_integration.dart`
- Create: `lib/features/steps/domain/entity/step_integration_status.dart`
- Create: `lib/features/steps/domain/entity/step_sync.dart`

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

// step_integration.dart
@freezed
class StepIntegration with _$StepIntegration {
  const factory StepIntegration({
    required String id,
    required String deviceId,
    required StepProviderType provider,
    required StepIntegrationStatus status,
    DateTime? lastSyncAt,
    String? lastError,
    required bool permissionsGranted,
    required bool isAuthoritative,
  }) = _StepIntegration;

  factory StepIntegration.fromServer(ServerStepIntegration integration) => ...;
}

// step_integration_status.dart
@freezed
class SyncStepStatus with _$SyncStepStatus {
  const factory SyncStepStatus({
    required bool hasActiveIntegration,
    StepProviderType? provider,
    required bool isAuthoritative,
    DateTime? lastSyncAt,
    StepSyncStatus? syncStatus,
    required List<UserDevice> connectedDevices,
    String? errorMessage,
  }) = _SyncStepStatus;
}

// step_sync.dart
@freezed
class StepSync with _$StepSync {
  const factory StepSync({
    required String id,
    required String integrationId,
    required DateTime syncedAt,
    required int stepCount,
    required StepProviderType syncSource,
    required bool isValid,
    String? validationNotes,
  }) = _StepSync;
}
```

---

### Task 3: Create Repository Interfaces

**Files:**
- Create: `lib/features/steps/domain/interface/i_user_device_repository.dart`
- Create: `lib/features/steps/domain/interface/i_steps_repository.dart`

- [ ] **Step 1: Implement repository interfaces**

```dart
// i_user_device_repository.dart
abstract interface class IUserDeviceRepository {
  TaskResult<List<UserDevice>> getUserDevices();
  TaskResult<UserDevice> registerDevice(String deviceId, String deviceName, String platform);
  TaskResult<void> updateLastSeen(String deviceId);
  TaskResult<void> deactivateDevice(String deviceId);
}

// i_steps_repository.dart
abstract interface class IStepsRepository {
  TaskResult<SyncStepStatus> getConnectionStatus();
  TaskResult<StepIntegration> connectProvider(String deviceId, String deviceName, String platform, StepProviderType provider, {required bool isAuthoritative});
  TaskResult<void> disconnectProvider(String deviceId);
  TaskResult<void> syncSteps(String deviceId, int stepCount, DateTime syncedAt, StepProviderType syncSource);
  TaskResult<int> getTodaySteps();
  TaskResult<StepConnectionDiagnostic> diagnose();
}
```

---

### Task 4: Create Steps Service (Platform Abstraction)

**Files:**
- Create: `lib/features/steps/data/service/i_steps_service.dart`
- Create: `lib/features/steps/data/service/steps_service.dart`

- [ ] **Step 1: Implement steps service interface and implementation**

```dart
// i_steps_service.dart
abstract interface class IStepsService {
  /// Check if step data is available on this platform
  Future<bool> isAvailable();
  
  /// Request step permissions
  Future<bool> requestPermissions();
  
  /// Check if permissions are granted
  Future<bool> hasPermissions();
  
  /// Read today's step count
  Future<int> getTodaySteps();
  
  /// Read steps for a specific date
  Future<int> getStepsForDate(DateTime date);

  /// Diagnose connection status
  Future<StepConnectionDiagnostic> diagnose();
  
  /// Get step provider type for current platform
  StepProviderType get providerType;
}

// steps_service.dart
class StepsService implements IStepsService {
  // Uses `health` package for platform-specific implementation
  // TODO(username): HealthKit implementation for iOS
  // TODO(username): Health Connect implementation for Android
  // TODO(username): Error handling for unavailable/unauthorized states
}
```

Register as `@LazySingleton(as: IStepsService)` in `injection.dart`.

---

### Task 5: Create Repository Implementations

**Files:**
- Create: `lib/features/steps/data/repository/user_device_repository.dart`
- Create: `lib/features/steps/data/repository/steps_repository.dart`

- [ ] **Step 1: Implement repositories with `TaskResult.tryCatch`**

```dart
// user_device_repository.dart
@LazySingleton(as: IUserDeviceRepository)
class UserDeviceRepository implements IUserDeviceRepository {
  UserDeviceRepository({required Serverpod serverpod});
  
  @override
  TaskResult<List<UserDevice>> getUserDevices() => TaskResult.tryCatch(() async {
    final devices = await serverpod.steps.getUserDevices();
    return devices.map(UserDevice.fromServer).toList();
  });
  // ... other methods
}

// steps_repository.dart
@LazySingleton(as: IStepsRepository)
class StepsRepository implements IStepsRepository {
  StepsRepository({
    required Serverpod serverpod,
    required IStepsService stepsService,
  });
  
  @override
  TaskResult<SyncStepStatus> getConnectionStatus() => TaskResult.tryCatch(() async {
    final status = await serverpod.steps.getConnectionStatus();
    return SyncStepStatus(
      hasActiveIntegration: status.hasActiveIntegration,
      provider: status.provider == 'healthkit' ? StepProviderType.healthkit : StepProviderType.healthconnect,
      // ... map remaining fields
    );
  });
  // ... other methods
}
```

---

### Task 6: Create Steps Cubit & State

**Files:**
- Create: `lib/features/steps/domain/cubit/steps_state.dart`
- Create: `lib/features/steps/domain/cubit/steps_cubit.dart`

- [ ] **Step 1: Implement `@freezed` state and Cubit**

```dart
// steps_state.dart
@freezed
class StepsState with _$StepsState {
  const factory StepsState({
    required SyncStepStatus? connectionStatus,
    required QueryStatus queryStatus,
    required List<UserDevice> devices,
    StepIntegration? activeIntegration,
    String? error,
  }) = _StepsState;
  
  const StepsState._();
  
  bool get isConnected => connectionStatus?.hasActiveIntegration ?? false;
  bool get isLoading => queryStatus == QueryStatus.loading;
}

enum QueryStatus { initial, loading, loaded, error }

// steps_cubit.dart
@injectable
class StepsCubit extends CubitSignal<StepsState> {
  StepsCubit({
    required IStepsRepository stepsRepository,
    required IUserDeviceRepository deviceRepository,
  }) : super(const StepsState()) {
    _stepsRepository = stepsRepository;
    _deviceRepository = deviceRepository;
  }
  
  final IStepsRepository _stepsRepository;
  final IUserDeviceRepository _deviceRepository;
  
  Future<void> loadConnectionStatus() async { ... }
  Future<void> connectProvider(StepProviderType provider, {required bool isAuthoritative}) async { ... }
  Future<void> disconnectProvider(String deviceId) async { ... }
  Future<void> syncSteps() async { ... }
}
```

---

### Task 7: Create Typed Route Definition

**Files:**
- Modify: `lib/app/router/app_router.dart` (add `@TypedGoRoute` for steps under account)

- [ ] **Step 1: Add steps route definition**

```dart
// Add to app_router.dart under account shell
@TypedGoRoute(
  path: '/account/steps',
  name: 'accountSteps',
)
class AccountStepsRoute extends GoRouteData {
  const AccountStepsRoute();
  
  static const String name = 'accountSteps';
  static const String path = '/account/steps';
}

extension AppRouterStepsExtension on AppRouter {
  // BuildEntry for AccountStepsRoute
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
- [ ] All domain enums created (`StepIntegrationStatus`, `StepConnectionDiagnostic`, etc.)
- [ ] All `@freezed` entities created with `fromServer` mapping
- [ ] `IStepsRepository` defined with `TaskResult<T>` return types
- [ ] `IStepsService` and `StepsService` implemented with platform abstraction and stubs
- [ ] Repository implementations registered via `@LazySingleton`
- [ ] `StepsCubit` implemented with single-action methods
- [ ] Typed route `/account/steps` added to `app_router.dart`
- [ ] Slang and build_runner completed successfully
- [ ] `dart analyze` passes cleanly

---
title: Health Data Integration - Flutter Architecture
status: Proposed
version: 1.0
related: health_data_integration_spec.md
---

# 5. Flutter Architecture

The health integration must be hidden behind a repository abstraction.

Recommended structure:

```text
lib/
├── features/
│   └── health/
│       ├── data/
│       │   ├── health_repository_impl.dart
│       │   └── health_service.dart
│       │
│       ├── domain/
│       │   ├── health_repository.dart
│       │   ├── health_integration.dart
│       │   ├── health_connection_diagnostic.dart
│       │   └── daily_steps.dart
│       │
│       └── presentation/
│           ├── health_integration_screen.dart
│           ├── health_integration_controller.dart
│           └── health_integration_state.dart
```

---

# 6. Health Repository

Recommended interface:

```dart
abstract interface class HealthRepository {
  Future<HealthConnectionDiagnostic> diagnose();

  Future<HealthConnectionDiagnostic> connect();

  Future<int> getTodaySteps();

  Future<List<DailySteps>> getStepsHistory({
    required DateTime start,
    required DateTime end,
  });

  Future<void> openHealthSettings();
}
```

The domain layer must not depend directly on HealthKit or Health Connect APIs.

---

# 7. Flutter Health Package

Use the Flutter `health` package as the initial platform abstraction.

Conceptually:

```text
[iOS] → health package → HealthKit
[Android] → health package → Health Connect
```

The package abstracts:

- Health service availability
- Permission handling
- Step data retrieval
- Health app opening

The `health` package is the recommended implementation but not required. You can build a custom abstraction if needed.

---

# 8. Health Integration States

The application must distinguish between multiple states:

### Device-level states

These states describe the current device's ability to access health data.

| State | Description |
|---|---|
| `not_supported` | The device/platform does not support HealthKit or Health Connect |
| `not_installed` | Health Connect is not installed (Android only) |
| `not_authorized` | The user has not granted permission |
| `authorized` | Permission granted, but data access has not been verified |
| `connected` | Permission granted and data is accessible |
| `unavailable` | The health service is temporarily unavailable |
| `error` | An error occurred while accessing health data |

### Data-level states

These states describe the health data itself.

| State | Description |
|---|---|
| `no_data` | Permission granted, but no step data is available for today |
| `has_data` | Step data is available |

---

# 9. Health Connection Diagnostic

The Flutter app should provide a diagnostic function that returns a combined state:

```dart
enum HealthConnectionDiagnostic {
  // Can connect
  supported,
  notInstalled, // Android only

  // Permission needed
  permissionDenied,
  permissionDeniedPermanently,
  permissionRestricted, // Android only (parental controls, etc.)

  // Permission granted
  authorized,

  // Permission + data verified
  connected,

  // Service issues
  serviceUnavailable,
  serviceDegraded, // partial availability

  // Data issues
  noDataFound, // permission OK, but no step data

  // Errors
  error,
}
```

This diagnostic should be called:

- On app launch
- On app resume
- Before attempting to read health data
- Before showing the health integration screen

---

# 10. Integration Validation

Do not assume that a successful permission dialog means the app can read health data.

The permission dialog may:

- Return "success" even if the user granted limited permission
- Return "success" even if the health service is temporarily unavailable
- Return "success" even if no data is available

The app must **verify data access** after permission is granted:

```dart
Future<HealthConnectionDiagnostic> diagnose() async {
  // 1. Check if the health service is available
  final isAvailable = await healthService.isAvailable();
  if (!isAvailable) return HealthConnectionDiagnostic.notInstalled;

  // 2. Request permission
  final granted = await healthService.requestPermission([HealthDataType.STEPS]);
  if (!granted) return HealthConnectionDiagnostic.permissionDenied;

  // 3. Verify data access by reading today's steps
  try {
    final steps = await healthService.getSteps(DateTime.now());
    if (steps.isEmpty) {
      return HealthConnectionDiagnostic.noDataFound;
    }
    return HealthConnectionDiagnostic.connected;
  } on HealthServiceException catch (e) {
    return HealthConnectionDiagnostic.error;
  }
}
```

---

# 11. iOS HealthKit

### Setup

Enable HealthKit in Xcode capabilities.

Add to `Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>StepHero reads your step count from Apple Health to track your daily activity.</string>
```

### Required capabilities

- HealthKit

### Read permissions

- Step Count (`HKQuantityTypeIdentifierStepCount`)

### Notes

- HealthKit may return multiple step samples for the same day from different sources.
- Use the `statistics` API to get the cumulative total, or aggregate the samples.
- The `health` package handles this automatically.
- The user may have HealthKit permissions but no Apple Watch or step-counting device.
- In this case, the diagnostic should return `noDataFound`.

---

# 12. Android Health Connect

### Setup

Add to `AndroidManifest.xml`:

```xml
<queries>
  <package android:name="com.google.android.apps.healthdata" />
</queries>
```

### Permissions

```xml
<uses-permission android:name="android.permission.health.READ_STEPS" />
```

Add metadata:

```xml
<meta-data
    android:name="health_permissions"
    android:resource="@array/health_permissions" />
```

### Required permissions

- `android.permission.health.READ_STEPS` (API 34+)
- Or legacy `android.permission.ACTIVITY_RECOGNITION` for older Android versions

### Notes

- Health Connect must be installed from the Play Store.
- Health Connect aggregates data from multiple sources.
- Some devices may have pre-installed Health Connect (Pixel, Samsung).
- The user may have Health Connect permission but no data sources configured.
- In this case, the diagnostic should return `noDataFound`.

---

# 13. Samsung Health Edge Case

### The Problem

Samsung Health does not automatically sync to Health Connect.

Samsung Health users on Android may:

1. Have Health Connect installed
2. Have granted permission to Health Connect
3. Never have configured Samsung Health to sync to Health Connect

Result: Health Connect returns `noDataFound`.

### Resolution UX

The app should detect this scenario and guide the user:

```text
Almost there

Health Connect is available and permission
is granted, but no step data was found.

If you use Samsung Health, make sure it is
sharing step data with Health Connect.

[ Open Health Connect ]
[ Check Again ]
```

### Detection

This scenario cannot be automatically detected. The UX should always show this message when `noDataFound` occurs on Android, regardless of the cause.

### Additional guidance

```text
To share Samsung Health data with Health Connect:

1. Open Samsung Health
2. Tap the profile icon (bottom right)
3. Tap the settings icon (top right)
4. Tap "Health Connect"
5. Toggle on the data types you want to share
```

---

## See also

- [Overview](overview.md)
- [UI/UX](ui-ux.md)
- [Backend Sync & Model](backend-sync-model.md)
- [Multi-Device Rules](multi-device-rules.md)
- [Backend Schema](backend-schema.md)

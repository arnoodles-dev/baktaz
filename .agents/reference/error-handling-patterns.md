# Error Handling Patterns — Code Examples

> **Note:** This file was cleaned on 2026-08-26 to match actual codebase.
> Older draft designs (failure-state properties, crashlytics property on Failure)
> were aspirational features never implemented — references removed.

## Failure Taxonomy

Sealed `Failure` class in `baktaz_shared` with 7 subtypes (all `Failure` suffix):

| Failure | Constructor | When Used |
|---------|-------------|-----------|
| `UnexpectedFailure` | `Failure.unexpected(String? message)` | Unknown exceptions |
| `ServerFailure` | `Failure.server(StatusCode code, String? message)` | HTTP/RPC errors |
| `ServerFailure` (with `StatusCode.serverpod`) | `Failure.server(StatusCode.serverpod, message)` | Serverpod RPC errors |
| `DeviceStorageFailure` | `Failure.deviceStorage(String? message)` | Local storage failures |
| `DeviceInfoFailure` | `Failure.deviceInfo(String? message)` | Device info unavailable |
| `AuthenticationFailure` | `Failure.authentication(String? message, {bool blocked = false})` | Auth failures |
| `ValidationFailure` | `Failure.validation(ValidationError error, String value)` | Data validation (incl. serialization) |
| `RemoteConfigFailure` | `Failure.remoteConfig(String? message)` | Remote config failures |

## FailureHandler Routing

`handleFailure(failure, [ErrorActions?])` → routes to `ErrorActions.onXxx()`:

| Failure | Handler |
|---------|---------|
| `ServerFailure(http000)` | `onNetworkError` |
| `ServerFailure(http408)` / `ServerFailure(http504)` | `onTimeoutError` |
| `ServerFailure(http403)` | `onPermissionError` |
| `ServerFailure(http404)` | `onNotFoundError` |
| `ServerFailure(other/serverpod)` | `onServerError` |
| `DeviceStorageFailure` / `DeviceInfoFailure` | `onDeviceRelatedError` |
| `ValidationFailure` | `onValidationError` |
| `RemoteConfigFailure` | `onRemoteConfigError` |
| `AuthenticationFailure` | `onAuthenticationError` |
| `UnexpectedFailure` | `onGenericError` |

## Pattern B — Side-Effect Only

NO error state variant — failures surface via `FailureHandler.handleFailure` side-effects.

```dart
// ✅ CORRECT — state stores generic flag, Failure routed to side-effect
safeRun(
  action: () async => emit(await _repo.login()),
  onException: _failureHandler.handleException,
);

// Contextual errors via side-effect union (NOT state variant):
emitPresentation(LoginStateOtpError("Invalid OTP code"));

// ❌ WRONG — Failure in state
emit(AuthState.failed(failure)); // NEVER do this
```

## safeRun Contract

```dart
safeRun({
  required Future<void> action(),
  required void Function(Exception, StackTrace?) onException,
}) → bool // true=success, false=failure/cancelled
```

## ErrorActions Mixin

Located in `baktaz_flutter/lib/app/helpers/mixins/error_actions.dart` AND
`baktaz_admin/lib/app/helpers/mixins/error_actions.dart`.

**Known drift**: `baktaz_admin` lacks `onAuthenticationError`/`onRemoteConfigError`;
validation handler differs. Documented as accepted debt.

```dart
mixin ErrorActions {
  void onServerError(ServerFailure error) { /* toast */ }
  void onNetworkError(String? message) { /* offline banner */ }
  void onTimeoutError(String? message) { /* retry prompt */ }
  void onPermissionError(String? message) { /* access denied */ }
  void onNotFoundError(String? message) { /* not found */ }
  void onDeviceRelatedError(Failure failure) { /* toast */ }
  void onValidationError(ValidationError error) { /* inline field error */ }
  void onAuthenticationError(AuthenticationFailure error) { /* re-login prompt */ }
  void onRemoteConfigError(RemoteConfigFailure error) { /* fallback defaults */ }
  void onGenericError(Failure error) { /* generic toast */ }
}
```

## Crashlytics Reporting

Crashlytics is called directly in cubits/repos, NOT through a Failure property.
Policy implemented via direct crashlytics-service calls where needed.

**Reporting policy (decision table):**

| Failure | Report to Crashlytics? |
|---------|----------------------|
| `UnexpectedFailure` | YES — always |
| `ServerFailure(http500/serverpod)` | YES |
| All other Failures | NO |

```dart
// Actual pattern in AuthCubit:
_crashlyticsService.setUserId(authInfo.authUserId.uuid);
```

Future improvement: Add centralized crashlytics routing via Failure if needed.

## Contextual Error UI

**Decision criteria:**

| Scenario | Pattern |
|----------|---------|
| Global toast (default) | `ErrorActions.onXxx()` via `FailureHandler.handleFailure` |
| Field-adjacent feedback (OTP pin error, form field error) | `*StateSideEffect` union + `BlocSignalPresentationMixin.emitPresentation` + `presentationStream` listener in widget |

**Existing consumers:**
- `HomeCubit` — existing `*StateSideEffect` consumer (reference)
- `LoginCubit` — second consumer landing with Task 1

**Minimal wiring example:**

```dart
// In cubit:
void _onAuthError(Failure failure) {
  _failureHandler.handleFailure(failure); // global toast
  if (failure is AuthenticationFailure && failure.blocked) {
    safeEmit(const LoginState.blocked());
    return;
  }
  emitPresentation(LoginStateOtpError(/* message */)); // contextual side-effect
}

// In widget:
BlocSignalPresentationListener<LoginCubit, LoginStateSideEffect>(
  listener: (context, event) {
    if (event is LoginStateOtpError) {
      otpError.value = event.message;
    }
  },
  child: ...,
)
```

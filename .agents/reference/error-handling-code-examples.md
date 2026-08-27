# Error Handling — Code Examples

> **Note:** This file was cleaned on 2026-08-26 to match actual codebase.
> References to `lastFailure`, `clearLastFailure()`, and `shouldReportToCrashlytics`
> were aspirational features never implemented — references removed.

---

## Failure Subclasses

```dart
@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.unexpected(String? message) = UnexpectedFailure;
  const factory Failure.server(StatusCode code, String? message) = ServerFailure;

  const factory Failure.deviceStorage(String? message) = DeviceStorageFailure;
  const factory Failure.deviceInfo(String? message) = DeviceInfoFailure;
  const factory Failure.authentication(String? message, {@Default(false) bool blocked}) = AuthenticationFailure;
  const factory Failure.validation(ValidationError error, String value) = ValidationFailure;
  const factory Failure.remoteConfig(String? message) = RemoteConfigFailure;
  const Failure._();
}
```

### StatusCode Enum

```dart
enum StatusCode {
  // Client errors (4xx)
  http400(null),
  http401(null),
  http403(null),
  http404(null),
  http408(null),
  http422(null),

  // Server errors (5xx)
  http500(null),
  http502(null),
  http503(null),
  http504(null),

  // Network/system errors
  http000(null),              // Network unavailable / DNS failure
  http999(null),              // Unknown HTTP error

  // Serverpod-specific
  serverpod(null);            // Serverpod RPC error

  const StatusCode(this.value);
  final int? value;
}
```

---

## FailureHandler Implementation

```dart
class FailureHandler with ErrorActions {
  FailureHandler(this._talker);

  final Talker _talker;

  void handleException(Exception error, StackTrace? stackTrace, [ErrorActions? errorActions]) {
    _talker.handle(error, stackTrace);
    handleFailure(Failure.unexpected(error.toString()), errorActions);
  }

  void handleFailure(Failure failure, [ErrorActions? errorActions]) {
    final ErrorActions actions = errorActions ?? this;

    switch (failure) {
      case ServerFailure(:final StatusCode code, :final String? message):
        switch (code) {
          case StatusCode.http000:       actions.onNetworkError(message);
          case StatusCode.http408 || StatusCode.http504:  actions.onTimeoutError(message);
          case StatusCode.http403:       actions.onPermissionError(message);
          case StatusCode.http404:       actions.onNotFoundError(message);
          default:                       actions.onServerError(failure);
        }
      case final DeviceStorageFailure():
      case final DeviceInfoFailure():
        actions.onDeviceRelatedError(failure);
      case final ValidationFailure():
        actions.onValidationError(failure);
      case final RemoteConfigFailure():
        actions.onRemoteConfigError(failure);
      case final AuthenticationFailure():
        actions.onAuthenticationError(failure);
      case final UnexpectedFailure():
        actions.onGenericError(failure);
    }
  }
}
```

---

## ErrorActions Mixin Implementation

> Located per-app:
> - `baktaz_flutter/lib/app/helpers/mixins/error_actions.dart`
> - `baktaz_admin/lib/app/helpers/mixins/error_actions.dart`
>
> **Known drift**: `baktaz_admin` lacks `onAuthenticationError`/`onRemoteConfigError`;
> validation handler differs. Accepted debt.

```dart
mixin ErrorActions {
  void _showErrorOnce(String message) {
    _activeToast = DialogUtils.showError(message);
  }

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

---

## Pattern B: AuthCubit Implementation

```dart
/// ✅ CORRECT — @lazySingleton, initialState: named param, Pattern B error handling
@lazySingleton
class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(this._repository, this._failureHandler) : super(initialState: const AuthState.initial());

  final IAuthRepository _repository;
  final FailureHandler _failureHandler;

  Future<void> login(String phone) async {
    final result = await _repository.login(phone).run();
    result.fold(
      (failure) => _failureHandler.handleFailure(failure),
      (_) => emit(AuthState.otpSent(phone)),
    );
  }

  Future<void> verifyOtp(String otp) async {
    final result = await TaskResult.tryCatch(
      onException: _failureHandler.handleException,
      () async => await _repository.verifyOtp(otp),
    ).run();
    result.fold(
      (failure) => _failureHandler.handleFailure(failure),
      (result) {
        if (result) {
          emit(const AuthState.authenticated());
        } else {
          // Blocked user — contextual side-effect, NOT a state variant
          emitPresentation(AuthStateBlocked());
        }
      },
    );
  }
}
```

---

## Pattern A: Legacy (Forbidden)

```dart
// ❌ FORBIDDEN — Pattern A stores Failure in state
@lazySingleton
class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(this._repository, this._failureHandler) : super(initialState: const AuthState.initial());

  Future<void> login(String phone) async {
    final result = await _repository.login(phone).run();
    // ❌ WRONG: storing Failure object in state
    result.fold(
      (failure) => emit(AuthState.failed(failure)),  // FORBIDDEN
      (_) => emit(AuthState.otpSent(phone)),
    );
  }
}

// ❌ FORBIDDEN — AuthState with Failure field
sealed class AuthState {
  const AuthState();
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.otpSent(String phone) = AuthStateOtpSent;
  const factory AuthState.authenticated() = AuthStateAuthenticated;
  const factory AuthState.failed(Failure failure) = AuthStateFailed; // FORBIDDEN
}
```

---

## safeRun Implementation

```dart
Future<bool> safeRun({
  required Future<void> action(),
  void Function(Exception, StackTrace?)? onException,
}) async {
  try {
    await action();
    return true;
  } on CancelledError catch (_) {
    return false;  // Swallowed silently
  } on Exception catch (error, stackTrace) {
    onException?.call(error, stackTrace);
    return false;
  }
}
```

---

## Server: ApiException

> **FUTURE MIGRATION TARGET — NOT YET IMPLEMENTED.**
> The codebase currently uses raw `Exception` throws in some server endpoints.
> This model is the planned replacement for standardizing server error responses.
> Implement separately when migrating server endpoints to typed error responses.

```dart
@freezed
class ApiException with _$ApiException {
  const factory ApiException({
    required String message,
    required ApiExceptionCode code,
  }) = _ApiException;

  const ApiException._();

  factory ApiException.fromJson(Map<String, dynamic> json) => _$ApiExceptionFromJson(json);
}

enum ApiExceptionCode {
  unauthenticated,  // Missing/invalid session
  notFound,          // Missing data row
  badRequest,        // Validation failed
  internal,          // Server bug
}
```

---

## Crashlytics Reporting Policy

> `shouldReportToCrashlytics` does **not** exist as a property on `Failure`.
> Reporting policy is implemented via direct `crashlytics-service` calls in
> cubits/repos where needed (e.g., `_crashlyticsService.setUserId(...)` in AuthCubit).

### Decision Table

| Failure | Report to Crashlytics? |
|---------|----------------------|
| `UnexpectedFailure` | YES — always |
| `ServerFailure(http500/serverpod)` | YES |
| All other Failures | NO |

### Usage in onException Callback

```dart
onException: (Exception error, StackTrace? stackTrace) {
  _failureHandler.handleException(error, stackTrace);
  // Direct crashlytics call in catch path — no Failure property
  _crashlyticsService.reportException(error, stackTrace);
}
```

---

## Tier-1 Client Error Mapping

Map server exceptions to client `Failure` subtypes at the lowest-level repository:

```dart
// Tier-1: ServerpodException → Failure
TaskResult<AuthResponse> login(String email, String password) async {
  try {
    final response = await _client.auth.signIn(email, password);
    return TaskResult.right(response);
  } on ServerpodException catch (e) {
    return TaskResult.left(_mapException(e));
  }
}

Failure _mapException(ServerpodException e) {
  return switch (e.statusCode) {
    401 => Failure.authentication('Invalid credentials'),
    403 => Failure.authentication('Account blocked', blocked: true),
    404 => Failure.server(StatusCode.http404, 'User not found'),
    _   => Failure.server(StatusCode.serverpod, e.message),
  };
}
```

---

## Error Actions: One-Shot UI Reactions

> NO error state variant exists — failures surface via `FailureHandler.handleFailure`
> side-effects only. Use `BlocSignalPresentationMixin.emitPresentation` for contextual
> errors (field-adjacent feedback), and `ErrorActions.onXxx()` for global toasts.

### Contextual Error via Side-Effect

```dart
// In cubit — emit contextual side-effect, NOT a state variant:
void _onAuthError(Failure failure) {
  _failureHandler.handleFailure(failure); // global toast via ErrorActions
  if (failure is AuthenticationFailure && failure.blocked) {
    emit(const AuthState.blocked());
    return;
  }
  emitPresentation(LoginStateOtpError(/* message */)); // contextual side-effect
}
```

### Widget Listener

```dart
BlocSignalPresentationListener<LoginCubit, LoginStateSideEffect>(
  listener: (context, event) {
    if (event is LoginStateOtpError) {
      // Show field-adjacent error, NOT global toast
      otpError.value = event.message;
    }
  },
  child: ...,
);
```
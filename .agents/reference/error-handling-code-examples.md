# Error Handling — Code Examples

This file contains extracted verbose code examples from the original `error-handling-architecture.md`.

---

## Failure Subclasses

```dart
@freezed
sealed class Failure with _$Failure implements Exception {
  const factory Failure.unexpected(String? message) = UnexpectedError;
  const factory Failure.server(StatusCode code, String? message) = ServerError;
  const factory Failure.deviceStorage(String? message) = DeviceStorageError;
  const factory Failure.deviceInfo(String? message) = DeviceInfoError;
  const factory Failure.authentication(String? message, {@Default(false) bool blocked}) = AuthenticationError;
  const factory Failure.sessionUnavailable() = SessionUnavailableError;
  const factory Failure.validation(String? message) = ValidationError;
  const factory Failure.remoteConfig(String? message) = RemoteConfigError;
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

  late final Failure lastFailure;

  void handleException(Exception error, StackTrace? stackTrace, [ErrorActions? errorActions]) {
    _talker.handle(error, stackTrace);
    handleFailure(Failure.unexpected(error.toString()), errorActions);
  }

  void handleFailure(Failure failure, [ErrorActions? errorActions]) {
    lastFailure = failure;
    final ErrorActions actions = errorActions ?? this;
    switch (failure) {
      case ServerError(:final StatusCode code, :final String? message):
        switch (code) {
          case StatusCode.http000:       actions.onNetworkError(message);
          case StatusCode.http408 || StatusCode.http504:  actions.onTimeoutError(message);
          case StatusCode.http403:       actions.onPermissionError(message);
          case StatusCode.http404:       actions.onNotFoundError(message);
          default:                       actions.onServerError(failure);
        }
      case final DeviceStorageError():
      case final DeviceInfoError():
        actions.onDeviceRelatedError(failure);
      case final ValidationError():
        actions.onValidationError(failure);
      case final RemoteConfigError():
        actions.onRemoteConfigError(failure);
      case final AuthenticationError():
        actions.onAuthenticationError(failure);
      case final SessionUnavailableError():
      case final UnexpectedError():
        actions.onGenericError(failure);
    }
  }
}
```

---

## ErrorActions Mixin Implementation

```dart
// Location: baktaz_shared/lib/src/mixin/error_actions.dart

mixin ErrorActions {
  void _showErrorOnce(String message) {
    _activeToast = DialogUtils.showError(message);
  }

  void onServerError(ServerError error) { /* toast */ }
  void onNetworkError(String? message) { /* offline banner */ }
  void onTimeoutError(String? message) { /* retry prompt */ }
  void onPermissionError(String? message) { /* access denied */ }
  void onNotFoundError(String? message) { /* not found */ }
  void onDeviceRelatedError(Failure failure) { /* toast */ }
  void onValidationError(ValidationError error) { /* inline field error */ }
  void onAuthenticationError(AuthenticationError error) { /* re-login prompt */ }
  void onRemoteConfigError(RemoteConfigError error) { /* fallback defaults */ }
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

  Future<void> login(String email, String password) async {
    final result = await safeRun(
      action: () => _repository.login(email, password),
      onException: _failureHandler.handleException,  // ← handleException wraps in Failure
      onSuccess: () {
        _failureHandler.handleFailure(_failureHandler.lastFailure);  // ← side effect fires here
        emit(const AuthState.failed());
      },
    );
    if (result && _failureHandler.lastFailure == null) {
      emit(const AuthState.loggedIn());
    }
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

  Future<void> login(String email, String password) async {
    final result = await _repository.login(email, password);
    // ❌ WRONG: storing Failure object in state
    result.fold(
      (failure) => emit(AuthState.failed(failure)),  // FORBIDDEN
      (_) => emit(const AuthState.loggedIn()),
    );
  }
}

// ❌ FORBIDDEN — AuthState with Failure field
sealed class AuthState {
  const AuthState();
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loggedIn() = AuthStateLoggedIn;
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

## Crashlytics: shouldReportToCrashlytics

```dart
/// On the Failure sealed class:
const factory Failure.unexpected(String? message) = UnexpectedError;

// Add to each factory:
bool get shouldReportToCrashlytics => switch (this) {
  UnexpectedError() => true,    // Unexpected = bug worth investigating
  ServerError(code: http500) => true,
  ServerError(code: http504) => true,
  ServerError(code: serverpod) => true,
  _ => false,
};
```

### Usage in onException Callback

```dart
onException: (Exception error, StackTrace? stackTrace) {
  _failureHandler.handleException(error, stackTrace);
  if (_failureHandler.lastFailure.shouldReportToCrashlytics) {
    _crashlyticsService.reportException(error, stackTrace);
  }
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

Use `useSignalEffect` for side effects in HookWidget:

```dart
useSignalEffect(() {
  final failure = authCubit.lastFailure;
  if (failure != null) {
    _failureHandler.handleFailure(failure);
    authCubit.clearLastFailure(); // Reset after handling
  }
});
```

Or `BlocSignalListener` in standard widgets:

```dart
BlocSignalListener<AuthCubit, AuthState>(
  listenWhen: (prev, curr) => curr is AuthStateFailed,
  listener: (context, state) {
    _failureHandler.handleFailure(_failureHandler.lastFailure);
  },
  child: ...,
);
```
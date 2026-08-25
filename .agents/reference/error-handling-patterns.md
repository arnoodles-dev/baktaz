# Error Handling Patterns — Code Examples

[Extracted from error-handling-architecture.md — code samples, safeRun, Pattern B]

## safeRun Usage

```dart
safeRun({
  required Future<void> action(),
  required void Function(Exception, StackTrace?) onException,
}) → bool  // true=success, false=failure/cancelled
```

## FailureHandler Example

```dart
class FailureHandler with ErrorActions {
  FailureHandler(this._talker);

  void handleException(Exception error, StackTrace? stackTrace, [ErrorActions? errorActions]) {
    _talker.handle(error, stackTrace);
    handleFailure(Failure.unexpected(error.toString()), errorActions);
  }

  void handleFailure(Failure failure, [ErrorActions? errorActions]) {
    final ErrorActions actions = errorActions ?? this;
    switch (failure) {
      case ServerError(:final StatusCode code, :final message):
        switch (code) {
          case StatusCode.http000:    actions.onNetworkError(message);
          case StatusCode.http408:    actions.onTimeoutError(message);
          case StatusCode.http504:    actions.onTimeoutError(message);
          case StatusCode.http403:    actions.onPermissionError(message);
          case StatusCode.http404:    actions.onNotFoundError(message);
          default:                    actions.onServerError(failure);
        }
      // ... other cases
    }
  }
}
```

## Pattern B — Side-Effect Only

```dart
// ✅ CORRECT
safeRun(
  action: () async => emit(await _repo.login()),
  onException: _failureHandler.handleException,
);
emit(const AuthState.failed()); // generic flag

// ❌ WRONG — Failure in state
emit(AuthState.failed(failure)); // NEVER do this
```

## ErrorActions Override

```dart
class MyErrorActions with ErrorActions {
  @override
  void onServerError(ServerError error) {
    // custom handling
  }
}
```

---
trigger: glob
description: Failure taxonomy, FailureHandler routing, safeRun contract, and Crashlytics reporting
globs: *_flutter/lib/**, *_admin/lib/**, *_shared/lib/**, *_server/lib/**, lib/**
---

# Error Handling Architecture

## Failure Taxonomy

Sealed `Failure` class in `baktaz_shared` with 8 subtypes (all `Error` suffix):

| Failure | When Used |
|---|---|
| `UnexpectedError` | Unknown exceptions |
| `ServerError(StatusCode code, String? message)` | HTTP/RPC errors |
| `DeviceStorageError(String? message)` | Local storage failures |
| `DeviceInfoError(String? message)` | Device info unavailable |
| `AuthenticationError(String? message, {@Default(false}) bool blocked)` | Auth failures |
| `SessionUnavailableError()` | Session expired |
| `ValidationError(String? message)` | Data validation (incl. serialization) |
| `RemoteConfigError(String? message)` | Remote config failures |

## Forbidden Names

- `ServerpodError` → use `ServerError(StatusCode.serverpod, msg)`
- `SerializationError` → use `ValidationError`
- `ValidationFailure` → use `ValidationError`

## FailureHandler Routing

```dart
handleFailure(failure, [ErrorActions?]) → ErrorActions.onXxx()
```

| Failure | Handler |
|---|---|
| `ServerError(StatusCode.http000)` | `onNetworkError` |
| `ServerError(StatusCode.http408)` / `ServerError(StatusCode.http504)` | `onTimeoutError` |
| `ServerError(StatusCode.http403)` | `onPermissionError` |
| `ServerError(StatusCode.http404)` | `onNotFoundError` |
| `ServerError(other/serverpod)` | `onServerError` |
| `DeviceStorageError` / `DeviceInfoError` | `onDeviceRelatedError` |
| `ValidationError` | `onValidationError` |
| `RemoteConfigError` | `onRemoteConfigError` |
| `AuthenticationError` | `onAuthenticationError` |
| `SessionUnavailableError` / `UnexpectedError` | `onGenericError` |


## ErrorActions Mixin

Located in `baktaz_shared/lib/src/mixin/error_actions.dart`.

Override handlers in `FailureHandler with ErrorActions` for custom behavior.

## Side-Effect Pattern (Pattern B)

Errors trigger UI feedback via `FailureHandler.handleFailure` side effect immediately. State stores generic error flag, NOT `Failure` object.

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

## Crashlytics

Only report unexpected/suspected bugs:

| Failure | Report? |
|---|---|
| `UnexpectedError` | ✅ Always |
| `ServerError(http500/serverpod)` | ✅ Yes |
| All others | ❌ No |

Use `shouldReportToCrashlytics` property on `Failure`.

## Server Rules

- All business errors: `ApiException(message:, code:)` — no raw `StateError`/`Exception`
- Wrap module exceptions (`AuthUserBlockedException`) into `ApiException` at repo boundary
- Log unexpected errors at `error` level before wrapping via `Error.throwWithStackTrace`
- Nullable returns: legitimate business absence only — never for auth/missing-data errors

## Reference Docs

See `.agents/reference/`:
- `error-handling-code-examples.md` — full code samples
- `error-handling-checklist.md` — exhaustive verification checklist
- `error-handling-migration.md` — migration guides
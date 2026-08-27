---
trigger: glob
description: Failure taxonomy, FailureHandler routing, safeRun contract, and Crashlytics reporting
globs: *_flutter/lib/**, *_admin/lib/**, *_shared/lib/**, *_server/lib/**, lib/**
---

# Error Handling Architecture

## Failure Taxonomy

Sealed `Failure` class in `baktaz_shared` with 7 subtypes (all `Failure` suffix):

| Failure | When Used |
|---|---|
| `UnexpectedFailure` | Unknown exceptions |
| `ServerFailure(StatusCode code, String? message)` | HTTP/RPC errors (incl. `StatusCode.serverpod` for Serverpod RPC) |
| `DeviceStorageFailure(String? message)` | Local storage failures |
| `DeviceInfoFailure(String? message)` | Device info unavailable |
| `AuthenticationFailure(String? message, {@Default(false)} bool blocked)` | Auth failures |
| `ValidationFailure(ValidationError error, String value)` | Data validation (incl. serialization) |
| `RemoteConfigFailure(String? message)` | Remote config failures |

## Forbidden Names

- `SerializationError` → use `ValidationFailure`

> **Note:** All `Failure` subtypes follow the `XxxFailure` naming convention. `ServerpodFailure` has been merged into `ServerFailure` with `StatusCode.serverpod`.

## FailureHandler Routing

```dart
handleFailure(failure, [ErrorActions?]) → ErrorActions.onXxx()
```

| Failure | Handler |
|---|---|
| `ServerFailure(StatusCode.http000)` | `onNetworkError` |
| `ServerFailure(StatusCode.http408)` / `ServerFailure(StatusCode.http504)` | `onTimeoutError` |
| `ServerFailure(StatusCode.http403)` | `onPermissionError` |
| `ServerFailure(StatusCode.http404)` | `onNotFoundError` |
| `ServerFailure(other)` | `onServerError` |
| `DeviceStorageFailure` / `DeviceInfoFailure` | `onDeviceRelatedError` |
| `ValidationFailure` | `onValidationError` |
| `RemoteConfigFailure` | `onRemoteConfigError` |
| `AuthenticationFailure` | `onAuthenticationError` |
| `UnexpectedFailure` | `onGenericError` |


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
| `UnexpectedFailure` | ✅ Always |
| `ServerFailure(http500/serverpod)` | ✅ Yes |
| All others | ❌ No |

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
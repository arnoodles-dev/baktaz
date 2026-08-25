# Error Handling — Migration Guide

This file contains extracted migration content from the original `error-handling-architecture.md`.

---

## Name Changes

| Old Name | New Name | Notes |
|---|---|---|
| `ValidationFailure` | `ValidationError` | Both represent "data didn't match expected format" |
| `SerializationError` | `ValidationError` | Merged — serialization is a form of validation |
| `ServerpodError` | `ServerError(StatusCode.serverpod, msg)` | Same conceptual failure, different transport |

---

## Pattern Migration

### Pattern A → Pattern B

Pattern A stored `Failure` in state. Pattern B uses side effects only.

**Before (Pattern A — Forbidden):**
```dart
// ❌ WRONG
class AuthCubit extends CubitSignal<AuthState> {
  Future<void> login() async {
    final result = await _repo.login();
    result.fold(
      (failure) => emit(AuthState.failed(failure)), // storing Failure in state
      (_) => emit(const AuthState.loggedIn()),
    );
  }
}

sealed class AuthState {
  const factory AuthState.failed(Failure failure) = AuthStateFailed; // FORBIDDEN
}
```

**After (Pattern B — Required):**
```dart
// ✅ CORRECT
class AuthCubit extends CubitSignal<AuthState> {
  Future<void> login() async {
    await safeRun(
      action: () async => emit(await _repo.login()),
      onException: _failureHandler.handleException,
    );
    // Side effect fires immediately via handleException → handleFailure
    // State stores generic flag only
    emit(const AuthState.failed()); // no Failure parameter
  }
}

sealed class AuthState {
  const factory AuthState.failed() = AuthStateFailed; // generic flag only
}
```

---

## Server Exception Migration

### Raw Throws → ApiException

**Before (Forbidden):**
```dart
// ❌ WRONG
Future<User?> getUser(int id) async {
  final user = await db.query(id);
  if (user == null) {
    throw StateError('User not found'); // opaque 500 to client
  }
  return user;
}
```

**After (Required):**
```dart
// ✅ CORRECT
Future<User?> getUser(int id, Session session) async {
  final user = await db.query(id);
  if (user == null) {
    throw ApiException(message: 'User not found', code: ApiExceptionCode.notFound);
  }
  return user;
}
```

### Module Exceptions → ApiException

**Before (Forbidden):**
```dart
// ❌ WRONG — module exception crosses the wire
throw AuthUserBlockedException(userId);
```

**After (Required):**
```dart
// ✅ CORRECT — wrapped at repo boundary
try {
  await _authService.verifyUser(userId);
} on AuthUserBlockedException catch (e) {
  throw ApiException(
    message: 'Account blocked',
    code: ApiExceptionCode.unauthenticated,
  );
}
```

---

## Tier-1 Client Error Mapping

Map server exceptions to client `Failure` subtypes at the lowest-level repository:

```dart
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

## Big-Bang Server Migration

The server error migration should be done as a single big-bang PR:

1. Add `ApiException` model + `ApiExceptionCode` enum
2. Create migration for model
3. Fix all endpoints to use `ApiException`
4. Update client Tier-1 mapping
5. Verify old client compatibility (unknown serializable types degrade to generic exceptions)
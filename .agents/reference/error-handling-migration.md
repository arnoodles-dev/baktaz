# Error Handling — Migration Guide

> **Status as of 2026-08-26:**
> - `ApiException` model: NOT YET IMPLEMENTED
> - `lastFailure` property: REMOVED (never implemented)

This file contains extracted migration content from the original `error-handling-architecture.md`.

---

## Name Changes

All `Failure` subtypes follow the `XxxFailure` naming convention. No `{T}Error` suffix aliases remain.

---

## Pattern Migration

### Pattern A → Pattern B (Side-Effect Only)

Pattern A stored `Failure` in state. Pattern B uses side effects only — NO error state variant exists. Failures surface via `FailureHandler.handleFailure` (global toast) or `*StateSideEffect` + `emitPresentation` + `presentationStream` listener (contextual error UI).

**Before (Pattern A — Forbidden):**
```dart
// ❌ WRONG — storing Failure in state
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

**After (Pattern B — Required) — Global toast via FailureHandler:**
```dart
// ✅ CORRECT — FailureHandler routes to ErrorActions (global toast)
@injectable
interface class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(this._repo, this._failureHandler);

  final IAuthRepository _repo;
  final FailureHandler _failureHandler;

  Future<void> login() async {
    await safeRun(
      action: () async {
        final result = await _repo.login();
        result.fold(
          (failure) => _failureHandler.handleFailure(failure),
          (_) => emit(const AuthState.loggedIn()),
        );
      },
      onException: _failureHandler.handleException,
    );
  }
}

// State — NO error variant, NO Failure parameter
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loggedIn() = AuthStateLoggedIn;
  // NO failed variant — errors are side effects only
}
```

**After (Pattern B — Required) — Contextual error UI via `emitPresentation`:**

For errors that need inline/contextual feedback (e.g., OTP pin error, field-adjacent error):

```dart
// State side-effect union (freezed sealed class)
@freezed
sealed class AuthStateSideEffect with _$AuthStateSideEffect {
  const factory AuthStateSideEffect.otpError(String message) = AuthStateOtpError;
  const factory AuthStateSideEffect.onException(Exception e) = AuthStateException;
}

// Cubit — emits contextual error as presentation event
@injectable
interface class AuthCubit extends CubitSignal<AuthState>
    with BlocSignalPresentationMixin<AuthStateSideEffect, AuthState> {
  AuthCubit(this._repo, this._failureHandler);

  final IAuthRepository _repo;
  final FailureHandler _failureHandler;

  void verifyOtp(String code) {
    safeRun(
      action: () async {
        final result = await _repo.verifyOtp(code);
        result.fold(
          (failure) => _failureHandler.handleFailure(failure),
          (user) => emit(AuthState.authenticated(user)),
        );
      },
      onException: _failureHandler.handleException,
    );
    // Contextual error: emit via presentation stream, not state
    emitPresentation(const AuthStateSideEffect.otpError('Invalid OTP code'));
  }
}

// Widget — listens to presentationStream for contextual errors
useEffect(() {
  final AuthCubit cubit = context.read<AuthCubit>();
  final StreamSubscription<AuthStateSideEffect> sub =
      cubit.presentationStream.listen((AuthStateSideEffect sideEffect) {
    if (context.mounted) {
      switch (sideEffect) {
        case AuthStateOtpError(:final String message):
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        case AuthStateException(:final Exception e):
          getIt<FailureHandler>().handleException(e, null);
      }
    }
  });
  return sub.cancel;
}, <Object?>[]);
```

---

## Server Exception Migration

> **⚠️ FUTURE MIGRATION TARGET — not yet implemented.** The `ApiException` model and `ApiExceptionCode` enum do not exist yet. Server endpoints currently throw raw `Exception` / `StateError`. This section describes the target state.

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

> **⚠️ FUTURE — not yet implemented.** Describes the planned migration to `ApiException`.

The server error migration should be done as a single big-bang PR:

1. Add `ApiException` model + `ApiExceptionCode` enum
2. Create migration for model
3. Fix all endpoints to use `ApiException`
4. Update client Tier-1 mapping
5. Verify old client compatibility (unknown serializable types degrade to generic exceptions)
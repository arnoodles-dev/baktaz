# Flutter Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Flutter-specific audit violations: Pattern-B state, i18n localization, HookWidget conversion, BlocSignalProvider compliance.

**Tech Stack:** Flutter 3.47+, bloc_signals, slang, freezed, mockito.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md`.

---

### Task 1: LoginState Pattern-B fix (no Failure in state)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_state.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart:114-122`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/login_email_screen.dart:30-33`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/otp_verification_screen.dart:45-47`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart:40-43`
- Test: `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_state_test.dart` (create)
- Test: `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_failure_test.dart` (create)

**Interfaces:**
- Consumes: `FailureHandler.handleFailure(Failure)` (existing lazySingleton), mockito mocks from `generated_mocks.dart`.
- Produces: `LoginState.failed()` — parameterless variant. All downstream handlers change arity from `(Failure)` to `()`.

- [ ] **Step 1: Write failing state-shape test**

Create `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_state_test.dart`:
```dart
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginState', () {
    test('failed variant carries no Failure payload (Pattern B)', () {
      const LoginState state = LoginState.failed();

      expect(state, isA<LoginState>());
      expect(state.toString(), isNot(contains('Failure')));
      expect(state.toString(), equals('LoginState.failed()'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd baktaz_flutter && fvm flutter test test/unit/features/auth/domain/cubit/login_cubit_state_test.dart`
Expected: FAIL — compile error (current signature requires `Failure failure`).

- [ ] **Step 3: Change state factory**

In `login_state.dart` replace:
```dart
  const factory LoginState.failed(Failure failure) = LoginStateFailed;
```
with:
```dart
  const factory LoginState.failed() = LoginStateFailed;
```

- [ ] **Step 4: Regenerate freezed**

Run: `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: BUILD SUCCEEDED.

- [ ] **Step 5: Update cubit emitter**

In `login_cubit.dart` replace `_onAuthError`:
```dart
  void _onAuthError(Failure failure) {
    _failureHandler.handleFailure(failure);
    if (failure is AuthenticationError && failure.blocked) {
      safeEmit(const LoginState.blocked());
      return;
    }
    safeEmit(const LoginState.failed());
  }
```

- [ ] **Step 6: Update screen listeners**

`login_email_screen.dart`: replace `failed: (Failure failure) { ... }` with `failed: () => context.loaderOverlay.hide(),`
`otp_verification_screen.dart`: same pattern
`registration_screen.dart`: same pattern
`login_screen.dart`: change `failed: (_) => ...` to `failed: () => ...`

- [ ] **Step 7: Write behavior test**

Create `baktaz_flutter/test/unit/features/auth/domain/cubit/login_cubit_failure_test.dart` with tests verifying:
- `LoginState.failed()` emitted on auth error
- `FailureHandler.handleFailure` called once
- Blocked auth routes to `LoginState.blocked()`

- [ ] **Step 8: Run tests + analyze**

Run: `cd baktaz_flutter && fvm flutter test test/unit/features/auth/domain/cubit/ && fvm dart analyze`
Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git commit -m "refactor(flutter): enforce Pattern B — LoginState.failed carries no Failure payload"
```

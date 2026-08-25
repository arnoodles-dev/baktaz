# Comprehensive Rules Audit + Error Handling Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remediate all 2026-08-26 rule audit violations AND clean up error-handling reference docs to match actual codebase state.

**Architecture:** Flutter monorepo (baktaz_flutter client, baktaz_admin dashboard, baktaz_shared design system, baktaz_server Serverpod backend). State = `CubitSignal<S>` (bloc_signals), repos return `TaskResult<T>` (fpdart), errors routed through sealed `Failure` → `FailureHandler.handleFailure` side-effects (Pattern B — state never stores `Failure`). Localization via slang (`assets/i18n/en.i18n.json` → `lib/app/generated/localization.g.dart`). Design tokens in `AppSizes`.

**Tech Stack:** Flutter 3.47+, Dart ≥3.13, Serverpod 2.x/4.0.0-beta.3 auth modules, bloc_signals, fpdart, freezed, injectable, slang, mockito, Alchemist goldens.

**Spec:** Audit report 2026-08-26 (session memory) + `.agents/rules/*.md` + `.agents/reference/error-handling-*.md`.

## Global Constraints

- Use `fvm` for all flutter/dart commands: `fvm flutter test`, `fvm dart analyze`.
- Lints: `very_good_analysis` + DCM, treat infos as fatal. Width 120 chars.
- Functions < 50 lines, files ≤ 800 lines, nesting ≤ 4 levels, ≤ 5 params.
- Codegen order ALWAYS: 1) `fvm dart run slang` 2) `fvm dart run build_runner build --delete-conflicting-outputs` 3) `serverpod generate` (only when `.spy.yaml` changed).
- Never edit generated files: `*.g.dart`, `*.freezed.dart`, `gen/`.
- Tests: mockito only (never mocktail); mocks registered in `baktaz_flutter/test/utils/generated_mocks.dart`; AAA naming like `emits failed state without Failure payload when repo returns left`.
- Coverage: overall ≥80%, Cubit/Repo 100%.
- No hardcoded user-facing strings outside `*_server`; use `context.i18n.*` (slang).
- Commits: conventional `<type>: <description>`; commit after every passing task.
- Worktree: execute in isolated git worktree created via superpowers:using-git-worktrees.

---

## Phase 1: Rule Audit Violations Fix (from 2026-08-26 plan)

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

---

### Task 2: Localize challenge/message/common strings (slang batch A)

**Files:**
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json`
- Modify: `baktaz_flutter/lib/features/challenge/presentation/views/pages/challenge_page.dart:19-20`
- Modify: `baktaz_flutter/lib/features/message/presentation/views/chat_page.dart:10-11`
- Modify: `baktaz_flutter/lib/features/message/presentation/views/notification_page.dart:10-11`
- Test: `baktaz_flutter/test/unit/localization_keys_test.dart` (create)

- [ ] **Step 1: Add keys to en.i18n.json**

Add to `common`:
```json
"discover_new": "Discover what's new on the app",
"confirm": "Confirm"
```

Add new namespaces:
```json
"challenge": {
  "history": "Challenge History",
  "nothing_happening_now": "Nothing's happening now",
  "no_activity": "No Activity"
},
"messages": {
  "find_chats": "Find your chats here!",
  "notifications_placeholder": "Notifications will appear here",
  "notifications_subtitle": "Watch this space for offers, updates, and more."
}
```

Extend `select_address`:
```json
"address_selection": "Address Selection"
```

- [ ] **Step 2: Regenerate slang**

Run: `cd baktaz_flutter && fvm dart run slang`

- [ ] **Step 3: Write test**

Create `baktaz_flutter/test/unit/localization_keys_test.dart` verifying all new keys.

- [ ] **Step 4: Swap hardcoded strings** in challenge_page, chat_page, notification_page.

- [ ] **Step 5: Verify + commit**

```bash
git commit -m "fix(flutter): localize challenge/message/common strings"
```

---

### Task 3: Localize remaining flutter strings (batch B)

**Files:**
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json`
- Modify: `challenge_history_screen.dart`, `review_screen.dart`, `contact_screen.dart`, `dark_mode_screen.dart`, `select_address_screen.dart`
- Test: extend `localization_keys_test.dart`

- [ ] **Step 1-6:** Add keys, regenerate, test, swap call-sites, verify, commit.

```bash
git commit -m "fix(flutter): localize remaining hardcoded strings"
```

---

### Task 4: PopupMenuButton → MenuAnchor (admin)

**Files:**
- Modify: `baktaz_admin/lib/features/remote_config/presentation/widgets/parameter_table.dart:165-220`

- [ ] **Step 1:** Replace `PopupMenuButton<SortCriteria>` with `MenuAnchor` + `_SortMenuItem` widget.
- [ ] **Step 2:** Analyze.
- [ ] **Step 3:** Commit.

```bash
git commit -m "refactor(admin): migrate PopupMenuButton to Material 3 MenuAnchor"
```

---

### Task 5: Typed RemoteConfigState

**Files:**
- Create: `baktaz_flutter/lib/core/domain/cubit/remote_config/remote_config_state.dart`
- Modify: `remote_config_cubit.dart`
- Modify: `registration_screen.dart:56,137-138`
- Modify: `support_webview_screen.dart:20`
- Test: `remote_config_state_test.dart`

- [ ] **Step 1-6:** Implement typed state, update callers, test, commit.

```bash
git commit -m "refactor(flutter): typed RemoteConfigState replaces raw Map state"
```

---

### Task 6: HomeWeeklyStepsChart → HookWidget

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart`
- Modify: `home_weekly_steps_chart.dart`

- [ ] **Step 1:** Add `AppSizes.chartBarAreaHeight = 120`.
- [ ] **Step 2:** Convert to HookWidget with `useState<int?>(null)`.
- [ ] **Step 3-4:** Verify, commit.

```bash
git commit -m "refactor(flutter): HomeWeeklyStepsChart to HookWidget, extract chart height token"
```

---

### Task 7: Server param-count fixes (RegistrationForm model)

**Files:**
- Create: `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`
- Modify: `auth_endpoint.dart`, `i_auth_repository.dart`, `auth_repository.dart`, `auth_utils.dart`
- Run: `serverpod generate`

- [ ] **Step 1-9:** Create model, regenerate, update callers, verify, commit.

```bash
git commit -m "refactor(server): promote RegistrationForm to Serverpod model, fix param counts"
```

---

### Task 8: BaktazTextField complexity (merge duplicate branches)

**Files:**
- Modify: `baktaz_shared/lib/src/widgets/baktaz_text_field.dart:116-215`

- [ ] **Step 1-3:** Merge email/normal arms, verify, commit.

```bash
git commit -m "refactor(shared): collapse BaktazTextField duplicate TextField branches"
```

---

### Task 9: BlocSignalProvider annotation compliance

**Files:**
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart:37-38`

- [ ] **Step 1-5:** Fix AccountCubit + HomeCubit to use `create:`, verify all providers match annotations, commit.

```bash
git commit -m "refactor: ensure BlocSignalProvider matches Cubit annotations"
```

---

### Task 10: Admin magic numbers → named constants

**Files:**
- Modify: `baktaz_shared/lib/src/theme/app_sizes.dart`
- Modify: 6 admin widget files

- [ ] **Step 1-5:** Add tokens, swap call-sites, verify, commit.

```bash
git commit -m "fix(admin): extract magic dimensions into named constants"
```

---

## Phase 2: Error Handling Docs Cleanup

### Task 11: Clean up error-handling-patterns.md

**Files:**
- Modify: ` .agents/reference/error-handling-patterns.md`

**Issues to fix:**
1. Typos: `errorActions? This` → `errorActions ?? this`
2. Fix switch case indentation
3. Add all 8 Failure subtypes to example
4. Remove `//. Other cases` comment
5. Fix `safeRun` signature to match actual API
6. Add removal note at top

- [ ] **Step 1: Rewrite file with correct content**

```markdown
# Error Handling Patterns — Code Examples

> **Note:** This file was cleaned on 2026-08-26 to match actual codebase.
> Removed references to non-existent features: `lastFailure`, `clearLastFailure()`,
> `shouldReportToCrashlytics`. These were aspirational designs never implemented.

## Failure Taxonomy

Sealed `Failure` class in `baktaz_shared` with 8 subtypes (all `Error` suffix):

| Failure | Constructor | When Used |
|---|---|---|
| `UnexpectedError` | `Failure.unexpected(String? message)` | Unknown exceptions |
| `ServerError` | `Failure.server(StatusCode code, String? message)` | HTTP/RPC errors |
| `ServerpodError` | `Failure.serverpod(String? message)` | Serverpod RPC errors |
| `DeviceStorageError` | `Failure.deviceStorage(String? message)` | Local storage failures |
| `DeviceInfoError` | `Failure.deviceInfo(String? message)` | Device info unavailable |
| `AuthenticationError` | `Failure.authentication(String? message, {bool blocked = false})` | Auth failures |
| `SessionUnavailableError` | `Failure.sessionUnavailable()` | Session expired |
| `ValidationFailure` | `Failure.validation(ValidationError error, String value)` | Data validation |
| `RemoteConfigError` | `Failure.remoteConfig(String? message)` | Remote config failures |

## FailureHandler Routing

`handleFailure(failure, [ErrorActions?])` → routes to `ErrorActions.onXxx()`:

| Failure | Handler |
|---|---|
| `ServerError(http000)` | `onNetworkError` |
| `ServerError(http408)` / `ServerError(http504)` | `onTimeoutError` |
| `ServerError(http403)` | `onPermissionError` |
| `ServerError(http404)` | `onNotFoundError` |
| `ServerError(other/serverpod)` | `onServerError` |
| `DeviceStorageError` / `DeviceInfoError` | `onDeviceRelatedError` |
| `ValidationFailure` | `onValidationError` |
| `RemoteConfigError` | `onRemoteConfigError` |
| `AuthenticationError` | `onAuthenticationError` |
| `SessionUnavailableError` / `UnexpectedError` | `onGenericError` |

## Pattern B — Side-Effect Only

```dart
// ✅ CORRECT — state stores generic flag, Failure routed to side-effect
safeRun(
  action: () async => emit(await _repo.login()),
  onException: _failureHandler.handleException,
);
emit(const AuthState.failed()); // generic flag only

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

Located in `baktaz_flutter/lib/app/helpers/mixins/error_actions.dart`.

```dart
mixin ErrorActions {
  void onServerError(ServerError error) { /* toast */ }
  void onNetworkError(String? message) { /* offline banner */ }
  void onTimeoutError(String? message) { /* retry prompt */ }
  void onPermissionError(String? message) { /* access denied */ }
  void onNotFoundError(String? message) { /* not found */ }
  void onDeviceRelatedError(Failure failure) { /* toast */ }
  void onValidationError(ValidationFailure error) { /* inline field error */ }
  void onAuthenticationError(AuthenticationError error) { /* re-login prompt */ }
  void onRemoteConfigError(RemoteConfigError error) { /* fallback defaults */ }
  void onGenericError(Failure error) { /* generic toast */ }
}
```

## Crashlytics Reporting

Crashlytics is called directly in cubits/repos, NOT through a Failure property.
The `shouldReportToCrashlytics` property referenced in older docs does NOT exist.

```dart
// Actual pattern in AuthCubit:
_crashlyticsService.setUserId(authInfo.authUserId.uuid);
```

Future improvement: Add centralized crashlytics routing via Failure if needed.
```
```

- [ ] **Step 2: Verify file syntax**

Run: `rtk head -20 .agents/reference/error-handling-patterns.md`
Expected: Clean markdown with correct syntax.

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: clean error-handling-patterns.md to match actual codebase"
```

---

### Task 12: Clean up error-handling-code-examples.md

**Files:**
- Modify: `.agents/reference/error-handling-code-examples.md`

**Issues to fix:**
1. Remove all `lastFailure` / `clearLastFailure()` references (don't exist)
2. Fix `Failure.validation(String? message)` → `Failure.validation(ValidationError error, String value)`
3. Label `ApiException` as "FUTURE MIGRATION TARGET — NOT YET IMPLEMENTED"
4. Fix StatusCode enum examples to match actual `status_code.dart`

- [ ] **Step 1: Rewrite file**

Replace entire content with cleaned version that:
- Has correct `Failure.validation` signature
- Removes all `lastFailure` references
- Labels `ApiException` clearly as future
- Matches actual `StatusCode` enum values

- [ ] **Step 2: Verify no dead references remain**

Run: `rtk grep -rn "lastFailure\|clearLastFailure\|shouldReportToCrashlytics" .agents/reference/`
Expected: zero matches.

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: fix error-handling-code-examples.md to match actual Failure API"
```

---

### Task 13: Clean up error-handling-migration.md

**Files:**
- Modify: `.agents/reference/error-handling-migration.md`

**Issues to fix:**
1. Add clear banner: "ApiException migration is FUTURE WORK — not yet implemented"
2. Remove any references to `lastFailure`
3. Clarify that `ValidationFailure` was renamed to match actual code

- [ ] **Step 1: Add migration banners**

At top of file add:
```markdown
> **STATUS:** This guide describes FUTURE migration targets.
> - `ApiException` model: NOT YET IMPLEMENTED
> - `lastFailure` property: REMOVED (never implemented)
> - `shouldReportToCrashlytics`: REMOVED (never implemented)
```

- [ ] **Step 2: Verify**

Run: `rtk grep -rn "lastFailure\|shouldReportToCrashlytics" .agents/reference/error-handling-migration.md`
Expected: zero matches.

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: label ApiException migration as future work"
```

---

### Task 14: Clean up error-handling-checklist.md

**Files:**
- Modify: `.agents/reference/error-handling-checklist.md`

**Issues to fix:**
1. Remove `lastFailure` checklist items
2. Remove `shouldReportToCrashlytics` checklist items
3. Add note about actual crashlytics pattern (direct in cubits)

- [ ] **Step 1: Rewrite checklist**

Replace all references to non-existent features with actual patterns.

- [ ] **Step 2: Verify**

Run: `rtk grep -rn "lastFailure\|shouldReportToCrashlytics" .agents/reference/error-handling-checklist.md`
Expected: zero matches.

- [ ] **Step 3: Commit**

```bash
git commit -m "docs: fix error-handling-checklist.md to match actual codebase"
```

---

### Task 15: Fix error-handling-architecture.md rule doc

**Files:**
- Modify: `.agents/rules/error-handling-architecture.md`

**Issues to fix:**
1. Fix `{@Default(false})` → `{@Default(false)}` typo (line 19)
2. Fix `ValidationError(String? message)` → `ValidationError(ValidationError error, String value)` (line 21)
3. Remove line 82: `Use shouldReportToCrashlytics property on Failure.`
4. Fix any other typos

- [ ] **Step 1: Fix typos**

Line 19: Change `{@Default(false})` to `{@Default(false)}`
Line 21: Change `ValidationError(String? message)` to `ValidationError(ValidationError error, String value)`

- [ ] **Step 2: Remove shouldReportToCrashlytics reference**

Delete line 82 entirely.

- [ ] **Step 3: Verify**

Run: `rtk grep -rn "shouldReportToCrashlytics" .agents/rules/error-handling-architecture.md`
Expected: zero matches.

- [ ] **Step 4: Commit**

```bash
git commit -m "docs: fix typos in error-handling-architecture.md rule"
```

---

### Task 16: Remove orphaned onSocketException handler

**Files:**
- Modify: `baktaz_flutter/lib/app/helpers/mixins/error_actions.dart`

**Issue:** `onSocketException()` is defined but never called (no `SocketFailure` subtype exists).

- [ ] **Step 1: Remove orphaned method**

Delete lines 51-54:
```dart
  void onSocketException() {
    getIt<AuthCubit>().terminateSession(isLogout: false);
  }
```

- [ ] **Step 2: Verify no callers remain**

Run: `rtk grep -rn "onSocketException" baktaz_flutter/lib/ baktaz_admin/lib/`
Expected: zero matches.

- [ ] **Step 3: Analyze + commit**

```bash
cd baktaz_flutter && fvm dart analyze
git commit -m "refactor: remove orphaned onSocketException handler"
```

---

## Final Verification

After ALL tasks complete:

1. Monorepo analyze: `melos exec -- fvm dart analyze`
2. Suites: `make test_flutter`, `make test_admin`; `make test_server` if Postgres up
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty
4. Grep gates:
   - `rtk grep -rn "PopupMenuButton" baktaz_admin/lib` → zero
   - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero
   - `rtk grep -rn "lastFailure\|shouldReportToCrashlytics" .agents/` → zero
5. Update `.coverage_exclude` if new test utils appear

## Accepted Deviations

- `auth_endpoint.completeRegistration` signature changes to `(Session, RegistrationForm)` — requires `serverpod generate` for client. Documented as required deviation.
- Server `throw Exception()` in `session_ext.dart` and `admin_endpoint.dart` — future `ApiException` migration (separate plan).
- `connectivity_checker` instance-constructor stays 4-param compliant.
- Serverpod `return null` endpoints (NP1/NP2) — legitimate business absence per error-handling rules.

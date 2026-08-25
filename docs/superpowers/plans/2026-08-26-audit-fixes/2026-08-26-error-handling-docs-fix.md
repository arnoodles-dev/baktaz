# Error Handling Docs Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Clean up 4 error-handling reference docs + 1 rule doc to match actual codebase state. Remove references to non-existent features (`lastFailure`, `shouldReportToCrashlytics`), fix typos, label future migrations clearly.

**Architecture:** Flutter monorepo with sealed `Failure` class, `FailureHandler` pattern, `ErrorActions` mixin. Reference docs in `.agents/reference/` and rules in `.agents/rules/`.

**Tech Stack:** Markdown, Dart (for verification), grep.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints.

## Global Constraints

- No code changes — documentation only
- Verify with grep: `rtk grep -rn "lastFailure\|shouldReportToCrashlytics" .agents/` → zero matches
- Commit after each task
- Cross-reference parent plan for context

---

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

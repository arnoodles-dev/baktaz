# Error Handling — Verification Checklist

This file contains extracted checklists from the original `error-handling-architecture.md`.

---

## Pre-flight Checks

Before considering error handling complete, verify:

### Failure Design
- [ ] New failure uses existing subtype (check StatusCode first for server-related)
- [ ] Subtype name follows `XxxError` suffix rule
- [ ] No `ServerpodError`, `SerializationError`, or `ValidationFailure` references remain

### Client (Flutter)
- [ ] Async repo calls wrapped in `safeRun(action:, onException:)`
- [ ] `onException` omitted ONLY when cubit needs no UI feedback (background work)
- [ ] No exception thrown past `safeRun` boundary
- [ ] `CancelledError` handled silently (no toast on widget dispose)
- [ ] `safeEmit` replaced with plain `emit`

### FailureHandler
- [ ] `FailureHandler.handleFailure` used (not direct `ErrorActions` calls)
- [ ] Single error path — no double-handling in callbacks
- [ ] `lastFailure` cleared after consumption

### State Design
- [ ] State classes contain NO `Failure` fields
- [ ] Error states are generic flags (`AuthState.failed()` not `failed(failure)`)

### Repositories
- [ ] `TaskResult<T>` returned, never thrown
- [ ] `TaskResult.tryCatch` used for all fallible operations
- [ ] `ServerpodException` mapped to `Failure` at repo boundary

### Testing
- [ ] Test verifies `handleFailure` called with exact `Failure` subtype
- [ ] Test verifies state transitions to generic error flag
- [ ] Mock repository stubbed with `TaskEither.left(Failure.xxx)`

### Crashlytics
- [ ] `shouldReportToCrashlytics` checked before reporting
- [ ] Only `UnexpectedError`, `ServerError(http500)`, `ServerError(http504)`, `ServerError(serverpod)` reported
- [ ] Expected failures (validation, auth, device) NOT reported

---

## Client Violations

| # | Violation | Fix |
|---|---|---|
| 1 | Double-handling: `handleException` + `_emitError` in same callback | Use single path: `onException: _failureHandler.handleException` |
| 2 | Storing `Failure` object in state (`AuthState.failed(failure)`) | Pattern B: side-effect only, state holds generic flag |
| 3 | `_emitError` helpers storing Failure in state | Replace with `safeRun` + `handleFailure` side effect |
| 4 | Throwing exceptions from cubit methods | Wrap in `safeRun(onException:)` |
| 5 | Catching `ServerpodException` in `FailureHandler`/cubits | Map at repo layer only |
| 6 | Creating new `Failure` subtypes without `Error` suffix | Naming rule: sealed base `Failure`, subtypes `XxxError` |
| 7 | Direct `ErrorActions` calls from cubits | Route through `FailureHandler` |
| 8 | Blanket Crashlytics reporting for all failures | Conditional via `shouldReportToCrashlytics` |
| 9 | `kDebugMode` checks outside `onGenericError` | Debug-only logic stays in one place |
| 10 | Using `safeEmit` | Replace with plain `emit` |

---

## Server Violations

| # | Violation | Fix |
|---|---|---|
| 11 | Throwing raw `StateError`/`Exception`/`ArgumentError` from server endpoints/repos | Use serializable `ApiException(code:)` — raw throws = opaque 500s |
| 12 | Letting module exceptions (`AuthUserBlockedException` etc.) cross the wire unwrapped | Wrap into `ApiException` at repo boundary |

---

## Server Testing Checklist

- [ ] All business errors thrown as `ApiException(message:, code:)` — no raw `StateError`/`Exception`/`ArgumentError`
- [ ] `ApiExceptionCode` used correctly (`unauthenticated` for missing session, `notFound` for missing data rows)
- [ ] Unexpected errors logged at `error` level before wrapping via `Error.throwWithStackTrace`
- [ ] Module exceptions wrapped into `ApiException` at repo boundary
- [ ] Nullable returns ONLY for legitimate business absence — never to mask unauthenticated/missing-data
- [ ] Endpoints are thin pass-through — no manual auth checks duplicating `requireLogin`/`requiredScopes`
- [ ] No PII in logs (emails, model JSON) — identifiers only
- [ ] Server test asserts: exception type + `code` field + sanitized message (no internals)

---

## Migration Checklist

- [ ] `safeEmit` calls replaced with plain `emit`
- [ ] Old `Failure.serverpod(...)` calls replaced with `Failure.server(StatusCode.serverpod, ...)`
- [ ] Old `ValidationFailure` renamed to `ValidationError`
- [ ] Old serialization catch-blocks now throw `ValidationError`
- [ ] Server violations migrated big-bang: single PR with ApiException model + migration + all fixes + client Tier-1 mapping
- [ ] Old client compatibility verified: unknown serializable types degrade to generic exceptions (no regression vs opaque 500)
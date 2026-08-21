# Email OTP Login & Registration — Design Spec

**Date**: 2026-08-20
**Status**: Approved for implementation planning
**Scope**: baktaz_flutter, baktaz_server, baktaz_shared

---

## 1. Overview

Replace mobile-number-based authentication with **passwordless email OTP login**:

```
Email input → OTP sent to email → OTP verification →
  ├─ Existing user → authenticated → App
  └─ New user → Profile setup (name, gender, dob) → authenticated → App
```

- Mobile login remains in codebase (no removal) — the existing `LoginMobileScreen` flow is **reused and adapted** for the email case.
- Registration flow: skip address (`SelectAddressScreen` remains a stub, not in this flow).

## 2. Goals / Non-Goals

**Goals**
- Passwordless email OTP sign-in via custom Serverpod endpoint.
- OTP length 6 digits, configurable expiry (default 5 min), configurable rate limit (default 3 sends/hour/email).
- New-user detection after OTP verification; route to profile setup (name, gender, dob).
- Auto-authenticate after profile setup.

**Non-Goals**
- No address collection (SelectAddressScreen stays stub).
- No password-based auth for this flow.
- No removal of mobile login code paths.
- No email service integration for MVP dev — OTP logged to server console in dev mode. Email sending via `mailer` (SendGrid/SMTP) behind a provider interface for production.

## 3. Server Design

### 3.1 OTP Endpoint

File: `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart`

```dart
class OtpEndpoint extends Endpoint {
  /// Sends (or in dev logs) an OTP code to the given email.
  /// Rate-limited per email per hour.
  Future<void> sendOtp(Session session, {required String email});

  /// Verifies the OTP. Returns whether the email belongs to an existing
  /// account and, if so, an authenticated session (AuthSuccess).
  Future<OtpVerificationResult> verifyOtp(Session session, {
    required String email,
    required String code,
  });
}
```

### 3.2 Result Model

`.spy.yaml` model (server + client codegen):

```yaml
class: OtpVerificationResult
table: none
fields:
  isNewUser: bool
  authInfo: AuthSuccess?  # null when isNewUser == true
```

`AuthSuccess` already exists in Serverpod auth core.

### 3.3 OTP Storage & Generation

- **Storage**: `session.caches.local` with key `otp:$email`, TTL = `OtpConfig.expiry`.
- **Generation**: `dart:math` secure random, `OtpConfig.length` digits (default 6).
- **Delivery**: `IEmailService` provider interface:
  - `DevelopmentEmailService` — logs OTP via `session.log` (visible in `tail_server_logs`).
  - `ProductionEmailService` — real send via `mailer` (SendGrid/SMTP), implemented later; wire in config.

### 3.4 Rate Limiting

`session.caches.local` key `otp:rate:$email` storing send count within the current hour window, TTL 1 hour. Requests above `OtpConfig.maxSendsPerHour` (default 3) rejected with typed failure.

### 3.5 Verification & User Creation

- `verifyOtp`:
  1. Read cached OTP; if absent or mismatch → failure (invalid/expired code).
  2. Delete OTP cache entry (one-time use).
  3. Check account existence via existing EmailIdp (`emailIdp.hasAccount`).
  4. If account exists → create session via `AuthServices.authenticateUser` → return `OtpVerificationResult(isNewUser: false, authInfo: ...)`.
  5. If no account → return `OtpVerificationResult(isNewUser: true, authInfo: null)`. Client proceeds to profile setup.

- Profile setup completes user creation: new endpoint method (extend `AccountEndpoint`) that creates auth user + profile (name, gender, dob, email) and returns `AuthSuccess`. Auto-authenticate on client with returned authInfo.

### 3.6 Configuration

`baktaz_server/lib/src/app/config/app_config.dart` — add `OtpConfig`:

```dart
class OtpConfig {
  static const int length = 6;
  static const Duration expiry = Duration(minutes: 5);
  static const int maxSendsPerHour = 3;
  static const String emailSender = ''; // production SMTP sender
}
```

## 4. Flutter Design

### 4.1 Reuse & Adapt Existing Screens

| Screen | Action |
|--------|--------|
| `LoginMobileScreen` | **Adapt for email input** (rename to `LoginEmailScreen`; email field replaces mobile field; country code picker removed). |
| `BaktazOtpScreen` | **Reuse**; parameterize description to show email; add `onOtpVerified` callback / OTP verify wiring instead of hardcoded `123456`. |
| `RegistrationScreen` | **Reuse**; remove mobile field; display email (read-only); fields = name, gender, dob. |
| `SelectAddressScreen` | **Unused** in this flow (stub stays). |

### 4.2 New Cubit Layer

`baktaz_flutter/lib/features/auth/domain/cubit/otp/`:

- `OtpCubit` (`@injectable`, extends `CubitSignal<OtpState>`)
  - `sendOtp(String email)`
  - `verifyOtp(String email, String code)`
  - `resendOtp(String email)`
- `OtpState` (freezed, sealed):

```dart
@freezed
sealed class OtpState with _$OtpState {
  const factory OtpState.idle({@Default(false) bool isLoading}) = OtpStateIdle;
  const factory OtpState.codeSent(String email) = OtpStateCodeSent;
  const factory OtpState.verifying({required String email}) = OtpStateVerifying;
  const factory OtpState.verified(OtpVerificationResult result) = OtpStateVerified;
  const factory OtpState.registrationCompleted(AuthSuccess authInfo) = OtpStateRegistrationCompleted;
  const factory OtpState.failed(Failure failure) = OtpStateFailed;
}
```

### 4.3 Repository

`IOtpRepository` (domain/interface) + `OtpRepository` (data/repository, `@LazySingleton(as: IOtpRepository)`):

```dart
abstract interface class IOtpRepository {
  TaskResult<Unit> sendOtp(String email);
  TaskResult<OtpVerificationResult> verifyOtp(String email, String code);
  TaskResult<AuthSuccess> completeRegistration({
    required String email,
    required String name,
    required Gender gender,
    required DateTime dob,
  });
}
```

Uses `baktaz_client` generated `client.otp.*` + `client.account.*`.

### 4.4 Screen Flow (go_router)

```
/login/email            → LoginEmailScreen (adapted LoginMobileScreen)
/login/otp?email=...    → BaktazOtpScreen (email extra)
/register/profile       → RegistrationScreen (email extra; name, gender, dob)
```

After verify:
- existing user → `AuthCubit.authenticate(authInfo)` → `context.go('/')` (or dashboard).
- new user → push `/register/profile`.
After registration submit → `AuthCubit.authenticate(authInfo)` → `context.go('/')`.

### 4.5 i18n Keys

`assets/i18n/en.i18n.json` — update `otp` block: description takes `email` variant, phone-specific copy replaced; register labels for gender/dob added. Existing registration + otp keys reused where possible.

## 5. Testing

- **Server** (`baktaz_server/test/integration/auth/`):
  - `otp_endpoint_test.dart` — send/verify happy path, wrong code, expired code, one-time use, rate limit, new vs existing user, registration completion.
- **Flutter**:
  - `OtpCubit` unit tests (mock `IOtpRepository`, `FailureHandler`).
  - `OtpRepository` unit tests (mock client).
  - Widget tests: `BaktazOtpScreen` golden (15% tolerance), `LoginEmailScreen` golden, `RegistrationScreen` golden update.
- TDD: write failing tests first per layer.

## 6. Codegen & Migration

- New `.spy.yaml` model `OtpVerificationResult` (with `table: none` — response-only DTO, no DB table) → `serverpod generate`. No migration required for this model. New auth-user/profile tables come from Serverpod auth modules' own migrations.
- Flutter codegen order: `slang` → `build_runner`.

## 7. Open Items (deferred)

- Production email delivery (SendGrid/SMTP) behind `IEmailService` — dev uses console log.
- Address collection — out of scope.
- Removing mobile auth code — explicitly kept.

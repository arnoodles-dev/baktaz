# Server Audit Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Fix Server-specific audit violations: promote RegistrationForm to shared Serverpod model, reduce param counts via records.

**Tech Stack:** Serverpod 2.x (4.0.0-beta.3), Dart 3.13 records.

**Spec:** See parent plan `2026-08-26-comprehensive-fix.md` for global constraints. NOTE: requires `serverpod generate` — run server-side first, then client regen propagates model.

---

### Task 7: Server param-count fixes (RegistrationForm model + records)

**Files:**
- Create: `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`
- Modify: `baktaz_server/lib/src/features/auth/endpoint/auth_endpoint.dart` (endpoint signature + body)
- Modify: `baktaz_server/lib/src/features/auth/domain/interface/i_auth_repository.dart`
- Modify: `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`
- Modify: `baktaz_server/lib/src/app/utils/auth_utils.dart:114-131`
- Modify: `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart` (auto-generated, verify)
- NOTE: `auth_endpoint.dart` signature CHANGES — this requires `serverpod generate` to update client. Document as required deviation.

**Interfaces:**
- Produces `RegistrationForm` Serverpod model:
```yaml
# registration_form.spy.yaml
class: RegistrationForm
table: none
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```
Generated class: `RegistrationForm` with fields `email`, `name`, `gender`, `registrationToken`, `birthday`.
Endpoint becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form) async`
Interface becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form);`
Repo becomes: `Future<OtpVerificationResult> completeRegistration(Session session, RegistrationForm form) async`

- [ ] **Step 1: Create RegistrationForm spy.yaml**

Create `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml`:
```yaml
class: RegistrationForm
table: none
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd baktaz_server && fvm dart run serverpod generate`
Expected: Generated `registration_form.dart` in `baktaz_server/lib/src/generated/protocol.dart` and `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart`.

- [ ] **Step 3: Update endpoint**

Replace `auth_endpoint.dart`:
```dart
import 'package:baktaz_server/src/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';

final class AuthEndpoint extends Endpoint {
  AuthEndpoint([IAuthRepository? authRepository])
    : _authRepository =
          authRepository ??
          (GetIt.I.isRegistered<IAuthRepository>()
              ? GetIt.I<IAuthRepository>()
              : AuthRepository(GetIt.I.isRegistered<SecurityLogger>() ? GetIt.I<SecurityLogger>() : SecurityLogger()));

  final IAuthRepository _authRepository;

  @override
  bool get requireLogin => false;

  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  ) async => _authRepository.completeRegistration(session, form);
}
```

- [ ] **Step 4: Update interface + repo**

`i_auth_repository.dart`:
```dart
// ignore_for_file: one_member_abstracts

import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IAuthRepository {
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  );
}
```

`auth_repository.dart` — change signature and destructure form at top:
```dart
  @override
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  ) async {
    try {
      final String normalizedEmail = form.email.trim().toLowerCase();

      final String? expectedToken = await session.caches.local.get<String>('otp:token:$normalizedEmail');
      if (expectedToken == null || expectedToken != form.registrationToken) {
        throw OtpException(message: 'Invalid or expired registration token');
      }
      await session.caches.local.invalidateKey('otp:token:$normalizedEmail');

      return await session.db.transaction((Transaction transaction) async {
        // ... rest uses form.name, form.gender, form.birthday
```


- [ ] **Step 6: Commit A** — `git commit -m "refactor(server): promote RegistrationForm to Serverpod model (spy.yaml + server-side codegen)"`

**NOTE:** This is Commit A only. Commit B (client regen + call-site updates) comes AFTER verify step.

- [ ] **Step 6b: Verify server-side analyze is clean BEFORE proceeding to Commit B**

Run: `cd baktaz_server && fvm dart analyze`
Expected: clean. If not, fix before regenerating client.

- [ ] **Step 7: Regenerate client** — since endpoint signature changed, client must regenerate.
Run: `cd baktaz_client && fvm dart run serverpod generate`
Verify: `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart` exists.

- [ ] **Step 8: Update flutter call-sites** — exactly 4 hand-written sites, ALL in baktaz_flutter, NONE in baktaz_admin:

  1. `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart:160`
  2. `baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart:135,143` (interface impl + Serverpod client call)
  3. `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart:80,91` (cubit method + repo call)
  4. `baktaz_flutter/lib/features/auth/domain/interface/i_auth_repository.dart:17`

  Fifth reference is auto-generated (`baktaz_client/lib/src/protocol/client.dart:141`) — regenerates via serverpod generate, never hand-edit.

  Update each to pass `RegistrationForm` object:
```dart
// Before:
await _serverpod.client.auth.completeRegistration(
  email: email,
  name: name,
  gender: gender,
  birthday: birthday,
  registrationToken: registrationToken,
);

// After:
await _serverpod.client.auth.completeRegistration(
  session,
  RegistrationForm(
    email: email,
    name: name,
    gender: gender,
    birthday: birthday,
    registrationToken: registrationToken,
  ),
);
```
  Note: `DateTime? birthday` passes through Serverpod codegen as plain `DateTime?` (verified convention) — no special handling step needed.

- [ ] **Step 9: Commit B** — `git commit -m "refactor(server): client regen + update completeRegistration call sites"`.
---

- [ ] **Step 5: Fix `_createAccount` via record** — replace `_createAccount` (auth_utils.dart lines 114-131) and its call site (lines 62-69) with record-tuple form:

Call site (in `onAfterUserProfileCreated`) — replace:
```dart
    // 4. Tie everything together in Account
    final Account insertedAccount = await _createAccount(
      session,
      authUser,
      userProfileDb,
      userInfoDb,
      walletDb,
      transaction,
    );
```
with:
```dart
    // 4. Tie everything together in Account
    final (AuthUserModel, UserProfile, UserInfo, Wallet) seed =
        (authUser, userProfileDb, userInfoDb, walletDb);
    final Account insertedAccount = await _createAccount(session, seed, transaction);
```

Method — replace:
```dart
  static Future<Account> _createAccount(
    Session session,
    AuthUserModel authUser,
    UserProfile userProfileDb,
    UserInfo userInfoDb,
    Wallet walletDb,
    Transaction transaction,
  ) async {
    final Account account = Account(
      id: authUser.id,
      authUserId: authUser.id,
      userProfileId: userProfileDb.id,
      userInfoId: userInfoDb.id,
      walletId: walletDb.id,
      createdAt: authUser.createdAt,
    );

    return Account.db.insertRow(session, account, transaction: transaction);
  }
```
with:
```dart
  static Future<Account> _createAccount(
    Session session,
    (AuthUserModel, UserProfile, UserInfo, Wallet) seed,
    Transaction transaction,
  ) async {
    final (AuthUserModel authUser, UserProfile userProfileDb, UserInfo userInfoDb, Wallet walletDb) = seed;
    final Account account = Account(
      id: authUser.id,
      authUserId: authUser.id,
      userProfileId: userProfileDb.id,
      userInfoId: userInfoDb.id,
      walletId: walletDb.id,
      createdAt: authUser.createdAt,
    );

    return Account.db.insertRow(session, account, transaction: transaction);
  }
```
This drops `_createAccount` from 6 params → 3.


## Final Verification

1. Monorepo analyze: `melos exec -- fvm dart analyze`
2. Suites: `make test_server` if Postgres up.
3. DCM re-audit: confirm cyclomatic-complexity >20 and number-of-parameters >5 lists are empty (using bare `dcm analyze`).
4. Three-tier grep gates:
   - ✅ **BLOCKING** (must be zero before merge):
     - `rtk grep -rn "CubitSignal<Map" baktaz_flutter/lib` → zero (indirect — via client)
     - `rtk grep -rn "LoginState\.failed\(|LoginStateFailed" baktaz_flutter/lib` → zero (indirect — via client)
     - `rtk grep -rn "completeRegistration" baktaz_server/lib` — verify only 1 hand-written site in auth_endpoint
   - ⚠️ **FIX-BEFORE-CLOSE** (non-blocking but tracked): none
   - ℹ️ **INFORMATIONAL**:
     - `rtk grep -rn "lastFailure|shouldReportToCrashlytics" .agents/` → zero
5. Update `.coverage_exclude` if new test utils appear; bump nothing else.

## Accepted Deviations

- `auth_endpoint.completeRegistration` signature changes to `(Session, RegistrationForm)` — requires `serverpod generate` for client. Documented as required deviation.
- Server `throw Exception()` in `session_ext.dart` and `admin_endpoint.dart` — future `ApiException` migration (separate plan).
- Serverpod `return null` endpoints (NP1/NP2) — legitimate business absence per error-handling rules.

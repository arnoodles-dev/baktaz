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

- [ ] **Step 5: Fix `_createAccount` via record** — same as before (see steps 3-4 in original plan).

- [ ] **Step 6: Regenerate client** — since endpoint signature changed, client must regenerate.
Run: `cd baktaz_client && fvm dart run serverpod generate`
Verify: `baktaz_client/lib/src/protocol/features/auth/domain/models/registration_form.dart` exists.

- [ ] **Step 7: Update flutter admin calls** — search for `completeRegistration` calls in `baktaz_flutter` and `baktaz_admin`, update to pass `RegistrationForm` object:
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

- [ ] **Step 8: Verify** — `cd baktaz_server && fvm dart analyze`, `cd baktaz_flutter && fvm dart analyze`, `cd baktaz_admin && fvm dart analyze`. Integration tests if Postgres up.

- [ ] **Step 9: Commit** — `git commit -m "refactor(server): promote RegistrationForm to Serverpod model, fix param counts"`.
---


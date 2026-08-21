# Email OTP Login — Implementation Plan (Refined)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Passwordless email OTP sign-in — unified through `LoginCubit` — with social-account consolidation (EmailAccount link) and profile setup (name, gender, dob) for new users.

**Architecture:** Custom `OtpEndpoint` on Serverpod stores OTP in `session.caches.local` (rolling-window rate limits). `AuthUtils.onAfterUserProfileCreated` hook creates the universal `EmailAccount` link row for ALL non-admin users (social + OTP), making EmailAccount the single authoritative email→authUser source. Client routes all auth through `LoginCubit` (google/facebook/email OTP).

**Tech Stack:** Serverpod 4.0.0-beta.3, serverpod_auth_core_server (AuthServices, serverSideSessions, authUsers, userProfiles, EmailIdpAdmin), serverpod_auth_idp_server (EmailAccount, AuthUserBlockedException), session.caches.local, `mailer` (dev: console log), Flutter pinput, bloc_signals, freezed, go_router, injectable, fpdart.

**Spec:** `docs/superpowers/specs/2026-08-20-email-otp-login-design.md`

## Global Constraints

- Dart SDK >=3.13.0; very_good_analysis + dart_code_metrics --fatal-infos; line width 120.
- No hardcoded user-facing strings (localization). Exception: *_server.
- Follow AGENTS.md, .agents/rules/{code-quality,flutter-architecture,serverpod-architecture}.md.
- Codegen order: slang -> build_runner -> serverpod generate.
- Use serverpod MCP for create_migration / apply_migrations / hot_restart. Never start server (user runs `serverpod start`).
- TDD: failing test → run → implement → pass → commit. Run dart analyze + dart format per changed package.
- Config centralization: all OTP constants in AppConfig (no literals).

## Architecture Decisions (from grilling — binding)

1. **Unified LoginCubit (Option 2)**: No separate OtpCubit/OtpState/IOtpRepository/OtpRepository. Email OTP lives in LoginCubit + LoginState + IAuthRepository + AuthRepository.
2. **EmailAccount = universal link row**: created by `AuthUtils.onAfterUserProfileCreated` hook for every non-admin user with email (Google/FB/OTP). Admin-scoped users skipped (real password via native createEmailAuthentication).
3. **verifyOtp detection**: query EmailAccount (unique) — found = existing user, not found = new user.
4. **Registration token**: cached at verifyOtp when new user (15min TTL), required by completeRegistration, consumed on success. Prevents unverified account creation.
5. **Security**: 3 OTP attempts (configurable) → invalidate; 3 sends/hr/email rolling window (configurable); generic sendOtp response (no enumeration); blocked users rejected with typed error on ALL paths.
6. **Social consolidation**: OTP-verified email that already has EmailAccount → create session for that authUserId, no duplicate account. "First-created wins" via unique EmailAccount index.
7. **CompleteRegistration creates only AuthUser + profile**: AuthUtils hook fires on profile creation → creates UserInfo, Wallet, Account, EmailAccount automatically. Endpoint does NOT create these manually (DRY).
8. **Admin auth path untouched**: seeding + admin creation use Scope.admin → hook skips → native createEmailAuthentication (real password). Promoted admins: admin UI calls setPassword (in-place hash update, no insert, no unique violation).
9. **Blocked UX**: Failure.authentication(message, blocked: true) → LoginState.blocked → BaktazErrorScreen (icon, title, subtitle).
10. **Email normalization**: trim().toLowerCase() at endpoint boundary, everywhere (cache keys, rate keys, DB queries, profile creation).

---

## File Map

| File | Responsibility |
|------|---------------|
| `baktaz_server/lib/src/app/config/app_config.dart` | Add `OtpConfig` constants |
| `baktaz_server/lib/src/features/auth/domain/service/i_email_service.dart` | Email delivery interface |
| `baktaz_server/lib/src/features/auth/domain/service/development_email_service.dart` | Dev OTP delivery (console log) |
| `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart` | `OtpEndpoint` — sendOtp, verifyOtp, completeRegistration |
| `baktaz_server/lib/src/features/auth/endpoint/models/otp_verification_result.spy.yaml` | Response model (table: none) |
| `baktaz_server/lib/src/app/utils/auth_utils.dart` | Extend hook: createEmailAccountLink + admin scope skip |
| `baktaz_server/test/integration/auth/otp_endpoint_test.dart` | Server integration tests |
| `baktaz_shared/lib/src/entity/failure.dart` | Add `blocked` param to Failure.authentication |
| `baktaz_shared/lib/src/widgets/baktaz_error_screen.dart` | Reusable icon/title/subtitle error screen |
| `baktaz_flutter/lib/features/auth/domain/entity/enum/login_provider.dart` | mobile → email |
| `baktaz_flutter/lib/features/auth/domain/cubit/login/login_state.dart` | Add codeSent, verifying, verified, registrationCompleted, blocked |
| `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart` | Add loginWithEmail, verifyOtp, resendOtp, completeRegistration; remove loginWithMobile |
| `baktaz_flutter/lib/features/auth/domain/interface/i_auth_repository.dart` | Add email param + verifyOtp + completeRegistration; remove mobileNumber |
| `baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart` | Implement OTP calls; remove _signInWithMobile; map AuthUserBlockedException |
| `baktaz_flutter/lib/features/auth/presentation/views/login_email_screen.dart` | Renamed/adapted LoginMobileScreen (email field) |
| `baktaz_flutter/lib/features/auth/presentation/views/otp_verification_screen.dart` | Wraps BaktazOtpScreen; drives navigation |
| `baktaz_flutter/lib/core/presentation/views/screens/baktaz_otp_screen.dart` | Parameterize (email description, callback) |
| `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart` | Email readonly, name, gender, dob; submit → completeRegistration |
| `baktaz_flutter/lib/core/presentation/views/screens/blocked_account_screen.dart` | Composes BaktazErrorScreen for blocked account |
| `baktaz_flutter/lib/app/routes/app_routes.dart` | LoginEmailRoute, OtpRoute, RegistrationRoute(email, registrationToken) |
| `baktaz_flutter/lib/app/routes/route_guard.dart` | New auth routes in unauthenticated guard |
| `baktaz_flutter/assets/i18n/en.i18n.json` | New keys (otp email description, gender, dob, blocked) |

---

### Task 1: Server — OtpConfig

**Files:**
- Modify: `baktaz_server/lib/src/app/config/app_config.dart`

- [ ] **Step 1: Add OtpConfig**

```dart
class AppConfig {
  static const Duration defaultTimeout = Duration(minutes: 1);
  static const Duration defaultCacheLifetime = Duration(minutes: 5);
}

class OtpConfig {
  static const int length = 6;
  static const Duration expiry = Duration(minutes: 5);
  static const int maxSendsPerHour = 3;
  static const int maxAttemptsPerOtp = 3;
  static const Duration registrationTokenLifetime = Duration(minutes: 15);
  static const String method = 'email_otp';
}
```

- [ ] **Step 2: Verify analyze**

Run: `cd baktaz_server && fvm dart analyze`

- [ ] **Step 3: Commit**

```bash
git commit -am "feat(server): add OtpConfig constants"
```

---

### Task 2: Server — OtpVerificationResult Model

**Files:**
- Create: `baktaz_server/lib/src/features/auth/endpoint/models/otp_verification_result.spy.yaml`

- [ ] **Step 1: Create model**

```yaml
class: OtpVerificationResult
table: none
fields:
  isNewUser: bool
  authInfo: AuthSuccess?
  registrationToken: String?
```

- [ ] **Step 2: Codegen**

```bash
cd baktaz_server && fvm dart run serverpod generate
```

- [ ] **Step 3: Verify generated file** — `lib/src/generated/protocol/models/otp_verification_result.dart`

- [ ] **Step 4: Commit**

```bash
git add baktaz_server/lib/src/features/auth/endpoint/models/otp_verification_result.spy.yaml baktaz_server/lib/src/generated/
git commit -m "feat(server): add OtpVerificationResult model"
```

---

### Task 3: Server — Email Service

**Files:**
- Create: `baktaz_server/lib/src/features/auth/domain/service/i_email_service.dart`
- Create: `baktaz_server/lib/src/features/auth/domain/service/development_email_service.dart`

- [ ] **Step 1: Interface**

```dart
import 'package:serverpod/serverpod.dart';

abstract interface class IEmailService {
  Future<void> sendOtp(Session session, {required String email, required String code});
}
```

- [ ] **Step 2: DevelopmentEmailService (logs OTP — visible in tail_server_logs)**

```dart
import 'package:serverpod/serverpod.dart';
import 'i_email_service.dart';

final class DevelopmentEmailService implements IEmailService {
  @override
  Future<void> sendOtp(Session session, {required String email, required String code}) async {
    session.log('OTP for $email: $code', level: LogLevel.info);
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add baktaz_server/lib/src/features/auth/domain/service/
git commit -m "feat(server): add IEmailService + DevelopmentEmailService"
```

---

### Task 4: Server — OtpEndpoint sendOtp

**Files:**
- Create: `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart`
- Test: `baktaz_server/test/integration/auth/otp_endpoint_test.dart` (test tools: `withServerpod`, `TestSessionBuilder`, `TestEndpoints`)

- [ ] **Step 1: Write failing test**

```dart
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import '../../fixtures/server_fixtures.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given OtpEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    group('sendOtp', () {
      test('sends OTP to valid email without error', () async {
        await endpoints.otp.sendOtp(sessionBuilder, email: 'test@example.com');
      });

      test('rejects invalid email format', () async {
        await expectLater(
          endpoints.otp.sendOtp(sessionBuilder, email: 'not-an-email'),
          throwsA(anything),
        );
      });

      test('rejects empty email', () async {
        await expectLater(endpoints.otp.sendOtp(sessionBuilder, email: ''), throwsA(anything));
      });

      test('rate limits after 3 sends per hour', () async {
        await endpoints.otp.sendOtp(sessionBuilder, email: 'ratelimit@example.com');
        await endpoints.otp.sendOtp(sessionBuilder, email: 'ratelimit@example.com');
        await endpoints.otp.sendOtp(sessionBuilder, email: 'ratelimit@example.com');
        await expectLater(
          endpoints.otp.sendOtp(sessionBuilder, email: 'ratelimit@example.com'),
          throwsA(anything),
        );
      });
    });
  });
}
```

- [ ] **Step 2: Run → FAIL** (otp endpoint not registered)

- [ ] **Step 3: Implement**

```dart
import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../../../app/config/app_config.dart';
import '../domain/service/development_email_service.dart';
import '../domain/service/i_email_service.dart';

final class OtpEndpoint extends Endpoint {
  OtpEndpoint([IEmailService? emailService]) : _emailService = emailService ?? DevelopmentEmailService();
  final IEmailService _emailService;

  @override
  bool get requireLogin => false;

  Future<void> sendOtp(Session session, {required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) throw const FormatException('Invalid email');

    // Rolling-window rate limit: timestamps list, drop > 1hr old
    final pastSends = await session.caches.local.get<List<DateTime>>('otp:times:$normalizedEmail') ?? <DateTime>[];
    final now = DateTime.now();
    final recent = pastSends.where((t) => now.difference(t) < const Duration(hours: 1)).toList();
    if (recent.length >= OtpConfig.maxSendsPerHour) {
      throw StateError('Too many OTP requests. Try again later.');
    }

    final code = List<int>.generate(OtpConfig.length, (_) => Random.secure().nextInt(10)).join();
    await session.caches.local.put('otp:$normalizedEmail', code, lifetime: OtpConfig.expiry);
    await session.caches.local.put('otp:times:$normalizedEmail', [...recent, now], lifetime: const Duration(hours: 1));
    await _emailService.sendOtp(session, email: normalizedEmail, code: code);
  }

  static bool _isValidEmail(String email) =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}\$').hasMatch(email);
}


// Invalidate any existing OTP for this email before storing new one
await session.caches.local.invalidateKey('otp:$normalizedEmail');```

- [ ] **Step 4: Run → PASS**

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart baktaz_server/test/integration/auth/otp_endpoint_test.dart
git commit -m "feat(server): OtpEndpoint.sendOtp with rolling-window rate limit"
```

---

### Task 5: Server — OtpEndpoint verifyOtp

**Files:**
- Modify: `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart`
- Modify: `baktaz_server/test/integration/auth/otp_endpoint_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
group('verifyOtp', () {
  test('fails with wrong code', () async {
    await endpoints.otp.sendOtp(sessionBuilder, email: 'wrong@example.com');
    await expectLater(
      endpoints.otp.verifyOtp(sessionBuilder, email: 'wrong@example.com', code: '000000'),
      throwsA(anything),
    );
  });

  test('invalidates OTP after 3 failed attempts', () async {
    await endpoints.otp.sendOtp(sessionBuilder, email: 'attempts@example.com');
    final session = sessionBuilder.build();
    final code = await session.caches.local.get<String>('otp:attempts@example.com');
    for (var i = 0; i < OtpConfig.maxAttemptsPerOtp; i++) {
      await expectLater(
        endpoints.otp.verifyOtp(sessionBuilder, email: 'attempts@example.com', code: '000000'),
        throwsA(anything),
      );
    }
    // OTP burned after max attempts
    await expectLater(
      endpoints.otp.verifyOtp(sessionBuilder, email: 'attempts@example.com', code: code),
      throwsA(anything),
    );
  });

  test('returns isNewUser=true + token for unknown email', () async {
    await endpoints.otp.sendOtp(sessionBuilder, email: 'newuser@example.com');
    final session = sessionBuilder.build();
    final code = await session.caches.local.get<String>('otp:newuser@example.com');
    final result = await endpoints.otp.verifyOtp(sessionBuilder, email: 'newuser@example.com', code: code!);
    expect(result.isNewUser, isTrue);
    expect(result.registrationToken, isNotNull);
  });

  test('returns isNewUser=false for existing user (EmailAccount exists)', () async {
    // Set up: create auth user + profile + EmailAccount (as social/OTP signup would)
    final authUser = await AuthServices.instance.authUsers.create(sessionBuilder.build());
    await AuthServices.instance.userProfiles.createUserProfile(
      sessionBuilder.build(), authUser.id,
      UserProfileData(email: 'existing@example.com', fullName: 'Existing'),
    );
    await endpoints.otp.sendOtp(sessionBuilder, email: 'existing@example.com');
    final session = sessionBuilder.build();
    final code = await session.caches.local.get<String>('otp:existing@example.com');
    final result = await endpoints.otp.verifyOtp(sessionBuilder, email: 'existing@example.com', code: code!);
    expect(result.isNewUser, isFalse);
    expect(result.authInfo, isNotNull);
  });
});
```

- [ ] **Step 2: Run → FAIL**

- [ ] **Step 3: Implement verifyOtp**

```dart
Future<OtpVerificationResult> verifyOtp(Session session, {
  required String email,
  required String code,
}) async {
  final normalizedEmail = email.trim().toLowerCase();

  // Attempt throttling
  final attemptsKey = 'otp:attempts:$normalizedEmail';
  final attempts = await session.caches.local.get<int>(attemptsKey) ?? 0;
  if (attempts >= OtpConfig.maxAttemptsPerOtp) {
    await session.caches.local.invalidateKey('otp:$normalizedEmail');
    throw StateError('Too many attempts. Request a new code.');
  }

  final cached = await session.caches.local.get<String>('otp:$normalizedEmail');
  if (cached == null || cached != code) {
    await session.caches.local.put(attemptsKey, attempts + 1, lifetime: OtpConfig.expiry);
    throw StateError('Invalid or expired OTP');
  }

  // One-time use
  await session.caches.local.invalidateKey('otp:$normalizedEmail');
  await session.caches.local.invalidateKey(attemptsKey);

  // Existing-user detection via EmailAccount (unique source of truth)
  final link = await EmailAccount.db.findFirstRow(
    session, where: (EmailAccountTable t) => t.email.equals(normalizedEmail));
  if (link != null) {
    final authUser = await AuthServices.instance.authUsers.get(session, authUserId: link.authUserId);
    if (authUser.blocked) throw AuthUserBlockedException();
    final authInfo = await AuthServices.instance.serverSideSessions.createSession(
      session, authUserId: link.authUserId, method: OtpConfig.method);
    return OtpVerificationResult(isNewUser: false, authInfo: authInfo);
  }

  // New user: registration token
  final token = const Uuid().v4();
  await session.caches.local.put('otp:token:$normalizedEmail', token, lifetime: OtpConfig.registrationTokenLifetime);
  return OtpVerificationResult(isNewUser: true, registrationToken: token);
}
```

- [ ] **Step 4: Run → PASS**

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart baktaz_server/test/integration/auth/otp_endpoint_test.dart
git commit -m "feat(server): OtpEndpoint.verifyOtp with attempts, one-time use, token"
```

---

### Task 6: Server — AuthUtils EmailAccount link hook

**Files:**
- Modify: `baktaz_server/lib/src/app/utils/auth_utils.dart`

- [ ] **Step 1: Write failing integration test**

Add to `otp_endpoint_test.dart`:

```dart
group('email link hook', () {
  test('provider-style signup creates EmailAccount link for non-admin', () async {
    final authUser = await AuthServices.instance.authUsers.create(sessionBuilder.build());
    await AuthServices.instance.userProfiles.createUserProfile(
      sessionBuilder.build(), authUser.id,
      UserProfileData(email: 'social@example.com', fullName: 'Social User'),
    );
    final link = await EmailAccount.db.findFirstRow(
      sessionBuilder.build(),
      where: (EmailAccountTable t) => t.email.equals('social@example.com'),
      include: EmailAccount.include(authUser: AuthUser.include()),
    );
    expect(link, isNotNull);
    expect(link!.authUserId, authUser.id);
    // place does NOT have real password (placeholder)
    expect(link.email, 'social@example.com');
  });
});
```

- [ ] **Step 2: Run → FAIL** (no EmailAccount row created)

- [ ] **Step 3: Implement**

In `baktaz_server/lib/src/app/utils/auth_utils.dart`:

```dart
import 'package:serverpod_auth_idp_server/core.dart'; // EmailAccount, EmailIdpAdmin etc if needed

/// Creates the email→authUser link row (EmailAccount) for a user profile.
/// Idempotent: skips if already exists. Uses placeholder hash (OTP-only auth).
static Future<void> createEmailAccountLink(
  Session session,
  UserProfileModel userProfile, {
  required Transaction transaction,
}) async {
  final email = userProfile.email;
  if (email == null || email.isEmpty) return;
  final emailLower = email.toLowerCase();

  final existing = await EmailAccount.db.findFirstRow(
    session,
    where: (EmailAccountTable t) => t.email.equals(emailLower),
    transaction: transaction,
  );
  if (existing != null) return; // already linked

  await EmailAccount.db.insertRow(
    session,
    EmailAccount(
      authUserId: userProfile.authUserId,
      email: emailLower,
      passwordHash: 'placeholder-otp-only-no-password', // never used; OTP path
    ),
    transaction: transaction,
  );
}

// Inside onAfterUserProfileCreated, after Account creation:
final AuthUserModel authUser = await AuthServices.instance.authUsers.get(...);  // already fetched
if (!authUser.scopes.contains(Scope.admin)) {
  await createEmailAccountLink(session, userProfile, transaction: transaction);
}
```

- [ ] **Step 4: Run → PASS**

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/app/utils/auth_utils.dart baktaz_server/test/integration/auth/otp_endpoint_test.dart
git commit -m "feat(server): EmailAccount link hook for non-admin users"
```

---

### Task 7: Server — completeRegistration

**Files:**
- Modify: `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart`
- Modify: `baktaz_server/test/integration/auth/otp_endpoint_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
group('completeRegistration', () {
  test('rejects missing/invalid registration token', () async {
    await expectLater(
      endpoints.otp.completeRegistration(
        sessionBuilder,
        email: 'tokenless@example.com',
        name: 'No Token',
        gender: 'male',
        birthday: DateTime(1990, 1, 1),
        registrationToken: 'invalid-token',
      ),
      throwsA(anything),
    );
  });

  test('creates account + EmailAccount + session for new user with valid token', () async {
    await endpoints.otp.sendOtp(sessionBuilder, email: 'fresh@example.com');
    final session = sessionBuilder.build();
    final code = await session.caches.local.get<String>('otp:fresh@example.com');
    final verifyResult = await endpoints.otp.verifyOtp(sessionBuilder, email: 'fresh@example.com', code: code!);
    expect(verifyResult.isNewUser, isTrue);

    final result = await endpoints.otp.completeRegistration(
      sessionBuilder,
      email: 'fresh@example.com',
      name: 'Fresh User',
      gender: 'female',
      birthday: DateTime(1992, 5, 15),
      registrationToken: verifyResult.registrationToken!,
    );
    expect(result.authInfo, isNotNull);

    // Account + EmailAccount created via AuthUtils hook
    final link = await EmailAccount.db.findFirstRow(
      sessionBuilder.build(), where: (EmailAccountTable t) => t.email.equals('fresh@example.com'));
    expect(link, isNotNull);
    final account = await Account.db.findFirstRow(
      sessionBuilder.build(), where: (AccountTable t) => t.authUserId.equals(result.authInfo!.authUserId));
    expect(account, isNotNull);
  });

  test('rejects second use of same registration token', () async {
    await endpoints.otp.sendOtp(sessionBuilder, email: 'once@example.com');
    final session = sessionBuilder.build();
    final code = await session.caches.local.get<String>('otp:once@example.com');
    final verifyResult = await endpoints.otp.verifyOtp(sessionBuilder, email: 'once@example.com', code: code!);
    await endpoints.otp.completeRegistration(
      sessionBuilder, email: 'once@example.com', name: 'Once', gender: 'male',
      birthday: DateTime(1988, 3, 3), registrationToken: verifyResult.registrationToken!,
    );
    await expectLater(
      endpoints.otp.completeRegistration(
        sessionBuilder, email: 'once@example.com', name: 'Twice', gender: 'female',
        birthday: DateTime(1989, 4, 4), registrationToken: verifyResult.registrationToken!,
      ),
      throwsA(anything),
    );
  });
});
```

- [ ] **Step 2: Run → FAIL**

- [ ] **Step 3: Implement**

```dart
Future<OtpVerificationResult> completeRegistration(Session session, {
  required String email,
  required String name,
  required String gender,
  DateTime? birthday,
  required String registrationToken,
}) async {
  final normalizedEmail = email.trim().toLowerCase();

  // Validate registration token
  final expectedToken = await session.caches.local.get<String>('otp:token:$normalizedEmail');
  if (expectedToken == null || expectedToken != registrationToken) {
    throw StateError('Invalid or expired registration token');
  }
  // Consume token (one-time)
  await session.caches.local.invalidateKey('otp:token:$normalizedEmail');

  // Create auth user
  final authUser = await AuthServices.instance.authUsers.create(session);

  // Create profile → AuthUtils hook auto-creates UserInfo, Wallet, Account, EmailAccount
  await AuthServices.instance.userProfiles.createUserProfile(
    session,
    authUser.id,
    UserProfileData(fullName: name, email: normalizedEmail),
  );

  // Update UserInfo with gender + birthday (hook created default UserInfo with unknown gender)
  final account = await Account.db.findFirstRow(
    session, where: (AccountTable t) => t.authUserId.equals(authUser.id),
    include: Account.include(userInfo: UserInfo.include()),
  );
  final userInfo = account?.userInfo;
  if (userInfo != null) {
    await UserInfo.db.updateRow(session, userInfo.copyWith(
      gender: Gender.values.asNameMap()[gender] ?? Gender.unknown,
      birthday: birthday,
    ));
  }

  // Create session
  final authInfo = await AuthServices.instance.serverSideSessions.createSession(
    session, authUserId: authUser.id, method: OtpConfig.method);
  return OtpVerificationResult(isNewUser: false, authInfo: authInfo);
}
```

- [ ] **Step 4: Run → PASS. Also verify existing email_idp_endpoint tests still pass** (admin seeding untouched)

```bash
cd baktaz_server && fvm dart test test/integration/auth/
```

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart baktaz_server/test/integration/auth/otp_endpoint_test.dart
git commit -m "feat(server): OtpEndpoint.completeRegistration with token gate"
```

- [ ] **Step 6: analyze + format**

```bash
cd baktaz_server && fvm dart analyze && fvm dart format lib test
```

- [ ] **Step 7: Regenerate client**

Use serverpod MCP hot_restart, or:
```bash
cd baktaz_server && fvm dart run serverpod generate
```

---

### Task 8: Shared — Failure.accountBlocked param + BaktazErrorScreen

**Files:**
- Modify: `baktaz_shared/lib/src/entity/failure.dart`
- Create: `baktaz_shared/lib/src/widgets/baktaz_error_screen.dart`
- Modify: `baktaz_shared/lib/baktaz_shared.dart` (export)
- Test: `baktaz_shared/test/` relevant tests

- [ ] **Step 1: Failure.authentication with blocked param (write test first if Failure tests exist; else update references)**

```dart
// failure.dart — change signature:
const factory Failure.authentication(String? message, {bool blocked}) = AuthenticationError;
```

Update all `Failure.authentication(...)` call sites to compile (add `blocked:` where needed — default false).

- [ ] **Step 2: Create BaktazErrorScreen**

```dart
// baktaz_shared/lib/src/widgets/baktaz_error_screen.dart
import 'package:flutter/material.dart';

class BaktazErrorScreen extends StatelessWidget {
  const BaktazErrorScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 16),
                Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onRetry, child: Text(retryLabel ?? 'Retry')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Export in baktaz_shared.dart**

```dart
export 'src/widgets/baktaz_error_screen.dart';
```

- [ ] **Step 4: Run shared tests + analyze**

```bash
cd baktaz_shared && fvm dart analyze && fvm dart test
```

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_shared/lib/src/entity/failure.dart baktaz_shared/lib/src/widgets/baktaz_error_screen.dart baktaz_shared/lib/baktaz_shared.dart
git commit -m "feat(shared): Failure.authentication blocked param + BaktazErrorScreen"
```

---

### Task 9: Flutter — LoginState + LoginCubit (unified)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_state.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/cubit/login/login_cubit.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/interface/i_auth_repository.dart`
- Modify: `baktaz_flutter/lib/features/auth/domain/entity/enum/login_provider.dart`
- Test: `baktaz_flutter/test/unit/login_cubit_test.dart` (update existing)

- [ ] **Step 1: LoginState — add variants**

```dart
@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.idle({@Default(false) bool isLoading}) = LoginStateIdle;
  const factory LoginState.codeSent(String email) = LoginStateCodeSent;
  const factory LoginState.verifying({required String email}) = LoginStateVerifying;
  const factory LoginState.verified(OtpVerificationResult result) = LoginStateVerified;
  const factory LoginState.registrationCompleted(AuthSuccess authInfo) = LoginStateRegistrationCompleted;
  const factory LoginState.success(AuthSuccess authInfo) = LoginStateSuccess;
  const factory LoginState.blocked() = LoginStateBlocked;
  const factory LoginState.failed(Failure failure) = LoginStateFailed;
}
```

- [ ] **Step 2: LoginProvider — mobile → email**

```dart
enum LoginProvider { google, facebook, email }
```

- [ ] **Step 3: IAuthRepository — replace mobileNumber with email; add methods**

```dart
abstract interface class IAuthRepository {
  AuthSuccess? get authInfo;

  /// Logs in with the given provider.
  /// - For `LoginProvider.email`: `email` is required, `onCodeSent` fires when OTP sent.
  /// - For `LoginProvider.google`/`facebook`: `onAuthenticated` fires on success.
  Future<void> loginWithProvider({
    required LoginProvider provider,
    required void Function(AuthSuccess?) onAuthenticated,
    required void Function() onCodeSent,
    required void Function(Failure) onError,
    String? email,
  });

  Future<void> verifyOtp({
    required String email,
    required String code,
    required void Function(OtpVerificationResult) onVerified,
    required void Function(Failure) onError,
  });

  Future<AuthSuccess> completeRegistration({
    required String email,
    required String name,
    required String gender,
    required DateTime birthday,
    required String registrationToken,
  });

  TaskResult<Unit> logout();
}
```

- [ ] **Step 4: Update LoginCubit**

```dart
// Remove loginWithMobile entirely.
// Add private field `String _currentEmail = '';` to class fields.
// Add:
Future<void> loginWithProvider(LoginProvider provider, {String? email, ErrorActions? errorActions}) async {
  // Validate email for email provider
  if (provider == LoginProvider.email && (email == null || email.isEmpty)) {
    _failureHandler.handleFailure(const Failure.authentication('Email required'), errorActions);
    safeEmit(const LoginState.failed(Failure.authentication('Email required')));
    return;
  }
  
  if (email != null) {
    _currentEmail = email;
  }
  
  await safeRun(
    onException: _failureHandler.handleException,
    onLoading: (bool isLoading) {
      if (stateValue is LoginStateIdle) safeEmit(LoginState.idle(isLoading: isLoading));
    },
    action: () async {
      await _authRepository.loginWithProvider(
        provider: provider,
        email: email,
        onAuthenticated: (authInfo) {
          if (authInfo != null) _onAuthenticated(authInfo, provider);
        },
        onCodeSent: () => safeEmit(LoginState.codeSent(email ?? '')),
        // Only pass errorActions for email provider (inline errors); others use default toast
        onError: (Failure failure) => _onAuthError(failure, provider == LoginProvider.email ? errorActions : null),
      );
    },
  );
}

Future<void> verifyOtp(String email, String code, {ErrorActions? errorActions}) async {
  await safeRun(
    onException: _failureHandler.handleException,
    action: () async {
      await _authRepository.verifyOtp(
        email: email,
        code: code,
        onVerified: (OtpVerificationResult result) {
          if (result.isNewUser) {
            safeEmit(LoginState.verified(result));  // → RegistrationScreen
          } else {
            _onAuthenticated(result.authInfo, LoginProvider.email);
          }
        },
        onError: (Failure failure) => _onAuthError(failure, errorActions),
      );
    },
  );
}

Future<void> completeRegistration({required String email, required String name, required String gender, required DateTime birthday, required String registrationToken}) async {
  await safeRun(
    onException: _failureHandler.handleException,
    action: () async {
      final authInfo = await _authRepository.completeRegistration(
        email: email, name: name, gender: gender, birthday: birthday, registrationToken: registrationToken);
      safeEmit(LoginState.registrationCompleted(authInfo));
      _onAuthenticated(authInfo, LoginProvider.email);
    },
  );
}

// Map auth failure → LoginState; blocked → LoginState.blocked; OTP errors stay on screen
void _onAuthError(Failure failure, [ErrorActions? errorActions]) {
  _failureHandler.handleFailure(failure, errorActions);
  if (failure is AuthenticationError && failure.blocked) {
    safeEmit(const LoginState.blocked());
  } else {
    // Handle network errors - stay on current screen, don't reset to idle
    if (failure is NetworkError || failure.message?.contains('network') == true || failure.message?.contains('connection') == true) {
      safeEmit(LoginState.failed(failure));
      safeEmit(LoginState.codeSent(_currentEmail)); // Stay on OTP screen for network errors
    } else {
      safeEmit(LoginState.failed(failure));
      safeEmit(const LoginState.idle());
    }
  }
}
```

- [ ] **Step 5: Update mock in generated_mocks.dart + run build_runner**

```bash
cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Update existing LoginCubit tests (remove mobile), add OTP tests**

Add tests using `blocSignalTest<LoginCubit, LoginState>` from `bloc_signals_test`:
- `loginWithProvider(LoginProvider.email, email:)` emits `[LoginState.idle(isLoading: true), LoginState.codeSent(email)]`
- `verifyOtp(email, code)` with new user emits `[LoginState.verified(result)]` where `isNewUser: true`
- `verifyOtp(email, code)` with existing user emits `[LoginState.success(authInfo)]`
- `verifyOtp(email, code)` with blocked user emits `[LoginState.blocked()]`
- `completeRegistration(...)` emits `[LoginState.registrationCompleted(authInfo), LoginState.success(authInfo)]`

- [ ] **Step 7: Run tests**

```bash
cd baktaz_flutter && fvm dart test test/unit/auth/
```

- [ ] **Step 8: Commit**

```bash
git add baktaz_flutter/lib/features/auth/ baktaz_flutter/test/unit/auth/ baktaz_flutter/test/utils/generated_mocks.dart
git commit -m "feat(flutter): unified LoginCubit email OTP flow"
```

---

### Task 10: Flutter — AuthRepository implementation

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart`
- Test: `baktaz_flutter/test/unit/auth_repository_test.dart`

- [ ] **Step 1: Remove _signInWithMobile + loginWithProvider mobile branch; implement OTP calls**

```dart
// In loginWithProvider:
switch (provider) {
  case LoginProvider.google: return _signInWithGoogle(onAuthenticated, onError);
  case LoginProvider.facebook: return _signInWithFacebook(onAuthenticated, onError);
  case LoginProvider.email: {
    if (email == null) { onError(const Failure.authentication('Email required')); return; }
    return _sendOtp(email, onCodeSent, onError);
  }
}

Future<void> _sendOtp(String email, void Function() onCodeSent, void Function(Failure) onError) async {
  try {
    await _serverpod.client.otp.sendOtp(email: email);
    onCodeSent();
  } on Object catch (e, st) { _talker.handle(e, st); onError(Failure.unexpected(e.toString())); }
}

@override
Future<void> verifyOtp({required String email, required String code, required void Function(OtpVerificationResult) onVerified, required void Function(Failure) onError}) async {
  try {
    final result = await _serverpod.client.otp.verifyOtp(email: email, code: code);
    if (result.authInfo != null) {
      await _serverpod.client.authSessionManager.updateSignedInUser(result.authInfo);
    }
    onVerified(result);
  } on AuthUserBlockedException catch (e) {
    onError(Failure.authentication('Account blocked', blocked: true));
  } on Object catch (e, st) { _talker.handle(e, st); onError(Failure.unexpected(e.toString())); }
}

@override
Future<AuthSuccess> completeRegistration({required String email, required String name, required String gender, required DateTime birthday, required String registrationToken}) async {
  try {
    final result = await _serverpod.client.otp.completeRegistration(
      email: email, name: name, gender: gender, birthday: birthday, registrationToken: registrationToken);
    await _serverpod.client.authSessionManager.updateSignedInUser(result.authInfo!);
    return result.authInfo!;
  } on Object catch (e, st) { _talker.handle(e, st); throw e; }
}

// _signInWithGoogle/_signInWithFacebook: map AuthUserBlockedException → Failure.authentication(msg, blocked: true)
```

- [ ] **Step 2: Update tests**

```bash
cd baktaz_flutter && fvm dart test test/unit/auth_repository_test.dart
```

- [ ] **Step 3: Commit**

```bash
git add baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart baktaz_flutter/test/unit/auth_repository_test.dart
git commit -m "feat(flutter): AuthRepository OTP calls + blocked mapping"
```

---

### Task 11: Flutter — LoginEmailScreen + routes

**Files:**
- Rename: `baktaz_flutter/lib/features/auth/presentation/views/login_mobile_screen.dart` → `login_email_screen.dart`
- Modify: `baktaz_flutter/lib/app/routes/app_routes.dart`
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/login_screen.dart` (button route)

- [ ] **Step 1: Rename + adapt screen** (email field, no country code; add `ValueNotifier<String?> emailError`; on submit → `LoginCubit.loginWithProvider(LoginProvider.email, email:, errorActions: _EmailErrorActions(emailError, context))` + rename class `LoginEmailScreen`; update references.

- [ ] **Step 2: Routes**

```dart
@TypedGoRoute<LoginEmailRoute>(path: '/loginEmail', name: 'loginEmail')
class LoginEmailRoute extends GoRouteData with $LoginEmailRoute {
  const LoginEmailRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => const NoTransitionPage(child: LoginEmailScreen());
}

@TypedGoRoute<OtpRoute>(path: '/otp', name: 'otp')
class OtpRoute extends GoRouteData with $OtpRoute {
  const OtpRoute({required this.email, this.$extra});
  final String email;
  @override
  Page<void> buildPage(...) => NoTransitionPage(child: OtpVerificationScreen(email: email));
}

@TypedGoRoute<RegistrationRoute>(path: '/registerProfile', name: 'registerProfile')
class RegistrationRoute extends GoRouteData with $RegistrationRoute {
  const RegistrationRoute({required this.email, required this.registrationToken});
  final String email;
  final String registrationToken;
  @override
  Page<void> buildPage(...) => NoTransitionPage(child: RegistrationScreen(email: email, registrationToken: registrationToken));
}
```

Remove `LoginMobileRoute`. Keep `SelectAddressRoute` (HomeScreen uses it).

- [ ] **Step 3: LoginScreen email button → LoginEmailRoute**

```dart
onPressed: () => const LoginEmailRoute().push<void>(context),
```

- [ ] **Step 4: Add Alchemist golden test** `test/widget/features/auth/login_email_screen_test.dart` using `goldenTest` + `MockMaterialApp(child: LoginEmailScreen())`
- [ ] **Step 5: Run codegen (go_router_builder)**

```bash
cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/auth/ baktaz_flutter/lib/app/routes/
git commit -m "feat(flutter): LoginEmailScreen + routes"
```

---



/// Overrides FailureHandler error actions for the LoginEmail screen: renders the
/// error inline in the email field instead of showing a toast.
final class _EmailErrorActions with ErrorActions {
  _EmailErrorActions(this.emailError, this.context);
  final ValueNotifier<String?> emailError;
  final BuildContext context;

  @override
  void onAuthenticationError(AuthenticationError error) {
    emailError.value = context.i18n.login.error.invalid_credentials; // or specific error
  }
}


### Task 12: Flutter — OtpVerificationScreen + BaktazOtpScreen param

**Files:**
- Create: `baktaz_flutter/lib/features/auth/presentation/views/otp_verification_screen.dart`
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/baktaz_otp_screen.dart`
- Modify: `baktaz_flutter/lib/app/utils/dialog_utils.dart` (remove showOtpDialog)

- [ ] **Step 1: Parameterize BaktazOtpScreen** (`email`, `otpError` ValueNotifier, `onOtpVerified(String code)`); replace hardcoded phone desc + `123456`; i18n description uses email.

- [ ] **Step 2: OtpVerificationScreen**

```dart
class OtpVerificationScreen extends HookWidget {
  const OtpVerificationScreen({required this.email, super.key});
  final String email;

  void _onStateChanged(BuildContext context, LoginState state) {
    state.whenOrNull(
      verified: (OtpVerificationResult result) {
        context.loaderOverlay.hide();
        if (result.isNewUser) {
          RegistrationRoute(email: email, registrationToken: result.registrationToken!).push<void>(context);
        }
      },
      registrationCompleted: (AuthSuccess authInfo) => context.read<AuthCubit>().authenticate(authInfo),
      success: (AuthSuccess authInfo) => context.read<AuthCubit>().authenticate(authInfo),
      blocked: () {
        context.loaderOverlay.hide();
        context.push('/blocked');
      },
      failed: (_) => context.loaderOverlay.hide(),
    );
  }

  // Allow back navigation to LoginEmailScreen (pop clears OTP state)
  Future<bool> _onWillPop(BuildContext context) async {
    if (context.mounted) {
      context.read<LoginCubit>().loginWithProvider(LoginProvider.email, email: '', errorActions: null);
    }
    return true; // Allow pop
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String?> otpError = useState<String?>(null);

    return BlocSignalProvider<LoginCubit>(
      create: (_) => getIt<LoginCubit>(),
      child: Builder(
        builder: (context) => BlocSignalListener<LoginCubit, LoginState>(
          listener: _onStateChanged,
          child: BaktazOtpScreen(
            email: email,
            otpError: otpError,
            onOtpVerified: (code) => context.read<LoginCubit>().verifyOtp(
              email,
              code,
              errorActions: _OtpErrorActions(otpError, context),
            ),
            onResend: () => context.read<LoginCubit>().loginWithProvider(LoginProvider.email, email: email, errorActions: _OtpErrorActions(otpError, context)),
          ),
        ),
      ),
    );
  }
}

/// Overrides FailureHandler error actions for the OTP screen: renders the
/// error inline in the OTP field instead of showing a toast.
final class _OtpErrorActions with ErrorActions {
  _OtpErrorActions(this.otpError, this.context);
  final ValueNotifier<String?> otpError;
  final BuildContext context;

  @override
  void onAuthenticationError(AuthenticationError error) {
    otpError.value = context.i18n.otp.error.incorrect_code;
  }
}

      },
      registrationCompleted: (AuthSuccess authInfo) => context.read<AuthCubit>().authenticate(authInfo),
      success: (AuthSuccess authInfo) => context.read<AuthCubit>().authenticate(authInfo),
      blocked: () {
        context.loaderOverlay.hide();
        context.push('/blocked');
      },
      failed: (_) => context.loaderOverlay.hide(),
    );
  }

  @override
  Widget build(BuildContext context) => BlocSignalProvider<LoginCubit>(
    create: (_) => getIt<LoginCubit>(),
    child: Builder(
      builder: (context) => BlocSignalListener<LoginCubit, LoginState>(
        listener: _onStateChanged,
          child: BaktazOtpScreen(
            email: email,
            otpError: otpError,
            onOtpVerified: (code) => context.read<LoginCubit>().verifyOtp(
              email,
              code,
              errorActions: _OtpErrorActions(otpError, context),
            ),
          onResend: () => context.read<LoginCubit>().loginWithProvider(LoginProvider.email, email: email, errorActions: _OtpErrorActions(otpError, context)),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 3: Remove showOtpDialog from dialog_utils.dart** (dead after LoginMobileScreen gone) — BaktazOtpScreen no longer self-manages errors; error flows LoginCubit → FailureHandler(ErrorActions override `_OtpErrorActions`) → otpError notifier → `_OtpForm` inline display. No toast.

- [ ] **Step 4: i18n — otp description with email** (`en.i18n.json`)

```json
"otp": {
  "header": "Verify your email",
  "description_email": "An OTP has been sent to ${email: String}",
  "error": { "incorrect_code": "Incorrect OTP Code" },
  "button": { "verify": "Verify" },
  "resend": "Resend OTP"
}
```

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/auth/ baktaz_flutter/lib/core/presentation/ baktaz_flutter/lib/app/utils/dialog_utils.dart baktaz_flutter/assets/i18n/en.i18n.json
git commit -m "feat(flutter): OtpVerificationScreen + BaktazOtpScreen parameterized"
```

---

### Task 13: Flutter — BlockedAccountScreen

**Files:**
- Create: `baktaz_flutter/lib/features/auth/presentation/views/blocked_account_screen.dart`
- Modify: `baktaz_flutter/lib/app/routes/app_routes.dart` (blocked route + guard)

- [ ] **Step 1: Create screen**

```dart
class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => BaktazErrorScreen(
    icon: Icon(Icons.block, size: 64, color: context.colorScheme.error),
    title: context.i18n.auth.blocked.title,
    subtitle: context.i18n.auth.blocked.subtitle,
    onRetry: () => context.pushReplacement(const LoginRoute().location),
    retryLabel: context.i18n.auth.blocked.go_to_login,
  );
}
```

- [ ] **Step 2: i18n keys**

```json
"auth": {
  "blocked": {
    "title": "Account Blocked",
    "subtitle": "Your account has been blocked. Please contact support.",
    "go_to_login": "Go to Login"
  }
}
```

- [ ] **Step 3: Route**

```dart
@TypedGoRoute<BlockedRoute>(path: '/blocked', name: 'blocked')
class BlockedRoute extends GoRouteData with $BlockedRoute { ... }
```

- [ ] **Step 4: RouteGuard** — allow `/blocked` for unauthenticated; authenticated users redirected home (blocked never has session anyway).

- [ ] **Step 4.5: Add widget test** `test/widget/features/auth/blocked_account_screen_test.dart` asserting `BaktazErrorScreen` renders title & subtitle
- [ ] **Step 5: Run slang + analyze**

```bash
cd baktaz_flutter && fvm dart run slang && fvm dart analyze
```

- [ ] **Step 6: Commit**

```bash
git add baktaz_flutter/lib/features/auth/presentation/views/blocked_account_screen.dart baktaz_flutter/lib/app/routes/app_routes.dart baktaz_flutter/assets/i18n/en.i18n.json
git commit -m "feat(flutter): BlockedAccountScreen"
```

---

### Task 14: Flutter — RegistrationScreen (email, name, gender, dob)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`

- [ ] **Step 1: Rewrite screen** — params `email`, `registrationToken`; remove mobile/address; fields: email (read-only, pre-filled from route), name, GenderSelector, DOB picker; submit → LoginCubit.completeRegistration; add "Back" button to return to OTP screen.

- [ ] **Step 2: i18n**

```json
"register": {
  "label": { "email": "Email", "name": "Name", "gender": "Gender", "birthday": "Date of birth" },
  "hint": { "name": "What should we call you?", "birthday": "Select date" },
  "submit": "Create Account"
}
```

- [ ] **Step 3: RegistrationScreen — own listener (self-contained navigation)** — wrap in `BlocSignalProvider<LoginCubit>` + `BlocSignalListener`: on `registrationCompleted(authInfo)` → `context.read<AuthCubit>().authenticate(authInfo)` → `context.go('/')` (or HomeRoute). No dependency on OtpVerificationScreen's covered listener.

- [ ] **Step 4: Update existing widget tests/goldens** for RegistrationScreen

```bash
cd baktaz_flutter && fvm dart test test/widget/features/auth/
```

- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart baktaz_flutter/assets/i18n/en.i18n.json
git commit -m "feat(flutter): RegistrationScreen gender + dob"
```

---





### Task 15: Flutter — GenderSelector Widget

**Files:**
- Create: `baktaz_flutter/lib/core/presentation/views/widgets/gender_selector.dart`

**Implementation:**
```dart
class GenderSelector extends StatelessWidget {
  const GenderSelector({required this.selectedGender, required this.onChanged, super.key});
  final Gender selectedGender;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<Gender>(
    value: selectedGender,
    decoration: InputDecoration(labelText: context.i18n.register.label.gender),
    items: Gender.values.where((g) => g != Gender.unknown).map((g) => DropdownMenuItem(value: g, child: Text(g.name.capitalize()))).toList(),
    onChanged: (g) => g != null ? onChanged(g) : null,
  );
}
```

- [ ] **Step 1: Create GenderSelector widget**
- [ ] **Step 2: Add i18n key for gender label**
- [ ] **Step 3: Update RegistrationScreen to use GenderSelector**
- [ ] **Step 4: Commit**

```bash
git add baktaz_flutter/lib/core/presentation/views/widgets/gender_selector.dart
git commit -m "feat(flutter): add GenderSelector widget"
```
### Task 16: Server — Block Admin Emails from OTP Flow

**Files:**
- Modify: `baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart`
- Test: `baktaz_server/test/integration/auth/otp_endpoint_test.dart`

**Changes:**
- In `verifyOtp` and `completeRegistration`, check if email maps to authUser with `Scope.admin`
- If found, reject with `StateError('Admin accounts cannot use OTP login')`
- Client maps to `Failure.authentication('Admin accounts cannot use OTP login')` → `BaktazErrorScreen`

```dart
// Inside verifyOtp, query by UserProfile.email at start to check admin scope:
final normalizedEmail = email.trim().toLowerCase();
final existingProfile = await UserProfile.db.findFirstRow(
  session, where: (t) => t.email.equals(normalizedEmail));
if (existingProfile != null) {
  final authUser = await AuthServices.instance.authUsers.get(session, authUserId: existingProfile.authUserId);
  if (authUser.scopes.contains(Scope.admin)) {
    throw StateError('Admin accounts cannot use OTP login');
  }
}

// Same check in completeRegistration (check if email already used by an admin)
```

- [ ] **Step 1: Add admin scope check to verifyOtp** (test first)
- [ ] **Step 2: Add admin scope check to completeRegistration** (test)
- [ ] **Step 3: Update tests** — admin email → blocked error
- [ ] **Step 4: Commit**

```bash
git add baktaz_server/lib/src/features/auth/endpoint/otp_endpoint.dart baktaz_server/test/integration/auth/otp_endpoint_test.dart
git commit -m "feat(server): block admin emails from OTP flow"
```

---

### Task 17: Server — Account Deletion (Configurable)

**Files:**
- Modify: `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart`
- Create: `baktaz_server/lib/src/app/config/feature_flags.dart` (or extend AppConfig)
- Test: `baktaz_server/test/integration/account/account_endpoint_test.dart`

**Design:**
- Add `FeatureFlags.accountDeletionEnabled` (default `false`, overridden via config/env)
- New endpoint method: `deleteAccount(Session session)` — requires auth, cascades:
  - Account → Wallet → UserInfo → UserProfile → EmailAccount → AuthUser
- Return `AuthSuccess?` (null on success, client logs out)
- Client: `baktaz_flutter` profile screen → "Delete Account" button → confirmation dialog → calls endpoint → logout on success
- Config: `dev: false`, `staging/prod: true` via env variable

- [ ] **Step 1: Add FeatureFlags / extend AppConfig**
- [ ] **Step 2: Implement AccountEndpoint.deleteAccount** (test: disabled → 403; enabled → cascading delete)
- [ ] **Step 3: Add feature flag to baktaz_flutter config**
- [ ] **Step 4: Flutter — DeleteAccountScreen + profile integration** (confirmation, destructive action)
- [ ] **Step 4.5: Add Alchemist golden test** `test/widget/features/auth/otp_verification_screen_test.dart` using `goldenTest` + `MockMaterialApp`
- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart baktaz_server/lib/src/app/config/
git commit -m "feat(server): account deletion with feature flag"
```

---

### Task 18: Server — Audit Log / Security Events

**Files:**
- Create: `baktaz_server/lib/src/features/security/domain/model/security_event.spy.yaml`
- Create: `baktaz_server/lib/src/features/security/endpoint/security_endpoint.dart`
- Create: `baktaz_server/lib/src/features/security/domain/service/security_logger.dart`
- Test: `baktaz_server/test/integration/security/`

**Event Model:**
```yaml
class: SecurityEvent
fields:
  id: UuidValue?, defaultPersist=random_v7
  authUserId: UuidValue?
  eventType: String  # 'otp_send', 'otp_verify_success', 'otp_verify_fail', 'login_password', 'login_social', 'admin_block', 'admin_unblock', 'admin_scope_change', 'password_reset_request', 'password_reset_complete', 'account_delete'
  metadata: String?  # JSON: {email, ip, userAgent, attempts, etc.}
  createdAt: DateTime, default=now
```

**SecurityLogger (singleton via DI):**
```dart
class SecurityLogger {
  Future<void> log(Session session, String eventType, {String? authUserId, Map<String, dynamic>? metadata});
}
```
- Call from: `OtpEndpoint.sendOtp/verifyOtp`, `AuthRepository` (password/social login), `AdminEndpoint` (block/unblock/scope), password reset endpoints
- Always async fire-and-forget (non-blocking)

**SecurityEndpoint (admin-only):**
- `listSecurityEvents(Session session, {int limit, int offset, String? eventType, UuidValue? authUserId})`

- [ ] **Step 1: Create SecurityEvent model + migration**
- [ ] **Step 2: Implement SecurityLogger + DI registration**
- [ ] **Step 3: Add logging calls to OtpEndpoint, AuthRepository, AdminEndpoint, password reset**
- [ ] **Step 4: Implement SecurityEndpoint (admin scope required)**
- [ ] **Step 5: Tests + commit**

```bash
git add baktaz_server/lib/src/features/security/ baktaz_server/test/integration/security/
git commit -m "feat(server): security event audit log"
```

---

### Task 19: Server — Admin Email Block from OTP (Client Integration)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart`
- Test: `baktaz_flutter/test/unit/auth_repository_test.dart`

**Change:**
- In `verifyOtp` + `completeRegistration` error handling, map admin-block error to `Failure.authentication('Admin accounts cannot use OTP login')`
- `LoginCubit._onAuthError` maps to `LoginState.blocked` → `BaktazErrorScreen` (same as blocked user)

- [ ] **Step 1: Map server error to Failure**
- [ ] **Step 2: Update tests**
- [ ] **Step 3: Commit**

```bash
git add baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart
git commit -m "feat(flutter): admin email block error mapping"
```

---


### Task 20: Integration Verification

- [ ] **Step 1: Analyze all packages**

```bash
cd baktaz_server && fvm dart analyze
cd baktaz_flutter && fvm dart analyze
cd baktaz_shared && fvm dart analyze
```

- [ ] **Step 2: All tests**

```bash
cd baktaz_server && fvm dart test
cd baktaz_flutter && fvm dart test
cd baktaz_shared && fvm dart test
```

- [ ] **Step 3: Format**

```bash
cd baktaz_server && fvm dart format lib test
cd baktaz_flutter && fvm dart format lib test
cd baktaz_shared && fvm dart format lib test
```

- [ ] **Step 4: Serverpod hot_restart** (MCP) + check tail_server_logs for errors

- [ ] **Step 5: Manual smoke** — user starts `serverpod start`:
  1. Login → Email → enter email → Continue
  2. Read OTP from tail_server_logs
  3. Wrong code → error; 3 wrong → new code required
  4. Correct code, new email → RegistrationScreen → name/gender/dob → Create Account → authenticated home
  5. Correct code, existing social email → authenticated immediately (no registration)
  6. Blocked email → BlockedAccountScreen
  7. Admin login in baktaz_admin still works (password flow untouched)

- [ ] **Step 6: Final commit**

```bash
git add -u && git commit -m "fix: address integration findings"
```

```
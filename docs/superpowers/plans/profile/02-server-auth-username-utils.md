# Task 2: Server Auth & Username Derivation Logic

**Files:**
- Create: `baktaz_server/lib/src/app/utils/username_utils.dart`
- Create: `baktaz_server/test/unit/utils/username_utils_test.dart`
- Modify: `baktaz_server/lib/src/app/utils/auth_utils.dart`
- Modify: `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`

**Interfaces:**
- Consumes: `Session`, `UserInfo`, `RegistrationForm`
- Produces: `UsernameUtils.deriveFromEmail`, `UsernameUtils.ensureUniqueUsername`, updated `AuthRepository.completeRegistration`

---

TDD flow: write failing test → verify failure → implement → verify pass → refactor if needed.

---

- [ ] **Step 1: Write failing unit test for UsernameUtils**

Create `baktaz_server/test/unit/utils/username_utils_test.dart`:
```dart
import 'package:test/test.dart';
import 'package:baktaz_server/src/app/utils/username_utils.dart';

void main() {
  group('UsernameUtils', () {
    test('deriveFromEmail cleans local-part and lowercases', () {
      expect(UsernameUtils.deriveFromEmail('Juan.DelaCruz+test@Example.com'), equals('juan.delacruz'));
      expect(UsernameUtils.deriveFromEmail('user_name123@domain.org'), equals('user_name123'));
      expect(UsernameUtils.deriveFromEmail('USER123@app.co.uk'), equals('user123'));
    });

    test('deriveFromEmail returns empty for invalid email', () {
      expect(UsernameUtils.deriveFromEmail(''), equals(''));
    });
  });
}
```

---

- [ ] **Step 2: Run unit test to verify failure**

Run:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_server
fvm dart test test/unit/utils/username_utils_test.dart
```
Expected: **FAIL** with compilation error (UsernameUtils not defined).

---

- [ ] **Step 3: Implement UsernameUtils**

Create `baktaz_server/lib/src/app/utils/username_utils.dart`:
```dart
import 'dart:math';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract final class UsernameUtils {
  static String deriveFromEmail(String email) {
    final String localPart = email.trim().toLowerCase().split('@').first;
    final String cleanLocal = localPart.split('+').first;
    return cleanLocal.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
  }

  static Future<String> ensureUniqueUsername(Session session, String baseUsername) async {
    String candidate = baseUsername;
    while (await _usernameExists(session, candidate)) {
      candidate = '$baseUsername${_randomFourDigits()}';
    }
    return candidate;
  }

  static String _randomFourDigits() => (1000 + Random().nextInt(9000)).toString();

  static Future<bool> _usernameExists(Session session, String username) async {
    final int count = await UserInfo.db.count(
      session,
      where: (UserInfoTable t) => t.username.equals(username),
    );
    return count > 0;
  }
}
```

---

- [ ] **Step 4: Run unit test to verify it passes**

Run:
```bash
fvm dart test test/unit/utils/username_utils_test.dart
```
Expected: **PASS**

---

- [ ] **Step 5: Update AuthUtils**

In `baktaz_server/lib/src/app/utils/auth_utils.dart`, update `_createUserInfo` to accept and populate new fields:

```dart
static Future<UserInfo> _createUserInfo(
  Session session,
  Transaction transaction,
  String firstName,
  String lastName,
  String username,
) async {
  final UserInfo userInfo = UserInfo(
    firstName: firstName,
    lastName: lastName,
    username: username,
    gender: Gender.unknown,
  );
  return UserInfo.db.insertRow(session, userInfo, transaction: transaction);
}
```

Update `onBeforeUserProfileCreated` hook to derive username from email:
```dart
@override
Future<void> onBeforeUserProfileCreated(
  Session session,
  Transaction transaction,
  UserProfileData profileData,
) async {
  final String email = profileData.email ?? '';
  final String firstName = profileData.firstName ?? '';
  final String lastName = profileData.lastName ?? '';
  
  final baseUsername = UsernameUtils.deriveFromEmail(email);
  final username = await UsernameUtils.ensureUniqueUsername(session, baseUsername);

  await _createUserInfo(session, transaction, firstName, lastName, username);
}
```

---

- [ ] **Step 6: Update AuthRepository.completeRegistration**

In `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`, update the `completeRegistration` method:

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
      final UserProfile? existingProfile = await UserProfile.db.findFirstRow(
        session,
        where: (UserProfileTable t) => t.email.equals(normalizedEmail),
        transaction: transaction,
      );

      final String baseUsername = UsernameUtils.deriveFromEmail(normalizedEmail);
      final String uniqueUsername = await UsernameUtils.ensureUniqueUsername(session, baseUsername);

      final UserInfo userInfo = UserInfo(
        firstName: form.firstName,
        lastName: form.lastName,
        username: uniqueUsername,
        gender: Gender.values.asNameMap()[form.gender] ?? Gender.unknown,
        birthday: form.birthday,
      );

      await UserInfo.db.insertRow(session, userInfo, transaction: transaction);

      // ... rest of existing registration logic (createUserProfile, etc.)
    });
  } on OtpException {
    rethrow;
  } catch (e, st) {
    session.log('Failed to complete registration: $e', stackTrace: st);
    throw ApiException(
      message: 'Failed to complete registration',
      code: ApiExceptionCode.internal,
    );
  }
}
```

---

- [ ] **Step 7: Run auth repository tests**

Run:
```bash
fvm dart test test/unit/features/auth/auth_repository_test.dart
```
Expected: All existing tests still PASS.

If no test file exists, create `baktaz_server/test/unit/features/auth/auth_repository_test.dart` with tests for:
- `completeRegistration` creates UserInfo with firstName, lastName, username
- Username auto-derived from email
- Collision handling appends 4-digit suffix

---

- [ ] **Step 8: Commit auth logic**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_server/lib/src/app/utils/ baktaz_server/lib/src/features/auth/ baktaz_server/test/unit/utils/
git commit -m "feat(server): implement UsernameUtils and update completeRegistration flow with firstName/lastName/username"
```

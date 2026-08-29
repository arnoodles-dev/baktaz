# Profile Header & Lifetime Stats — Auth & Username Derivation

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/profile/00-overview.md`

---

## 1. Username Derivation Logic

**Location:** `baktaz_server/lib/src/app/utils/username_utils.dart`

### deriveFromEmail

```dart
static String deriveFromEmail(String email) {
  final String localPart = email.trim().toLowerCase().split('@').first;
  final String cleanLocal = localPart.split('+').first;
  return cleanLocal.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
}
```

**Examples:**
| Input Email | Derived Username |
|---|---|
| `Juan.DelaCruz+test@Example.com` | `juan.delacruz` |
| `user_name123@domain.org` | `user_name123` |
| `USER123@app.co.uk` | `user123` |

**Rules:**
- Lowercase everything
- Strip `@domain` suffix
- Remove `+tag` suffix (everything after `+`)
- Remove non-alphanumeric except `.`, `_`, `-`

### ensureUniqueUsername (Collision Handling)

```dart
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
```

**Collision strategy:**
- Append random 4-digit suffix: `juan.delacruz` → `juan.delacruz7291`
- Loop until unique (handles edge case of another collision on the suffix)

---

## 2. AuthUtils Updates

**File:** `baktaz_server/lib/src/app/utils/auth_utils.dart`

### Updated `_createUserInfo`

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

### Updated `onBeforeUserProfileCreated` Hook

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

**Notes:**
- For OTP registration: `profileData.firstName`/`lastName` come from `RegistrationForm`
- For social login: `profileData` may have `firstName`/`lastName` from provider; if not, derive from email local-part

---

## 3. AuthRepository.completeRegistration Updates

**File:** `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`

### Changes to `completeRegistration`

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
      // ... existing user profile checks ...

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

      // ... rest of existing registration logic ...
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

## 4. Social Login Username Derivation

For social logins (Google, Facebook), `serverpod_auth_idp_flutter` handles the initial authentication. The `onBeforeUserProfileCreated` hook runs after the provider creates the profile.

**Fallback if provider doesn't supply firstName/lastName:**

```dart
// Inside onBeforeUserProfileCreated
final String localPart = email.split('@').first;
final List<String> parts = localPart.split('.');
final String derivedFirstName = parts.isNotEmpty ? parts.first.capitalize() : 'User';
final String derivedLastName = parts.length > 1 ? parts.skip(1).join(' ').capitalize() : 'User';
```

Then pass `derivedFirstName`/`derivedLastName` to `_createUserInfo`.

---

## 5. Migration Backfill Strategy

**Assumption:** No existing users in production (per decision in grilling session).

If backfill were needed for existing users:
1. Derive username from email (local-part, lowercase)
2. Split `UserProfile.fullName` on first space → `firstName`, `lastName`
3. Resolve username collisions with 4-digit suffix
4. Run as part of migration SQL

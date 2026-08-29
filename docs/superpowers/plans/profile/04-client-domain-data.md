# Task 4: Client Domain & Data Layer Updates

**Files:**
- Modify: `baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart`
- Modify: `baktaz_flutter/lib/features/account/domain/entity/model/profile.dart`
- Modify: `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`
- Modify: `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`
- Modify: `baktaz_flutter/assets/i18n/en.i18n.json` (add new keys)

**Interfaces:**
- Consumes: `baktaz_client` generated models (`AccountSummary`, `Profile`, `UpdateProfileRequest`, `AvatarUploadUrl`)
- Produces: Updated Flutter `AccountSummary`, `Profile` freezed entities, and `IAccountRepository` methods (`updateProfile`, `getAvatarUploadUrl`, `getLinkedProviders`).

---

- [ ] **Step 1: Update Flutter AccountSummary entity**

Modify `baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_summary.freezed.dart';

@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required ValueName name,
    required Money balance,
    required Number connect,
    Url? imageUrl,
    LocalDateTime? memberSince,
    required Number totalChallengeSteps,
    required Number challengesJoined,
    required Number challengesWon,
    required Number winRatePercentage,
  }) = _AccountSummary;

  const AccountSummary._();

  factory AccountSummary.fromServer(serverpod.AccountSummary accountSummary) => AccountSummary(
    name: ValueName(accountSummary.name),
    balance: Money(accountSummary.cashBalance),
    connect: Number(accountSummary.connectBalance),
    imageUrl: accountSummary.imageUrl.let((Uri uri) => Url(uri.toString())),
    memberSince: accountSummary.memberSince.let(LocalDateTime.new),
    totalChallengeSteps: Number(accountSummary.totalChallengeSteps),
    challengesJoined: Number(accountSummary.challengesJoined),
    challengesWon: Number(accountSummary.challengesWon),
    winRatePercentage: Number(accountSummary.winRatePercentage),
  );

  Option<Failure> get validate => name.validate
      .andThen(() => imageUrl?.validate ?? right(unit))
      .andThen(() => balance.validate)
      .andThen(() => connect.validate)
      .andThen(() => memberSince?.validate ?? right(unit))
      .andThen(() => totalChallengeSteps.validate)
      .andThen(() => challengesJoined.validate)
      .andThen(() => challengesWon.validate)
      .andThen(() => winRatePercentage.validate)
      .fold(some, (_) => none());
}
```

---

- [ ] **Step 2: Update Flutter Profile entity**

Modify `baktaz_flutter/lib/features/account/domain/entity/model/profile.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart'
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required ValueName firstName,
    required ValueName lastName,
    required ValueName username,
    required serverpod.Gender gender,
    EmailAddress? email,
    MobileNumber? mobileNumber,
    LocalDateTime? birthday,
    Number? age,
    Url? imageUrl,
    LocalDateTime? updatedAt,
  }) = _Profile;

  const Profile._();

  factory Profile.fromServer(serverpod.Profile profile) => Profile(
    firstName: ValueName(profile.firstName),
    lastName: ValueName(profile.lastName),
    username: ValueName(profile.username),
    gender: profile.gender,
    birthday: profile.birthday.let(LocalDateTime.new),
    age: profile.age.let(Number.new),
    imageUrl: profile.imageUrl.let((Uri uri) => Url(uri.toString())),
    updatedAt: profile.updatedAt.let(LocalDateTime.new),
    email: profile.email.let(EmailAddress.new),
    mobileNumber: profile.mobileNumber.let(MobileNumber.new),
  );

  Option<Failure> get validate => firstName.validate
      .andThen(() => lastName.validate)
      .andThen(() => username.validate)
      .andThen(() => email?.validate ?? right(unit))
      .andThen(() => mobileNumber?.validate ?? right(unit))
      .andThen(() => age?.validate ?? right(unit))
      .andThen(() => imageUrl?.validate ?? right(unit))
      .fold(some, (_) => none());
}
```

---

- [ ] **Step 3: Update IAccountRepository**

Modify `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`:
```dart
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAccountRepository {
  TaskResult<AccountSummary> getAccountSummary();
  TaskResult<Profile> getProfile();
  TaskResult<Profile> updateProfile({
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? birthday,
    String? gender,
    String? avatarUrl,
  });
  TaskResult<serverpod.AvatarUploadUrl> getAvatarUploadUrl();
  TaskResult<List<String>> getLinkedProviders();
  TaskResult<Unit> addAddress(Address address);
  TaskResult<Address?> getDefaultAddress();
  TaskResult<Unit> deleteAccount();
}
```

---

- [ ] **Step 4: Update AccountRepository implementation**

Modify `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/config/app_config.dart';
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IAccountRepository)
final class AccountRepository implements IAccountRepository {
  const AccountRepository(this._serverpod, this._retry, this._talker);

  final Serverpod _serverpod;
  final RetryOptions _retry;
  final Talker _talker;

  @override
  TaskResult<AccountSummary> getAccountSummary() => TaskResult<AccountSummary>.tryCatch(
    () async {
      final serverpod.AccountSummary? result = await _retry.retry(
        () => _serverpod.client.account.getAccountSummary(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      if (result == null) throw const FormatException('Account summary is null');

      if (AppConfig.environment == Env.development && TargetPlatform.android == defaultTargetPlatform) {
        result.imageUrl = result.imageUrl.let(
          (Uri uri) => Uri.parse(uri.toString().replaceAll('http://localhost:8080/', 'http://10.0.2.2:8080/')),
        );
      }

      final AccountSummary possibleFailure = AccountSummary.fromServer(result);
      if (possibleFailure.validate.isSome()) throw possibleFailure.validate.asSome();
      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<Profile> getProfile() => TaskResult<Profile>.tryCatch(
    () async {
      final serverpod.Profile? result = await _retry.retry(
        () => _serverpod.client.account.getProfile(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      if (result == null) throw const FormatException('Profile is null');

      if (AppConfig.environment == Env.development && TargetPlatform.android == defaultTargetPlatform) {
        result.imageUrl = result.imageUrl.let(
          (Uri uri) => Uri.parse(uri.toString().replaceAll('http://localhost:8080/', 'http://10.0.2.2:8080/')),
        );
      }

      final Profile possibleFailure = Profile.fromServer(result);
      if (possibleFailure.validate.isSome()) throw possibleFailure.validate.asSome();
      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<Profile> updateProfile({
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? birthday,
    String? gender,
    String? avatarUrl,
  }) => TaskResult<Profile>.tryCatch(
    () async {
      final serverpod.Profile? result = await _retry.retry(
        () => _serverpod.client.account.updateProfile(UpdateProfileRequest(
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobileNumber,
          birthday: birthday,
          gender: gender,
          avatarUrl: avatarUrl,
        )),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      if (result == null) throw const FormatException('Profile update returned null');

      final Profile possibleFailure = Profile.fromServer(result);
      if (possibleFailure.validate.isSome()) throw possibleFailure.validate.asSome();
      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<serverpod.AvatarUploadUrl> getAvatarUploadUrl() => TaskResult<serverpod.AvatarUploadUrl>.tryCatch(
    () async {
      final serverpod.AvatarUploadUrl? result = await _retry.retry(
        () => _serverpod.client.account.getAvatarUploadUrl(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      if (result == null) throw const FormatException('Avatar upload URL is null');
      return result;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<List<String>> getLinkedProviders() => TaskResult<List<String>>.tryCatch(
    () async {
      final List<String>? result = await _retry.retry(
        () => _serverpod.client.account.getLinkedProviders(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );
      return result ?? <String>[];
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  // ... existing addAddress, getDefaultAddress, deleteAccount
}
```

---

- [ ] **Step 5: Run build_runner on baktaz_flutter**

Run:
```bash
cd /Users/Arnold/Projects/baktaz/baktaz_flutter
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
Expected: Freezed code regenerated without conflicts.

---

- [ ] **Step 6: Update i18n JSON file**

Modify `baktaz_flutter/assets/i18n/en.i18n.json`, add keys under `"account"`:
```json
"account": {
  "total_challenge_steps": "Total Steps",
  "challenges_joined": "Joined",
  "challenges_won": "Won",
  "win_rate": "Win Rate",
  "member_since": "Member since {date}",
  "first_name": "First Name",
  "last_name": "Last Name",
  "username": "Username",
  "social_providers": "Linked Accounts",
  "google": "Google",
  "facebook": "Facebook",
  "linked": "Linked",
  "not_linked": "Not Linked",
  "avatar": "Profile Photo",
  "remove_photo": "Remove Photo",
  "take_photo": "Take Photo",
  "choose_from_gallery": "Choose from Gallery",
  "email": "Email",
  "change_email": "Change Email",
  "username_taken": "This username is already taken",
  "username_invalid": "Username must be 3-20 alphanumeric characters",
  "avatar_upload_failed": "Failed to upload avatar",
  "avatar_removed": "Avatar removed"
}
```

---

- [ ] **Step 7: Run make codegen_flutter if needed**

Run:
```bash
cd /Users/Arnold/Projects/baktaz
rtk make codegen_flutter
```

---

- [ ] **Step 8: Commit Flutter Domain/Data changes**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_flutter/
git commit -m "feat(flutter): update AccountSummary and Profile entities, repo interface, and i18n keys"
```

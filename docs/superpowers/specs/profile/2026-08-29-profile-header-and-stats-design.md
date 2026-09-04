# Profile Header & Lifetime Stats — Design Spec

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Status:** Draft  
> **Parent Spec:** `docs/superpowers/specs/account/2026-08-28-00-overview.md`  
> **Scope:** Server model changes, Auth flow updates, AccountPage header, ProfileScreen rewrite

---

## 1. Overview & Scope

This spec covers three interconnected changes to the Baktaz account surface:

| Change | Package | Files |
|---|---|---|
| Profile Header & Lifetime Stats | `baktaz_server` + `baktaz_flutter` | `account_summary`, `AccountPage`, `AccountCubit` |
| Auth/Registration updates | `baktaz_server` + `baktaz_flutter` | `registration_form`, `AuthUtils`, `RegistrationScreen` |
| ProfileScreen rewrite | `baktaz_flutter` | `profile_screen`, `ProfileCubit`, new edit flow |

### Out of Scope (Deferred)
- Host subscription banners (`HostSubscriptionBanner`)
- Payment management (`PaymentPayoutScreen`)
- Steps sync diagnostics (`StepsSyncScreen`)
- Settings screens (notifications, language, dark mode)
- Support/Legal screens
- Challenge table implementation (Challenge feature not yet built)

### Key Decisions

| Decision | Rationale |
|---|---|
| `UserInfo` stores `firstName` + `lastName` (no `fullName`) | Matches existing migration schema which has `firstName`/`lastName` columns |
| Username auto-derived from email | Eliminates manual username input; collision handled server-side with 4-digit suffix |
| Collision suffix: random 4-digit, lowercase only | Simpler than sequential; `juan.delacruz` → `juan.delacruz7291` |
| `memberSince` removed from `UserInfo`, use `Account.createdAt` | Single source of truth; `Account` already has `createdAt` |
| `AccountChallengeStats` computed on-demand | No persistence needed; derived from step telemetry at query time |
| Backfill runs as migration | Existing users get `firstName`/`lastName`/`username` without code changes |
| Social login linking is one-way | Prevents accidental unlinking; user can only add, not remove |
| MVP only — no payment models | HostSubscriptionBanner, PaymentPayoutScreen deferred |

---

## 2. Server Model Changes

### 2.1 `UserInfo` (`user_info.spy.yaml`)

**Current** (`baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml`):
```yaml
class: UserInfo
table: user_info
fields:
  id: UuidValue?, defaultPersist=random
  gender: Gender, default=unknown
  birthday: DateTime?
  updatedAt: DateTime?
  mobileNumber: String?
```

**Proposed**:
```yaml
class: UserInfo
table: user_info
fields:
  id: UuidValue?, defaultPersist=random
  firstName: String
  lastName: String
  username: String
  gender: Gender, default=unknown
  birthday: DateTime?
  updatedAt: DateTime?
  mobileNumber: String?
indexes:
  username_unique_idx:
    fields: username
    unique: true
```

**Changes**:
- Removed: `fullName` (was never in server model — it lives in `UserProfile`)
- Added: `firstName: String`
- Added: `lastName: String`
- Added: `username: String` (unique)
- `username` requires unique DB index

### 2.2 `AccountSummary` — Add Challenge Stats

**Current** (`account_summary.spy.yaml`):
```yaml
class: AccountSummary
fields:
  name: String
  imageUrl: Uri?
  cashBalance: double
  connectBalance: int
```

**Proposed**:
```yaml
class: AccountSummary
fields:
  name: String
  imageUrl: Uri?
  cashBalance: double
  connectBalance: int
  memberSince: DateTime
  totalChallengeSteps: int
  challengesJoined: int
  challengesWon: int
  winRatePercentage: double
```

**Notes**:
- `memberSince` mapped from `Account.createdAt` in endpoint
- Challenge stats computed on-demand (see §2.5)
- No new DB table — stats are derived at query time

### 2.3 `RegistrationForm` — Split Name into firstName/lastName

**Current** (`registration_form.spy.yaml`):
```yaml
class: RegistrationForm
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

**Proposed**:
```yaml
class: RegistrationForm
fields:
  email: String
  firstName: String
  lastName: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

**Changes**:
- Removed: `name: String`
- Added: `firstName: String`
- Added: `lastName: String`

### 2.4 New: `AccountChallengeStats` (Serverpod DTO, not table)

```yaml
class: AccountChallengeStats
fields:
  totalChallengeSteps: int
  challengesJoined: int
  challengesWon: int
  winRatePercentage: double
```

**Purpose**: Returned as part of `AccountSummary`. Computed on-demand from step telemetry data (see §2.5). No DB table — Serverpod DTO only.

### 2.5 Challenge Stats Computation

**Location**: `baktaz_server/lib/src/features/account/data/repository/account_challenge_stats_repository.dart`

**Interface**:
```dart
abstract interface class IAccountChallengeStatsRepository {
  Future<AccountChallengeStats> computeChallengeStats(Session session);
}
```

**Implementation notes**:
- Queries step telemetry tables (daily step records) for challenge-related steps
- `totalChallengeSteps`: Sum of steps recorded during active/completed challenges
- `challengesJoined`: Count of unique challenge participations
- `challengesWon`: Count of challenges where user placed #1
- `winRatePercentage`: `(challengesWon / challengesJoined) * 100`, rounded to 1 decimal, `0.0` if `challengesJoined == 0`

**MVP constraint**: Challenge domain models do not yet exist. The repository method returns zeros until Challenge tables are implemented. This is a stub that returns `AccountChallengeStats(totalChallengeSteps: 0, challengesJoined: 0, challengesWon: 0, winRatePercentage: 0.0)` until challenge infrastructure is built.

### 2.6 `Profile` Model — Add username, firstName, lastName

**Current** (`profile.spy.yaml`):
```yaml
class: Profile
fields:
  fullName: String
  gender: Gender
  email: String?
  mobileNumber: String?
  birthday: DateTime?
  age: int?
  imageUrl: Uri?
  updatedAt: DateTime?
```

**Proposed**:
```yaml
class: Profile
fields:
  firstName: String
  lastName: String
  username: String
  gender: Gender
  email: String?
  mobileNumber: String?
  birthday: DateTime?
  age: int?
  imageUrl: Uri?
  updatedAt: DateTime?
```

**Changes**:
- Removed: `fullName: String`
- Added: `firstName: String`
- Added: `lastName: String`
- Added: `username: String`

---

## 3. Server Auth Changes

### 3.1 Username Derivation Logic

**Location**: `baktaz_server/lib/src/app/utils/auth_utils.dart`

**Current behavior** (`onBeforeUserProfileCreated`):
```dart
if (userProfile.userName == null && userProfile.email != null) {
  userProfile.userName = userProfile.email?.split('@').first;
}
```

**New behavior** — derive username from email with collision handling:

```dart
/// Derives a unique username from email with collision handling.
/// Collisions resolved by appending a 4-digit random suffix.
/// Examples:
///   juan.delacruz@example.com → juan.delacruz
///   juan.delacruz@example.com (collision) → juan.delacruz7291
///   JUAN.DE LA CRUZ @Example.COM → juan.delacruz
static Future<String> deriveUsername(
  Session session,
  String email,
) async {
  final String base = email
      .trim()
      .toLowerCase()
      .split('@')
      .first
      .replaceAll(RegExp(r'[^a-z0-9._-]'), '');

  // Check for collision
  final int? existing = await session.db.selectCount(
    session.db.table('user_info'),
    where: (t) => t.rawExpr('username = ?', [base]),
  );

  if (existing == 0) return base;

  // Collision: append random 4-digit suffix
  final String suffix = DateTime.now().microsecondsSinceEpoch.toString().substring(8, 12);
  return '$base$suffix';
}
```

**Called from**:
1. `onBeforeUserProfileCreated` in `AuthUtils` (for social login flows)
2. `completeRegistration` in `AuthRepository` (for OTP registration)

### 3.2 `AuthRepository.completeRegistration` Changes

**File**: `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`

**Current** (relevant section):
```dart
await AuthServices.instance.userProfiles.createUserProfile(
  session,
  authUser.id,
  UserProfileData(fullName: form.name, email: normalizedEmail),
  transaction: transaction,
);
```

**New** (after model changes):
```dart
// Derive username from email
final String username = await AuthUtils.deriveUsername(session, normalizedEmail);

await AuthServices.instance.userProfiles.createUserProfile(
  session,
  authUser.id,
  UserProfileData(firstName: form.firstName, lastName: form.lastName, email: normalizedEmail),
  transaction: transaction,
);

// Create UserInfo with derived username
final UserInfo userInfo = UserInfo(
  firstName: form.firstName,
  lastName: form.lastName,
  username: username,
  gender: Gender.values.asNameMap()[form.gender] ?? Gender.unknown,
  birthday: form.birthday,
);
await UserInfo.db.insertRow(session, userInfo, transaction: transaction);

// Link UserInfo to Account (via account.userInfoId)
await Account.db.updateRow(
  session,
  account.copyWith(userInfoId: userInfo.id),
  transaction: transaction,
);
```

### 3.3 `AuthUtils.onBeforeUserProfileCreated` — Social Login

**File**: `baktaz_server/lib/src/app/utils/auth_utils.dart`

**Current**:
```dart
if (userProfile.userName == null && userProfile.email != null) {
  userProfile.userName = userProfile.email?.split('@').first;
}
if (userProfile.fullName == null && userProfile.userName != null) {
  userProfile.fullName = userProfile.userName;
}
```

**New**:
```dart
// Derive username from email with collision handling
final String email = userProfile.email ?? '';
final String username = await deriveUsername(session, email);
userProfile.userName = username;

// Set firstName/lastName from email local part if not provided
if (userProfile.firstName == null && email.isNotEmpty) {
  final String localPart = email.split('@').first;
  final List<String> parts = localPart.split('.');
  userProfile.firstName = parts.isNotEmpty ? parts.first : localPart;
  if (parts.length > 1) {
    userProfile.lastName = parts.skip(1).join(' ');
  }
}
// Fallback: use username as fullName if both first/last are null
if (userProfile.firstName == null && userProfile.lastName == null) {
  userProfile.fullName = username;
}
```

### 3.4 Social Login Linking (One-Way)

**One-way linking** means: user can link Google/Facebook account to existing email account, but cannot unlink.

**New endpoint**: `POST /account/linkSocialProvider`

```dart
// baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart
Future<void> linkSocialProvider(
  Session session,
  SocialProviderLinkRequest request,
) async {
  final UuidValue? authUserId = session.authenticated?.authUserId;
  if (authUserId == null) {
    throw ApiException(
      message: 'User not authenticated',
      code: ApiExceptionCode.unauthenticated,
    );
  }

  await session.db.transaction((Transaction tx) async {
    // Find existing social account
    final existing = await SocialAccount.db.findFirstRow(
      session,
      where: (SocialAccountTable t) =>
          t.provider.equals(request.provider) &
          t.providerUserId.equals(request.providerUserId),
      transaction: tx,
    );

    if (existing != null) {
      // Check if already linked to another user
      if (existing.authUserId != authUserId) {
        throw ApiException(
          message: 'This $request.provider account is already linked to another Baktaz account',
          code: ApiExceptionCode.badRequest,
        );
      }
      return; // Already linked
    }

    // Link to current user
    await SocialAccount.db.insertRow(
      session,
      SocialAccount(
        authUserId: authUserId,
        provider: request.provider,
        providerUserId: request.providerUserId,
        createdAt: DateTime.now(),
      ),
      transaction: tx,
    );

    await _securityLogger.log(
      session,
      'social_link',
      authUserId: authUserId,
      metadata: '{"provider":"${request.provider}"}',
      transaction: tx,
    );
  });
}
```

**Request DTO** (new):
```yaml
# baktaz_server/lib/src/features/account/domain/model/social_provider_link_request.spy.yaml
class: SocialProviderLinkRequest
fields:
  provider: String      # google, facebook
  providerUserId: String
```

**Note**: The unlink endpoint is intentionally NOT implemented (one-way linking).

---

## 4. Server Account Endpoint Changes

### 4.1 `getAccountSummary` — Add memberSince and Challenge Stats

**File**: `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart`

**Current**:
```dart
Future<AccountSummary?> getAccountSummary(Session session) async {
  final Account? account = await getCurrentAccount(session);
  if (account == null) return null;

  return AccountSummary(
    name: account.userProfile?.fullName ?? 'Baktaz Walker',
    cashBalance: account.wallet?.cashBalance ?? 0,
    connectBalance: account.wallet?.connectBalance ?? 0,
  );
}
```

**New**:
```dart
Future<AccountSummary?> getAccountSummary(Session session) async {
  final Account? account = await getCurrentAccount(session);
  if (account == null) return null;

  final UserInfo? userInfo = account.userInfo;
  final String firstName = userInfo?.firstName ?? account.userProfile?.firstName ?? '';
  final String lastName = userInfo?.lastName ?? account.userProfile?.lastName ?? '';
  final String displayName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

  final AccountChallengeStats stats =
      await _challengeStatsRepository.computeChallengeStats(session);

  return AccountSummary(
    name: displayName.isNotEmpty ? displayName : account.userProfile?.fullName ?? 'Baktaz Walker',
    imageUrl: userInfo?.avatarUrl,
    cashBalance: account.wallet?.cashBalance ?? 0,
    connectBalance: account.wallet?.connectBalance ?? 0,
    memberSince: account.createdAt,
    totalChallengeSteps: stats.totalChallengeSteps,
    challengesJoined: stats.challengesJoined,
    challengesWon: stats.challengesWon,
    winRatePercentage: stats.winRatePercentage,
  );
}
```

### 4.2 `getProfile` — Add firstName, lastName, username

**Current**:
```dart
Future<Profile?> getProfile(Session session) async {
  final Account? account = await getCurrentAccount(session);
  if (account == null) return null;

  return Profile(
    fullName: account.userProfile?.fullName ?? 'Baktaz Walker',
    gender: account.userInfo?.gender ?? Gender.unknown,
    email: account.userProfile?.email,
    mobileNumber: account.userInfo?.mobileNumber,
    birthday: account.userInfo?.birthday,
    updatedAt: account.userInfo?.updatedAt,
  );
}
```

**New**:
```dart
Future<Profile?> getProfile(Session session) async {
  final Account? account = await getCurrentAccount(session);
  if (account == null) return null;

  final UserInfo? userInfo = account.userInfo;
  final UserProfile? userProfile = account.userProfile;

  return Profile(
    firstName: userInfo?.firstName ?? userProfile?.firstName ?? '',
    lastName: userInfo?.lastName ?? userProfile?.lastName ?? '',
    username: userInfo?.username ?? '',
    gender: userInfo?.gender ?? Gender.unknown,
    email: userProfile?.email,
    mobileNumber: userInfo?.mobileNumber,
    birthday: userInfo?.birthday,
    age: userInfo?.birthday?.value.age,
    imageUrl: userInfo?.avatarUrl ?? userProfile?.imageUrl,
    updatedAt: userInfo?.updatedAt,
  );
}
```

### 4.3 New: `updateProfile` Endpoint

**Endpoint**: `POST /account/updateProfile`

**Request DTO** (new):
```yaml
# baktaz_server/lib/src/features/account/domain/model/update_profile_request.spy.yaml
class: UpdateProfileRequest
fields:
  firstName: String
  lastName: String
  mobileNumber: String?
  birthday: DateTime?
  gender: String?
  avatarUrl: String?
```

**Implementation**:
```dart
Future<Profile> updateProfile(Session session, UpdateProfileRequest request) async {
  final UuidValue? authUserId = session.authenticated?.authUserId;
  if (authUserId == null) {
    throw ApiException(
      message: 'User not authenticated',
      code: ApiExceptionCode.unauthenticated,
    );
  }

  final Account? account = await getCurrentAccount(session);
  if (account == null) {
    throw ApiException(
      message: 'Account not found',
      code: ApiExceptionCode.notFound,
    );
  }

  final UserInfo? userInfo = account.userInfo;
  if (userInfo == null) {
    throw ApiException(
      message: 'User info not found',
      code: ApiExceptionCode.notFound,
    );
  }

  await session.db.transaction((Transaction tx) async {
    // Update UserInfo
    final UserInfo updatedUserInfo = userInfo.copyWith(
      firstName: request.firstName,
      lastName: request.lastName,
      mobileNumber: request.mobileNumber,
      birthday: request.birthday,
      avatarUrl: request.avatarUrl ?? userInfo.avatarUrl,
      gender: request.gender != null
          ? (Gender.values.asNameMap()[request.gender!] ?? Gender.unknown)
          : userInfo.gender,
      updatedAt: DateTime.now(),
    );
    await UserInfo.db.updateRow(session, updatedUserInfo, transaction: tx);

    // Update UserProfile fullName if it differs
    final UserProfile? userProfile = account.userProfile;
    if (userProfile != null) {
      final String newFullName =
          [request.firstName, request.lastName].where((s) => s.isNotEmpty).join(' ').trim();
      if (newFullName.isNotEmpty && userProfile.fullName != newFullName) {
        await UserProfile.db.updateRow(
          session,
          userProfile.copyWith(fullName: newFullName, updatedAt: DateTime.now()),
          transaction: tx,
        );
      }
    }
  });

  // Return updated profile
  return getProfile(session);
}
```

### 4.4 New: `getAvatarUploadUrl` Endpoint (Presigned URL)

**Purpose**: Generate presigned S3/GCS upload URL for avatar image.

**Serverpod Setup Required**:
1. `generator.yaml` — configure `fileRepository` with S3 bucket
2. `UploadDescription` — define avatar upload (max 5MB, jpeg/png/webp)

**New endpoint**: `GET /account/avatarUploadUrl`

**Response DTO**:
```yaml
# baktaz_server/lib/src/features/account/domain/model/avatar_upload_url.spy.yaml
class: AvatarUploadUrl
fields:
  uploadUrl: String
  fileKey: String
  expiresAt: DateTime
```

**Implementation**:
```dart
Future<AvatarUploadUrl> getAvatarUploadUrl(Session session) async {
  final UuidValue? authUserId = session.authenticated?.authUserId;
  if (authUserId == null) {
    throw ApiException(
      message: 'User not authenticated',
      code: ApiExceptionCode.unauthenticated,
    );
  }

  final String fileKey = 'avatars/$authUserId/${DateTime.now().millisecondsSinceEpoch}.webp';

  final FileRepository fileRepo = session.server.fileRepository;
  final String presignedUrl = await fileRepo.getUploadUrl(
    fileKey,
    duration: const Duration(minutes: 10),
  );

  return AvatarUploadUrl(
    uploadUrl: presignedUrl,
    fileKey: fileKey,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
}
```

### 4.5 Update `updateProfile` Request DTO

Add `avatarUrl: String?` field to `UpdateProfileRequest`.

**Updated Request DTO**:
```yaml
# baktaz_server/lib/src/features/account/domain/model/update_profile_request.spy.yaml
class: UpdateProfileRequest
fields:
  firstName: String
  lastName: String
  mobileNumber: String?
  birthday: DateTime?
  gender: String?
  avatarUrl: String?
```

---

## 5. Flutter UI Changes

### 5.1 AccountPage — Profile Header with Lifetime Stats

**File**: `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart`

**Current state**: Shows avatar + name in `SliverAppBar`, no stats.

**Changes needed**:
1. Update `AccountSummary` entity to include challenge stats and memberSince
2. Update `AccountCubit` to use new `AccountSummary` fields
3. Update `_AccountAppBar` to show:
   - Expanded: avatar (80px) + firstName + lastName + username + member since
   - Collapsed: avatar (48px) + firstName + lastName + username
4. Add `ChallengeStatsGrid` below header (4-column grid)

**New `AccountSummary` entity** (`baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart`):
```dart
@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required ValueName name,
    required ValueName firstName,
    required ValueName lastName,
    required ValueName username,
    required Money balance,
    required Number connect,
    Url? imageUrl,
    LocalDateTime? memberSince,
    required Number totalChallengeSteps,
    required Number challengesJoined,
    required Number challengesWon,
    required Number winRatePercentage,
  }) = _AccountSummary;
  // ... fromServer mapping, validate
}
```

**`AccountCubit` changes**:
- No changes to cubit logic — only state model changes
- `initialize()` still calls `getAccountSummary()` — mapping happens in `AccountSummary.fromServer()`

**New `_AccountAppBar` layout**:
```dart
class _AccountAppBar extends StatelessWidget {
  const _AccountAppBar({
    required this.name,
    required this.username,
    required this.memberSince,
    required this.isSliverAppBarExpanded,
    required this.avatarSize,
    required this.titleStyle,
    required this.imageUrl,
    this.isLoading = false,
  });

  final String name;
  final String username;
  final DateTime? memberSince;
  final bool isSliverAppBarExpanded;
  final double avatarSize;
  final TextStyle? titleStyle;
  final Url? imageUrl;
  final bool isLoading;

  static Widget loading({
    required double avatarSize,
    required TextStyle? titleStyle,
  }) => _AccountAppBar(
    isSliverAppBarExpanded: true,
    avatarSize: avatarSize,
    titleStyle: titleStyle,
    imageUrl: null,
    name: '',
    username: '',
    memberSince: null,
    isLoading: true,
  );

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    child: Row(
      children: <Widget>[
        Gap.medium(),
        BaktazAvatar(
          size: avatarSize,
          imageUrl: imageUrl?.getValue(),
          isCachedSize: false,
          maxSize: 80,
          isLoading: isLoading,
        ),
        Gap.xSmall(),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(text: name, style: titleStyle),
              if (username.isNotEmpty) ...[
                Gap.x2Small(),
                BaktazText(
                  text: '@$username',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.outline,
                  ),
                ),
              ],
              if (memberSince != null && isSliverAppBarExpanded) ...[
                Gap.x2Small(),
                BaktazText(
                  text: 'Member since ${DateFormat.yMMM().format(memberSince!)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
```

**New `ChallengeStatsGrid` widget**:
```dart
class ChallengeStatsGrid extends StatelessWidget {
  const ChallengeStatsGrid({
    required this.isLoading,
    required this.totalChallengeSteps,
    required this.challengesJoined,
    required this.challengesWon,
    required this.winRatePercentage,
    super.key,
  });

  final bool isLoading;
  final int totalChallengeSteps;
  final int challengesJoined;
  final int challengesWon;
  final double winRatePercentage;

  @override
  Widget build(BuildContext context) => Padding(
    padding: Paddings.horizontalMedium,
    child: Skeletonizer(
      enabled: isLoading,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatCard(
              value: NumberFormatter.format(totalChallengeSteps),
              label: context.i18n.account_totalChallengeSteps,
              icon: right(Icons.directions_walk),
            ),
          ),
          Gap.small(),
          Expanded(
            child: _StatCard(
              value: '$challengesJoined',
              label: context.i18n.account_challengesJoined,
              icon: right(Icons.groups),
            ),
          ),
          Gap.small(),
          Expanded(
            child: _StatCard(
              value: '$challengesWon',
              label: context.i18n.account_challengesWon,
              icon: right(Icons.emoji_events),
            ),
          ),
          Gap.small(),
          Expanded(
            child: _StatCard(
              value: '${winRatePercentage.toStringAsFixed(1)}%',
              label: context.i18n.account_winRate,
              icon: right(Icons.percent),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final Either<String, IconData> icon;

  @override
  Widget build(BuildContext context) => BaktazCard(
    child: Padding(
      padding: Paddings.allMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(
            text: value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: AppFontWeight.bold,
            ),
          ),
          Gap.x2Small(),
          BaktazText(
            text: label,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
```

### 5.2 RegistrationScreen & ProfileScreen — Avatar Upload Flow

**ProfileScreen avatar editing**:
- Tap avatar → bottom sheet: "Take Photo", "Choose from Gallery", "Remove Photo"
- On image selected:
  1. Call `getAvatarUploadUrl()`
  2. HTTP PUT image to presigned URL
  3. On success, call `updateProfile(avatarUrl: permanentUrl)`
  4. Refresh profile display

**Permanent URL format**: `https://bucket.s3.region.amazonaws.com/avatars/{userId}/{timestamp}.webp`

### 5.3 AccountPage — Avatar Display

Use `avatarUrl` from `AccountSummary.imageUrl` (already added).

### 5.4 RegistrationScreen — First Name, Last Name, Auto-Username

**File**: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`

**Current**: Single `name` field → `RegistrationForm.name`

**Changes**:
1. Replace `nameController` with `firstNameController` and `lastNameController`
2. Update form submission to send `firstName` and `lastName` separately
3. Add hint text explaining username is auto-generated

**New form fields**:
```dart
final TextEditingController firstNameController = useTextEditingController();
final TextEditingController lastNameController = useTextEditingController();
```

**Form submission**:
```dart
context.read<LoginCubit>().completeRegistration(
  RegistrationForm(
    email: email,
    firstName: firstNameController.text.trim(),
    lastName: lastNameController.text.trim(),
    gender: selectedGender.value!.name,
    birthday: selectedBirthday.value,
    registrationToken: registrationToken,
  ),
);
```

**UI layout**:
```dart
// First Name
BaktazText(text: context.i18n.register.label.first_name),
BaktazTextField(
  controller: firstNameController,
  hintText: context.i18n.register.hint.first_name,
  validator: ValidationUtils.requiredValidator,
),

// Last Name
BaktazText(text: context.i18n.register.label.last_name),
BaktazTextField(
  controller: lastNameController,
  hintText: context.i18n.register.hint.last_name,
  validator: ValidationUtils.requiredValidator,
),

// Username hint (read-only info, not input)
BaktazText(
  text: context.i18n.register.hint.username_auto_generated,
  style: context.textTheme.bodySmall?.copyWith(
    color: context.colorScheme.outline,
  ),
);
```

### 5.5 ProfileScreen — Full Rewrite

**File**: `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/profile_screen.dart`

**Current state**: Shows `fullName`, `gender`, `birthday`, `age`, `mobileNumber`, `email`. Has TODO stubs for edit and mobile number. No username, no avatar editing, no social login linking.

**New layout**:
```
+-------------------------------------------------------+
| (<) Profile                              [Save]      |
+-------------------------------------------------------+
|                   [ Avatar (80px) ]                   |
|                  ( Change Photo Icon )                |
|                                                       |
|  FIRST NAME                                           |
|  [ Juan                                             ] |
|                                                       |
|  LAST NAME                                            |
|  [ Dela Cruz                                        ] |
|                                                       |
|  USERNAME                                             |
|  [ @juandelacruz                                    ] |
|  * Username is auto-generated from your email         |
|                                                       |
| ----------------------------------------------------- |
|  CONTACT INFORMATION                                  |
|  [ Mobile Number             Juan +63917xxxx       ]  |
|  [ Email Address             juan@example.com      ]  |
|  [ Date of Birth             March 15, 1990        ]  |
|                                                       |
| ----------------------------------------------------- |
|  SOCIAL ACCOUNTS                                      |
|  [ Google                    Linked ●              ]  |
|  [ Facebook                  Not linked     (+)    ]  |
|                                                       |
| ----------------------------------------------------- |
|  ACCOUNT SETTINGS                                     |
|  [ Request for Account Deletion (Red)             ]  |
|  [ Log Out                       (Red Destructive) ] |
+-------------------------------------------------------+
```

**New Profile entity** (`baktaz_flutter/lib/features/account/domain/entity/model/profile.dart`):
```dart
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required ValueName firstName,
    required ValueName lastName,
    required ValueName username,
    required Gender gender,
    EmailAddress? email,
    MobileNumber? mobileNumber,
    LocalDateTime? birthday,
    Number? age,
    Url? imageUrl,
    LocalDateTime? updatedAt,
  }) = _Profile;

  // ... fromServer mapping updated
}
```

**New ProfileCubit actions**:
```dart
// In profile_cubit.dart
Future<void> updateProfile({
  required String firstName,
  required String lastName,
  String? mobileNumber,
  DateTime? birthday,
  String? gender,
}) async {
  await safeRun(
    onException: _failureHandler.handleException,
    onLoading: (bool isLoading) {
      safeEmit(stateValue.copyWith(queryStatus: isLoading ? const QueryStatus.loading() : const QueryStatus.done()));
    },
    action: () async {
      final Result<Profile> possibleFailure = await _accountRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
        birthday: birthday,
        gender: gender,
      ).run();

      possibleFailure.fold(
        _failureHandler.handleFailure,
        (Profile profile) {
          safeEmit(stateValue.copyWith(profile: profile, queryStatus: const QueryStatus.done()));
        },
      );
    },
  );
}
```

**New `IAccountRepository` interface**:
```dart
abstract interface class IAccountRepository {
  TaskResult<AccountSummary> getAccountSummary();
  TaskResult<Profile> getProfile();
  TaskResult<Profile> updateProfile({
    required String firstName,
    required String lastName,
    String? mobileNumber,
    DateTime? birthday,
    String? gender,
  });
  TaskResult<Unit> addAddress(Address address);
  TaskResult<Address?> getDefaultAddress();
  TaskResult<Unit> deleteAccount();
}
```

**New `AccountRepository.updateProfile` implementation**:
```dart
@override
TaskResult<Profile> updateProfile({
  required String firstName,
  required String lastName,
  String? mobileNumber,
  DateTime? birthday,
  String? gender,
}) => TaskResult<Profile>.tryCatch(
  () async {
    final serverpod.UpdateProfileRequest request = serverpod.UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      birthday: birthday,
      gender: gender,
    );
    final serverpod.Profile? result = await _retry.retry(
      () => _serverpod.client.account.updateProfile(request),
      retryIf: (Exception exception) =>
          exception is SocketException || exception is TimeoutException,
    );

    if (result == null) {
      throw const FormatException('Profile update returned null');
    }

    final Profile possibleFailure = Profile.fromServer(result);
    if (possibleFailure.validate.isSome()) {
      throw possibleFailure.validate.asSome();
    }

    return possibleFailure;
  },
  (Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace);
    return Failure.server(StatusCode.serverpod, error.toString());
  },
);
```

**Social login linking UI** (in ProfileScreen):
```dart
// Social Accounts section
AccountDetailsContainer(
  child: AccountDetailsContent(
    title: 'Social Accounts',
    children: <Widget>[
      AccountDetailsTile(
        label: 'Google',
        value: state.profile?.isGoogleLinked == true ? 'Linked' : 'Not linked',
        trailing: state.profile?.isGoogleLinked != true
            ? BaktazButton(
                label: '+',
                variant: BaktazButtonVariant.text,
                onPressed: () => _linkSocialProvider(context, LoginProvider.google),
              )
            : null,
      ),
      const BaktazDivider(padding: Paddings.verticalMedium),
      AccountDetailsTile(
        label: 'Facebook',
        value: state.profile?.isFacebookLinked == true ? 'Linked' : 'Not linked',
        trailing: state.profile?.isFacebookLinked != true
            ? BaktazButton(
                label: '+',
                variant: BaktazButtonVariant.text,
                onPressed: () => _linkSocialProvider(context, LoginProvider.facebook),
              )
            : null,
      ),
    ],
  ),
),
```

**Social linking handler**:
```dart
void _linkSocialProvider(BuildContext context, LoginProvider provider) async {
  try {
    await context.read<AuthCubit>().linkSocialProvider(provider);
    if (context.mounted) {
      // Refresh profile to show updated linked state
      await context.read<ProfileCubit>().initialize();
    }
  } catch (e) {
    // Error handled by AuthCubit/FailureHandler
  }
}
```

---

## 6. Migration Strategy

### 6.1 Database Migration

**New migration** (auto-generated by Serverpod after model changes):

```sql
-- Add columns to user_info
ALTER TABLE user_info ADD COLUMN first_name TEXT NOT NULL DEFAULT '';
ALTER TABLE user_info ADD COLUMN last_name TEXT NOT NULL DEFAULT '';
ALTER TABLE user_info ADD COLUMN username TEXT NOT NULL DEFAULT '';
CREATE UNIQUE INDEX user_info_username_unique_idx ON user_info (username);

-- Backfill username from email for existing users
UPDATE user_info ui
SET username = sub.username
FROM (
  SELECT ui2.id,
         LOWER(SPLIT_PART(up.email, '@', 1)) as username
  FROM user_info ui2
  JOIN account a ON a.user_info_id = ui2.id
  JOIN serverpod_auth_core_profile up ON up.auth_user_id = a.auth_user_id
  WHERE ui2.username = ''
) sub
WHERE user_info.id = sub.id;

-- Resolve collisions: append random suffix to duplicates
WITH ranked AS (
  SELECT id, username,
         ROW_NUMBER() OVER (PARTITION BY username ORDER BY id) as rn
  FROM user_info
  WHERE username != ''
)
UPDATE user_info
SET username = username || substr((random() * 9000 + 1000)::integer::text, 1, 4)
FROM ranked
WHERE user_info.id = ranked.id AND ranked.rn > 1;
```

### 6.2 Migration Execution

1. Update `.spy.yaml` files (see §2)
2. Run `serverpod create-migration --tag profile-header-update` in `baktaz_server/`
3. Run `make apply_migrations` to apply to local DB
4. Verify backfill completed: `SELECT username FROM user_info WHERE username = ''` returns 0 rows

### 6.3 Codegen Order

After model changes, run in order:
1. `make codegen_server` — regenerates `baktaz_server/lib/src/generated/`
2. `make codegen_client` — regenerates `baktaz_client/`
3. `make codegen_flutter` — regenerates Flutter Freezed files
4. `make codegen_shared` — regenerates shared utilities

### 6.4 Backfill Script

If migration backfill doesn't cover all edge cases, provide a standalone Dart script:

```dart
// baktaz_server/tool/backfill_usernames.dart
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Run: dart run tool/backfill_usernames.dart
/// Usage: Requires running within serverpod context (use withServerpod)
Future<void> backfillUsernames(Session session) async {
  final List<UserInfo> userInfos = await UserInfo.db.findAll(session);
  for (final UserInfo userInfo in userInfos) {
    if (userInfo.username.isNotEmpty) continue;

    final UserProfile? profile = await UserProfile.db.findFirstRow(
      session,
      where: (UserProfileTable t) => t.authUserId.equals(userInfo.account!.authUserId!),
    );
    if (profile?.email == null) continue;

    final String baseUsername = profile!.email!.split('@').first.toLowerCase();
    final String username = await deriveUniqueUsername(session, baseUsername);

    await UserInfo.db.updateRow(
      session,
      userInfo.copyWith(username: username),
    );
  }
}

Future<String> deriveUniqueUsername(Session session, String base) async {
  final int count = await session.db.selectCount(
    session.db.table('user_info'),
    where: (t) => t.rawExpr('username = ?', [base]),
  );
  if (count == 0) return base;

  final String suffix = DateTime.now().microsecondsSinceEpoch.toString().substring(8, 12);
  return '$base$suffix';
}
```

### 6.5 Migration: File Repository Config

Add to `baktaz_server/generator.yaml`:
```yaml
fileRepository:
  default: s3
  s3:
    bucket: baktaz-avatars
    region: ap-southeast-1
```

---

## 7. Testing Plan

### 7.1 Server Integration Tests

**Location**: `baktaz_server/test/integration/features/account/`

```dart
// account_endpoint_test.dart — add:
group('getAccountSummary', () {
  test('returns memberSince from Account.createdAt', () async {
    // Arrange
    final Account account = await Account.db.insertRow(session, Account(
      authUserId: userId,
      createdAt: DateTime(2024, 1, 15),
    ));
    // Act
    final AccountSummary? summary = await accountEndpoint.getAccountSummary(session);
    // Assert
    expect(summary?.memberSince, equals(DateTime(2024, 1, 15)));
  });

  test('returns challenge stats computed from repository', () async {
    // Arrange — mock ChallengeRepository returns known stats
    when(mockChallengeRepo.computeChallengeStats(session))
        .thenAnswer((_) async => AccountChallengeStats(
          totalChallengeSteps: 50000,
          challengesJoined: 5,
          challengesWon: 2,
          winRatePercentage: 40.0,
        ));
    // Act
    final AccountSummary? summary = await accountEndpoint.getAccountSummary(session);
    // Assert
    expect(summary?.totalChallengeSteps, equals(50000));
    expect(summary?.winRatePercentage, equals(40.0));
  });
});

group('updateProfile', () {
  test('updates firstName and lastName', () async {
    // Arrange
    final UserInfo userInfo = await UserInfo.db.insertRow(session, UserInfo(
      firstName: 'Old',
      lastName: 'Name',
      username: 'oldname',
      gender: Gender.unknown,
    ));
    // Act
    final Profile updated = await accountEndpoint.updateProfile(session, UpdateProfileRequest(
      firstName: 'New',
      lastName: 'Name',
    ));
    // Assert
    expect(updated.firstName, equals('New'));
    expect(updated.lastName, equals('Name'));
  });

  test('throws notFound when userInfo does not exist', () async {
    // Arrange — user has no userInfo
    // Act & Assert
    expect(
      () => accountEndpoint.updateProfile(session, UpdateProfileRequest(firstName: 'Test', lastName: 'User')),
      throwsA(isA<ApiException>().having(
        (e) => e.code,
        'code',
        equals(ApiExceptionCode.notFound),
      )),
    );
  });
});

group('linkSocialProvider', () {
  test('links Google provider to user', () async {
    // Act
    await accountEndpoint.linkSocialProvider(session, SocialProviderLinkRequest(
      provider: 'google',
      providerUserId: 'google_12345',
    ));
    // Assert
    final SocialAccount? linked = await SocialAccount.db.findFirstRow(
      session,
      where: (SocialAccountTable t) =>
          t.authUserId.equals(userId) & t.provider.equals('google'),
    );
    expect(linked, isNotNull);
    expect(linked?.providerUserId, equals('google_12345'));
  });

  test('throws error when linking to different user', () async {
    // Arrange — create another user with same social account
    final UuidValue otherUserId = const UuidValue.v4();
    await SocialAccount.db.insertRow(session, SocialAccount(
      authUserId: otherUserId,
      provider: 'google',
      providerUserId: 'google_12345',
      createdAt: DateTime.now(),
    ));
    // Act & Assert
    expect(
      () => accountEndpoint.linkSocialProvider(session, SocialProviderLinkRequest(
        provider: 'google',
        providerUserId: 'google_12345',
      )),
      throwsA(isA<ApiException>().having(
        (e) => e.message,
        'message',
        contains('already linked'),
      )),
    );
  });

  test('is idempotent — linking same account twice is no-op', () async {
    // Act (first link)
    await accountEndpoint.linkSocialProvider(session, SocialProviderLinkRequest(
      provider: 'google',
      providerUserId: 'google_12345',
    ));
    // Act (second link)
    await accountEndpoint.linkSocialProvider(session, SocialProviderLinkRequest(
      provider: 'google',
      providerUserId: 'google_12345',
    ));
    // Assert — only one record
    final List<SocialAccount> linked = await SocialAccount.db.findAll(
      session,
      where: (SocialAccountTable t) =>
          t.authUserId.equals(userId) & t.provider.equals('google'),
    );
    expect(linked, hasLength(1));
  });
});

group('getAvatarUploadUrl', () {
  test('returns valid presigned URL with correct file key', () async {
    // Act
    final AvatarUploadUrl result = await accountEndpoint.getAvatarUploadUrl(session);
    // Assert
    expect(result.uploadUrl, isNotEmpty);
    expect(result.fileKey, startsWith('avatars/'));
    expect(result.fileKey, contains(userId.toString()));
    expect(result.expiresAt, isAfter(DateTime.now()));
    expect(result.expiresAt, isBefore(DateTime.now().add(const Duration(minutes: 11))));
  });

  test('throws unauthenticated when user not logged in', () async {
    // Arrange — create unauthenticated session
    final Session unauthSession = await createUnauthenticatedSession();
    // Act & Assert
    expect(
      () => accountEndpoint.getAvatarUploadUrl(unauthSession),
      throwsA(isA<ApiException>().having(
        (e) => e.code,
        'code',
        equals(ApiExceptionCode.unauthenticated),
      )),
    );
  });
});
```

### 7.2 Auth Repository Tests

**Location**: `baktaz_server/test/unit/features/auth/auth_repository_test.dart`

```dart
group('completeRegistration', () {
  test('derives username from email with collision handling', () async {
    // Arrange — first user with email juan@example.com
    when(mockSecurityLogger.log(any, any, any: anyNamed(''), any: anyNamed(''))).thenAnswer((_) async {});

    // Act
    await authRepository.completeRegistration(session, RegistrationForm(
      email: 'juan@example.com',
      firstName: 'Juan',
      lastName: 'Dela Cruz',
      gender: 'male',
      registrationToken: 'valid-token',
    ));

    // Assert
    final UserInfo? userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.firstName.equals('Juan'),
    );
    expect(userInfo?.username, equals('juan'));
  });

  test('appends collision suffix when username exists', () async {
    // Arrange — pre-create user with username 'juan'
    await UserInfo.db.insertRow(session, UserInfo(
      firstName: 'Existing',
      lastName: 'User',
      username: 'juan',
      gender: Gender.unknown,
    ));

    // Act
    await authRepository.completeRegistration(session, RegistrationForm(
      email: 'juan2@example.com',
      firstName: 'Juan',
      lastName: 'Two',
      gender: 'male',
      registrationToken: 'valid-token',
    ));

    // Assert — new username should have suffix
    final UserInfo? newUserInfo = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.lastName.equals('Two'),
    );
    expect(newUserInfo?.username, startsWith('juan'));
    expect(newUserInfo?.username.length, greaterThan(4)); // has suffix
  });
});
```

### 7.3 Flutter Unit Tests

**Location**: `baktaz_flutter/test/unit/profile_cubit_test.dart`

```dart
group('updateProfile', () {
  blocTest<ProfileCubit, ProfileState>(
    'emits loading then updated profile on success',
    build: () {
      when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
      when(mockRepo.updateProfile(
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => right(mockUpdatedProfile));
      return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
    },
    act: (cubit) async {
      await cubit.initialize(); // load initial profile
      await cubit.updateProfile(
        firstName: 'New',
        lastName: 'Name',
      );
    },
    expect: () => [
      ProfileState.loading(),
      ProfileState.loaded(profile: mockProfile),
      ProfileState.loading(),
      ProfileState.loaded(profile: mockUpdatedProfile),
    ],
    verify: (_) {
      verify(mockRepo.updateProfile(
        firstName: 'New',
        lastName: 'Name',
      )).called(1);
    },
  );

  blocTest<ProfileCubit, ProfileState>(
    'handles update failure',
    build: () {
      when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
      when(mockRepo.updateProfile(
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => left(const ServerFailure(500)));
      return ProfileCubit(mockRepo, mockDeviceRepo, mockHandler);
    },
    act: (cubit) async {
      await cubit.initialize();
      await cubit.updateProfile(firstName: 'New', lastName: 'Name');
    },
    expect: () => [
      ProfileState.loading(),
      ProfileState.loaded(profile: mockProfile),
      ProfileState.loading(),
      ProfileState.failed(),
    ],
    verify: (_) {
      verify(mockHandler.handleFailure(any)).called(1);
    },
  );
});
```

### 7.4 Flutter Widget Tests

**Location**: `baktaz_flutter/test/widget/account/profile_screen_test.dart`

```dart
void main() {
  group('ProfileScreen', () {
    late MockIAccountRepository mockRepo;
    late MockFailureHandler mockHandler;
    late MockIDeviceInfoRepository mockDeviceRepo;

    setUp(() {
      mockRepo = MockIAccountRepository();
      mockHandler = MockFailureHandler();
      mockDeviceRepo = MockIDeviceInfoRepository();
    });

    Widget _buildProfileScreen(ProfileState state) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: mockRepo),
          RepositoryProvider.value(value: mockDeviceRepo),
        ],
        child: BlocSignalProvider<ProfileCubit>(
          create: (_) => ProfileCubit(mockRepo, mockDeviceRepo, mockHandler)..initialize(),
          child: const ProfileScreen(),
        ),
      );
    }

    testWidgets('displays firstName and lastName separately', (tester) async {
      // Arrange
      final Profile mockProfile = Profile(
        firstName: ValueName('Juan'),
        lastName: ValueName('Dela Cruz'),
        username: ValueName('juandelacruz'),
        gender: Gender.male,
        email: EmailAddress('juan@example.com'),
      );
      when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
      when(mockDeviceRepo.getAppVersion()).thenReturn(right('1.0.0'));
      when(mockDeviceRepo.getBuildNumber()).thenReturn(right('1'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: _buildProfileScreen(ProfileState.loaded(profile: mockProfile)),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('Dela Cruz'), findsOneWidget);
      expect(find.textContaining('@juandelacruz'), findsOneWidget);
    });

    testWidgets('shows social login linking buttons', (tester) async {
      // Arrange
      final Profile mockProfile = Profile(
        firstName: ValueName('Juan'),
        lastName: ValueName('Dela Cruz'),
        username: ValueName('juandelacruz'),
        gender: Gender.male,
        isGoogleLinked: false,
        isFacebookLinked: false,
      );
      when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
      when(mockDeviceRepo.getAppVersion()).thenReturn(right('1.0.0'));
      when(mockDeviceRepo.getBuildNumber()).thenReturn(right('1'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: _buildProfileScreen(ProfileState.loaded(profile: mockProfile)),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — Google linked state shown
      expect(find.textContaining('Not linked'), findsWidgets);
    });

    testWidgets('shows Linked badge for linked providers', (tester) async {
      // Arrange
      final Profile mockProfile = Profile(
        firstName: ValueName('Juan'),
        lastName: ValueName('Dela Cruz'),
        username: ValueName('juandelacruz'),
        gender: Gender.male,
        isGoogleLinked: true,
        isFacebookLinked: false,
      );
      when(mockRepo.getProfile()).thenAnswer((_) async => right(mockProfile));
      when(mockDeviceRepo.getAppVersion()).thenReturn(right('1.0.0'));
      when(mockDeviceRepo.getBuildNumber()).thenReturn(right('1'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: _buildProfileScreen(ProfileState.loaded(profile: mockProfile)),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Linked'), findsOneWidget);
      expect(find.textContaining('Not linked'), findsOneWidget);
    });
  });
}
```

### 7.5 Golden Tests

**Location**: `baktaz_flutter/test/widget/account/goldens/profile_screen_macos/`

```dart
void main() {
  group('ProfileScreen', () {
    goldenTest(
      'renders profile with all fields in light mode',
      fileName: 'profile_screen_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints.tightFor(width: 390, height: 844),
        children: [
          GoldenTestScenario(
            name: 'loaded state',
            child: MaterialApp(
              home: Scaffold(
                body: BlocSignalProvider<ProfileCubit>(
                  create: (_) => ProfileCubit(
                    MockIAccountRepository(),
                    MockIDeviceInfoRepository(),
                    MockFailureHandler(),
                  )..initialize(),
                  child: const ProfileScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
```

---

## 8. i18n Keys Required

Add to Slang `i18n.json` files:

```json
{
  "register": {
    "label": {
      "first_name": "First Name",
      "last_name": "Last Name"
    },
    "hint": {
      "first_name": "Enter your first name",
      "last_name": "Enter your last name",
      "username_auto_generated": "Username is auto-generated from your email"
    }
  },
  "account": {
    "totalChallengeSteps": "Challenge Steps",
    "challengesJoined": "Joined",
    "challengesWon": "Won",
    "winRate": "Win Rate"
  }
}
```

---

## 9. File Change Summary

| File | Change Type | Description |
|---|---|---|
| `baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml` | **Modify** | Add firstName, lastName, username, unique index |
| `baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml` | **Modify** | Add memberSince, challenge stats fields |
| `baktaz_server/lib/src/features/account/domain/model/profile.spy.yaml` | **Modify** | Replace fullName with firstName/lastName/username |
| `baktaz_server/lib/src/features/auth/domain/models/registration_form.spy.yaml` | **Modify** | Replace name with firstName/lastName |
| `baktaz_server/lib/src/features/account/domain/model/account_challenge_stats.spy.yaml` | **Create** | New DTO for challenge stats |
| `baktaz_server/lib/src/features/account/domain/model/social_provider_link_request.spy.yaml` | **Create** | New request DTO |
| `baktaz_server/lib/src/features/account/domain/model/avatar_upload_url.spy.yaml` | **Create** | New DTO for presigned upload URL |
| `baktaz_server/lib/src/features/account/domain/model/social_account.spy.yaml` | **Create** | New table for social account links |
| `baktaz_server/generator.yaml` | **Modify** | Configure `fileRepository` with S3 bucket for avatars |
| `baktaz_server/lib/src/features/account/data/repository/account_challenge_stats_repository.dart` | **Create** | Stub implementation |
| `baktaz_server/lib/src/features/account/data/repository/i_account_challenge_stats_repository.dart` | **Create** | Interface |
| `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart` | **Modify** | Update getAccountSummary, getProfile, add updateProfile, linkSocialProvider, getAvatarUploadUrl |
| `baktaz_server/lib/src/app/utils/auth_utils.dart` | **Modify** | Update username derivation logic |
| `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart` | **Modify** | Update completeRegistration for new fields |
| `baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart` | **Modify** | Add new fields, update fromServer |
| `baktaz_flutter/lib/features/account/domain/entity/model/profile.dart` | **Modify** | Replace fullName with firstName/lastName/username |
| `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart` | **Modify** | Add updateProfile method |
| `baktaz_flutter/lib/features/account/data/repository/account_repository.dart` | **Modify** | Implement updateProfile |
| `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_cubit.dart` | **Modify** | Add updateProfile method |
| `baktaz_flutter/lib/features/account/domain/cubit/profile/profile_state.dart` | **Modify** | Add isGoogleLinked, isFacebookLinked |
| `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart` | **Modify** | Update header with name/username/memberSince, add ChallengeStatsGrid |
| `baktaz_flutter/lib/features/account/presentation/views/screens/my_account/profile_screen.dart` | **Rewrite** | Full rewrite with edit mode, username, social linking |
| `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart` | **Modify** | Split name into firstName/lastName |
| `baktaz_flutter/lib/features/auth/domain/cubit/auth/auth_cubit.dart` | **Modify** | Add linkSocialProvider method |
| `baktaz_flutter/lib/features/auth/domain/interface/i_auth_repository.dart` | **Modify** | Add linkSocialProvider method |
| `baktaz_flutter/lib/features/auth/data/repository/auth_repository.dart` | **Modify** | Implement linkSocialProvider |
| `baktaz_flutter/lib/l10n/` | **Modify** | Add new i18n keys |
| `baktaz_server/test/integration/features/account/account_endpoint_test.dart` | **Modify** | Add tests for new endpoints |
| `baktaz_server/test/unit/features/auth/auth_repository_test.dart` | **Modify** | Add tests for username derivation |
| `baktaz_flutter/test/unit/profile_cubit_test.dart` | **Modify** | Add updateProfile tests |
| `baktaz_flutter/test/widget/account/profile_screen_test.dart` | **Create** | New widget tests |

---

## 10. Implementation Checklist

- [ ] Update `.spy.yaml` model files
- [ ] Run `serverpod create-migration --tag profile-header-update`
- [ ] Run `make apply_migrations`
- [ ] Run `make codegen` (all packages)
- [ ] Update `AuthUtils.deriveUsername` with collision handling
- [ ] Update `AuthRepository.completeRegistration` for new fields
- [ ] Update `AccountEndpoint.getAccountSummary` with challenge stats
- [ ] Update `AccountEndpoint.getProfile` with new fields
- [ ] Implement `AccountEndpoint.updateProfile`
- [ ] Implement `AccountEndpoint.linkSocialProvider`
- [ ] Implement `AccountEndpoint.getAvatarUploadUrl` for presigned S3 uploads
- [ ] Configure `fileRepository` in `baktaz_server/generator.yaml`
- [ ] Implement avatar upload & presigned URL flow in `ProfileScreen`
- [ ] Create `AccountChallengeStatsRepository` stub
- [ ] Update Flutter `AccountSummary` entity
- [ ] Update Flutter `Profile` entity
- [ ] Update `AccountRepository` with new methods
- [ ] Update `ProfileCubit` with `updateProfile`
- [ ] Update `ProfileState` with social link booleans
- [ ] Update `AccountCubit` if needed
- [ ] Rewrite `ProfileScreen` with edit mode, username, social linking
- [ ] Update `AccountPage` header with stats
- [ ] Update `RegistrationScreen` with firstName/lastName
- [ ] Update i18n files
- [ ] Write server integration tests
- [ ] Write Flutter unit tests
- [ ] Write Flutter widget/golden tests
- [ ] Run `make analyze` to verify no lint errors
- [ ] Run `make test` to verify tests pass

---

## 11. Handoff Notes

### For Implementer
1. **Start with server models** — update `.spy.yaml` files first, then run migration
2. **Challenge stats are stubs** — return zeros until Challenge domain is built
3. **Username derivation** — the collision handling uses DB check + random suffix; consider caching in production to avoid N+1 queries
4. **Social linking** — requires `SocialAccount` table; ensure serverpod_auth_idp handles the provider token exchange before linking
5. **Profile edit mode** — consider using a separate `ProfileEditScreen` or inline edit in `ProfileScreen`; this spec assumes inline edit for MVP

### Open Questions
- Should `username` be editable after registration? (Spec says no — auto-derived, immutable)
- Should social unlinking be allowed via admin endpoint? (Out of scope for MVP)
- What happens to `UserProfile.fullName` when we split into firstName/lastName? (Spec: keep in sync, derive from firstName + lastName)

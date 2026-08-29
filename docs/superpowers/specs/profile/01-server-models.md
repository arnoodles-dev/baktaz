# Profile Header & Lifetime Stats — Server Models

> **Document Version:** 1.1  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/Account/2026-08-28-00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/models/`)  

---

## 1. UserInfo (`user_info.spy.yaml`)

**Current:**
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

**Proposed (matches Account spec v1.1):**
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
  avatarUrl: String?
indexes:
  username_unique_idx:
    fields: username
    unique: true
```

**Changes:**
- Added: `firstName: String`
- Added: `lastName: String`
- Added: `username: String` (unique)
- Added: `avatarUrl: String?`
- Removed: `fullName` (computed from firstName + lastName at read time)
- Removed: `memberSince` (use `Account.createdAt` instead)

---

## 2. AccountSummary (`account_summary.spy.yaml`)

**Current:**
```yaml
class: AccountSummary
fields:
  name: String
  imageUrl: Uri?
  cashBalance: double
  connectBalance: int
```

**Proposed (matches Account spec v1.1 nested structure):**
```yaml
class: AccountSummary
fields:
  userInfo: UserInfo
  isPremiumHost: bool
  stats: AccountChallengeStats
```

**Notes:**
- Uses nested `userInfo: UserInfo` and `stats: AccountChallengeStats` per Account spec
- `memberSince` is derived from `Account.createdAt` at read time
- Challenge stats computed on-demand (see §6 below)
- No new DB table — stats are derived at query time

---

## 3. Profile (`profile.spy.yaml`)

**Current:**
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

**Proposed:**
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

**Changes:**
- Removed: `fullName: String`
- Added: `firstName: String`
- Added: `lastName: String`
- Added: `username: String`

---

## 4. RegistrationForm (`registration_form.spy.yaml`)

**Current:**
```yaml
class: RegistrationForm
fields:
  email: String
  name: String
  gender: String
  registrationToken: String
  birthday: DateTime?
```

**Proposed:**
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

**Changes:**
- Removed: `name: String`
- Added: `firstName: String`
- Added: `lastName: String`

---

## 5. AccountChallengeStats (New — Serverpod DTO, not table)

```yaml
class: AccountChallengeStats
fields:
  totalChallengeSteps: int
  challengesJoined: int
  challengesWon: int
  winRatePercentage: double
```

**Purpose:** Returned as part of `AccountSummary`. Computed on-demand from step telemetry data (see §6). No DB table — Serverpod DTO only.

---

## 6. Challenge Stats Computation

**Location:** `baktaz_server/lib/src/features/account/data/repository/account_challenge_stats_repository.dart`

**Interface:**
```dart
abstract interface class IAccountChallengeStatsRepository {
  Future<AccountChallengeStats> computeChallengeStats(Session session);
}
```

**Implementation notes:**
- Queries step telemetry tables (daily step records) for challenge-related steps
- `totalChallengeSteps`: Sum of steps recorded during active/completed challenges
- `challengesJoined`: Count of unique challenge participations
- `challengesWon`: Count of challenges where user placed #1
- `winRatePercentage`: `(challengesWon / challengesJoined) * 100`, rounded to 1 decimal, `0.0` if `challengesJoined == 0`

**MVP constraint:** Challenge domain models do not yet exist. The repository method returns zeros until Challenge tables are implemented. This is a stub that returns `AccountChallengeStats(totalChallengeSteps: 0, challengesJoined: 0, challengesWon: 0, winRatePercentage: 0.0)` until challenge infrastructure is built.

---

## 7. ProfileDetails DTO (New — Flutter-only, for ProfileScreen)

**Purpose:** Flat DTO for ProfileScreen with combined user details, mapped from `AccountSummary` + Profile endpoint data.

```dart
@freezed
class ProfileDetails with _$ProfileDetails {
  const factory ProfileDetails({
    required ValueName firstName,
    required ValueName lastName,
    required ValueName username,
    required LocalDateTime? memberSince,
    required Url? avatarUrl,
    required EmailAddress? email,
    required MobileNumber? mobileNumber,
    required LocalDateTime? birthday,
    required Number? age,
    required List<String> linkedProviders,
  }) = _ProfileDetails;

  factory ProfileDetails.fromAccountSummary(AccountSummary summary) => ProfileDetails(
    firstName: summary.userInfo.firstName,
    lastName: summary.userInfo.lastName,
    username: summary.userInfo.username,
    memberSince: summary.memberSince, // derived from Account.createdAt
    avatarUrl: summary.userInfo.avatarUrl,
    email: null, // populated from Profile endpoint
    mobileNumber: null, // populated from Profile endpoint
    birthday: null, // populated from Profile endpoint
    age: null, // populated from Profile endpoint
    linkedProviders: [], // populated from getLinkedProviders endpoint
  );
}
```

---

## 7. AvatarUploadUrl (New)

```yaml
class: AvatarUploadUrl
fields:
  uploadUrl: String
  fileKey: String
  permanentUrl: String
  expiresAt: DateTime
```

---

## 8. UpdateProfileRequest (New)

```yaml
class: UpdateProfileRequest
fields:
  firstName: String
  lastName: String
  mobileNumber: String?
  birthday: DateTime?
  gender: String?
  avatarUrl: String?
```

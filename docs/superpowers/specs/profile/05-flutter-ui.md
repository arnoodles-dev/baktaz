# Profile Header & Lifetime Stats — Flutter UI (AccountPage, RegistrationScreen, ChallengeStatsGrid)

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/profile/00-overview.md`

---

## 1. RegistrationScreen

**File:** `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`

### Changes

Replace single `nameController` with three controllers:
```dart
final TextEditingController firstNameController = useTextEditingController();
final TextEditingController lastNameController = useTextEditingController();
final TextEditingController usernameController = useTextEditingController();
```

Auto-populate username from email:
```dart
// When email is set (read-only in this screen):
usernameController.text = email.split('@').first.toLowerCase();
```

Form fields rendered:
```
First Name    [ Juan          ] *
Last Name     [ Dela Cruz     ] *
Username      [ @juandelacruz  ] *  (auto-filled from email, editable)
Gender        [ Male ▼ ]       *
Birthday      [ 1990-01-15   ] *
```

Submit `RegistrationForm`:
```dart
RegistrationForm(
  email: email,
  firstName: firstNameController.text.trim(),
  lastName: lastNameController.text.trim(),
  gender: selectedGender.value!.name,
  registrationToken: registrationToken,
  birthday: selectedBirthday.value,
)
```

---

## 2. AccountPage Header

**File:** `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart`

### Updated `_AccountAppBar` Widget

Accepts additional parameters:
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
}
```

### Expanded State (top of scroll)
```
[80px Avatar]  Juan Dela Cruz
                @juandelacruz
                Member since Jan 2024
```

### Collapsed State (scrolled up)
```
[48px Avatar]  Juan Dela Cruz  @juandelacruz
```

### Build Method
```dart
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
        maxSize: avatarSize.toInt(),
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
```

---

## 3. ChallengeStatsGrid Widget

**File:** `baktaz_flutter/lib/features/account/presentation/widgets/challenge_stats_grid.dart`

### 4-Column Layout
```
+-------------------+ +------------------+ +--------+ +---------------+
| 142,500           | | 12               | | 4      | | 33.3%         |
| Challenge Steps   | | Joined           | | Won    | | Win Rate      |
+-------------------+ +------------------+ +--------+ +---------------+
```

### Implementation
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
              value: MoneyFormatter.formatWithoutSymbol(totalChallengeSteps.toDouble()),
              label: context.i18n.account.total_challenge_steps,
            ),
          ),
          Gap.xSmall(),
          Expanded(
            child: _StatCard(
              value: '$challengesJoined',
              label: context.i18n.account.challenges_joined,
            ),
          ),
          Gap.xSmall(),
          Expanded(
            child: _StatCard(
              value: '$challengesWon',
              label: context.i18n.account.challenges_won,
            ),
          ),
          Gap.xSmall(),
          Expanded(
            child: _StatCard(
              value: '${winRatePercentage.toStringAsFixed(1)}%',
              label: context.i18n.account.win_rate,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => BaktazCard(
    child: Padding(
      padding: Paddings.allSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(
            text: value,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
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

---

## 4. AccountPage Body Integration

Add `ChallengeStatsGrid` inside `SliverToBoxAdapter` column:
```dart
SliverToBoxAdapter(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      // ... existing header ...
      ChallengeStatsGrid(
        isLoading: _isLoading(state),
        totalChallengeSteps: state.accountSummary?.totalChallengeSteps.toInt() ?? 0,
        challengesJoined: state.accountSummary?.challengesJoined.toInt() ?? 0,
        challengesWon: state.accountSummary?.challengesWon.toInt() ?? 0,
        winRatePercentage: state.accountSummary?.winRatePercentage.toDouble() ?? 0.0,
      ),
      Gap.medium(),
      // ... navigation list ...
    ],
  ),
)
```

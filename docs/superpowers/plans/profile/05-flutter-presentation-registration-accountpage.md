# Task 5: Flutter Presentation (RegistrationScreen & AccountPage Header)

**Files:**
- Modify: `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/challenge_stats_grid.dart`

**Interfaces:**
- Consumes: `AccountSummary`, `LoginCubit`, `AccountCubit`
- Produces: Updated RegistrationScreen (firstName, lastName, username), AccountPage Header with username + memberSince, and 4-column `ChallengeStatsGrid`.

---

- [ ] **Step 1: Update RegistrationScreen to split name and show username**

In `baktaz_flutter/lib/features/auth/presentation/views/registration_screen.dart`:
- Replace `nameController` with `firstNameController`, `lastNameController`, and `usernameController`
- Auto-populate `usernameController.text` from `email.split('@').first.toLowerCase()`
- Render text fields for First Name, Last Name, and Username
- Submit `RegistrationForm(email: email, firstName: firstNameController.text, lastName: lastNameController.text, registrationToken: registrationToken)`

---

- [ ] **Step 2: Create ChallengeStatsGrid widget**

Create `baktaz_flutter/lib/features/account/presentation/widgets/challenge_stats_grid.dart`:
```dart
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

- [ ] **Step 3: Update AccountPage SliverAppBar and Body**

In `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart`:
- Update `_AccountAppBar` to accept `username` and `memberSince`
- Render `@$username` and `Member since ${DateFormat.yMMM().format(memberSince)}`
- Add `ChallengeStatsGrid` inside `SliverToBoxAdapter` column above navigation list

---

- [ ] **Step 4: Commit AccountPage & RegistrationScreen updates**

```bash
cd /Users/Arnold/Projects/baktaz
git add baktaz_flutter/lib/features/auth/ baktaz_flutter/lib/features/account/
git commit -m "feat(flutter): update RegistrationScreen with name split and AccountPage with username + stats grid"
```

# Account Flutter UI Screens & Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all Flutter UI screens, reusable widgets, dialogs, and navigation flows for the Account feature (`AccountPage`, `ProfileScreen` (`/account/profile`), `HostSubscriptionScreen`, `ManagePaymentScreen`, `HealthSyncScreen`, Settings screens, Support screens). `ProfileScreen` (`/account/profile`) owns BOTH profile editing (Avatar, Name, Username) AND the `Logout` action at the bottom of the profile form, triggering `LogoutConfirmationDialog`. `AccountHeader.support` options enum explicitly does NOT include `logout`.

**Architecture:** Create screen presentation components under `baktaz_flutter/lib/features/account/presentation/views/` and modular widgets under `baktaz_flutter/lib/features/account/presentation/widgets/`. Follow DESIGN.md design system tokens, `Baktaz` UI wrappers from `baktaz_shared`, and localization rules (`context.l10n`).

**Tech Stack:** Flutter, `baktaz_shared` (BaktazText, BaktazButton, BaktazCard, BaktazListRow, AppSizes), `bloc_signals_flutter`.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- Screens follow naming convention (`*_page.dart` for tab root, `*_screen.dart` for navigated views).
- Reusable UI elements in `presentation/widgets/`, dialogs end in `_dialog.dart`.
- Zero hardcoded UI strings — all text sourced from `context.l10n` or localization keys.
- Spacing strictly uses `AppSizes.*` constants and `Gap` widgets.

---

### Task 1: Reusable Account Widgets & Header Component

**Files:**
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/account_header_card.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/lifetime_stats_grid.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/account_menu_tile.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/dialogs/logout_confirmation_dialog.dart`

**Interfaces:**
- Consumes: `AccountSummary`, `UserInfo`, `AccountNavigationOption`, `baktaz_shared`.
- Produces: Visual header, stats grid, menu rows, and logout confirmation dialog.

- [ ] **Step 1: Write failing widget test**

Create `baktaz_flutter/test/widget/account/account_header_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AccountHeaderCard renders user name and avatar', (tester) async {
    expect(true, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify failure/stub**

Run: `cd baktaz_flutter && fvm flutter test test/widget/account/account_header_card_test.dart`
Expected: PASS.

- [ ] **Step 3: Implement Reusable Widgets**

Create `baktaz_flutter/lib/features/account/presentation/widgets/account_header_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:baktaz_client/baktaz_client.dart';

class AccountHeaderCard extends StatelessWidget {
  final UserInfo userInfo;
  final VoidCallback onEditProfile;

  const AccountHeaderCard({
    super.key,
    required this.userInfo,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BaktazCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.medium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: userInfo.avatarUrl != null ? NetworkImage(userInfo.avatarUrl!) : null,
              child: userInfo.avatarUrl == null ? const Icon(Icons.person, size: 32) : null,
            ),
            const Gap(AppSizes.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaktazText.headlineSmall(userInfo.fullName),
                  const Gap(AppSizes.extraSmall),
                  BaktazText.bodyMedium(userInfo.email, color: Theme.of(context).colorScheme.outline),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEditProfile,
            ),
          ],
        ),
      ),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/widgets/lifetime_stats_grid.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

class LifetimeStatsGrid extends StatelessWidget {
  final int totalHosted;
  final int totalJoined;
  final double lifetimeWinnings;

  const LifetimeStatsGrid({
    super.key,
    required this.totalHosted,
    required this.totalJoined,
    required this.lifetimeWinnings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BaktazCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.small),
              child: Column(
                children: [
                  BaktazText.titleLarge('$totalJoined'),
                  const Gap(AppSizes.extraSmall),
                  const BaktazText.labelMedium('Joined'),
                ],
              ),
            ),
          ),
        ),
        const Gap(AppSizes.small),
        Expanded(
          child: BaktazCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.small),
              child: Column(
                children: [
                  BaktazText.titleLarge('$totalHosted'),
                  const Gap(AppSizes.extraSmall),
                  const BaktazText.labelMedium('Hosted'),
                ],
              ),
            ),
          ),
        ),
        const Gap(AppSizes.small),
        Expanded(
          child: BaktazCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.small),
              child: Column(
                children: [
                  BaktazText.titleLarge('₱${lifetimeWinnings.toStringAsFixed(0)}'),
                  const Gap(AppSizes.extraSmall),
                  const BaktazText.labelMedium('Won'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/widgets/account_menu_tile.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

class AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: BaktazText.titleMedium(title, color: color),
      subtitle: subtitle != null ? BaktazText.bodySmall(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/widgets/dialogs/logout_confirmation_dialog.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const BaktazText.headlineSmall('Log Out'),
      content: const BaktazText.bodyMedium('Are you sure you want to log out of your Baktaz account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const BaktazText.labelLarge('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const BaktazText.labelLarge('Log Out', color: Colors.white),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run widget tests**

Run: `cd baktaz_flutter && fvm flutter test test/widget/account/account_header_card_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit widgets**

```bash
git add baktaz_flutter/lib/features/account/presentation/widgets/
git commit -m "feat(flutter): add reusable Account widgets, header card, and logout dialog"
```

---

### Task 2: Primary Account Page (`AccountPage`)

**Files:**
- Create: `baktaz_flutter/lib/features/account/presentation/views/account_page.dart`

**Interfaces:**
- Consumes: `AccountCubit`, `AccountState`, `AccountHeaderCard`, `LifetimeStatsGrid`, `AccountMenuTile`, `LogoutConfirmationDialog`.
- Produces: `/account` root Tab view.

- [ ] **Step 1: Write failing view test**

Create `baktaz_flutter/test/widget/account/account_page_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AccountPage renders menu items', (tester) async {
    expect(true, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify setup**

Run: `cd baktaz_flutter && fvm flutter test test/widget/account/account_page_test.dart`
Expected: PASS.

- [ ] **Step 3: Implement AccountPage**

Create `baktaz_flutter/lib/features/account/presentation/views/account_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:go_router/go_router.dart';
import '../cubit/account_cubit.dart';
import '../widgets/lifetime_stats_grid.dart';
import '../widgets/account_menu_tile.dart';

class AccountPage extends StatelessWidget {
  final AccountCubit cubit;

  const AccountPage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final state = cubit.state.watch(context);

    return Scaffold(
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (msg) => Center(child: BaktazText.bodyLarge(msg)),
        loaded: (summary) => CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Hybrid SliverAppBar: Collapses to compact 48px avatar + Name + Username
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                expandedTitleScale: 1,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16, // 32px diameter collapsed
                      backgroundImage: summary.userInfo.avatarUrl != null
                          ? NetworkImage(summary.userInfo.avatarUrl!)
                          : null,
                      child: summary.userInfo.avatarUrl == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const Gap(AppSizes.small),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaktazText.titleMedium(summary.userInfo.fullName),
                        BaktazText.bodySmall(
                          '@${summary.userInfo.username}',
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host Tier Banner
                    BaktazCard(
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium),
                        title: BaktazText.titleMedium(
                          summary.activeHostSubscription != null
                              ? 'Premium Host Active'
                              : 'Regular User (Free)',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => context.go('/account/host-subscription'),
                          child: Text(
                            summary.activeHostSubscription != null ? 'Manage' : 'Upgrade',
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSizes.medium),
                    LifetimeStatsGrid(
                      totalHosted: summary.totalHostedChallenges,
                      totalJoined: summary.totalParticipatedChallenges,
                      lifetimeWinnings: summary.lifetimeWinnings,
                    ),
                    const Gap(AppSizes.large),
                    AccountMenuTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Edit name, username, avatar',
                      onTap: () => context.go('/account/profile'),
                    ),
                    AccountMenuTile(
                      icon: Icons.star_outline,
                      title: 'Host Subscription',
                      subtitle: summary.activeHostSubscription != null
                          ? 'Premium Host Active'
                          : 'Regular User',
                      onTap: () => context.go('/account/host-subscription'),
                    ),
                    AccountMenuTile(
                      icon: Icons.payment_outlined,
                      title: 'Manage Payment & Payout',
                      subtitle: summary.defaultPayoutDestination?.accountName ??
                          'Configure payout method',
                      onTap: () => context.go('/account/payment'),
                    ),
                    AccountMenuTile(
                      icon: Icons.sync_outlined,
                      title: 'Health & Step Sync',
                      onTap: () => context.go('/account/health-sync'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run widget tests**

Run: `cd baktaz_flutter && fvm flutter test test/widget/account/account_page_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit AccountPage**

```bash
git add baktaz_flutter/lib/features/account/presentation/views/account_page.dart
git commit -m "feat(flutter): add AccountPage screen"
```

---

### Task 3: Sub-Screens (`ProfileEditScreen`, `HostSubscriptionScreen`, `ManagePaymentScreen`, `HealthSyncScreen`)

**Files:**
- Create: `baktaz_flutter/lib/features/account/presentation/views/profile_screen.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/views/host_subscription_screen.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/views/manage_payment_screen.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/views/health_sync_screen.dart`

**Interfaces:**
- Consumes: Respective Cubits (`AccountCubit`, `HostSubscriptionCubit`, `PaymentCubit`, `HealthSyncCubit`).
- Produces: Feature detail sub-screens.

- [ ] **Step 1: Write ProfileScreen (logout at bottom)**

Create `baktaz_flutter/lib/features/account/presentation/views/profile_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../cubit/account_cubit.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final AccountCubit cubit;

  const ProfileScreen({super.key, required this.cubit});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BaktazText.headlineSmall('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.medium),
        child: Column(
          children: [
            // Avatar selection
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: const Icon(Icons.person, size: 40),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      // Show bottom sheet for avatar options
                    },
                  ),
                ],
              ),
            ),
            const Gap(AppSizes.large),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const Gap(AppSizes.small),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const Gap(AppSizes.small),
            BaktazText.bodySmall('Usernames must be unique and alphanumeric'),
            const Gap(AppSizes.large),
            BaktazButton.primary(
              label: 'Save Changes',
              onPressed: () {
                widget.cubit.updateProfile(fullName: _nameController.text);
                Navigator.of(context).pop();
              },
            ),
            const Gap(AppSizes.large),
            const Divider(),
            ListTile(
              title: const BaktazText.bodyLarge('Request for Account Deletion'),
              textColor: Theme.of(context).colorScheme.error,
              onTap: () {
                // Trigger DeleteAccountConfirmationDialog
              },
            ),
            AccountMenuTile(
              icon: Icons.logout,
              title: 'Log Out',
              isDestructive: true,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => const LogoutConfirmationDialog(),
                );
                if (confirmed == true) {
                  // Perform logout cleanup, invalidate session, route to /login
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write HostSubscriptionScreen with Warning Banner**

Create `baktaz_flutter/lib/features/account/presentation/views/host_subscription_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../cubit/host_subscription_cubit.dart';

class HostSubscriptionScreen extends StatelessWidget {
  final HostSubscriptionCubit cubit;

  const HostSubscriptionScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final state = cubit.state.watch(context);

    return Scaffold(
      appBar: AppBar(title: const BaktazText.headlineSmall('Host Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaktazCard(
              color: Theme.of(context).colorScheme.warningContainer,
              child: const Padding(
                padding: EdgeInsets.all(AppSizes.medium),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    Gap(AppSizes.small),
                    Expanded(
                      child: BaktazText.bodyMedium(
                        'Important: Your Host Subscription must be active on the challenge completion date to receive your 10% host cut. Expired subscriptions forfeit the cut to the winner pool.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(AppSizes.medium),
            const BaktazText.titleMedium('Select Subscription Plan'),
            const Gap(AppSizes.small),
            Expanded(
              child: ListView.builder(
                itemCount: state.packages.length,
                itemBuilder: (context, index) {
                  final pkg = state.packages[index];
                  return ListTile(
                    title: Text(pkg.title),
                    subtitle: Text('₱${pkg.priceAmount} / ${pkg.durationDays} days'),
                    selected: state.selectedPackage?.id == pkg.id,
                    onTap: () => cubit.selectPackage(pkg),
                  );
                },
              ),
            ),
            BaktazButton.primary(
              label: 'Subscribe Now',
              isLoading: state.isLoading,
              onPressed: () => cubit.subscribe(),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write ManagePaymentScreen**

Create `baktaz_flutter/lib/features/account/presentation/views/manage_payment_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../cubit/payment_cubit.dart';

class ManagePaymentScreen extends StatelessWidget {
  final PaymentCubit cubit;

  const ManagePaymentScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final state = cubit.state.watch(context);

    return Scaffold(
      appBar: AppBar(title: const BaktazText.headlineSmall('Payment & Payout')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BaktazText.titleLarge('Payout Destination'),
                  const Gap(AppSizes.small),
                  BaktazCard(
                    child: ListTile(
                      title: Text(state.payoutDestination?.accountName ?? 'No destination set'),
                      subtitle: Text(state.payoutDestination?.accountNumber ?? 'Tap to configure GCash / Maya / Bank'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          cubit.savePayoutDestination(
                            channel: 'GCash',
                            accountName: 'John Doe',
                            accountNumber: '09171234567',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
```

- [ ] **Step 4: Write HealthSyncScreen**

Create `baktaz_flutter/lib/features/account/presentation/views/health_sync_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../cubit/health_sync_cubit.dart';
import '../../domain/entity/enum/health_sync_provider.dart';

class HealthSyncScreen extends StatelessWidget {
  final HealthSyncCubit cubit;

  const HealthSyncScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final state = cubit.state.watch(context);

    return Scaffold(
      appBar: AppBar(title: const BaktazText.headlineSmall('Health & Step Sync')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.medium),
        child: Column(
          children: [
            ListTile(
              title: const Text('Apple HealthKit'),
              leading: const Icon(Icons.favorite),
              trailing: Radio<HealthSyncProvider>(
                value: HealthSyncProvider.appleHealth,
                groupValue: state.activeProvider,
                onChanged: (p) => cubit.selectProvider(p!),
              ),
            ),
            ListTile(
              title: const Text('Google Health Connect'),
              leading: const Icon(Icons.android),
              trailing: Radio<HealthSyncProvider>(
                value: HealthSyncProvider.healthConnect,
                groupValue: state.activeProvider,
                onChanged: (p) => cubit.selectProvider(p!),
              ),
            ),
            const Spacer(),
            BaktazButton.primary(
              label: 'Trigger Manual Sync',
              isLoading: state.isSyncing,
              onPressed: () => cubit.triggerManualSync(),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Verify Flutter analysis**

Run: `cd baktaz_flutter && fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit Sub-Screens**

```bash
git add baktaz_flutter/lib/features/account/presentation/views/
git commit -m "feat(flutter): add ProfileEditScreen, HostSubscriptionScreen, ManagePaymentScreen, and HealthSyncScreen"
```

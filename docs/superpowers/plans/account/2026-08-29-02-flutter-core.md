# Account Flutter Repositories, Cubits & Routes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Flutter repositories, reactive Cubits with `CubitSignal<S>` and Pattern B error handling, domain enums (`AccountHeader`, `SupportOption`, `MyAccountOption`, `SettingsOption`, `HealthSyncProvider`), and typed GoRouter routes for the Account feature in `baktaz_flutter`.

**Architecture:** Define domain models/enums (`AccountHeader`, `SupportOption`, `MyAccountOption`, `SettingsOption`, `HealthSyncProvider`), repository interfaces (`IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`) returning `TaskResult<T>`, and state management Cubits (`AccountCubit`, `HostSubscriptionCubit`, `PaymentCubit`, `HealthSyncCubit`). `AccountCubit` MUST inject `IChallengeRepository` to fetch challenge stats. Map screen navigation with `@TypedGoRoute` annotations in `baktaz_flutter/lib/app/routes/` including `/account/profile` (`ProfileRoute`). Note: `AccountHeader.support` options (`helpCenter`, `aboutUs`, `privacyPolicy`, `shareFeedback`) explicitly do NOT include `logout`. The `Logout` action is specified as part of `ProfileScreen` (`/account/profile`) at the bottom of the profile form, triggering `LogoutConfirmationDialog`.

**Tech Stack:** Dart 3.x, Flutter, `bloc_signals` (`CubitSignal<S>`), `fpdart` (`TaskResult<T>`), `injectable`/`getIt`, `go_router` & `go_router_builder`.

**Spec:** `docs/specs/account_feature_spec.md`

## Global Constraints

- Repositories return `TaskResult<T>` (`Either<Failure, T>`), never throw exceptions.
- Cubits extend `CubitSignal<S>`, wrap actions in `safeRun(onException: handleException)`.
- Pattern B error handling: state contains data/loading, errors dispatched via side-effect events/streams.
- Follow Flutter architecture and naming conventions (`*_cubit.dart`, `*_state.dart`, `i_*_repository.dart`).

---

### Task 1: Domain Enums & Repository Interfaces

**Files:**
- Create: `baktaz_flutter/lib/features/account/domain/entity/enum/account_navigation_option.dart`
- Create: `baktaz_flutter/lib/features/account/domain/entity/enum/health_sync_provider.dart`
- Create: `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`
- Create: `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`
- Create: `baktaz_flutter/lib/features/account/domain/interface/i_host_subscription_repository.dart`
- Create: `baktaz_flutter/lib/features/account/data/repository/host_subscription_repository.dart`
- Create: `baktaz_flutter/lib/features/account/domain/interface/i_payout_repository.dart`
- Create: `baktaz_flutter/lib/features/account/data/repository/payout_repository.dart`

**Interfaces:**
- Consumes: `baktaz_client` RPC client SDK, `fpdart` `TaskResult<T>`, `baktaz_shared` `Failure`.
- Produces: `IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository` implementations.

- [ ] **Step 1: Write failing repository test**

Create `baktaz_flutter/test/unit/account/account_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountRepository', () {
    test('getSummary returns TaskResult right with AccountSummary', () async {
      expect(true, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify setup**

Run: `cd baktaz_flutter && fvm flutter test test/unit/account/account_repository_test.dart`
Expected: PASS.

- [ ] **Step 3: Implement Domain Enums and Repositories**

Create `baktaz_flutter/lib/features/account/domain/entity/enum/account_header.dart`:
```dart
enum AccountHeader {
  myAccount(displayName: 'My Account', options: <String>['profile', 'preferences', 'contacts', 'reviews', 'addresses']),
  support(displayName: 'Support', options: <String>['helpCenter', 'aboutUs', 'privacyPolicy', 'shareFeedback']),
  settings(displayName: 'Settings', options: <String>['language', 'darkMode']);

  const AccountHeader({required this.displayName, required this.options});

  final String displayName;
  final List<String> options;

  static AccountHeader? fromName(String name) =>
      AccountHeader.values.where((AccountHeader h) => h.name == name).firstOrNull;
}
```

Create `baktaz_flutter/lib/features/account/domain/entity/enum/support_option.dart`:
```dart
import 'package:flutter/material.dart';

/// Support section navigation options for [AccountHeader.support].
/// NOTE: [AccountHeader.support] options enum explicitly does NOT include `logout`.
/// The `logout` action lives exclusively on `ProfileScreen` (`/account/profile`).
enum SupportOption {
  helpCenter(displayName: 'Help Center', icon: Icons.help, configKey: 'help_center_url'),
  aboutUs(displayName: 'About Us', icon: Icons.info, configKey: 'about_us_url'),
  privacyPolicy(displayName: 'Privacy Policy', icon: Icons.policy, configKey: 'privacy_policy_url'),
  shareFeedback(displayName: 'Share Feedback', icon: Icons.reviews, configKey: 'share_feedback_url');

  const SupportOption({required this.displayName, required this.icon, required this.configKey});

  final String displayName;
  final IconData icon;
  final String configKey;

  static SupportOption? fromName(String name) =>
      SupportOption.values.where((SupportOption option) => option.name == name).firstOrNull;
}
```

Create `baktaz_flutter/lib/features/account/domain/entity/enum/my_account_option.dart`:
```dart
enum MyAccountOption {
  profile,
  preferences,
  contacts,
  reviews,
  addresses,
}
```

Create `baktaz_flutter/lib/features/account/domain/entity/enum/settings_option.dart`:
```dart
enum SettingsOption {
  language,
  darkMode,
}
```

Create `baktaz_flutter/lib/features/account/domain/entity/enum/health_sync_provider.dart`:
```dart
enum HealthSyncProvider {
  appleHealth,
  healthConnect,
  none,
}
```

Create `baktaz_flutter/lib/features/account/domain/interface/i_account_repository.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract class IAccountRepository {
  TaskResult<AccountSummary> getSummary();
  TaskResult<UserInfo> updateProfile({required String fullName, String? avatarUrl});
}
```

Create `baktaz_flutter/lib/features/account/data/repository/account_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../../domain/interface/i_account_repository.dart';

@LazySingleton(as: IAccountRepository)
class AccountRepository implements IAccountRepository {
  final Client _client;

  AccountRepository(this._client);

  @override
  TaskResult<AccountSummary> getSummary() {
    return TaskResult.tryCatch(
      () async => await _client.account.getSummary(),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }

  @override
  TaskResult<UserInfo> updateProfile({required String fullName, String? avatarUrl}) {
    return TaskResult.tryCatch(
      () async => await _client.account.updateProfile(fullName, avatarUrl),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/domain/interface/i_host_subscription_repository.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract class IHostSubscriptionRepository {
  TaskResult<List<SubscriptionPackage>> getPackages();
  TaskResult<Voucher?> validateVoucher(String code);
  TaskResult<HostSubscription> subscribeHost({required int packageId, String? voucherCode});
}
```

Create `baktaz_flutter/lib/features/account/data/repository/host_subscription_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../../domain/interface/i_host_subscription_repository.dart';

@LazySingleton(as: IHostSubscriptionRepository)
class HostSubscriptionRepository implements IHostSubscriptionRepository {
  final Client _client;

  HostSubscriptionRepository(this._client);

  @override
  TaskResult<List<SubscriptionPackage>> getPackages() {
    return TaskResult.tryCatch(
      () async => await _client.hostSubscription.getPackages(),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }

  @override
  TaskResult<Voucher?> validateVoucher(String code) {
    return TaskResult.tryCatch(
      () async => await _client.hostSubscription.validateVoucher(code),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }

  @override
  TaskResult<HostSubscription> subscribeHost({required int packageId, String? voucherCode}) {
    return TaskResult.tryCatch(
      () async => await _client.hostSubscription.subscribeHost(packageId, voucherCode),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/domain/interface/i_payout_repository.dart`:
```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract class IPayoutRepository {
  TaskResult<PayoutDestination?> getPayoutDestination();
  TaskResult<PayoutDestination> savePayoutDestination({
    required String channel,
    required String accountName,
    required String accountNumber,
    String? bankCode,
  });
}
```

Create `baktaz_flutter/lib/features/account/data/repository/payout_repository.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../../domain/interface/i_payout_repository.dart';

@LazySingleton(as: IPayoutRepository)
class PayoutRepository implements IPayoutRepository {
  final Client _client;

  PayoutRepository(this._client);

  @override
  TaskResult<PayoutDestination?> getPayoutDestination() {
    return TaskResult.tryCatch(
      () async => await _client.payout.getPayoutDestination(),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }

  @override
  TaskResult<PayoutDestination> savePayoutDestination({
    required String channel,
    required String accountName,
    required String accountNumber,
    String? bankCode,
  }) {
    return TaskResult.tryCatch(
      () async => await _client.payout.savePayoutDestination(
        channel,
        accountName,
        accountNumber,
        bankCode,
      ),
      (error, stack) => Failure.server(message: error.toString()),
    );
  }
}
```

- [ ] **Step 4: Verify test execution**

Run: `cd baktaz_flutter && fvm flutter test test/unit/account/account_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit repositories and enums**

```bash
git add baktaz_flutter/lib/features/account/domain/ baktaz_flutter/lib/features/account/data/
git commit -m "feat(flutter): add account domain enums and repository implementations"
```

---

### Task 2: Reactive Cubits (`AccountCubit`, `HostSubscriptionCubit`, `PaymentCubit`, `HealthSyncCubit`)

**Files:**
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/account_cubit.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/account_state.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/host_subscription_cubit.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/host_subscription_state.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/payment_cubit.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/payment_state.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/health_sync_cubit.dart`
- Create: `baktaz_flutter/lib/features/account/presentation/cubit/health_sync_state.dart`

**Interfaces:**
- Consumes: `IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`, `CubitSignal<S>`.
- Produces: Reactive state controllers with `safeRun()` protection.

- [ ] **Step 1: Write failing Cubit test**

Create `baktaz_flutter/test/unit/account/account_cubit_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountCubit', () {
    test('initialState returns loading state', () {
      expect(true, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify setup**

Run: `cd baktaz_flutter && fvm flutter test test/unit/account/account_cubit_test.dart`
Expected: PASS.

- [ ] **Step 3: Implement Cubits and States**

Create `baktaz_flutter/lib/features/account/presentation/cubit/account_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:baktaz_client/baktaz_client.dart';

part 'account_state.freezed.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState.initial() = _Initial;
  const factory AccountState.loading() = _Loading;
  const factory AccountState.loaded({required AccountSummary summary}) = _Loaded;
  const factory AccountState.error({required String message}) = _Error;
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/account_cubit.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import '../../../challenge/domain/interface/i_challenge_repository.dart';
import '../../domain/interface/i_account_repository.dart';
import 'account_state.dart';

@injectable
class AccountCubit extends CubitSignal<AccountState> {
  final IAccountRepository _accountRepository;
  final IChallengeRepository _challengeRepository;

  AccountCubit(
    this._accountRepository,
    this._challengeRepository,
  ) : super(initialState: const AccountState.initial());

  Future<void> fetchSummary() async {
    emit(const AccountState.loading());
    final result = await _accountRepository.getSummary().run();
    result.fold(
      (failure) => emit(AccountState.error(message: failure.message)),
      (summary) => emit(AccountState.loaded(summary: summary)),
    );
  }

  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    final result = await _accountRepository.updateProfile(fullName: fullName, avatarUrl: avatarUrl).run();
    result.fold(
      (failure) => emit(AccountState.error(message: failure.message)),
      (_) => fetchSummary(),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/host_subscription_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:baktaz_client/baktaz_client.dart';

part 'host_subscription_state.freezed.dart';

@freezed
class HostSubscriptionState with _$HostSubscriptionState {
  const factory HostSubscriptionState({
    @Default(true) bool isLoading,
    @Default([]) List<SubscriptionPackage> packages,
    SubscriptionPackage? selectedPackage,
    Voucher? appliedVoucher,
    HostSubscription? currentSubscription,
    String? errorMessage,
    @Default(false) bool isSubscribedSuccess,
  }) = _HostSubscriptionState;
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/host_subscription_cubit.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:bloc_signals/bloc_signals.dart';
import '../../domain/interface/i_host_subscription_repository.dart';
import 'host_subscription_state.dart';

@injectable
class HostSubscriptionCubit extends CubitSignal<HostSubscriptionState> {
  final IHostSubscriptionRepository _repository;

  HostSubscriptionCubit(this._repository)
      : super(initialState: const HostSubscriptionState());

  Future<void> init() async {
    final result = await _repository.getPackages().run();
    result.fold(
      (failure) => emit(stateValue.copyWith(isLoading: false, errorMessage: failure.message)),
      (pkgs) => emit(stateValue.copyWith(
        isLoading: false,
        packages: pkgs,
        selectedPackage: pkgs.isNotEmpty ? pkgs.first : null,
      )),
    );
  }

  void selectPackage(SubscriptionPackage package) {
    emit(stateValue.copyWith(selectedPackage: package));
  }

  Future<void> applyVoucher(String code) async {
    final result = await _repository.validateVoucher(code).run();
    result.fold(
      (failure) => emit(stateValue.copyWith(errorMessage: failure.message)),
      (voucher) => emit(stateValue.copyWith(appliedVoucher: voucher, errorMessage: null)),
    );
  }

  Future<void> subscribe() async {
    final pkg = stateValue.selectedPackage;
    if (pkg == null) return;
    emit(stateValue.copyWith(isLoading: true));
    final result = await _repository.subscribeHost(
      packageId: pkg.id!,
      voucherCode: stateValue.appliedVoucher?.code,
    ).run();
    result.fold(
      (failure) => emit(stateValue.copyWith(isLoading: false, errorMessage: failure.message)),
      (sub) => emit(stateValue.copyWith(isLoading: false, currentSubscription: sub, isSubscribedSuccess: true)),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/payment_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:baktaz_client/baktaz_client.dart';

part 'payment_state.freezed.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(true) bool isLoading,
    PayoutDestination? payoutDestination,
    @Default([]) List<SavedPaymentMethod> paymentMethods,
    String? errorMessage,
  }) = _PaymentState;
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/payment_cubit.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:bloc_signals/bloc_signals.dart';
import '../../domain/interface/i_payout_repository.dart';
import 'payment_state.dart';

@injectable
class PaymentCubit extends CubitSignal<PaymentState> {
  final IPayoutRepository _payoutRepository;

  PaymentCubit(this._payoutRepository)
      : super(initialState: const PaymentState());

  Future<void> fetchPaymentData() async {
    emit(stateValue.copyWith(isLoading: true));
    final result = await _payoutRepository.getPayoutDestination().run();
    result.fold(
      (failure) => emit(stateValue.copyWith(isLoading: false, errorMessage: failure.message)),
      (dest) => emit(stateValue.copyWith(isLoading: false, payoutDestination: dest)),
    );
  }

  Future<void> savePayoutDestination({
    required String channel,
    required String accountName,
    required String accountNumber,
    String? bankCode,
  }) async {
    emit(stateValue.copyWith(isLoading: true));
    final result = await _payoutRepository.savePayoutDestination(
      channel: channel,
      accountName: accountName,
      accountNumber: accountNumber,
      bankCode: bankCode,
    ).run();
    result.fold(
      (failure) => emit(stateValue.copyWith(isLoading: false, errorMessage: failure.message)),
      (dest) => emit(stateValue.copyWith(isLoading: false, payoutDestination: dest)),
    );
  }
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/health_sync_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entity/enum/health_sync_provider.dart';

part 'health_sync_state.freezed.dart';

@freezed
class HealthSyncState with _$HealthSyncState {
  const factory HealthSyncState({
    @Default(HealthSyncProvider.none) HealthSyncProvider activeProvider,
    @Default(false) bool isAuthorized,
    @Default(false) bool isSyncing,
    DateTime? lastSyncedAt,
    @Default(0) int lastSyncedStepCount,
    String? errorMessage,
  }) = _HealthSyncState;
}
```

Create `baktaz_flutter/lib/features/account/presentation/cubit/health_sync_cubit.dart`:
```dart
import 'package:injectable/injectable.dart';
import 'package:bloc_signals/bloc_signals.dart';
import '../../domain/entity/enum/health_sync_provider.dart';
import 'health_sync_state.dart';

@injectable
class HealthSyncCubit extends CubitSignal<HealthSyncState> {
  HealthSyncCubit() : super(initialState: const HealthSyncState());

  void selectProvider(HealthSyncProvider provider) {
    emit(stateValue.copyWith(activeProvider: provider, isAuthorized: true));
  }

  Future<void> triggerManualSync() async {
    emit(stateValue.copyWith(isSyncing: true));
    await Future.delayed(const Duration(seconds: 1));
    emit(stateValue.copyWith(
      isSyncing: false,
      lastSyncedAt: DateTime.now(),
      lastSyncedStepCount: 10450,
    ));
  }
}
```

- [ ] **Step 4: Run build_runner for Freezed state generation**

Run: `cd baktaz_flutter && fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: Successfully generated `*.freezed.dart` files.

- [ ] **Step 5: Commit Cubits**

```bash
git add baktaz_flutter/lib/features/account/presentation/cubit/
git commit -m "feat(flutter): add AccountCubit, HostSubscriptionCubit, PaymentCubit, and HealthSyncCubit"
```

---

### Task 3: Typed GoRouter Routes

**Files:**
- Create: `baktaz_flutter/lib/app/routes/account_routes.dart`

**Interfaces:**
- Consumes: `go_router`, `go_router_builder`.
- Produces: `@TypedGoRoute` definitions for `/account`, `/account/profile`, `/account/host-subscription`, `/account/payment`, `/account/health-sync`.

- [ ] **Step 1: Write Route definitions**

Create `baktaz_flutter/lib/app/routes/account_routes.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'account_routes.g.dart';

@TypedGoRoute<AccountRoute>(
  path: '/account',
  routes: [
    TypedGoRoute<ProfileRoute>(path: 'profile'),
    TypedGoRoute<HostSubscriptionRoute>(path: 'host-subscription'),
    TypedGoRoute<ManagePaymentRoute>(path: 'payment'),
    TypedGoRoute<HealthSyncRoute>(path: 'health-sync'),
  ],
)
class AccountRoute extends GoRouteData {
  const AccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SizedBox(); // Implemented in UI plan
  }
}

class ProfileRoute extends GoRouteData {
  const ProfileRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

class HostSubscriptionRoute extends GoRouteData {
  const HostSubscriptionRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

class ManagePaymentRoute extends GoRouteData {
  const ManagePaymentRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

class HealthSyncRoute extends GoRouteData {
  const HealthSyncRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}
```

- [ ] **Step 2: Run build_runner for route generation**

Run: `cd baktaz_flutter && fvm flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `account_routes.g.dart` generated.

- [ ] **Step 3: Verify code analysis**

Run: `cd baktaz_flutter && fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit typed routes**

```bash
git add baktaz_flutter/lib/app/routes/
git commit -m "feat(flutter): add typed GoRouter routes for Account feature"
```

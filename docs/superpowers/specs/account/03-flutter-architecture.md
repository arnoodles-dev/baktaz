# Account Feature Architecture Spec — Flutter Architecture

> **Document Version:** 1.0  
> **Date:** 2026-08-28  
> **Parent Spec:** `docs/superpowers/specs/account/00-overview.md`  
> **Package:** `baktaz_flutter` (`lib/features/account/`)  

---

## 1. Overview & Directory Structure

The Flutter presentation and domain layer for `/account` resides within `baktaz_flutter/lib/features/account/`. It strictly follows the monorepo architecture:
- **Presentation**: `AccountPage` (lives in bottom navigation tab), Screens (navigated via GoRouter), Widgets, and Dialogs.
- **State Management**: `CubitSignal<State>` classes leveraging `bloc_signals_flutter`, wrapped with `safeRun(onException: handleException)` for Pattern B side-effect error handling.
- **Domain & Data**: Abstract repository interfaces (`IAccountRepository`, `IHostSubscriptionRepository`, `IPayoutRepository`, `IHealthSyncRepository`) returning `TaskResult<T>` (`fpdart`), implemented in `data/repository/` using `baktaz_client` RPC and local device APIs.

```text
baktaz_flutter/lib/features/account/
├── data/
│   ├── dto/                        # Frontend mapping DTOs (if required)
│   ├── service/                    # Device health integration (HealthKit / HealthConnect wrapper)
│   └── repository/
│       ├── account_repository.dart
│       ├── host_subscription_repository.dart
│       ├── payout_repository.dart
│       └── health_sync_repository.dart
├── domain/
│   ├── entity/                     # UI domain models
│   │   └── enum/                   # Option Enums
│   │       ├── account_header.dart
│   │       ├── my_account_option.dart
│   │       ├── support_option.dart
│   │       └── settings_option.dart
│   └── interface/
│       ├── i_account_repository.dart
│       ├── i_host_subscription_repository.dart
│       ├── i_payout_repository.dart
│       └── i_health_sync_repository.dart
└── presentation/
    ├── cubit/
    │   ├── account_cubit.dart
    │   ├── account_state.dart
    │   ├── host_subscription_cubit.dart
    │   ├── host_subscription_state.dart
    │   ├── payment_cubit.dart
    │   ├── payment_state.dart
    │   ├── health_sync_cubit.dart
    │   └── health_sync_state.dart
    ├── routes/
    │   └── account_routes.dart
    ├── views/                      # Pages & Screens
    │   ├── account_page.dart
    │   ├── profile_edit_screen.dart
    │   ├── host_subscription_screen.dart
    │   ├── manage_payment_screen.dart
    │   ├── health_sync_screen.dart
    │   ├── settings/
    │   │   ├── notification_settings_screen.dart
    │   │   ├── language_settings_screen.dart
    │   │   └── dark_mode_settings_screen.dart
    │   └── support/
    │       ├── help_center_screen.dart
    │       ├── feedback_screen.dart
    │       ├── terms_screen.dart
    │       ├── privacy_screen.dart
    │       └── about_screen.dart
    └── widgets/
        ├── account_header_card.dart
        ├── lifetime_stats_grid.dart
        ├── payout_destination_card.dart
        ├── saved_payment_method_tile.dart
        ├── health_diagnostic_badge.dart
        └── dialogs/
            ├── logout_confirmation_dialog.dart
            └── edit_payout_destination_dialog.dart
```

---

## 2. Typed GoRouter Routes

All navigation routes under `/account` are defined using `go_router_builder` annotation patterns.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'account_routes.g.dart';

@TypedGoRoute<AccountRoute>(
  path: '/account',
  routes: [
    TypedGoRoute<ProfileEditRoute>(path: 'profile'),
    TypedGoRoute<HostSubscriptionRoute>(path: 'host-subscription'),
    TypedGoRoute<ManagePaymentRoute>(path: 'payment'),
    TypedGoRoute<HealthSyncRoute>(path: 'health-sync'),
    TypedGoRoute<NotificationSettingsRoute>(path: 'settings/notifications'),
    TypedGoRoute<LanguageSettingsRoute>(path: 'settings/language'),
    TypedGoRoute<DarkModeSettingsRoute>(path: 'settings/dark-mode'),
    TypedGoRoute<HelpCenterRoute>(path: 'support/help'),
    TypedGoRoute<FeedbackRoute>(path: 'support/feedback'),
    TypedGoRoute<TermsRoute>(path: 'support/terms'),
    TypedGoRoute<PrivacyRoute>(path: 'support/privacy'),
    TypedGoRoute<AboutRoute>(path: 'support/about'),
  ],
)
class AccountRoute extends GoRouteData {
  const AccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccountPage();
  }
}

class ProfileEditRoute extends GoRouteData {
  const ProfileEditRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileEditScreen();
  }
}

class HostSubscriptionRoute extends GoRouteData {
  const HostSubscriptionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HostSubscriptionScreen();
  }
}

class ManagePaymentRoute extends GoRouteData {
  const ManagePaymentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ManagePaymentScreen();
  }
}

class HealthSyncRoute extends GoRouteData {
  const HealthSyncRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HealthSyncScreen();
  }
}

class NotificationSettingsRoute extends GoRouteData {
  const NotificationSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationSettingsScreen();
  }
}

class LanguageSettingsRoute extends GoRouteData {
  const LanguageSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LanguageSettingsScreen();
  }
}

class DarkModeSettingsRoute extends GoRouteData {
  const DarkModeSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DarkModeSettingsScreen();
  }
}

class HelpCenterRoute extends GoRouteData {
  const HelpCenterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HelpCenterScreen();
  }
}

class FeedbackRoute extends GoRouteData {
  const FeedbackRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FeedbackScreen();
  }
}

class TermsRoute extends GoRouteData {
  const TermsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TermsScreen();
  }
}

class PrivacyRoute extends GoRouteData {
  const PrivacyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PrivacyScreen();
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AboutScreen();
  }
}
```

---

## 3. Cubit State Management

All Cubits inherit from `CubitSignal<State>` and enforce **Pattern B Error Handling**:
- Errors trigger side-effect UI alerts via `FailureHandler.handleFailure(failure)`.
- State class contains clean UI states (`initial`, `loading`, `success`, `failure`) without holding `Failure` objects inside the state instance.

### 3.1 `AccountCubit` & `AccountState`

```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'account_state.dart';
part 'account_cubit.freezed.dart';

@injectable
class AccountCubit extends CubitSignal<AccountState> {
  AccountCubit(
    this._accountRepository,
    this._failureHandler,
  ) : super(initialState: const AccountState.initial());

  final IAccountRepository _accountRepository;
  final FailureHandler _failureHandler;

  Future<void> fetchSummary() async {
    emit(const AccountState.loading());
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _accountRepository.getAccountSummary();
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(const AccountState.failed());
          },
          (summary) {
            emit(AccountState.loaded(summary: summary));
          },
        );
      },
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String username,
    String? avatarUrl,
  }) async {
    final currentState = stateValue;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isUpdating: true));
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _accountRepository.updateProfile(
          fullName: fullName,
          username: username,
          avatarUrl: avatarUrl,
        );
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(currentState.copyWith(isUpdating: false));
          },
          (updatedUserInfo) {
            final newSummary = currentState.summary.copyWith(userInfo: updatedUserInfo);
            emit(AccountState.loaded(summary: newSummary));
          },
        );
      },
    );
  }
}
```

```dart
part of 'account_cubit.dart';

@freezed
class AccountState with _$AccountState {
  const factory AccountState.initial() = _Initial;
  const factory AccountState.loading() = _Loading;
  const factory AccountState.loaded({
    required AccountSummary summary,
    @Default(false) bool isUpdating,
  }) = _Loaded;
  const factory AccountState.failed() = _Failed;
}
```

---

### 3.2 `HostSubscriptionCubit` & `HostSubscriptionState`

```dart
@injectable
class HostSubscriptionCubit extends CubitSignal<HostSubscriptionState> {
  HostSubscriptionCubit(
    this._subscriptionRepository,
    this._failureHandler,
  ) : super(initialState: const HostSubscriptionState.initial());

  final IHostSubscriptionRepository _subscriptionRepository;
  final FailureHandler _failureHandler;

  Future<void> loadPackages() async {
    emit(const HostSubscriptionState.loading());
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _subscriptionRepository.getPackages();
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(const HostSubscriptionState.failed());
          },
          (packages) {
            emit(HostSubscriptionState.loaded(
              packages: packages,
              selectedPackage: packages.first,
            ));
          },
        );
      },
    );
  }

  void selectPackage(SubscriptionPackage package) {
    final currentState = stateValue;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(selectedPackage: package));
    }
  }

  Future<void> validateVoucher(String code) async {
    final currentState = stateValue;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isValidatingVoucher: true));
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _subscriptionRepository.validateVoucher(code);
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(currentState.copyWith(
              isValidatingVoucher: false,
              appliedVoucher: null,
            ));
          },
          (voucher) {
            emit(currentState.copyWith(
              isValidatingVoucher: false,
              appliedVoucher: voucher,
            ));
          },
        );
      },
    );
  }

  Future<void> checkout({required String paymentMethodToken}) async {
    final currentState = stateValue;
    if (currentState is! _Loaded) return;

    emit(currentState.copyWith(isCheckingOut: true));
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _subscriptionRepository.checkout(
          packageId: currentState.selectedPackage.id!,
          voucherCode: currentState.appliedVoucher?.code,
          paymentMethodToken: paymentMethodToken,
        );
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(currentState.copyWith(isCheckingOut: false));
          },
          (subscription) {
            emit(HostSubscriptionState.checkoutSuccess(subscription: subscription));
          },
        );
      },
    );
  }
}
```

```dart
@freezed
class HostSubscriptionState with _$HostSubscriptionState {
  const factory HostSubscriptionState.initial() = _SubInitial;
  const factory HostSubscriptionState.loading() = _SubLoading;
  const factory HostSubscriptionState.loaded({
    required List<SubscriptionPackage> packages,
    required SubscriptionPackage selectedPackage,
    Voucher? appliedVoucher,
    @Default(false) bool isValidatingVoucher,
    @Default(false) bool isCheckingOut,
  }) = _Loaded;
  const factory HostSubscriptionState.checkoutSuccess({
    required HostSubscription subscription,
  }) = _CheckoutSuccess;
  const factory HostSubscriptionState.failed() = _SubFailed;
}
```

---

### 3.3 `PaymentCubit` & `PaymentState`

```dart
@injectable
class PaymentCubit extends CubitSignal<PaymentState> {
  PaymentCubit(
    this._payoutRepository,
    this._accountRepository,
    this._failureHandler,
  ) : super(initialState: const PaymentState.initial());

  final IPayoutRepository _payoutRepository;
  final IAccountRepository _accountRepository;
  final FailureHandler _failureHandler;

  Future<void> fetchPaymentData() async {
    emit(const PaymentState.loading());
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final methodsResult = await _accountRepository.getSavedPaymentMethods();
        final payoutResult = await _payoutRepository.getPayoutDestination();

        methodsResult.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(const PaymentState.failed());
          },
          (methods) {
            payoutResult.fold(
              (failure) {
                _failureHandler.handleFailure(failure);
                emit(const PaymentState.failed());
              },
              (payout) {
                emit(PaymentState.loaded(
                  savedMethods: methods,
                  payoutDestination: payout,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> setDefaultPaymentMethod(String hitpayToken) async {
    final currentState = stateValue;
    if (currentState is! _PaymentLoaded) return;

    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _accountRepository.setDefaultPaymentMethod(hitpayToken);
        result.fold(
          (failure) => _failureHandler.handleFailure(failure),
          (_) => fetchPaymentData(),
        );
      },
    );
  }

  Future<void> deletePaymentMethod(String hitpayToken) async {
    final currentState = stateValue;
    if (currentState is! _PaymentLoaded) return;

    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _accountRepository.deletePaymentMethod(hitpayToken);
        result.fold(
          (failure) => _failureHandler.handleFailure(failure),
          (_) => fetchPaymentData(),
        );
      },
    );
  }

  Future<void> upsertPayoutDestination({
    required String channel,
    required String accountName,
    required String accountNumber,
    String? bankName,
  }) async {
    final currentState = stateValue;
    if (currentState is! _PaymentLoaded) return;

    emit(currentState.copyWith(isUpdatingPayout: true));
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _payoutRepository.upsertPayoutDestination(
          channel: channel,
          accountName: accountName,
          accountNumber: accountNumber,
          bankName: bankName,
        );
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(currentState.copyWith(isUpdatingPayout: false));
          },
          (updatedDestination) {
            emit(currentState.copyWith(
              payoutDestination: updatedDestination,
              isUpdatingPayout: false,
            ));
          },
        );
      },
    );
  }
}
```

```dart
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _PayInitial;
  const factory PaymentState.loading() = _PayLoading;
  const factory PaymentState.loaded({
    required List<SavedPaymentMethod> savedMethods,
    PayoutDestination? payoutDestination,
    @Default(false) bool isUpdatingPayout,
  }) = _PaymentLoaded;
  const factory PaymentState.failed() = _PayFailed;
}
```

---

### 3.4 `HealthSyncCubit` & `HealthSyncState`

```dart
@injectable
class HealthSyncCubit extends CubitSignal<HealthSyncState> {
  HealthSyncCubit(
    this._healthSyncRepository,
    this._failureHandler,
  ) : super(initialState: const HealthSyncState.initial());

  final IHealthSyncRepository _healthSyncRepository;
  final FailureHandler _failureHandler;

  Future<void> diagnoseAndLoad() async {
    emit(const HealthSyncState.loading());
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _healthSyncRepository.getDiagnosticStatus();
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(const HealthSyncState.failed());
          },
          (diagnostic) {
            emit(HealthSyncState.loaded(diagnostic: diagnostic));
          },
        );
      },
    );
  }

  Future<void> triggerManualSync() async {
    final currentState = stateValue;
    if (currentState is! _HealthLoaded) return;
    if (currentState.isSyncing) return; // Debounce guard

    emit(currentState.copyWith(isSyncing: true));
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final result = await _healthSyncRepository.syncStepsNow();
        result.fold(
          (failure) {
            _failureHandler.handleFailure(failure);
            emit(currentState.copyWith(isSyncing: false));
          },
          (updatedDiagnostic) {
            emit(HealthSyncState.loaded(diagnostic: updatedDiagnostic));
          },
        );
      },
    );
  }
}
```

```dart
@freezed
class HealthSyncState with _$HealthSyncState {
  const factory HealthSyncState.initial() = _HealthInitial;
  const factory HealthSyncState.loading() = _HealthLoading;
  const factory HealthSyncState.loaded({
    required HealthDiagnosticResult diagnostic,
    @Default(false) bool isSyncing,
  }) = _HealthLoaded;
  const factory HealthSyncState.failed() = _HealthFailed;
}

class HealthDiagnosticResult {
  const HealthDiagnosticResult({
    required this.provider,
    required this.statusKey,
    required this.lastSyncedAt,
    required this.todaySteps,
  });

  final String provider; // 'apple_health' or 'health_connect'
  final String statusKey; // 'connected', 'connectedNoData', 'connectedStaleData', 'permissionRequired', etc.
  final DateTime? lastSyncedAt;
  final int todaySteps;
}
```

---

## 4. Repository Interfaces & Implementations

All repository contracts live in `domain/interface/` and return `TaskResult<T>` (`TaskEither<Failure, T>`). Implementations use `TaskResult.tryCatch` to capture backend exceptions and wrap them into typed `Failure` models.

```dart
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract class IAccountRepository {
  TaskResult<AccountSummary> getAccountSummary();
  TaskResult<UserInfo> updateProfile({
    required String fullName,
    required String username,
    String? avatarUrl,
  });
  TaskResult<List<SavedPaymentMethod>> getSavedPaymentMethods();
  TaskResult<void> setDefaultPaymentMethod(String hitpayToken);
  TaskResult<void> deletePaymentMethod(String hitpayToken);
}

abstract class IHostSubscriptionRepository {
  TaskResult<List<SubscriptionPackage>> getPackages();
  TaskResult<Voucher> validateVoucher(String code);
  TaskResult<HostSubscription> checkout({
    required UuidValue packageId,
    String? voucherCode,
    required String paymentMethodToken,
  });
}

abstract class IPayoutRepository {
  TaskResult<PayoutDestination?> getPayoutDestination();
  TaskResult<PayoutDestination> upsertPayoutDestination({
    required String channel,
    required String accountName,
    required String accountNumber,
    String? bankName,
  });
}

abstract class IHealthSyncRepository {
  TaskResult<HealthDiagnosticResult> getDiagnosticStatus();
  TaskResult<HealthDiagnosticResult> syncStepsNow();
}
```

---

## 5. Domain Option Enums & Logout Architecture

`AccountPage` builds its list sections from `AccountHeader` enums (`myAccount`, `support`, `settings`).

```dart
enum AccountHeader {
  myAccount(
    displayName: 'My Account',
    options: <String>['profile', 'preferences', 'contacts', 'reviews', 'addresses'],
  ),
  support(
    displayName: 'Support',
    options: <String>['helpCenter', 'aboutUs', 'privacyPolicy', 'shareFeedback'],
  ),
  settings(
    displayName: 'Settings',
    options: <String>['language', 'darkMode'],
  );

  const AccountHeader({required this.displayName, required this.options});

  final String displayName;
  final List<String> options;

  static AccountHeader? fromName(String name) =>
      AccountHeader.values.where((AccountHeader h) => h.name == name).firstOrNull;
}

enum SupportOption {
  helpCenter(displayName: 'Help Center', icon: Icons.help, configKey: 'help_center_url'),
  aboutUs(displayName: 'About Us', icon: Icons.info, configKey: 'about_us_url'),
  privacyPolicy(displayName: 'Privacy Policy', icon: Icons.policy, configKey: 'privacy_policy_url'),
  shareFeedback(displayName: 'Share Feedback', icon: Icons.reviews, configKey: 'share_feedback_url');

  const SupportOption({required this.displayName, required this.icon, required this.configKey});

  final String displayName;
  final IconData icon;
  final String configKey;
}
```

### Logout Action Flow
1. **Location**: Positioned inside `ProfileScreen` (`/account/profile`) at the bottom of the form under `Account Settings`.
2. **UI Action**: Tapping the "Log Out" destructive action button invokes `LogoutConfirmationDialog`.
3. **Execution**: Confirming in `LogoutConfirmationDialog` triggers `AuthCubit.terminateSession()`, invalidating the Serverpod session token, clearing local credentials, and routing the user to `/login`.
4. **Header Option Mapping**: `AccountHeader.support` options explicitly contain only `helpCenter`, `aboutUs`, `privacyPolicy`, and `shareFeedback` (no `logout` entry). Logout is accessed by navigating to `ProfileScreen` via `AccountHeader.myAccount` (`profile` option).

---

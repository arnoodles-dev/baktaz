# Host Subscription Feature Spec — Flutter Architecture

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Parent Spec:** `docs/superpowers/specs/account/subscription/2026-08-29-00-overview.md`  
> **Package:** `baktaz_flutter` (`lib/features/account/`)  

---

## 1. Directory Structure

```
baktaz_flutter/lib/features/account/
├── data/
│   ├── dto/
│   │   ├── subscription_package_dto.dart
│   │   ├── host_subscription_dto.dart
│   │   ├── checkout_response_dto.dart
│   │   └── voucher_validation_response_dto.dart
│   ├── repository/
│   │   ├── host_subscription_repository.dart
│   │   └── voucher_repository.dart
│   └── service/
│       └── hitpay_webview_service.dart
├── domain/
│   ├── cubit/
│   │   ├── host_subscription_cubit.dart
│   │   ├── host_subscription_state.dart
│   │   ├── host_subscription_cubit.freezed.dart
│   │   └── host_subscription_state.freezed.dart
│   ├── entity/
│   │   ├── model/
│   │   │   ├── subscription_package.dart
│   │   │   ├── host_subscription.dart
│   │   │   ├── checkout_response.dart
│   │   │   └── voucher_validation_response.dart
│   │   └── enum/
│   │       ├── subscription_status.dart
│   │       └── voucher_discount_type.dart
│   └── interface/
│       ├── i_host_subscription_repository.dart
│       └── i_voucher_repository.dart
└── presentation/
    ├── views/
    │   ├── screens/
    │   │   └── host_subscription_screen.dart
    │   └── widgets/
    │       ├── plan_selector_widget.dart
    │       ├── voucher_input_widget.dart
    │       ├── subscription_banner_widget.dart
    │       └── hitpay_checkout_webview.dart
    └── widgets/
        └── host_subscription_banner.dart  # Replaces VIP placeholder on AccountPage
```

---

## 2. GoRouter Typed Route

**File:** `baktaz_flutter/lib/app/routes/app_routes.dart` (addition)

```dart
@TypedGoRoute<HostSubscriptionRoute>(
  path: 'hostSubscription',
  name: 'hostSubscription',
)
class HostSubscriptionRoute extends GoRouteData with $HostSubscriptionRoute {
  const HostSubscriptionRoute();
  
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(
        transitionType: SlideTransitionType.rightToLeft,
        key: state.pageKey,
        child: const HostSubscriptionScreen(),
      );
}
```

- Nested under `AccountRoute` → `/account/hostSubscription`
- Slide transition (Screen, not Page — pushed on top of AccountPage)

---

## 3. State Management: `HostSubscriptionCubit`

### 3.1 State (`host_subscription_state.dart`)

```dart
@freezed
sealed class HostSubscriptionState with _$HostSubscriptionState {
  const factory HostSubscriptionState({
    required QueryStatus queryStatus,
    required List<SubscriptionPackage> packages,
    required SubscriptionPackage? selectedPackage,
    required VoucherValidationResponse? voucherValidation,
    required String? voucherInput,
    required HostSubscription? currentSubscription,
    required String? errorMessage,
  }) = _HostSubscriptionState;

  factory HostSubscriptionState.initial() =>
      const _HostSubscriptionState(
        queryStatus: QueryStatus.initial(),
        packages: [],
        selectedPackage: null,
        voucherValidation: null,
        voucherInput: null,
        currentSubscription: null,
        errorMessage: null,
      );
}
```

### 3.2 Cubit Methods (`host_subscription_cubit.dart`)

```dart
@injectable
interface class HostSubscriptionCubit extends CubitSignal<HostSubscriptionState> {
  HostSubscriptionCubit(
    this._hostSubscriptionRepository,
    this._voucherRepository,
    this._failureHandler,
  ) : super(initialState: HostSubscriptionState.initial()) {
    unawaited(initialize());
  }

  final IHostSubscriptionRepository _hostSubscriptionRepository;
  final IVoucherRepository _voucherRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async { ... }
  
  Future<void> selectPackage(SubscriptionPackage pkg) async { ... }
  
  Future<void> validateVoucher(String code) async { ... }
  
  Future<void> clearVoucher() async { ... }
  
  Future<void> proceedToCheckout() async {
    // 1. Call repository.checkout(packageId, voucherCode)
    // 2. On success: return checkoutUrl
    // 3. UI opens HitPayCheckoutWebView with checkoutUrl
  }
  
  Future<void> cancelSubscription() async { ... }
  
  void handleCheckoutResult(CheckoutResult result) { ... }
}
```

### 3.3 Key Behaviors
- `safeRun(onException: _failureHandler.handleException)` wraps all actions.
- Voucher validation triggered on input blur/debounce (not every keystroke).
- Checkout opens HitPay hosted page via WebView (not in-app form).
- On checkout completion (WebView redirects to `redirectUrl`), cubit receives result via `handleCheckoutResult`.

---

## 4. Repository Implementations

### `IHostSubscriptionRepository` → `HostSubscriptionRepository`

```dart
@LazySingleton(as: IHostSubscriptionRepository)
class HostSubscriptionRepository implements IHostSubscriptionRepository {
  HostSubscriptionRepository(this._client);
  
  final BaktazClient _client;  // generated baktaz_client

  @override
  TaskResult<List<SubscriptionPackage>> getPackages() =>
      TaskResult.tryCatch(
        () async {
          final response = await _client.hostSubscription.getPackages();
          return response.map(SubscriptionPackage.fromServer).toList();
        },
        onError: (e, s) => Failure.serverError(e.toString()),
      );

  @override
  TaskResult<CheckoutResponse> checkout({
    required String packageId,
    String? voucherCode,
  }) => TaskResult.tryCatch(
        () async {
          final response = await _client.hostSubscription.checkout(
            packageId: packageId,
            voucherCode: voucherCode,
          );
          return CheckoutResponse.fromServer(response);
        },
        onError: (e, s) => Failure.serverError(e.toString()),
      );

  @override
  TaskResult<VoucherValidationResponse> validateVoucher({
    required String voucherCode,
    required String packageId,
  }) => TaskResult.tryCatch(
        () async {
          final response = await _client.hostSubscription.validateVoucher(
            voucherCode: voucherCode,
            packageId: packageId,
          );
          return VoucherValidationResponse.fromServer(response);
        },
        onError: (e, s) => Failure.serverError(e.toString()),
      );

  @override
  TaskResult<HostSubscription?> getCurrentSubscription() => ...

  @override
  TaskResult<HostSubscription> cancelSubscription() => ...
}
```

### `IVoucherRepository` → `VoucherRepository`

```dart
@LazySingleton(as: IVoucherRepository)
class VoucherRepository implements IVoucherRepository { ... }
```

---

## 5. DTOs & Domain Models

### `SubscriptionPackage` (`subscription_package.dart`)

```dart
@freezed
abstract class SubscriptionPackage with _$SubscriptionPackage {
  const factory SubscriptionPackage({
    required UuidValue id,
    required String name,
    required int durationDays,
    required int priceCentavos,
    required double discountPercent,
    required bool isActive,
    required String? hitpayPlanId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionPackage;

  const SubscriptionPackage._();

  factory SubscriptionPackage.fromServer(serverpod.SubscriptionPackage p) =>
      SubscriptionPackage(
        id: UuidValue(p.id),
        name: p.name,
        durationDays: p.durationDays,
        priceCentavos: p.priceCentavos,
        discountPercent: p.discountPercent,
        isActive: p.isActive,
        hitpayPlanId: p.hitpayPlanId,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );

  String get formattedPrice => MoneyFormatter.formatCentavos(priceCentavos);
  String get periodLabel => _periodLabel(durationDays);
}
```

### `VoucherValidationResponse` (`voucher_validation_response.dart`)

```dart
@freezed
abstract class VoucherValidationResponse with _$VoucherValidationResponse {
  const factory VoucherValidationResponse({
    required bool isValid,
    required String? discountType,
    required double? discountValue,
    required int? finalPriceCentavos,
    required String? errorMessage,
  }) = _VoucherValidationResponse;
}
```

---

## 6. AccountPage Integration

### Update `AccountContentHeader` to use `HostSubscriptionBanner`

```dart
// In account_content_header.dart - replace hardcoded "VIP" card
HostSubscriptionBanner(
  isPremiumHost: state.accountSummary?.isPremiumHost ?? false,
  onUpgradeTap: () => context.goNamed('hostSubscription'),
)
```

### `AccountSummary` extended with `isPremiumHost`

```dart
@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required ValueName name,
    required Money balance,
    required Number connect,
    Url? imageUrl,
    required bool isPremiumHost,  // NEW
  }) = _AccountSummary;

  factory AccountSummary.fromServer(serverpod.AccountSummary s) => AccountSummary(
    name: ValueName(s.name),
    balance: Money(s.cashBalance),
    connect: Number(s.connectBalance),
    imageUrl: s.imageUrl.let((uri) => Url(uri.toString())),
    isPremiumHost: s.isPremiumHost,  // NEW from server
  );
}
```

---

## 7. HitPay WebView Flow

```
User taps "Subscribe" on HostSubscriptionScreen
    ↓
HostSubscriptionCubit.proceedToCheckout() → returns checkoutUrl
    ↓
HostSubscriptionScreen navigates to HitPayCheckoutWebView(checkoutUrl)
    ↓
User completes card entry on HitPay hosted page
    ↓
HitPay redirects to redirectUrl (e.g., `baktaz://subscription/success?subscriptionId=...`)
    ↓
HitPayCheckoutWebView intercepts redirect, extracts result
    ↓
HostSubscriptionCubit.handleCheckoutResult(CheckoutResult)
    ↓
Cubit emits success state → UI shows confirmation → pops to AccountPage
    ↓
AccountPage refreshes → HostSubscriptionBanner shows "Premium Host"
```

---

## 8. Error Handling (Pattern B)

- All failures surfaced via `FailureHandler.handleFailure(failure)` → shows `BaktazSnackBar` or dialog.
- No `Failure` objects stored in state — only clean UI states.
- Network/timeout → retry option in snackbar.
- Voucher validation errors shown inline below input field.


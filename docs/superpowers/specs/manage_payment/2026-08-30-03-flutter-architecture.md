# Manage Payment & Payout Architecture Spec — Flutter Architecture

> **Document Version:** 1.3  
> **Date:** 2026-08-30  
> **Parent Spec:** `docs/superpowers/specs/manage_payment/2026-08-30-00-overview.md`  
> **Package:** `baktaz_flutter` (`lib/features/account/`)  
> **Rule Compliance:** 100% compliant with `.agents/rules/flutter-architecture.md`, `state-management-architecture.md`, `error-handling-architecture.md`, `design-system.md`, and `naming-convention.md`.

---

## 1. Cubit & State Machine Architecture

Per `.agents/rules/flutter-architecture.md` and `state-management-architecture.md`:
- **Cubit**: `ManagePaymentCubit` (`lib/features/account/domain/cubit/payment/manage_payment_cubit.dart`) extends `CubitSignal<ManagePaymentState>`.
- **Constructor**: Must use `initialState:` named parameter constructor (`ManagePaymentCubit({required ManagePaymentState initialState, required AccountRepository accountRepository, required FailureHandler failureHandler})`).
- **Async Execution**: Wrap repository calls in `safeRun(onException: _failureHandler.handleException)`.
- **Immutable State Progression**: Inline actions (setting default, deleting method, saving destination) emit `state.copyWith(isSubmitting: true)` or `state.copyWith(isTokenizing: true)` to preserve loaded list state while executing.
- **Pattern B Error Handling**: Errors trigger UI popups via `FailureHandler.handleFailure` side effects immediately. State stores sealed state branches (`_Failed` / `_Loaded`) with generic flags — NEVER store `Failure` objects inside `ManagePaymentState`.

```dart
@freezed
class ManagePaymentState with _$ManagePaymentState {
  const factory ManagePaymentState.initial() = _Initial;
  const factory ManagePaymentState.loading() = _Loading;
  const factory ManagePaymentState.loaded({
    required List<SavedPaymentMethod> savedMethods,
    required PayoutDestination? payoutDestination,
    required bool isSubmitting,
    required bool isTokenizing,
  }) = _Loaded;
  const factory ManagePaymentState.failed() = _Failed;
}
```

## 2. Business Logic & Repository Integration

- `AccountRepository` (Serverpod client wrapper) manages RPC calls to `AccountEndpoint`.
- Repository methods return `TaskResult<T>`, never throw (`.agents/rules/serverpod-architecture.md`).
- Cubit methods:
  - `loadSummary()`: Fetches `PaymentPayoutSummary` via AccountEndpoint.
  - `savePaymentMethodToken(hitpayToken, paymentType, last4, cardBrand)`: Wrapped in `safeRun(onException: _failureHandler.handleException)`, updates state via `copyWith(isTokenizing: true/false)`.
  - `setDefaultPaymentMethod(methodId)`: Wrapped in `safeRun(onException: _failureHandler.handleException)`, updates state via `copyWith(isSubmitting: true/false)`.
  - `deletePaymentMethod(methodId)`: Wrapped in `safeRun(onException: _failureHandler.handleException)`, updates state via `copyWith(isSubmitting: true/false)`.
  - `upsertPayoutDestination(channel, accountName, accountNumber, bankName)`: Wrapped in `safeRun(onException: _failureHandler.handleException)`, updates state via `copyWith(isSubmitting: true/false)`.
  - `deletePayoutDestination()`: Wrapped in `safeRun(onException: _failureHandler.handleException)`, updates state via `copyWith(isSubmitting: true/false)`.

## 3. UI Views, Widgets, Dialogs & Webview Integration

Per `.agents/rules/design-system.md`:
- **Component Wrappers**: Built using `baktaz_shared` wrappers (`BaktazCard`, `BaktazButton`, `BaktazStatusBadge`, `BaktazTextField`, `BaktazSectionHeader`, `ConfirmationDialog`).
- **Localization**: All text elements use `context.i18n.manage_payment.*` translation keys. Zero hardcoded user-facing strings.
- **HitPay Tokenization Webview (`HitPayTokenizeWebview`)**:
  - Intercepts `onNavigationRequest` for redirect URL `https://baktaz.app/payment/token-callback?token=...&type=...&last4=...&brand=...`.
  - Extracts parameters and pops result tuple `(token, type, last4, brand)` back to caller before invoking `ManagePaymentCubit.savePaymentMethodToken(...)`.
- **Edit Payout Destination Dialog (`EditPayoutDestinationDialog`)**:
  - Local form validation regex: GCash (`^09\d{9}$`), Maya (`^09\d{9}$`), Bank (`^\d{10,16}$`).
  - Disables submit button if input regex validation fails.
  - Overwrite confirmation: Prompts an explicit `ConfirmationDialog` before submitting replacement payout destination if `payoutDestination` already exists.
- **Screen & Dialog Naming**: File suffix `_screen.dart` (`lib/features/account/presentation/views/screens/manage_payment_screen.dart`) for full-page route views; file suffix `_dialog.dart` (`lib/features/account/presentation/widgets/dialogs/edit_payout_destination_dialog.dart`).
- **"Add Payment Method" Button State**:
  - Renders as disabled with a `BaktazStatusBadge` reading `"Max 5 methods"` (`context.i18n.manage_payment.max_saved_methods_reached`) when `savedMethods.length >= AppConfig.maxSavedPaymentMethods`.
  - Validated client-side prior to triggering the webview flow.

---

## 4. Challenge Join & Create Hard Block

- **File**: `lib/features/account/domain/cubit/payment/manage_payment_cubit.dart` / relevant challenge cubits.
- `ChallengeJoinCubit` and `ChallengeCreateCubit` check `PayoutDestination` presence via summary fetching.
- **Action if missing**: Blocks the operation (join/create) and immediately calls `GoRouter.of(context).go('/account/payment')` paired with a popup warning dialog (`context.i18n.manage_payment.payout_destination_required_for_paid_challenge`): *"You must set up a payout destination before joining or creating a paid challenge."*

# Task 3: Flutter `ManagePaymentCubit` & Hard Block Integration

> **Rule Compliance:** 100% compliant with `.agents/rules/flutter-architecture.md`, `state-management-architecture.md`, `error-handling-architecture.md`, and `testing.md`.

**Files:**
- Create: `baktaz_flutter/lib/features/account/domain/cubit/payment/manage_payment_cubit.dart`
- Create: `baktaz_flutter/lib/features/account/domain/cubit/payment/manage_payment_state.dart`
- Create: `baktaz_flutter/test/unit/manage_payment_cubit_test.dart`
- Modify (for Hard Block): `baktaz_flutter/lib/features/account/domain/cubit/challenge/challenge_join_cubit.dart`
- Modify (for Hard Block): `baktaz_flutter/lib/features/account/domain/cubit/challenge/challenge_create_cubit.dart`

- [ ] **Step 1: Implement `ManagePaymentState` with freezed**
  Sealed class with `initial()`, `loading()`, `loaded(savedMethods, payoutDestination, isSubmitting)`, `failed()`. *Do not store Failure objects in state (Pattern B).*
- [ ] **Step 2: Implement `ManagePaymentCubit` extending `CubitSignal<ManagePaymentState>`**
  - Use `initialState:` named constructor (`ManagePaymentCubit({required ManagePaymentState initialState, required AccountRepository accountRepository, required FailureHandler failureHandler})`).
  - Wrap async repository calls in `safeRun(onException: _failureHandler.handleException)`.
  - Expose single-action methods: `loadSummary()`, `savePaymentMethodToken(...)`, `setDefaultPaymentMethod(...)`, `deletePaymentMethod(...)`, `upsertPayoutDestination(...)`, `deletePayoutDestination()`.
- [ ] **Step 3: Add hard block logic to `ChallengeJoinCubit` and `ChallengeCreateCubit`**
  Validate `PayoutDestination` presence before joining/creating paid challenge; if missing, block action and trigger route redirect to `/account/payment` with warning dialog (`context.i18n.manage_payment.payout_destination_required_for_paid_challenge`).
- [ ] **Step 4: Implementation-First Requirement & Cubit Unit Tests**
  *Note: Implementation and codegen MUST be complete before running unit tests (`.agents/rules/testing.md`).*
  Write unit tests in `test/unit/manage_payment_cubit_test.dart` using `mockito` mocks (`@GenerateMocks` in `test/utils/generated_mocks.dart`):
  - Verify initial load fetches `PaymentPayoutSummary`.
  - Verify `savePaymentMethodToken` handles success and surfaces limit failure via `FailureHandler`.
  - Verify auto-reassignment reflects in state after deletion.
  - Verify hard block triggers when payout destination is missing.
- [ ] **Step 5: Run unit tests to verify 100% pass**
  Run: `cd baktaz_flutter && flutter test test/unit/manage_payment_cubit_test.dart`

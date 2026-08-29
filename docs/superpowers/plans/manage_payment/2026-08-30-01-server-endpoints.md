# Task 2: Serverpod Endpoints, Repositories & Integration Tests

> **Rule Compliance:** 100% compliant with `.agents/rules/serverpod-architecture.md`, `error-handling-architecture.md`, and `testing.md`.

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_payment_repository.dart`
- Create: `baktaz_server/lib/src/features/account/domain/interface/i_payout_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/payment_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/repository/payout_repository.dart`
- Create: `baktaz_server/lib/src/features/account/data/service/hitpay_service.dart`
- Modify: `baktaz_server/lib/src/features/account/endpoint/account_endpoint.dart`
- Create: `baktaz_server/test/integration/features/account/manage_payment_endpoint_test.dart`

- [ ] **Step 1: Create `HitPayService` in `data/service/`**
  Encapsulate external HitPay HTTP API interaction (token verification, HTTP client calls).
- [ ] **Step 2: Create repository interfaces and `@LazySingleton` implementations**
  - `IPaymentRepository` interface in `domain/interface/` and `PaymentRepository` implementation in `data/repository/` (annotated `@LazySingleton(as: IPaymentRepository)`).
  - `IPayoutRepository` interface in `domain/interface/` and `PayoutRepository` implementation in `data/repository/` (annotated `@LazySingleton(as: IPayoutRepository)`).
  - Register dependencies via `build_runner`.
- [ ] **Step 3: Implement RPC methods in `AccountEndpoint`**
  - `getPaymentPayoutSummary`: Fetch methods ordered by `isDefault DESC`, `createdAt DESC` and active destination.
  - `savePaymentMethodToken`: Enforce `AppConfig.maxSavedPaymentMethods = 5` limit check; throw `ValidationFailure('MAX_SAVED_PAYMENT_METHODS_REACHED')` if limit reached.
  - `setDefaultPaymentMethod`: Single DB transaction setting target as `isDefault = true`.
  - `deletePaymentMethod`: Single DB transaction with auto-reassignment to next oldest method (`createdAt ASC`) if default was deleted.
  - `upsertPayoutDestination`: Perform regex structural validation (`GCash`: `^09\d{9}$`, `Maya`: `^09\d{9}$`, `Bank`: `^\d{10,16}$`), perform DB upsert, and write event log to `audit_logs`.
  - `deletePayoutDestination`: Delete active destination and log event to `audit_logs`.
- [ ] **Step 4: Implementation-First Requirement & Integration Tests**
  *Note: Implementation, codegen, and migrations MUST compile cleanly BEFORE writing or executing tests (`.agents/rules/testing.md`).*
  Write integration tests in `test/integration/features/account/manage_payment_endpoint_test.dart` using `withServerpod`:
  - Max 5 saved payment methods limit (`MAX_SAVED_PAYMENT_METHODS_REACHED`)
  - Auto-reassignment of default method on deletion in single DB transaction
  - Structural regex validation for GCash, Maya, and Bank
  - Audit logging to `audit_logs` table upon payout destination update/overwrite
- [ ] **Step 5: Run integration tests**
  Run: `cd baktaz_server && fvm dart test test/integration/features/account/manage_payment_endpoint_test.dart`

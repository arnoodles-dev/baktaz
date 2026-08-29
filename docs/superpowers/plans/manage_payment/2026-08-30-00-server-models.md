# Task 1: Serverpod Data Models & Codegen

> **Rule Compliance:** 100% compliant with `.agents/rules/serverpod-architecture.md` and `.agents/rules/operations.md`.

**Files:**
- Modify: `baktaz_server/lib/src/app/config/app_config.dart`
- Create: `baktaz_server/lib/src/features/account/domain/model/saved_payment_method.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/payout_destination.spy.yaml`
- Create: `baktaz_server/lib/src/features/account/domain/model/payment_payout_summary.spy.yaml`
- Modify: `baktaz_client/` (auto-generated)

- [ ] **Step 1: Add `AppConfig.maxSavedPaymentMethods = 5` in `baktaz_server/lib/src/app/config/app_config.dart`**
- [ ] **Step 2: Create `saved_payment_method.spy.yaml` in `lib/src/features/account/domain/model/`**
  Define Serverpod table `saved_payment_method` with `UuidValue?` ID (`defaultPersist=random`), `userId`, `hitpayToken`, `paymentType`, `last4`, `cardBrand`, `isDefault`, and `user_id_idx`.
- [ ] **Step 3: Create `payout_destination.spy.yaml` in `lib/src/features/account/domain/model/` with unique index on userId**
  Define Serverpod table `payout_destination` with `UuidValue?` ID (`defaultPersist=random`), `userId`, `channel`, `accountName`, `accountNumber`, `bankName`, `isVerified`, and `user_id_unique_idx` (`unique: true`).
- [ ] **Step 4: Create `payment_payout_summary.spy.yaml` in `lib/src/features/account/domain/model/`**
  Define domain model containing `savedMethods: List<SavedPaymentMethod>` and `payoutDestination: PayoutDestination?`.
- [ ] **Step 5: Run Serverpod code generation**
  Run: `cd baktaz_server && serverpod generate`
- [ ] **Step 6: Create and verify database migration**
  Run: `cd baktaz_server && serverpod create-migration`

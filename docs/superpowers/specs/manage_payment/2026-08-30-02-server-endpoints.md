# Manage Payment & Payout Architecture Spec — Server Endpoints

> **Document Version:** 1.3  
> **Date:** 2026-08-30  
> **Parent Spec:** `docs/superpowers/specs/manage_payment/2026-08-30-00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/features/account/endpoint/account_endpoint.dart`)  
> **Rule Compliance:** 100% compliant with `.agents/rules/serverpod-architecture.md` (Service vs Repository separation, `@LazySingleton` injection, Session passing, transactions, idempotency).

---

## 1. Architecture & Dependency Chain

Per `.agents/rules/serverpod-architecture.md`:
- **Services** (`data/service/`): Talk directly to external integrations (e.g., `HitPayService`). Own *how* (HTTP request execution, API payload mapping).
- **Repositories** (`domain/interface/` & `data/repository/`): Orchestrate services and database queries via `Session`. Expose clean domain API (`IPaymentRepository`, `IPayoutRepository`) annotated with `@LazySingleton(as: Interface)`.
- **Endpoints** (`endpoint/`): Accept `Session`, validate boundaries, call repositories. Never depend on services directly.

```text
                  ┌────────────────────────────────────────┐
                  │            AccountEndpoint             │
                  │   (/account/payment management RPCs)   │
                  └───────────────────┬────────────────────┘
                                      │
                                      │ (Injected via GetIt)
                                      ▼
┌─────────────────────────┐     ┌────────────────────────────────────────┐     ┌────────────────────────┐
│     PaymentEndpoint     │ ──► │ IPaymentRepository / IPayoutRepository │ ◄── │     PayoutEndpoint     │
│ (Challenge Join Charges)│     │  (Manages DB tables: saved_payment_    │     │(Prize & Host Payouts)  │
└─────────────────────────┘     │   method and payout_destination)       │     └────────────────────────┘
                                └───────────────────┬────────────────────┘                              
                                                    │                                                   
                                                    │                                                   
                                                    ▼                                                   
                                              HitPayService                                             
                                       (HitPay HTTP API Integration)                                    
```

---

## 2. `AccountEndpoint` Methods & Business Logic

### 2.1 `getPaymentPayoutSummary`
- `Future<PaymentPayoutSummary> getPaymentPayoutSummary(Session session)`
- Fetches all `SavedPaymentMethod` records for `userId` ordered by `isDefault DESC`, `createdAt DESC`.
- Fetches the active `PayoutDestination?` for `userId`.

### 2.2 `savePaymentMethodToken`
- `Future<SavedPaymentMethod> savePaymentMethodToken(Session session, String hitpayToken, String paymentType, String? last4, String? cardBrand)`
- **Limit Check**: Counts existing `SavedPaymentMethod` records for `userId`. If count >= `AppConfig.maxSavedPaymentMethods` (5), throws `ValidationFailure('MAX_SAVED_PAYMENT_METHODS_REACHED')`.
- Sets `isDefault = true` if this is the user's first saved payment method, otherwise `false`.
- Inserts and returns the new `SavedPaymentMethod`.

### 2.3 `setDefaultPaymentMethod`
- `Future<void> setDefaultPaymentMethod(Session session, UuidValue methodId)`
- Executes a single database transaction via `session.db.transaction` setting the target method `isDefault = true` and clearing the remaining user methods (`isDefault = false`) atomically.

### 2.4 `deletePaymentMethod`
- `Future<void> deletePaymentMethod(Session session, UuidValue methodId)`
- Executes a single database transaction via `session.db.transaction`:
  1. Fetches target method for `userId`. If not found, throws `NotFoundException`.
  2. Deletes the target method.
  3. **Auto-Reassignment**: If deleted method was `isDefault == true`:
     - Queries remaining payment methods for `userId` ordered by `createdAt ASC` (oldest first).
     - If a remaining method exists, updates it to `isDefault = true`.

### 2.5 `upsertPayoutDestination`
- `Future<PayoutDestination> upsertPayoutDestination(Session session, String channel, String accountName, String accountNumber, String? bankName)`
- **Structural Regex Validation**:
  - `channel == 'gcash'`: `^09\d{9}$`
  - `channel == 'maya'`: `^09\d{9}$`
  - `channel == 'bank'`: `^\d{10,16}$` and non-empty `bankName`
  - If validation fails, throws `ValidationFailure('INVALID_PAYOUT_ACCOUNT_NUMBER')`.
- **Database Atomic Upsert**:
  - Executes atomic upsert against `payout_destination.user_id_unique_idx` (userId unique index).
  - Determines action (`payout_destination_created` vs `payout_destination_overwritten`).
- **Audit Logging**: Logs audit record to `audit_logs` table with `userId`, `action`, `channel`, and `timestamp`.

### 2.6 `deletePayoutDestination`
- `Future<void> deletePayoutDestination(Session session)`
- Deletes active `PayoutDestination` for `userId`.
- Logs audit event (`action: "payout_destination_deleted"`) to `audit_logs` table.

---

## 3. Exceptions & Error Codes

Per `.agents/rules/error-handling-architecture.md` (Server Rules):
- Business errors throw typed `ApiException` domain models (`ValidationFailure`, `DatabaseFailure`) that are serialized via RPC (or specific `NotFoundException` mapped to Serverpod response codes).

| Failure Exception | Error Code String | Trigger Scenario |
|---|---|---|
| `ValidationFailure` | `MAX_SAVED_PAYMENT_METHODS_REACHED` | Attempting to save payment token when `savedMethods.length >= 5` |
| `ValidationFailure` | `INVALID_PAYOUT_ACCOUNT_NUMBER` | Account number fails channel regex check (GCash, Maya, Bank) |
| `NotFoundException` | `PAYMENT_METHOD_NOT_FOUND` | Operating on a non-existent or unowned method ID |
| `ValidationFailure` | `MISSING_BANK_NAME` | Channel is `'bank'` but `bankName` is null or empty |

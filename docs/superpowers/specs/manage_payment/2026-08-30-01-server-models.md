# Manage Payment & Payout Architecture Spec — Server Models

> **Document Version:** 1.3  
> **Date:** 2026-08-30  
> **Parent Spec:** `docs/superpowers/specs/manage_payment/2026-08-30-00-overview.md`  
> **Package:** `baktaz_server` (`lib/src/app/config/app_config.dart`, `lib/src/features/account/domain/model/`)  
> **Rule Compliance:** 100% compliant with `.agents/rules/serverpod-architecture.md` and `code-quality.md`.

---

## 1. AppConfig — `maxSavedPaymentMethods`

### 1.1 `AppConfig.maxSavedPaymentMethods`

Defined in `lib/src/app/config/app_config.dart`. Controls the maximum number of saved payment tokens a user may persist.

```dart
class AppConfig {
  static const int maxSavedPaymentMethods = 5;
}
```

## 2. Serverpod Model Definitions (`.spy.yaml`)

Per `.agents/rules/serverpod-architecture.md`:
- Strongly-typed models defined in `.spy.yaml` files inside `lib/src/features/account/domain/model/`.
- No raw SQL; schema migrations only.
- PKs use `UuidValue` with `defaultPersist=random`.
- Always return typed domain models from endpoints, never `Map` or `dynamic`.

### 2.1 `SavedPaymentMethod` (`lib/src/features/account/domain/model/saved_payment_method.spy.yaml`)
```yaml
class: SavedPaymentMethod
table: saved_payment_method
indexes:
  user_id_idx:
    fields: userId
fields:
  id: UuidValue?, defaultPersist=random
  userId: UuidValue
  hitpayToken: String
  paymentType: String # card, gcash, maya
  last4: String?
  cardBrand: String? # visa, mastercard, jcb, etc.
  isDefault: bool
  createdAt: DateTime
  updatedAt: DateTime
```

### 2.2 `PayoutDestination` (`lib/src/features/account/domain/model/payout_destination.spy.yaml`)
```yaml
class: PayoutDestination
table: payout_destination
indexes:
  user_id_unique_idx:
    fields: userId
    unique: true  # Strict single active payout destination per user (atomic upsert target)
fields:
  id: UuidValue?, defaultPersist=random
  userId: UuidValue
  channel: String # gcash, maya, bank
  accountName: String
  accountNumber: String  # Validated via structural regex before upsert
  bankName: String? # Required if channel == 'bank'
  isVerified: bool
  createdAt: DateTime
  updatedAt: DateTime
```

**Validation Rules (applied at endpoint boundary before DB write):**
| Channel | Regex Pattern |
|---|---|
| GCash | `^09\d{9}$` |
| Maya | `^09\d{9}$` |
| Bank | `^\d{10,16}$` |

### 2.3 `PaymentPayoutSummary` (`lib/src/features/account/domain/model/payment_payout_summary.spy.yaml`)
```yaml
class: PaymentPayoutSummary
fields:
  savedMethods: List<SavedPaymentMethod>
  payoutDestination: PayoutDestination?
```

### 2.4 Server Error Models & RPC Serialization

Per `.agents/rules/serverpod-architecture.md` and `.agents/rules/error-handling-architecture.md`:
- Serverpod repositories throw typed `ApiException` domain models (`ValidationFailure`, `DatabaseFailure`, `NotFoundException`).
- Exceptions are serialized over RPC for client consumption:
  - `ValidationFailure`: Repositories and endpoints throw `ValidationFailure(message, code)` on boundary or business rule failure.
  - `DatabaseFailure`: Repositories wrap DB transaction/query errors into `DatabaseFailure(message, code)`.

### 2.5 Audit Logging

Server logs audit events to `audit_logs` table upon:
- Payout destination creation (atomic upsert)
- Payout destination overwrite (in-place atomic update against `payout_destination.user_id_unique_idx`)
- Payout destination deletion

Audit entry format: `{userId, action: "payout_destination_upsert|overwrite|delete", channel, timestamp}`

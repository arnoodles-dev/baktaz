# Payment & Payout Plan — Server Models

**Goal:** Create all database models and migrations for payment system.

## Task 1: Database Models

**Files:**
- Create: `baktaz_server/lib/src/features/payment/domain/model/challenges.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/challenge_entries.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/payments.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/payment_accounts.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/challenge_winners.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/payouts.spy.yaml`
- Create: `baktaz_server/lib/src/features/payment/domain/model/host_payouts.spy.yaml`
- Create: `baktaz_server/lib/src/features/ledger/domain/model/ledger_accounts.spy.yaml`
- Create: `baktaz_server/lib/src/features/ledger/domain/model/ledger_transactions.spy.yaml`
- Create: `baktaz_server/lib/src/features/ledger/domain/model/ledger_entries.spy.yaml`
- Create: `baktaz_server/lib/src/features/ledger/domain/model/tax_rules.spy.yaml`
- Create: `baktaz_server/lib/src/features/ledger/domain/model/audit_logs.spy.yaml`
- Delete: `baktaz_server/lib/src/features/wallet/domain/model/wallet.spy.yaml`
- Delete: `baktaz_server/lib/src/features/wallet/domain/model/wallet_transactions.spy.yaml`

**Enums to create in `baktaz_server/lib/src/core/domain/model/enum/`:**
- `challenge_status.spy.yaml`
- `challenge_entry_status.spy.yaml`
- `payment_status.spy.yaml`
- `settlement_status.spy.yaml`
- `payout_status.spy.yaml`
- `host_payout_status.spy.yaml`
- `transaction_type.spy.yaml`
- `ledger_account_type.spy.yaml`

- [ ] **Step 1: Create all .spy.yaml model files**

Create each model file with exact schema from spec Section 5. Include:
- `id: UuidValue?, defaultPersist=random`
- Relations using `relation` keyword
- DateTime fields with `DateTime`
- String enums with `String` and comment listing values

- [ ] **Step 2: Create enum files**

Create enum files listing all status values as comments.

- [ ] **Step 3: Delete wallet models**

Remove `wallet.spy.yaml` and `wallet_transactions.spy.yaml`.

- [ ] **Step 4: Run codegen**

Run: `cd baktaz_server && fvm dart run build_runner build --delete-conflicting-outputs`
Expected: Generated models in `lib/src/generated/protocol.dart`

- [ ] **Step 5: Create migration**

Run: `serverpod create-migration` in baktaz_server
Review generated SQL for:
- CREATE TABLE statements for all new tables
- DROP TABLE statements for wallet tables
- Index on `challenge_entries(challenge_id, user_id)` unique
- Index on `payments(challenge_id, user_id)`
- Index on `payouts(challenge_id, status)`

- [ ] **Step 6: Apply migration**

Run: `serverpod apply-migrations`
Verify: Tables created, wallet tables dropped.

- [ ] **Step 7: Commit**

```bash
git add baktaz_server/lib/src/features/payment/domain/model/
git add baktaz_server/lib/src/features/ledger/domain/model/
git add baktaz_server/lib/src/core/domain/model/enum/
git add baktaz_server/lib/src/features/wallet/  # deleted
git commit -m "feat(payment): add database models and migrations"
```

## Task 2: Pre-seed Ledger Accounts

**Files:**
- Create: `baktaz_server/lib/src/features/ledger/domain/service/ledger_seeder.dart`

- [ ] **Step 1: Create ledger seeder**

```dart
@lazySingleton
final class LedgerSeeder {
  Future<void> seedAccounts(Session session) async {
    final accounts = <LedgerAccount>[
      LedgerAccount(accountType: 'PAYMENT_CLEARING', currency: 'PHP'),
      LedgerAccount(accountType: 'PRIZE_LIABILITY', currency: 'PHP'),
      LedgerAccount(accountType: 'PLATFORM_REVENUE', currency: 'PHP'),
      LedgerAccount(accountType: 'PAYMENT_PROCESSING_EXPENSE', currency: 'PHP'),
      LedgerAccount(accountType: 'PAYOUT_EXPENSE', currency: 'PHP'),
      LedgerAccount(accountType: 'TAX_LIABILITY', currency: 'PHP'),
      LedgerAccount(accountType: 'WINNER_PAYABLE', currency: 'PHP'),
      LedgerAccount(accountType: 'HOST_CUT_PAYABLE', currency: 'PHP'),
      LedgerAccount(accountType: 'REFUND_LIABILITY', currency: 'PHP'),
    ];

    for (final account in accounts) {
      await LedgerAccount.db.insertRow(session, account);
    }
  }
}
```

- [ ] **Step 2: Call seeder from server startup**

In `baktaz_server/bin/main.dart`, after DB connection:
```dart
await getIt<LedgerSeeder>().seedAccounts(session);
```

- [ ] **Step 3: Commit**

```bash
git add baktaz_server/lib/src/features/ledger/
git commit -m "feat(payment): add ledger account seeder"
```

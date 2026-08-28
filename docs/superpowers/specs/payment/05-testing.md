# Payment & Payout Architecture Spec — Testing Strategy

**Date:** 2026-08-28
**Parent Spec:** `docs/superpowers/specs/payment/00-overview.md`

## 9. Testing Strategy

### 9.1 Server Tests

```
test/unit/features/payment/payment_repository_test.dart
test/integration/features/payment/payment_endpoint_test.dart
test/integration/features/payment/webhook_payment_test.dart
test/integration/features/payout/payout_flow_test.dart
test/integration/features/ledger/double_entry_test.dart
```

### 9.2 Flutter Tests

```
test/unit/payment_cubit_test.dart
test/unit/payment_repository_test.dart
test/widget/payment/payment_method_tile_test.dart
test/widget/payment/goldens/payment_method_tile_macos/
test/widget/challenge/challenge_entry_ticket_test.dart
```

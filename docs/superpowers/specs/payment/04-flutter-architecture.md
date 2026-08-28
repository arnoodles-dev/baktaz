# Payment & Payout Architecture Spec — Flutter Architecture

**Date:** 2026-08-28
**Parent Spec:** `docs/superpowers/specs/payment/00-overview.md`

## 8. Flutter Architecture

### 8.1 Feature Structure

```
baktaz_flutter/lib/features/
├── payment/
│   ├── data/
│   │   ├── repository/
│   │   │   ├── payment_repository.dart
│   │   │   └── payout_repository.dart
│   │   └── dto/ # Reuse baktaz_client models
│   ├── domain/
│   │   └── cubit/
│   │       ├── payment_cubit.dart
│   │       └── payout_cubit.dart
│   └── presentation/
│       └── widgets/
│           ├── payment_method_selector.dart
│           ├── payment_method_tile.dart
│           └── payout_method_tile.dart
├── payout/
│   └── presentation/
│       └── views/
│           ├── payout_methods_screen.dart
│           └── payout_claim_screen.dart
└── challenge/ # Updated
    └── presentation/
        └── views/
            ├── screens/
            │   ├── challenge_details_screen.dart
            │   ├── challenge_create_screen.dart
            │   ├── challenge_create_success_screen.dart
            │   └── challenge_done_screen.dart
            └── widgets/
                ├── challenge_entry_ticket.dart
                └── payment_intent_webview.dart
```

### 8.2 Key Widgets

- **PaymentMethodSelector** — embedded in challenge flow, shows saved methods or prompts to add
- **PaymentIntentWebView** — opens HitPay checkout in in-app browser
- **ChallengeEntryTicket** — shows payment status on challenge card
- **HostPayoutScreen** — shows host cut status and amount

### 8.3 Routing

```
/challenge/create           → ChallengeCreateScreen
/challenge/detail/:id       → ChallengeDetailsScreen
/challenge/success          → ChallengeCreateSuccessScreen
/payment/success            → PaymentSuccessScreen (deep link)
/payment/cancel             → PaymentCancelScreen
/payment/methods            → PaymentMethodsScreen
/payout/methods             → PayoutMethodsScreen
/payout/claim/:challengeId  → PayoutClaimScreen
```

### 8.4 Wallet Removal

- Delete `baktaz_flutter/lib/features/wallet/`
- Delete `baktaz_server/lib/src/features/wallet/`
- Remove all `cashBalance` references from challenge code
- Replace wallet join flow with payment intent flow

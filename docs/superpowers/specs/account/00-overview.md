# Account Feature Architecture Spec — Overview

> **Document Version:** 1.0  
> **Date:** 2026-08-28  
> **Topic:** Baktaz App Account & Wallet Tab (`/account`) Comprehensive Architectural & Full-Stack Overview  
> **Status:** Approved  

---

## Sub-Specs Table of Contents

| Spec File | Title & Focus |
|---|---|
| `00-overview.md` | System overview, Scope, Exclusions, Included features summary, Sub-spec index |
| `01-server-models.md` | Serverpod YAML model definitions (`.spy.yaml`) with fields, tables, types, and index constraints |
| `02-server-endpoints.md` | Serverpod endpoints, Services, Repositories, Host Cut forfeiture, Voucher validation |
| `03-flutter-architecture.md` | `baktaz_flutter` layer design, GoRouter typed routes, Cubit signals, Repositories (`TaskResult<T>`), Pattern B errors |
| `04-flutter-ui.md` | Comprehensive UI spec for `AccountPage`, `ProfileEditScreen`, `HostSubscriptionScreen`, `ManagePaymentScreen`, `HealthSyncScreen`, Settings, and Support |
| `05-testing.md` | Unit testing strategy (100% Cubits/Repos), Widget/Golden testing (80% UI), Serverpod integration testing (`withServerpod`) |

---

## 1. System Overview

The `/account` route (Account Tab) in Baktaz serves as the central user management, subscription, payment/payout configuration, health sync control, app preferences, and support portal. It unifies user identity, host monetization privileges, transaction account bindings, and device step telemetry configuration into a clean presentation layer.

---

## 2. Included Features Summary

1. **Profile Header & Lifetime Stats**: User metadata (avatar, name, username, member since) + Challenge-only cumulative step counters (total steps in challenges, challenges joined, challenges won).
2. **Host Subscription Management (`/account/host-subscription`)**: Free Regular User vs Subscribed Premium Host tier, subscription plans, voucher application, and strict server-side Host Cut entitlement validation.
3. **Manage Payment (`/account/payment`)**: Single unified screen managing tokenized saved payment methods (cards/e-wallets via HitPay) and a strictly enforced single active payout destination (GCash, Maya, Bank).
4. **Health Sync Configuration (`/account/health-sync`)**: Platform health provider diagnostic matrix (iOS Apple HealthKit & Android Health Connect), background lifecycle sync, manual sync debounce, and single active provider constraint.
5. **Preferences & Settings (`/account/settings/*`)**: Granular push notification toggles, app language localization (`context.l10n`), and theme configuration (Light, Dark, System Default).
6. **Support & Legal (`/account/support/*`)**: Help Center FAQ, feedback submission form, markdown terms & privacy rendering, and app version info. (Note: Session logout is located within `ProfileScreen` at `/account/profile`).

---

## 3. Explicit Scope Exclusions

To maintain zero unnecessary complexity (YAGNI principle) and minimize regulatory overhead:
- ❌ **In-App Wallet Card / Stored Balance**: Completely removed to eliminate internal wallet ledger holding obligations and e-money licensing requirements. Direct payouts occur via external channels (GCash/Maya/Bank).
- ❌ **Achievements & Badges**: Excluded from profile scope.
- ❌ **Referral & Affiliate Hub**: Deferred to future roadmap.
- ❌ **User Bio**: Removed (replaced by simple username and member since date).
- ❌ **Contacts & Social Connections**: Removed.
- ❌ **User Reviews & Ratings**: Removed.
- ❌ **Saved Delivery Addresses**: Removed (Baktaz focuses strictly on digital fitness challenges).

---

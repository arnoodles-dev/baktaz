# Profile Header & Lifetime Stats — Overview

> **Document Version:** 1.0  
> **Date:** 2026-08-29  
> **Status:** Draft  
> **Parent Spec:** `docs/superpowers/specs/account/2026-08-28-00-overview.md`

---

## Scope

This spec covers three interconnected changes to the Baktaz account surface:

| Change | Package | Files |
|---|---|---|
| Profile Header & Lifetime Stats | `baktaz_server` + `baktaz_flutter` | `account_summary`, `AccountPage`, `AccountCubit` |
| Auth/Registration updates | `baktaz_server` + `baktaz_flutter` | `registration_form`, `AuthUtils`, `RegistrationScreen` |
| ProfileScreen rewrite | `baktaz_flutter` | `profile_screen`, `ProfileCubit`, new edit flow |

## Out of Scope (Deferred)

- Host subscription banners
- Payment management (`PaymentPayoutScreen`)
- Steps sync diagnostics (`StepsSyncScreen`)
- Settings screens (notifications, language, dark mode)
- Support/Legal screens
- Challenge table implementation (Challenge feature not yet built)

---

## Key Decisions

| Decision | Rationale |
|---|---|
| `UserInfo` stores `firstName` + `lastName` (no `fullName`) | Matches existing migration schema which has `firstName`/`lastName` columns |
| Username auto-derived from email | Eliminates manual username input; collision handled server-side with 4-digit suffix |
| Collision suffix: random 4-digit, lowercase only | Simpler than sequential; `juan.delacruz` → `juan.delacruz7291` |
| `memberSince` removed from `UserInfo`, use `Account.createdAt` | Single source of truth; `Account` already has `createdAt` |
| `AccountChallengeStats` computed on-demand | No persistence needed; derived from step telemetry at query time |
| Backfill runs as migration | Existing users get `firstName`/`lastName`/`username` without code changes |
| Social login linking is one-way | Prevents accidental unlinking; user can only add, not remove |
| MVP only — no payment models | HostSubscriptionBanner, PaymentPayoutScreen deferred |

---

## File Index

| Spec File | Focus |
|---|---|
| `00-overview.md` | This file — system overview, scope, decisions |
| `01-server-models.md` | Serverpod `.spy.yaml` model definitions with fields, tables, indexes |
| `02-auth-username-derivation.md` | Username derivation logic, collision handling, AuthRepository updates |
| `03-server-endpoints.md` | Account endpoints: getAccountSummary, getProfile, updateProfile, getAvatarUploadUrl, getLinkedProviders |
| `04-client-domain-data.md` | Flutter AccountSummary, Profile entities, IAccountRepository, i18n keys |
| `05-flutter-ui.md` | AccountPage header, RegistrationScreen, ChallengeStatsGrid |
| `06-profile-screen.md` | ProfileScreen rewrite: edit flow, avatar upload, social links |
| `07-testing.md` | Unit, widget, golden, integration testing strategy |

---

## Execution Order

```
01 → 02 → 03 → 04 → 05 → 06 → 07
```

# Profile Header & Lifetime Stats — Implementation Plan Index

> **Parent Canonical Roadmap:** Governed by and aligned with the Master Integration Plan in [`/Users/Arnold/Projects/baktaz/docs/superpowers/plans/2026-08-30-master-integration-plan.md`](../2026-08-30-master-integration-plan.md).
> All models, paths, and invariants (username derivation logic with collision handling in `UsernameUtils`, presigned S3 avatar upload flow, Serverpod 2.x account endpoints, boundary RPC input validation, `session.auth.authenticatedUserId` identity derivation, Pattern B error handling, `TaskResult<T>` repository returns, and implementation-first testing workflows) strictly conform to the master roadmap.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Profile Header, Lifetime Challenge Stats, Auth/Registration updates (firstName, lastName, username derivation + collision handling), and full ProfileScreen rewrite with presigned avatar upload and social login status.

**Architecture:** Update Serverpod `.spy.yaml` models, run codegen & migrations, implement server endpoints + `UsernameUtils`, rewrite client models and screens using `CubitSignal` + `bloc_signals_flutter`, and verify with unit, widget, golden, and integration tests.

**Tech Stack:** Dart 3.x, Flutter, Serverpod 2.x, `bloc_signals_flutter`, `fpdart`, `slang` (i18n), `Alchemist` (goldens), `withServerpod` (integration testing).

**Spec:** `docs/superpowers/specs/account/profile/2026-08-29-profile-header-and-stats-design.md`

---

## Plan Files

| Task | File | Description |
|------|------|-------------|
| 0 | `00-plan-index.md` | This index file |
| 1 | `01-server-models-migration.md` | Server models update & migration |
| 2 | `02-server-auth-username-utils.md` | Server auth & username derivation logic |
| 3 | `03-server-account-endpoints.md` | Server account endpoints (getAccountSummary, updateProfile, getAvatarUploadUrl, getLinkedProviders) |
| 4 | `04-client-domain-data.md` | Client domain & data layer updates |
| 5 | `05-flutter-presentation-registration-accountpage.md` | Flutter presentation: RegistrationScreen & AccountPage |
| 6 | `06-profile-screen-rewrite.md` | ProfileScreen rewrite (edit flow, avatar upload, social links) |
| 7 | `07-verification-testing.md` | Verification & testing |

---

## Global Constraints

- `UserInfo` fields: `firstName`, `lastName`, `username` (unique), `avatarUrl` (no `fullName`, no `memberSince`)
- `memberSince` derived from `Account.createdAt`
- Username derivation: lowercase email local-part, remove non-alphanumeric (except `.`, `_`, `-`), append random 4-digit suffix on collision
- `AccountChallengeStats`: computed DTO (returns zeros until Challenge domain built)
- Avatar upload: local-first via Serverpod fileRepository for dev, S3 for prod
- Social login linking: read-only status in ProfileScreen for MVP
- TDD required: write failing test → verify failure → implement → verify pass → commit

---

## Execution Order

```
01 → 02 → 03 → 04 → 05 → 06 → 07
```

Each task depends on the previous one. Run in sequence.

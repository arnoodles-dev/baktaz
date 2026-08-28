---
trigger: always_on
description: Rules for deciding whether code belongs in baktaz_shared vs package-internal packages
---

# Shared Package Placement Rules

## Purpose

`baktaz_shared` is a shared Flutter UI library consumed by both `baktaz_flutter` and `baktaz_admin`. It provides reusable widgets, design tokens, and cross-package utilities.

## The Placement Rule

**Only place code in `baktaz_shared` if it can be used by BOTH `baktaz_flutter` AND `baktaz_admin`.**

If a widget, entity, screen, utility, or any piece of code is only needed by one package, it stays in that package's `core/` or `lib/` directory — not in shared.

### Decision Flow

1. **Is this needed by baktaz_flutter AND baktaz_admin?**
   - Yes → Place in `baktaz_shared/lib/src/...`
   - No, flutter only → Place in `baktaz_flutter/lib/core/...` or feature directory
   - No, admin only → Place in `baktaz_admin/lib/core/...` or feature directory
   - No, server only → Place in `baktaz_server/lib/src/...`

2. **What about feature-specific code?**
   - Feature-specific widgets, entities, and screens belong in their respective feature directories, NOT shared.
   - Example: `ChallengeCard` used only in the challenge feature stays in `baktaz_flutter/lib/features/challenge/`.
   - Example: `GapMeter` used across multiple features in both flutter and admin → goes to shared.

3. **What about utilities/helpers?**
   - Pure utility functions used by both packages → shared `lib/src/utils/`
   - Package-specific helpers → stay in their package's `core/` directory

## Examples

| Code | Location |
|------|----------|
| `BaktazButton`, `BaktazText` | `baktaz_shared/lib/src/widgets/` (used by both) |
| `GapMeter` (if shared across features) | `baktaz_shared/lib/src/widgets/` (used by both) |
| `ChallengeCubit` | `baktaz_flutter/lib/features/challenge/` (flutter only) |
| `ChallengeRepository` | `baktaz_flutter/lib/features/challenge/` (flutter only) |
| `HomeCubit` | `baktaz_flutter/lib/features/home/` (flutter only) |
| `AppSizes`, `AppTextStyle` | `baktaz_shared/lib/src/theme/` (used by both) |
| `Failure` sealed class | `baktaz_shared/lib/src/entity/` (used by both) |
| `TaskResult<T>` | `baktaz_shared/lib/src/entity/` (used by both) |

## Cross-Package Dependencies

- `baktaz_shared` has NO internal dependencies on `baktaz_flutter` or `baktaz_admin`.
- `baktaz_flutter` depends on `baktaz_shared`.
- `baktaz_admin` depends on `baktaz_shared`.
- Shared package code must be neutral — no references to flutter or admin-specific APIs.

## Verification

When adding code to `baktaz_shared`, confirm:
- [ ] Code is used (or planned to be used) by `baktaz_flutter`
- [ ] Code is used (or planned to be used) by `baktaz_admin`
- [ ] Code has no dependencies on feature-specific packages

If any condition fails, the code belongs in a package-internal directory.

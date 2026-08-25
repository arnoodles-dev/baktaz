# baktaz_shared — DOX Contract

## Purpose

Shared Flutter UI library providing reusable widgets, design tokens (DESIGN.md), and cross-package utilities (Failure, ErrorActions, etc.).

## Ownership

- **Owner**: Design system team
- **Dependencies**: N/A (shared dependency)
- **Dependents**: baktaz_flutter, baktaz_admin, baktaz_site

## Local Contracts

### UI Components
- All widgets prefixed with `App` (e.g., `AppText`, `AppButton`)
- Follow DESIGN.md for tokens, colors, typography
- Use `AppTextStyle`, `AppSizes`, `CustomColors`

### Shared Utilities
- `Failure` sealed class — error taxonomy (see `.agents/rules/error-handling-architecture.md`)
- `ErrorActions` mixin — handler routing
- `TaskResult<T>` — repo return type
- `safeRun()` — error handling utility

### Design System Rules
- Prioritize existing shared widgets over new implementations
- Add to `*_shared/lib/src/widgets/` only
- Update DESIGN.md when adding new tokens

## Work Guidance

### Adding a New Widget
1. Check if existing widget suffices (see `.agents/rules/design-system.md`)
2. Create in `lib/src/widgets/<name>.dart`
3. Export from `lib/baktaz_shared.dart`
4. Add to widget list in `.agents/rules/design-system.md`
5. Update DESIGN.md with new token if applicable

### Adding Error Types
1. Add to `Failure` sealed class
2. Follow `XxxError` naming convention
3. Update `.agents/rules/error-handling-architecture.md`
4. Update reference: `.agents/reference/error-handling-patterns.md`

## Verification

See `.agents/rules/operations.md` for verification commands.

## Child DOX Index

- `.agents/rules/design-system.md` — UI wrappers, typography, colors
- `.agents/rules/error-handling-architecture.md` — Failure taxonomy
- `.agents/rules/code-quality.md` — style rules applicable here

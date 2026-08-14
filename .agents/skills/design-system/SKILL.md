---
name: design-system
description: Use this skill to generate, audit, and enforce design system consistency across Flutter (Mobile/Admin) and Jaspr (Site) in the monorepo.
metadata:
  origin: Monorepo
---

# Design System — Generate & Audit Visual Systems (Dart/Flutter/Jaspr)

## When to Use

- Starting a new feature that needs design system components.
- Auditing existing Flutter (`<project>_flutter`, `<project>_admin` / `*_flutter`, `*_admin`) or Jaspr (`<project>_site` / `*_site`) code for visual consistency.
- Extracting hardcoded values into the shared `<project>_shared` / `*_shared` design system.
- Reviewing PRs that touch styling across the Dart ecosystem.

## How It Works

### Mode 1: Enforce & Audit Flutter Theme

Analyzes Flutter codebase and enforces strict adherence to `ThemeData` and `*_shared` components.

```
1. Scan Flutter widget trees for hardcoded colors, padding, and text styles.
2. Flag uses of `Color(0xFF...)` instead of `Theme.of(context).colorScheme...`.
3. Flag uses of `TextStyle(...)` instead of `Theme.of(context).textTheme...`.
4. Suggest migration paths to shared components in `*_shared`.
5. Ensure responsive design matches `LayoutBuilder` / breakpoints defined in `*_shared/lib/theme/`.
```

### Mode 2: Enforce & Audit Jaspr Styling

Analyzes Jaspr web codebase (`*_site`) and enforces CSS-in-Dart styling best practices.

```
1. Scan for inline styles (`styles: Styles.box(...)`) vs reusable CSS classes.
2. Ensure color variables and spacing units match the global design tokens.
3. Validate responsive behavior (media queries in Dart).
4. Check for component consistency with shared Jaspr components (if any) or standard HTML elements.
```

### Mode 3: Generate Design System Artifacts

When building out the base theme in `*_shared`, this mode helps structure it:

```
1. Generate `AppColors`, `AppTypography`, `AppSpacing` classes in `*_shared`.
2. Generate a cohesive `ThemeData` factory for light and dark modes.
3. Map these same tokens to a `styles.css` or Jaspr `StyleRule` set for web consistency.
4. Update `DESIGN.md` in the root with the latest token values and component guidelines.
```

### Mode 4: AI Slop Detection in Flutter/Jaspr

Identifies generic or unpolished UI code:

```
- Overuse of generic `Container` wrappers when a specific widget (e.g., `SizedBox`, `Padding`) would suffice.
- Gratuitous drop shadows (`BoxShadow` with generic offsets).
- Lack of hover states on interactive Jaspr elements.
- Missing `InkWell` or splash effects on custom Flutter buttons.
- Hardcoded `EdgeInsets.all(8.0)` instead of semantic spacing units (e.g., `AppSpacing.sm`).
```

## Examples

**Audit Flutter UI:**
```
/design-system audit-flutter --path <project>_flutter/lib/features/profile
```

**Audit Jaspr UI:**
```
/design-system audit-jaspr --path <project>_site/lib/components
```

**Extract to Shared:**
```
/design-system extract-tokens --source <project>_admin/lib/ --dest <project>_shared/lib/theme/
```

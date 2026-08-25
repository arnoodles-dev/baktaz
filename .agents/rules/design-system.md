---
trigger: glob
description: Layout, typography, colors, spacing, and component wrappers from DESIGN.md
globs: *_flutter/lib/features/*/presentation/**, *_flutter/lib/shared/widgets/**, *_admin/lib/features/*/presentation/**, *_admin/lib/shared/widgets/**, *_shared/lib/src/widgets/**, lib/**
---

# Design System

## Truth

Follow `DESIGN.md`.

## Components

Use existing shared widgets from `*_shared` before building new:

`<App>` is a template placeholder — replace with package name (e.g., `BaktazText`, `BaktazButton`).

- Text: `<App>Text`, `<App>Button`, `<App>TextField`, `<App>Card`, `<App>Icon`, `<App>Avatar`
- Layout: `<App>Divider`, `<App>FilterChip`, `<App>IconTile`, `<App>ListRow`
- Inputs: `<App>MobileNumberField`, `<App>ProgressBar`, `<App>SectionHeader`, `<App>StatusBadge`, `<App>Toggle`

Wrappers: `ConnectivityChecker`, `Shimmer`, `UnfocusableScaffold`

Dialogs: `ConfirmationDialog`

## Typography & Colors

- Typography: `AppTextStyle`
- Colors: Theme `colorScheme` or `CustomColors`
- No hardcoded user-facing strings — use localization keys (`context.l10n.*`)
- No magic numbers — extract to named constants

## Spacing

- `Padding`/`Paddings` → `EdgeInsets` with `AppSizes.*`
- `Gap` for inline spacing

## Dark Mode

- Surface lightening
- No shadows
- Dynamic SVG tinting
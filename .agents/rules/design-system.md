---
name: Design System
description: Layout, typography, colors, spacing, and component wrappers from DESIGN.md
trigger: glob
globs: *_flutter/lib/features/*/presentation/**, *_flutter/lib/shared/widgets/**, *_admin/lib/features/*/presentation/**, *_admin/lib/shared/widgets/**, *_shared/lib/src/widgets/**, lib/**
---
# Design System

### Truth
- Follow `DESIGN.md`

### Wrappers
- Use existing shared UI widgets from `*_shared` before building new ones: `<App>Text`, `<App>Button`, `<App>TextField`, `<App>Card`, `<App>Icon`, `<App>Avatar`, `<App>Divider`, `<App>FilterChip`, `<App>IconTile`, `<App>ListRow`, `<App>MobileNumberField`, `<App>ProgressBar`, `<App>SectionHeader`, `<App>StatusBadge`, `<App>Toggle`.
- Wrappers: `ConnectivityChecker`, `Shimmer`, `UnfocusableScaffold`.
- Dialogs: `ConfirmationDialog`.
- Always check `*_shared/lib/src/widgets/` for existing reusable widgets before creating new UI components.

### Typography & Colors
- **Typography**: `AppTextStyle`
- **Colors**: Theme `colorScheme` or `CustomColors`
- **Localization**: Never hardcode user-facing strings in widgets. Use localization keys (e.g., `context.l10n.*`). Exception: `*_server`.
- **Magic Numbers**: Never use unexplained numeric literals. Extract to named constants (e.g., `const maxRetries = 3;`).

### Spacing & Feedback
- **Spacing**: `Padding`/`Paddings` → `EdgeInsets` with `AppSizes.*`, or `Gap` for inline spacing
- Contextual feedback: `toastification`, `LoaderOverlay`, shimmering

### Dark Mode
- Surface lightening.
- No shadows.
- Dynamic SVG tinting.

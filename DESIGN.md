# DESIGN.md — Baktaz Design System & UI Specification

Design system specification and component guidelines for the Baktaz monorepo (`*_flutter`, `*_admin`, `*_shared`).

---

## 1. Core Principles

- **Single Source of Truth**: Aligned with `.agents/rules/design-system.md` and implementation in `baktaz_shared/lib/src/theme/` & `baktaz_shared/lib/src/widgets/`.
- **Component Reuse**: Check `baktaz_shared` widgets before building custom UI components.
- **No Hardcoded Strings**: User-facing text must use localization keys (`context.l10n.*`).
- **No Magic Numbers**: Layout values must use `AppSizes.*` or `Paddings.*`.
- **Dark Mode Compliance**: Surface lightening, zero shadows in dark theme, dynamic SVG/icon tinting.

---

## 2. Color Palette & Tokens

Colors resolve via Material `ColorScheme` and `BaktazCustomColors` (`ThemeExtension`).

### 2.1 Primary & Brand Colors (Blue + Teal)

| Token Name | Light Value | Dark Value | Usage |
|---|---|---|---|
| Primary | `#1A6FD4` | `#85B7EB` | Main actions, active states, key elements |
| Primary Mid | `#378ADD` | `#85B7EB` | Hover/secondary accents |
| Primary Light / Subtle | `#B5D4F4` | `#0C447C` | Containers, active tabs, subtle highlights |
| Secondary (Teal) | `#0F6E56` | `#5DCAA5` | Success indicators, secondary accents |
| Secondary Container | `#E1F5FE` / `#D4F2E7` | `#1D4D3E` | Chip backgrounds, badge containers |

### 2.2 Neutral & Surface Colors

| Token Name | Light Value | Dark Value | Usage |
|---|---|---|---|
| Surface / Scaffold | `#FFFFFF` | `#0F1C2E` | Base background |
| Surface Container | `#F9F9FB` | `#1E2C3D` | Cards, input fields, subtle panels |
| Surface Container Highest | `#F0F4F8` | `#253A55` | Elevated chips, active states |
| Border / Outline | `#E6E8EB` | `#2A3F5D` | Card borders, dividers, field borders |
| Text Primary | `#0F1C2E` | `#F0F4F8` | Body & heading text |
| Text Secondary | `#5F6D7E` | `#94A3B8` | Captions, muted text, hints |

### 2.3 Semantic & Custom Extension Tokens (`context.baktazColors`)

| Token Name | Light Value | Dark Value | Usage |
|---|---|---|---|
| `warning` | `#EF9F27` | `#FAC775` | Warning icons, amber indicators |
| `warningOnContainer` | `#854F0B` | `#854F0B` | Warning text on container |
| `successOnContainer` | `#0F6E56` | `#5DCAA5` | Success text on badge/container |
| `errorOnContainer` | `#A32D2D` | `#F09595` | Error text on container |
| `starFilled` | `#EF9F27` | `#FAC775` | Star ratings |
| `badgePendingBg` | `#FAEEDA` | `0x26EF9F27` (15%) | Pending status background |
| `badgePendingText` | `#854F0B` | `#FAC775` | Pending status text |
| `badgeNeutralBg` | `#F1EFE8` | `#2C2C2A` | Neutral status background |
| `badgeNeutralText` | `#5F5E5A` | `#B4B4A9` | Neutral status text |

---

## 3. Typography Standards

Typography uses **Inter** for UI text and **Roboto Mono** for code/data/IDs (`AppTextStyle`).

### 3.1 Type Scale

| Category | Token | Font | Size | Weight | Line Height | Letter Spacing |
|---|---|---|---|---|---|---|
| **Display** | `displayLarge` | Inter | 28px | Bold (700) | 1.21 | -0.3px |
| | `displayMedium` | Inter | 24px | SemiBold (600) | 1.25 | -0.2px |
| | `displaySmall` | Inter | 20px | SemiBold (600) | 1.30 | 0.0px |
| **Headline** | `headlineLarge` | Inter | 20px | SemiBold (600) | 1.30 | -0.1px |
| | `headlineMedium` | Inter | 18px | SemiBold (600) | 1.33 | 0.0px |
| | `headlineSmall` | Inter | 16px | SemiBold (600) | 1.38 | 0.0px |
| **Title** | `titleLarge` | Inter | 16px | SemiBold (600) | 1.38 | 0.0px |
| | `titleMedium` | Inter | 15px | Medium (500) | 1.33 | 0.0px |
| | `titleSmall` | Inter | 14px | Medium (500) | 1.33 | 0.0px |
| **Body** | `bodyLarge` | Inter | 16px | Regular (400) | 1.50 | 0.0px |
| | `bodyMedium` | Inter | 14px | Regular (400) | 1.43 | 0.0px |
| | `bodySmall` | Inter | 12px | Regular (400) | 1.33 | 0.0px |
| **Label** | `labelLarge` | Inter | 14px | SemiBold (600) | 1.43 | +0.1px |
| | `labelMedium` | Inter | 12px | SemiBold (600) | 1.33 | +0.2px |
| | `labelSmall` | Inter | 10px | Medium (500) | 1.40 | +0.3px |
| **Mono** | `mono` | Roboto Mono | 13px | Regular (400) | 1.38 | +0.08em |

---

## 4. Spacing, Radii & Sizes

Centralized in `AppSizes`, `Gap`, and `Paddings`.

### 4.1 Spacing Scale (`AppSizes`)

| Token | Size (dp) | Gap Helper | Padding Constant |
|---|---|---|---|
| `x3Small` | 2 | `Gap.x3Small()` | `Paddings.allX3Small` |
| `x2Small` | 4 | `Gap.x2Small()` | `Paddings.allX2Small` |
| `xSmall` | 8 | `Gap.xSmall()` | `Paddings.allXSmall` |
| `small` | 12 | `Gap.small()` | `Paddings.allSmall` |
| `medium` | 16 | `Gap.medium()` | `Paddings.allMedium` |
| `large` | 20 | `Gap.large()` | `Paddings.allLarge` |
| `xLarge` | 24 | `Gap.xLarge()` | `Paddings.allXLarge` |
| `x2Large` | 32 | `Gap.x2Large()` | `Paddings.allX2Large` |
| `x3Large` | 40 | `Gap.x3Large()` | `Paddings.allX3Large` |
| `x4Large` | 48 | `Gap.x4Large()` | `Paddings.allX4Large` |

- Screen Horizontal Margin: `AppSizes.screenMarginH` (16dp).

### 4.2 Border Radius Scale

| Token | Value (dp) | Constant / Component Usage |
|---|---|---|
| `radiusX2Small` | 4 | Fine borders |
| `radiusXSmall` | 8 | `ThemeConstants.inputBorderRadius` |
| `radiusSmall` | 12 | `ThemeConstants.cardBorderRadius` |
| `radiusMedium` | 16 | `ThemeConstants.defaultBorderRadius` |
| `radiusXLarge` | 24 | Dialogs, bottom sheets |
| `radiusX2Large` | 36 | Large containers |
| `radiusFull` | 999 | `ThemeConstants.buttonBorderRadius`, Badges, Chips, Avatars |

### 4.3 Icon & Avatar Sizes

- **Icons**: `iconXSmall` (16), `iconSmall` (20), `iconMedium` (24), `iconLarge` (32), `iconXLarge` (48).
- **Avatars**: `avatarXS` (24), `avatarSM` (36), `avatarMD` (44), `avatarLG` (64), `avatarXL` (88).

---

## 5. Elevation, Shadows & Motion

### 5.1 Shadows (`ThemeConstants`)

- **Level 1** (Cards): `Offset(0, 1)`, blur `3`, color `cs.shadow` @ 6% opacity.
- **Level 2** (Focused Cards / Bottom Sheets): `Offset(0, 4)`, blur `12`, color `cs.shadow` @ 8% opacity.
- **Level 3** (Modal Dialogs): `Offset(0, 8)`, blur `24`, color `cs.shadow` @ 12% opacity.
- **Dark Mode**: Elevation shadows disabled (`0`).

### 5.2 Animations & Timings

- `animationCardPress`: 80ms
- `animationFast`: 200ms
- `animationNormal`: 300ms
- `animationSlow`: 500ms
- `animationSkeleton`: 1200ms
- Curves: `Curves.easeIn`, `Curves.easeOut`, `Curves.easeInOut`.

---

## 6. Shared Component Library (`*_shared`)

Always prefer these wrappers over raw Flutter widgets:

### 6.1 Basic Components

- `<App>Text` (`BaktazText`): Supports `regular`, `styled` (bold, blueText, link, icon tags), `markdown`, and `selectable` variants.
- `<App>Button` (`BaktazButton`): Supports `filled`, `outlined`, `elevated`, `tonal`, `text`, and `destructive` types with built-in event throttling (`flutter_event_limiter`), loading spinner, and full-width layout option.
- `<App>TextField` (`BaktazTextField`): Form field with standard styling, clear button, obscure text toggle, label, prefix/suffix, error validation.
- `<App>Card` (`BaktazCard`): Surface card with optional header icon/title/action, divider, body, and footer slots.
- `<App>Icon` (`BaktazIcon`): Icon container supporting material icon or SVG asset rendering with theme tinting.
- `<App>Avatar` (`BaktazAvatar`): Circular/rounded image or initials avatar with size variants (`avatarXS` to `avatarXL`).
- `<App>Divider` (`BaktazDivider`): Theme-aware thin rule divider (`DividerThemeData`).
- `<App>FilterChip` (`BaktazFilterChip`): Selection pill chip with active state styling.
- `<App>IconTile` (`BaktazIconTile`): Square icon badge tile with rounded background.
- `<App>ListRow` (`BaktazListRow`): Standard list tile with leading icon/avatar, title, subtitle, trailing widget/chevron.
- `<App>MobileNumberField` (`BaktazMobileNumberField`): Form field specialized for international/national phone entry with country code prefix.
- `<App>ProgressBar` (`BaktazProgressBar`): Determinate linear progress bar with brand color fill.
- `<App>SectionHeader` (`BaktazSectionHeader`): Category/section header row with title and optional action link.
- `<App>StatusBadge` (`BaktazStatusBadge`): Status pill combining background + icon + label (variants: `available`, `confirmed`, `active`, `pending`, `failed`, `neutral`).
- `<App>Toggle` (`BaktazToggle`): Switch toggle bound to design system colors.

### 6.2 Utility Wrappers & Dialogs

- `ConnectivityChecker`: Listens to network connectivity changes (`connection_status.dart`) and renders offline state banner.
- `Shimmer`: Shimmer skeleton loading container (`lightShimmerBase`/`darkShimmerBase`).
- `UnfocusableScaffold`: Scaffold wrapper that dismisses keyboard on tap outside input fields.
- `ConfirmationDialog`: Standard modal dialog for destruction or confirm actions.

---

## Component Sizes

| Token | Value | Usage |
|-------|-------|-------|
| `dialogWidth` | 400 | Max-width for auth/localization dialogs; applied via `ConstrainedBox(maxWidth:)` |
| `tableSearchWidth` | 240 | Max-width for table search field; applied via `ConstrainedBox(maxWidth:)` |
| `chartHeightLarge` | 250 | Fixed height for large dashboard charts (activities_overview_chart) |
| `chartHeightMedium` | 200 | Fixed height for medium dashboard charts (activities_reports_chart) |
| `chartBarAreaHeight` | 120 | Fixed height for chart bar area (HomeWeeklyStepsChart in flutter plan) |

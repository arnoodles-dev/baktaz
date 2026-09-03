---
trigger: glob
description: Layout, typography, colors, spacing, and component wrappers from DESIGN.md
globs: *_flutter/lib/features/*/presentation/**, *_flutter/lib/shared/widgets/**, *_admin/lib/features/*/presentation/**, *_admin/lib/shared/widgets/**, *_shared/lib/src/widgets/**, lib/**
---

# Design System

## Truth

Follow `DESIGN.md`.

## Tokens (Emerald Green, v3.1.2)

- **Colors**: `BaktazTheme` — mapped to `ColorScheme` roles. Access via `Theme.of(context).colorScheme`.
- **Typography**: `TextTheme` (Common styles: `headlineLarge`, `bodyLarge`, `labelSmall`, etc.) + `BaktazType` (Custom/display: `metricHero`, `headlineTitle`, `labelRanking`, etc.)
  - **Space Grotesk** (display, numerals, technical labels): `displayHero`, `metricHero`, `headlineTitle`, `subheadingUppercase`, `labelRanking`
  - **Plus Jakarta Sans** (names, body, navigation): mapped to `TextTheme`
- **Spacing**: `BaktazSpacing.*` (xs2=4, xs=8, sm=12, md=16, lg=20, xl=24, xl2=32, xl3=40)
- **Radius**: `BaktazRadius` — card, row, chip, pill (with named BorderRadius getters)
- **Elevation**: `BaktazElevation` — surface, active, floatingNav, fab (brightness-aware)
- **Special tokens**: `BaktazCustomColors` (ThemeExtension) — stars, warnings, special badges not in ColorScheme

## Typography Usage

```dart
// Common styles (theme-aware, automatic dark mode)
final textTheme = Theme.of(context).textTheme;
final scheme = Theme.of(context).colorScheme;

Text('Sarah', style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface));
Text('2M AGO', style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant));

// Custom/display styles (when TextTheme doesn't fit)
Text('8,432', style: BaktazType.metricHero(scheme.onSurface));
Text('LIVE LEADERBOARD', style: BaktazType.headlineTitle(scheme.onSurface));
```

## Components

Use existing shared widgets from `*_shared` before building new:

`<App>` is a template placeholder — replace with package name (e.g., `BaktazText`, `BaktazButton`).

### Atoms (basic)
- Text: `BaktazText` (supports regular, styled, markdown, selectable)
- Button: `BaktazButton` (filled, outlined, elevated, tonal, text, destructive)
- Icon: `BaktazIcon` (Material + SVG support)
- Avatar: `BaktazAvatar` (sizes: 24, 36, 44, 64, 88dp)
- Badge: `BaktazStatusBadge` (available, confirmed, active, pending, failed, neutral)
- Progress: `BaktazProgressBar`
- Divider: `BaktazDivider`
- StageProgressBar: `BaktazStageProgressBar` (track: outlineVariant, fill: primary/primaryContainer)
- SlotsProgressRing: `BaktazSlotsProgressRing` (circular, track: outlineVariant, fill: primary)
- FireIcon: `BaktazFireIcon` (warning color, inline with step count)

### Molecules (combinations)
- SectionHeader: `BaktazSectionHeader` (title + View All link)
- FilterChip: `BaktazFilterChip` (selection pill)
- ListRow: `BaktazListRow` (leading icon/avatar + title + trailing)
- IconTile: `BaktazIconTile` (square icon badge)
- Toggle: `BaktazToggle` (switch)
- LeadersStrip: `BaktazLeadersStrip` (AvatarStack + podium Text)
- RankTrend: `BaktazRankTrend` (arrow + Text, primary/error/outline)
- GapMeter: `BaktazGapMeter` (ProgressBar + Text, primaryContainer fill)
- WeeklyStepsBarChart: `BaktazWeeklyStepsBarChart` (7-day vertical bars)
- LeaderboardTable: `BaktazLeaderboardTable` (DataTable + infinite scroll)

### Wrappers
- ConnectivityChecker
- Shimmer
- UnfocusableScaffold

### Dialogs
- ConfirmationDialog

### Missing (to implement)
- FAB (54dp circular)
- NotificationIconButton
- StatSubCard
- RankBadge
- AvatarStack
- StakeReturnValue
- IdentityBlock
- StageProgressBar
- SlotsProgressRing
- FireIcon
- LeadersStrip
- RankTrend
- GapMeter
- WeeklyStepsBarChart
- LeaderboardTable

## Colors

- **Primary**: Emerald `#10B981` (light) / `#34D399` (dark)
- **Tertiary** (Success): `#059669` (light) / `#10B981` (dark)
- **Surface**: White (light) / Charcoal `#181B20` (dark)
- **Canvas**: `#F6F8F7` (light) / `#0D0F12` (dark) — set on `scaffoldBackgroundColor`

## Rules

- No hardcoded user-facing strings — use localization keys (`context.l10n.*`)
- No hardcoded colors — use `scheme.*` or `BaktazCustomColors.*`
- No magic numbers — use `BaktazSpacing.*`, `BaktazRadius.*`
- Dark mode: surface lightening, no shadows, dynamic SVG tinting
- **Typography**: Use `Theme.of(context).textTheme.*` for common styles. Only use `BaktazType.*` for custom/display styles not covered by TextTheme.
- **BaktazCustomColors Scope**: Frozen at 10 tokens. New tokens require: (1) no ColorScheme slot, (2) used in ≥3 feature screens, (3) ThemeExtension behavior needed. Feature-scoped icon tints use inline constants.

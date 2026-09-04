---
name: Baktaz Design System
edition: Emerald Green
version: 3.1.2
architecture: Atomic Design (Tokens → Atoms → Molecules)
platform: Flutter / Dart
modes: [light, dark]
---

# Baktaz — Design System

## Brand & Style

Baktaz blends fitness analytics with social, money-backed accountability: step challenges, live leaderboards, and pooled stakes. The reference UI reads as **calm fintech, not neon gym** — a soft, high-trust light canvas, white card stacks, a single disciplined emerald accent, and generous 20–24dp rounding. The system also ships a dark counterpart for low-light use. There is one accent — Emerald Green — carrying every "this matters" signal (active status, positive stakes, progress, the current user's row), while everything else stays neutral gray/white (light) or charcoal/off-white (dark).

This document targets a **Flutter/Dart** implementation. Colors are wired through Flutter's built-in `ColorScheme` (via `ThemeData`), so screens read `Theme.of(context).colorScheme` rather than hardcoding values — no custom `ThemeExtension` is needed for primary colors. Typography is wired through Flutter's `TextTheme` (via `ThemeData`), so screens read `Theme.of(context).textTheme.headlineLarge` rather than calling custom static methods. Assumes fonts are loaded via the `google_fonts` package (swap for local `pubspec.yaml` font assets if offline fonts are required).

## Core Principles

- **Single Source of Truth**: All tokens live in `baktaz_shared/lib/src/theme/`. Implementation follows this document.
- **Component Reuse**: Check `baktaz_shared/lib/src/widgets/` before building custom UI components.
- **No Hardcoded Colors**: All colors resolve from `Theme.of(context).colorScheme`. Only `BaktazCustomColors` (ThemeExtension) is kept for tokens without a ColorScheme slot (stars, warnings, special badges).
- **No Hardcoded Typography**: All text styles resolve from `Theme.of(context).textTheme`. Only `BaktazType` is kept for truly custom display styles not covered by TextTheme.
- **No Hardcoded Strings**: User-facing text must use localization keys (`context.l10n.*`).
- **No Magic Numbers**: Layout values must use `BaktazSpacing.*`, `BaktazRadius.*`, or `AppSizes.*`.
- **Dark Mode Compliance**: Surface lightening, zero shadows in dark theme, dynamic SVG/icon tinting.

## How to read this document

1. **Foundations** — raw design tokens (color, type, spacing, radius, elevation) as Dart constants/classes. Every color token lists a **Light** and a **Dark** value, mapped onto a standard `ColorScheme` role; nothing downstream hardcodes a `Color(0x...)` literal.
2. **Atoms** — the smallest reusable pieces, mapped to concrete Flutter widgets.
3. **Molecules** — small, fixed combinations of atoms.
4. **Component Library** — existing widgets in `baktaz_shared` with their current status.
5. **Implementation Status** — what exists vs. what's missing, and migration notes.

---

## 0. Foundations / Design Tokens

### 0.1 Color Tokens — mapped to Flutter's `ColorScheme`

Emerald Green is the only accent — there is no runtime-swappable colorway. Several of the original semantic slots share an identical hex value on purpose (e.g. the "positive stake" color and the "brand accent" color are the same green), which is exactly the kind of role reuse `ColorScheme` already expects — so almost every token lands on a standard M3 role instead of a bespoke one.

| Semantic role | `ColorScheme` property | Light | Dark |
|---|---|---|---|
| Card / list-row base, avatar ring | `surface` | `#FFFFFF` | `#181B20` |
| Inset sub-card (Pool / Stake chips) | `surfaceContainerHigh` | `#F2F4F3` | `#20242A` |
| Current-user row highlight fill | `primaryContainer` | `#E9F9F1` | `#123326` |
| Circular icon-button well | `surfaceContainerHighest` | `#EDEFEF` | `#20242A` |
| Community Pulse card, dark accent blocks | `inverseSurface` | `#10141C` | `#0A0C10` |
| Chip on an inverse surface ("+14 online") *(repurposed — no true 2nd hue)* | `secondaryContainer` | `#232833` | `#1B1F27` |
| Headlines, names, hero numbers | `onSurface` | `#0D1117` | `#F1F3F2` |
| Eyebrow labels, muted suffixes | `onSurfaceVariant` | `#6B7280` | `#9AA6A0` |
| Zero-state / muted values | `outline` | `#9AA1AC` | `#6B7570` |
| Text on inverse / dark-accent surfaces | `onInverseSurface` | `#FFFFFF` | `#F1F3F2` |
| Brand accent — badges, links, fills, positive returns, active-row stroke | `primary` | `#10B981` | `#34D399` |
| Pressed / high-emphasis accent | `onPrimaryContainer` | `#059669` | `#10B981` |
| Content on a solid accent fill | `onPrimary` | `#FFFFFF` | `#052E22` |
| Card hairlines, progress track | `outlineVariant` | `#E7EAE8` | `#2A2F35` |
| App/page background *(not a `ColorScheme` role)* | `ThemeData.scaffoldBackgroundColor` | `#F6F8F7` | `#0D0F12` |
| Success state (goal exceeded, rank positive) | `tertiary` | `#059669` | `#10B981` |
| Content on success fill | `onTertiary` | `#FFFFFF` | `#052E22` |

`error` / `onError` are required by `ColorScheme` but were never defined in the original visual language — a standard semantic red is used below as a placeholder; replace it if/when Baktaz defines a brand error color. `secondary`/`onSecondary` are set equal to `primary`/`onPrimary` purely to satisfy the constructor — this system has no genuine second accent hue, so they're unused elsewhere in the spec.

```dart
import 'package:flutter/material.dart';

class BaktazTheme {
  BaktazTheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE9F9F1),
    onPrimaryContainer: Color(0xFF059669),
    secondary: Color(0xFF10B981),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF232833),
    onSecondaryContainer: Color(0xFFFFFFFF),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0D1117),
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFF9AA1AC),
    outlineVariant: Color(0xFFE7EAE8),
    surfaceContainerHigh: Color(0xFFF2F4F3),
    surfaceContainerHighest: Color(0xFFEDEFEF),
    inverseSurface: Color(0xFF10141C),
    onInverseSurface: Color(0xFFFFFFFF),
    tertiary: Color(0xFF059669),     // success
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE9F9F1),
    onTertiaryContainer: Color(0xFF059669),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF34D399),
    onPrimary: Color(0xFF052E22),
    primaryContainer: Color(0xFF123326),
    onPrimaryContainer: Color(0xFF10B981),
    secondary: Color(0xFF34D399),
    onSecondary: Color(0xFF052E22),
    secondaryContainer: Color(0xFF1B1F27),
    onSecondaryContainer: Color(0xFFF1F3F2),
    error: Color(0xFFEF4444),
    onError: Color(0xFF450A0A),
    surface: Color(0xFF181B20),
    onSurface: Color(0xFFF1F3F2),
    onSurfaceVariant: Color(0xFF9AA6A0),
    outline: Color(0xFF6B7570),
    outlineVariant: Color(0xFF2A2F35),
    surfaceContainerHigh: Color(0xFF20242A),
    surfaceContainerHighest: Color(0xFF20242A),
    inverseSurface: Color(0xFF0A0C10),
    onInverseSurface: Color(0xFFF1F3F2),
    tertiary: Color(0xFF10B981),     // success
    onTertiary: Color(0xFF052E22),
    tertiaryContainer: Color(0xFF123326),
    onTertiaryContainer: Color(0xFF10B981),
  );

  // Not part of ColorScheme — set directly on ThemeData.scaffoldBackgroundColor.
  static const Color canvasLight = Color(0xFFF6F8F7);
  static const Color canvasDark = Color(0xFF0D0F12);
}
```

> Roles this design doesn't use (`scrim`, `shadow`, `surfaceDim`, `surfaceBright`, `surfaceContainerLow(est)`) are simply omitted; `tertiary` was added in v3.1.2 for success states (goal exceeded, rank positive). check the `ColorScheme` constructor in the Flutter SDK version you're on, since which parameters are required vs. defaulted has shifted across Flutter releases. `ColorScheme.fromSeed(seedColor: Color(0xFF10B981))` is a lighter-weight alternative if pixel-exact role values aren't critical — but it will *not* reproduce the exact hexes above.

### 0.2 Typography — TextTheme Mapping

Two families: **Space Grotesk** (display, numerals, technical/status labels) and **Plus Jakarta Sans** (names, body, navigation). `height` below is Flutter's line-height *multiplier* (`lineHeight px ÷ fontSize px`), not an absolute value.

Common text styles are mapped to Flutter's `TextTheme` slots. Custom/display styles that don't fit standard slots remain in `BaktazType`.

#### TextTheme Mapping (Common Styles)

| TextTheme Slot | Design Token | Family | Size | Weight | `height` | `letterSpacing` | Usage |
|---|---|---|---|---|---|---|---|
| `headlineLarge` | `bodyBold` | Plus Jakarta Sans | 15 | w700 | 1.47 | -0.15 | Names, currency values |
| `headlineMedium` | `bodyRegular` | Plus Jakarta Sans | 15 | w500 | 1.47 | -0.15 | Body copy |
| `bodyLarge` | `bodySubtext` | Plus Jakarta Sans | 13 | w500 | 1.38 | 0.00 | Steps subtext, captions, quotes |
| `bodyMedium` | `labelBadge` | Space Grotesk | 10 | w700 | 1.20 | 0.80 | Pill badge text ("ACTIVE") |
| `labelSmall` | `navLabel` | Plus Jakarta Sans | 11 | w600 | 1.27 | 0.22 | Bottom nav labels |
| `titleLarge` | `brandLockup` | Space Grotesk | 24 | w700 | 1.17 | -0.48 | "BAKTAZ" wordmark |

#### BaktazType (Custom/Display Styles)

Styles that don't fit TextTheme slots. Use sparingly for display purposes.

| Token | Family | Size | Weight | `height` | `letterSpacing` | Used for |
|---|---|---|---|---|---|---|
| `displayHero` | Space Grotesk | 44 | w700 | 1.09 | -1.32 | Marketing / onboarding headlines |
| `metricHero` | Space Grotesk | 40 | w700 | 1.10 | -0.80 | Hero step count ("8,432") |
| `headlineTitle` | Space Grotesk | 18 | w700 | 1.33 | 0.72 | Section titles ("LIVE LEADERBOARD") |
| `subheadingUppercase` | Space Grotesk | 11 | w700 | 1.45 | 1.32 | Eyebrow labels |
| `labelRanking` | Space Grotesk, italic | 18 | w600 | 1.22 | -0.18 | Rank numerals ("01", "04") |

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Common styles mapped to TextTheme — use Theme.of(context).textTheme.*
/// Custom/display styles that don't fit TextTheme remain here.
class BaktazType {
  BaktazType._();

  // ── Custom/Display (no TextTheme equivalent) ──────────────────────────────

  static TextStyle displayHero(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 44, fontWeight: FontWeight.w700, height: 1.09,
        letterSpacing: -1.32, color: color,
      );

  static TextStyle metricHero(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w700, height: 1.10,
        letterSpacing: -0.80, color: color,
      );

  static TextStyle headlineTitle(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w700, height: 1.33,
        letterSpacing: 0.72, color: color,
      );

  static TextStyle subheadingUppercase(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 11, fontWeight: FontWeight.w700, height: 1.45,
        letterSpacing: 1.32, color: color,
      );

  static TextStyle labelRanking(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.22,
        letterSpacing: -0.18, fontStyle: FontStyle.italic, color: color,
      );
}
```

### 0.3 Spacing Scale

```dart
class BaktazSpacing {
  BaktazSpacing._();

  static const double xs2 = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xl2 = 32;
  static const double xl3 = 40;

  static const double cardPadding = 20;
  static const double screenMarginMobile = 20;
  static const double screenMarginTablet = 32;
  static const double layoutGap = 16;

  /// Bottom scroll padding so content clears the floating nav bar.
  static const double navBottomClearance = 96;
}
```

### 0.4 Radius Scale

```dart
class BaktazRadius {
  BaktazRadius._();

  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double full = 999;

  static BorderRadius get card => BorderRadius.circular(xl2);   // Hero card, Community Pulse card
  static BorderRadius get row => BorderRadius.circular(xl);      // Leaderboard rows
  static BorderRadius get chip => BorderRadius.circular(lg);     // Pool / Stake sub-cards
  static BorderRadius get pill => BorderRadius.circular(full);   // Badges, FAB, avatars
}
```

### 0.5 Elevation / Shadow

Light mode uses a soft ambient `BoxShadow`; dark mode swaps it for a 1dp hairline border plus, on accent-bearing surfaces, a colored glow.

```dart
class BaktazElevation {
  BaktazElevation._();

  static List<BoxShadow> surface(Brightness b) => b == Brightness.light
      ? [const BoxShadow(color: Color(0x0A0D1117), blurRadius: 24, offset: Offset(0, 8))]
      : [BoxShadow(color: Colors.white.withOpacity(0.04), blurRadius: 0, spreadRadius: 1)];

  static List<BoxShadow> active(Brightness b) => b == Brightness.light
      ? [const BoxShadow(color: Color(0x3810B981), blurRadius: 20, offset: Offset(0, 4))]
      : [const BoxShadow(color: Color(0x3834D399), blurRadius: 24)];

  static List<BoxShadow> floatingNav(Brightness b) => b == Brightness.light
      ? [const BoxShadow(color: Color(0x1A0D1117), blurRadius: 32, offset: Offset(0, 12))]
      : [const BoxShadow(color: Color(0x80000000), blurRadius: 32, offset: Offset(0, 12))];

  static List<BoxShadow> fab(Brightness b) => b == Brightness.light
      ? [const BoxShadow(color: Color(0x5910B981), blurRadius: 20)]
      : [const BoxShadow(color: Color(0x7334D399), blurRadius: 20)];
}
```

---

## 1. Atoms

### 1.1 Color Swatch
Raw reference to any role in §0.1 via `Theme.of(context).colorScheme`. Never used standalone; underlies every other atom.

### 1.2 Typography Styles
**Primary:** Use `Theme.of(context).textTheme.*` for common styles.
**Secondary:** Use `BaktazType.*` for custom/display styles not covered by TextTheme.

```dart
// Common (theme-aware, preferred)
final scheme = Theme.of(context).colorScheme;
final textTheme = Theme.of(context).textTheme;

Text('Sarah', style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface));
Text('2M AGO', style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant));

// Custom (for display styles)
Text('8,432', style: BaktazType.metricHero(scheme.onSurface));
Text('LIVE LEADERBOARD', style: BaktazType.headlineTitle(scheme.onSurface));
```

### 1.3 Icon
Flutter widget: `Icon`.

| Spec | Value |
|---|---|
| Grid | 24×24 (`size: 24`) |
| Stroke | outline-style glyphs, e.g. Material Symbols "*_outlined"/`Icons.*_rounded` |
| Color (default) | `scheme.onSurfaceVariant` |
| Color (active/selected) | `scheme.primary` |
| Set used in reference | bell, home, trophy (challenges), chat_bubble, wallet, add (FAB) |

### 1.4 Avatar
Flutter widgets: `CircleAvatar` wrapped in a `Container` for the ring.

| Spec | Value |
|---|---|
| Sizes | 24 (micro/stack), 36 (leaderboard row), 40 (header profile) — `radius = size / 2` |
| Border | `Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: scheme.surface)))` wrapping the `CircleAvatar` |
| Fallback | `CircleAvatar(backgroundColor: scheme.surfaceContainerHigh, child: Text(initials, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: scheme.onSurface)))` |

### 1.5 Badge / Pill
Flutter widget: `Container` with `ShapeDecoration(shape: StadiumBorder())` + `Padding` + `Text`.

| Variant | Background | Text | Type token |
|---|---|---|---|
| Status — Active | `scheme.primary` | `scheme.onPrimary` | `textTheme.bodyMedium` |
| Count chip (inverse) | `scheme.secondaryContainer` | `scheme.onSecondaryContainer` | `textTheme.bodyLarge` (w600) |
| Return — Positive | transparent, text-only | `scheme.primary` | `textTheme.headlineLarge` |
| Return — Neutral | transparent, text-only | `scheme.outline` | `textTheme.headlineLarge` |

### 1.6 Button
| Variant | Flutter build |
|---|---|
| FAB (primary circular) | Custom 54dp `Container`/`InkWell` (not the default 56dp `FloatingActionButton`) — `decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary, boxShadow: BaktazElevation.fab(brightness))`, centered `Icon(Icons.add, color: scheme.onPrimary)` |
| Text link | `TextButton(style: TextButton.styleFrom(padding: EdgeInsets.zero), child: Text('View All', style: textTheme.bodyLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600)))` |
| Icon button | `IconButton` inside a 40dp circular `Container(color: scheme.surfaceContainerHighest)` |

### 1.7 Progress Bar
Custom widget (not the stock `LinearProgressIndicator`, to control the rounded leading edge and track color independently).

```dart
class BaktazProgressBar extends StatelessWidget {
  const BaktazProgressBar({super.key, required this.value, required this.scheme});
  final double value; // 0.0–1.0
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BaktazRadius.pill,
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: scheme.outlineVariant,
        valueColor: AlwaysStoppedAnimation(scheme.primary),
      ),
    );
  }
}
```

### 1.8 Divider / Stroke
| Variant | Flutter build |
|---|---|
| Hairline | `Border.all(width: 1, color: scheme.outlineVariant)` inside a card's `BoxDecoration` |
| Active stroke | `Border.all(width: 1.5, color: scheme.primary)` — a full-perimeter card outline, not a `Divider()` line |

### 1.9 Stage Progress Bar
`Container` with `BaktazProgressBar` + label. Track: `outlineVariant`, fill: `primary` if <100%, `primaryContainer` if exceeded. Label: `textTheme.bodyMedium` showing "Day 16 of 30 (53%)".

### 1.10 Slots Progress Ring
Circular progress showing `18/25`. Track: `outlineVariant`, fill: `scheme.primary`. Center text: `textTheme.bodyLarge` with count.

### 1.11 Fire Icon
Small flame icon from `BaktazCustomColors.warning`. Inline with step count. Optional subtle pulse animation.

---

## 2. Molecules

### 2.1 Icon Button (Notification Bell)
Icon atom (bell, `scheme.onSurfaceVariant`) centered in a 40dp Icon Button atom. Optional unread dot: `Positioned` 6dp `Container` circle, `scheme.primary`, with a 1dp ring matching the page canvas (`BaktazTheme.canvasLight`/`canvasDark`, not a `ColorScheme` role) via a `Container` border, top-right of a `Stack`.

### 2.2 Nav Item
`Column(mainAxisSize: MainAxisSize.min)` — Icon atom (24dp) above `Text(style: Theme.of(context).textTheme.labelSmall)`. Inactive: both `scheme.onSurfaceVariant`. Active: both `scheme.primary`.

### 2.3 Stat Sub-card
`Container(decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BaktazRadius.chip), padding: EdgeInsets.all(BaktazSpacing.sm))` — a `Column` with a `BaktazType.subheadingUppercase` label (`scheme.onSurfaceVariant`) over a `textTheme.headlineLarge` value scaled to ~20px. Value color is contextual: `scheme.primary` for pool/earnings, `scheme.onSurface` for neutral figures like a stake amount.

### 2.4 Rank Badge
`Text(style: BaktazType.labelRanking)`. Default: `scheme.onSurfaceVariant`. Current-user row: `scheme.primary`. Zero-padded (`01`, `04`).

### 2.5 Avatar Stack + Count Pill
`Stack` of 2–3 Avatar atoms (24dp) at -8dp horizontal offset each (via negative `Positioned`/`Transform.translate`), `scheme.surface` border for separation, followed by a Count-chip Badge ("+14 online").

### 2.6 Stake Return Value
`Text(style: textTheme.headlineLarge)`, right-aligned. Positive: `scheme.primary` with a leading "+". Zero/none: `scheme.outline`, no leading symbol.

### 2.7 Section Header
`Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)` — `BaktazType.headlineTitle` label (`scheme.onSurface`) and a Text-link Button atom ("View All", `scheme.primary`), same baseline.

### 2.8 Identity Block
**Brand lockup:** `Column` — `BaktazType.displayHero` wordmark (`scheme.onSurface`) over `BaktazType.subheadingUppercase` edition tag (`scheme.primary`).
**Participant identity:** `Column` — `textTheme.headlineLarge` name (`scheme.onSurface`) over `textTheme.bodyLarge` metric (`scheme.onSurfaceVariant`), e.g. "8,432 steps".

---

## 3. Component Library

Always prefer these wrappers over raw Flutter widgets.

### 3.1 Basic Components

| Token | Widget | Status | Description |
|---|---|---|---|
| `BaktazText` | `baktaz_text.dart` | ✅ Exists | Supports `regular`, `styled` (bold, blueText, link, icon tags), `markdown`, and `selectable` variants. Uses `AppTextStyle` (legacy) — migrate to `TextTheme`. |
| `BaktazButton` | `baktaz_button.dart` | ✅ Exists | Supports `filled`, `outlined`, `elevated`, `tonal`, `text`, and `destructive` types with built-in event throttling (`flutter_event_limiter`), loading spinner, and full-width layout option. |
| `BaktazTextField` | `baktaz_text_field.dart` | ✅ Exists | Form field with standard styling, clear button, obscure text toggle, label, prefix/suffix, error validation. |
| `BaktazCard` | `baktaz_card.dart` | ✅ Exists | Surface card with optional header icon/title/action, divider, body, and footer slots. Uses `AppSizes` — migrate to `BaktazRadius`. |
| `BaktazIcon` | `baktaz_icon.dart` | ✅ Exists | Icon container supporting material icon or SVG asset rendering with theme tinting. |
| `BaktazAvatar` | `baktaz_avatar.dart` | ✅ Exists | Circular/rounded image or initials avatar with size variants (`sizeXS` to `sizeXL`). Uses `AppSizes` — migrate to `BaktazSpacing`. |
| `BaktazDivider` | `baktaz_divider.dart` | ✅ Exists | Theme-aware thin rule divider (`DividerThemeData`). |
| `BaktazFilterChip` | `baktaz_filter_chip.dart` | ✅ Exists | Selection pill chip with active state styling. Uses `AppSizes` — migrate to `BaktazRadius`. |
| `BaktazIconTile` | `baktaz_icon_tile.dart` | ✅ Exists | Square icon badge tile with rounded background. Uses `AppSizes` — migrate to `BaktazRadius`. |
| `BaktazListRow` | `baktaz_list_row.dart` | ✅ Exists | Standard list tile with leading icon/avatar, title, subtitle, trailing widget/chevron. Uses `AppSizes` — migrate to `BaktazSpacing`. |
| `BaktazMobileNumberField` | `baktaz_mobile_number_field.dart` | ✅ Exists | Form field specialized for international/national phone entry with country code prefix. |
| `BaktazProgressBar` | `baktaz_progress_bar.dart` | ✅ Exists | Determinate linear progress bar with brand color fill. Uses `AppSizes` — migrate to `BaktazRadius`. |
| `BaktazSectionHeader` | `baktaz_section_header.dart` | ✅ Exists | Category/section header row with title and optional action link. Uses `AppSizes` — migrate to `BaktazSpacing`. |
| `BaktazStatusBadge` | `baktaz_status_badge.dart` | ✅ Exists | Status pill combining background + icon + label (variants: `available`, `confirmed`, `active`, `pending`, `failed`, `neutral`). Uses `BaktazCustomColors` — migrate to `ColorScheme` roles. |
| `BaktazToggle` | `baktaz_toggle.dart` | ✅ Exists | Switch toggle bound to design system colors. |

### 3.2 Missing Components (to implement)

#### Phase 1 — Existing missing molecules (priority)
| Token | Status | Target File |
|---|---|---|
| FAB (54dp circular) | ✅ Implemented | `baktaz_fab.dart` |
| NotificationIconButton | ✅ Implemented | `notification_icon_button.dart` |
| StatSubCard | ✅ Implemented | `stat_sub_card.dart` |
| RankBadge | ✅ Implemented | `rank_badge.dart` |
| AvatarStack | ✅ Implemented | `avatar_stack.dart` |
| StakeReturnValue | ✅ Implemented | `stake_return_value.dart` |
| IdentityBlock | ✅ Implemented | `identity_block.dart` |

#### Phase 2 — New molecules (added v3.1.2)
| Token | Status | Target File |
|---|---|---|
| StageProgressBar | ✅ Implemented | `baktaz_stage_progress_bar.dart` |
| SlotsProgressRing | ✅ Implemented | `baktaz_slots_progress_ring.dart` |
| FireIcon | ✅ Implemented | `baktaz_fire_icon.dart` |
| LeadersStrip | ✅ Implemented | `leaders_strip.dart` |
| RankTrend | ✅ Implemented | `rank_trend.dart` |
| GapMeter | ✅ Implemented | `gap_meter.dart` |
| WeeklyStepsBarChart | ✅ Implemented | `weekly_steps_bar_chart.dart` |
| LeaderboardTable | ✅ Implemented | `leaderboard_table.dart` |

### 3.3 Utility Wrappers & Dialogs

| Token | Widget | Description |
|---|---|---|
| `ConnectivityChecker` | `wrappers/connectivity_checker.dart` | Listens to network connectivity changes and renders offline state banner. |
| `Shimmer` | `wrappers/shimmer.dart` | Shimmer skeleton loading container. |
| `UnfocusableScaffold` | `wrappers/unfocusable_scaffold.dart` | Scaffold wrapper that dismisses keyboard on tap outside input fields. |
| `ConfirmationDialog` | `dialogs/confirmation_dialog.dart` | Standard modal dialog for destruction or confirm actions. |

---

## 4. Implementation Status

### 4.1 Current State

The `baktaz_shared` package uses **legacy tokens** that need migration:

| Legacy Token | New Token | Status |
|---|---|---|
| `AppColors` (blue `#1A6FD4`) | `BaktazTheme` (emerald `#10B981`) | ❌ Needs migration |
| `AppTextStyle` (Inter + Roboto Mono) | `TextTheme` + `BaktazType` | ❌ Needs migration |
| `AppSizes` | `BaktazSpacing`, `BaktazRadius` | ⚠️ Partial — keep for backward compat during migration |
| `BaktazCustomColors` (ThemeExtension) | `ColorScheme` roles | ⚠️ Keep for special tokens (stars, warnings) not covered by ColorScheme |

### 4.2 Migration Checklist

- [ ] Replace `AppColors` → `BaktazTheme` in all widgets
- [ ] Replace `AppTextStyle` → `TextTheme` in all widgets
- [ ] Replace `AppSizes.xLarge` → `BaktazSpacing.xl`, etc.
- [ ] Remove `BaktazCustomColors` from widgets that can use `ColorScheme` roles
- [ ] Keep `BaktazCustomColors` only for: star ratings, warnings, special badge variants
- [ ] Add missing molecules (FAB, notification button, stat sub-card, rank badge, avatar stack, stake return, identity block)
- [ ] Update `baktaz_shared.dart` exports
- [ ] Update consumer packages (`baktaz_flutter`, `baktaz_admin`)

### 4.3 Backward Compatibility

During migration, the following aliases can be kept to avoid breaking changes:

```dart
// Legacy aliases (deprecated, remove after migration)
typedef AppColors = BaktazTheme;
// AppSizes keeps its name but values align with BaktazSpacing/BaktazRadius
```

**Decision point:** Hard break (remove aliases) or soft migration (keep aliases with deprecation warnings)?

**BaktazCustomColors Scope — Frozen (v3.1.2)**

The `BaktazCustomColors` ThemeExtension is frozen at 10 tokens. New semantic color needs must map to existing `ColorScheme` roles (`primary`, `error`, `outline`, etc.) or use `BaktazCustomColors.warning` for attention states.

New tokens may only be added if **all three criteria** are met:
1. No `ColorScheme` role exists for this semantic purpose
2. The token is used in ≥3 feature screens (not feature-scoped icon tints)
3. ThemeExtension behavior is required (light/dark auto-switch)

Feature-scoped icon tints (e.g., Health Connect blue, Apple red) use inline `Color(0xFF...)` constants in feature widgets — they do **not** belong in `BaktazCustomColors`.

---

## 5. Theming Implementation (Flutter)

```dart
ThemeData buildBaktazTheme(Brightness brightness) {
  final ColorScheme scheme =
      brightness == Brightness.light ? BaktazTheme.light : BaktazTheme.dark;

  // Base text theme from Google Fonts
  final baseTextTheme = brightness == Brightness.light
      ? ThemeData.light().textTheme
      : ThemeData.dark().textTheme;

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        brightness == Brightness.light ? BaktazTheme.canvasLight : BaktazTheme.canvasDark,
    textTheme: baseTextTheme.copyWith(
      // Map TextTheme slots to our design tokens
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w700, height: 1.47, letterSpacing: -0.15,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 10, fontWeight: FontWeight.w700, height: 1.20, letterSpacing: 0.80,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: 0.22,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w700, height: 1.17, letterSpacing: -0.48,
      ),
    ),
    // Keep BaktazCustomColors for tokens not covered by ColorScheme
    extensions: <ThemeExtension<dynamic>>[
      BaktazCustomColors.light, // light mode
    ],
  );
}

ThemeData buildBaktazDarkTheme(Brightness brightness) {
  final ColorScheme scheme = BaktazTheme.dark;
  final baseTextTheme = ThemeData.dark().textTheme;

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: BaktazTheme.canvasDark,
    textTheme: baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w700, height: 1.47, letterSpacing: -0.15,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 10, fontWeight: FontWeight.w700, height: 1.20, letterSpacing: 0.80,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: 0.22,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 24, fontWeight: FontWeight.w700, height: 1.17, letterSpacing: -0.48,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      BaktazCustomColors.dark, // dark mode
    ],
  );
}
```

```dart
MaterialApp(
  theme: buildBaktazTheme(Brightness.light),
  darkTheme: buildBaktazDarkTheme(Brightness.dark),
  themeMode: ThemeMode.system,
  home: const HomeScreen(),
);
```

Any widget reads tokens the same way, regardless of active brightness — no custom method calls required for common styles:

```dart
final scheme = Theme.of(context).colorScheme;
final textTheme = Theme.of(context).textTheme;
final brightness = Theme.of(context).brightness;

// Common styles (theme-aware, automatic dark mode)
Text('Sarah', style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface));
Text('2M AGO', style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant));

// Custom/display styles (when TextTheme doesn't fit)
Text('8,432', style: BaktazType.metricHero(scheme.onSurface));
Text('LIVE LEADERBOARD', style: BaktazType.headlineTitle(scheme.onSurface));

// Card with elevation
Container(
  decoration: BoxDecoration(
    color: scheme.surface,
    borderRadius: BaktazRadius.card,
    boxShadow: BaktazElevation.surface(brightness),
  ),
  child: Text('8,432', style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface)),
);
```

For special tokens not in ColorScheme:

```dart
final customColors = Theme.of(context).extension<BaktazCustomColors>() ?? BaktazCustomColors.light;
final starColor = customColors.starFilled;
final warningColor = customColors.warning;
```

Package assumptions: `google_fonts` for Space Grotesk / Plus Jakarta Sans (bundle as local `pubspec.yaml` font assets instead if the app must work fully offline on first launch); `cached_network_image` for avatar images.

---

## Appendix: Change Log

- **v3.1.2** — Design system expansion: Added 3 new atoms (`StageProgressBar`, `SlotsProgressRing`, `FireIcon`), 5 new molecules (`LeadersStrip`, `RankTrend`, `GapMeter`, `WeeklyStepsBarChart`, `LeaderboardTable`). Added `tertiary` to ColorScheme for success states (goal exceeded). `BaktazCustomColors` scope frozen — new tokens require 3 criteria (no ColorScheme slot, used in ≥3 screens, ThemeExtension behavior needed). Health provider colors and payment brand colors must use inline constants, not ThemeExtension.
- **v3.1.1** — Typography migration: Common text styles now use Flutter's `TextTheme` (`headlineLarge`, `bodyLarge`, `labelSmall`, etc.) instead of `BaktazType` static methods. `BaktazType` kept only for custom/display styles not covered by TextTheme (`displayHero`, `metricHero`, `headlineTitle`, `subheadingUppercase`, `labelRanking`).
- **v3.1.0** — Hard break migration: Removed `AppColors` (blue `#1A6FD4`) and `AppTextStyle` (Inter + Roboto Mono). Replaced with `BaktazTheme` (emerald `#10B981`) and `TextTheme` mapping. Removed Organisms, Templates, and Pages sections. Added Implementation Status section. Kept `BaktazCustomColors` ThemeExtension for special tokens (stars, warnings) not covered by ColorScheme.
- **v3.0.0** — Renamed the product from StrideStake to **Baktaz** (brand lockup, edition tag, and all page/content references updated accordingly). Removed the **Colorway Accent Variants** section entirely; the system now ships a single, fixed **Emerald Green** accent. Re-platformed foundations and theming from CSS to Flutter/Dart.

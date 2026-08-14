import 'package:flutter/material.dart';

/// Custom color tokens beyond Material ColorScheme — accessed via
/// `context.baktazColors`.
///
/// DESIGN.md tokens with no standard ColorScheme slot.
/// Each property auto-resolves to the right color for the current theme:
/// `context.baktazColors.warning` gives the light or dark value depending on theme.
@immutable
class BaktazCustomColors extends ThemeExtension<BaktazCustomColors> {
  const BaktazCustomColors({
    // ── Star rating ───────────────────────────────────────────────────
    required this.starFilled,
    // ── Semantic tones ────────────────────────────────────────────────
    required this.warning,
    required this.warningOnContainer,
    required this.successOnContainer,
    required this.errorOnContainer,
    // ── Badge variant extras (don't map to standard ColorScheme slots) ─
    required this.badgePendingBg,
    required this.badgePendingText,
    required this.badgeNeutralBg,
    required this.badgeNeutralText,
    // ── Other design tokens ───────────────────────────────────────────
    required this.primaryMid,
    required this.primaryLight,
  });

  // ── Star rating ───────────────────────────────────────────────────────
  /// Filled star color (DESIGN.md §12.12): `#EF9F27` light, `#FAC775` dark.
  final Color starFilled;

  // ── Semantic tones ─────────────────────────────────────────────────────
  final Color warning; // warning icon/text
  final Color warningOnContainer; // text on warning container
  final Color successOnContainer; // text on success/accent container
  final Color errorOnContainer; // text on error container

  // ── Badge variant extras ──────────────────────────────────────────────
  final Color badgePendingBg;
  final Color badgePendingText;
  final Color badgeNeutralBg;
  final Color badgeNeutralText;

  // ── Other design tokens ───────────────────────────────────────────────
  final Color primaryMid;
  final Color primaryLight;

  /// Light-mode instance.
  static const BaktazCustomColors light = BaktazCustomColors(
    starFilled: Color(0xFFEF9F27),
    warning: Color(0xFFEF9F27),
    warningOnContainer: Color(0xFF854F0B),
    successOnContainer: Color(0xFF0F6E56),
    errorOnContainer: Color(0xFFA32D2D),
    badgePendingBg: Color(0xFFFAEEDA),
    badgePendingText: Color(0xFF854F0B),
    badgeNeutralBg: Color(0xFFF1EFE8),
    badgeNeutralText: Color(0xFF5F5E5A),
    primaryMid: Color(0xFF378ADD),
    primaryLight: Color(0xFFB5D4F4),
  );

  /// Dark-mode instance (values differ where DESIGN.md specifies dark tokens).
  static const BaktazCustomColors dark = BaktazCustomColors(
    starFilled: Color(0xFFFAC775),
    warning: Color(0xFFFAC775),
    warningOnContainer: Color(0xFF854F0B),
    successOnContainer: Color(0xFF5DCAA5), // secondary in dark mode — good on secondaryContainer
    errorOnContainer: Color(0xFFF09595), // onErrorContainer in dark mode
    badgePendingBg: Color(0x26EF9F27), // warning at ~15% alpha
    badgePendingText: Color(0xFFFAC775),
    badgeNeutralBg: Color(0xFF2C2C2A),
    badgeNeutralText: Color(0xFFB4B2A9),
    primaryMid: Color(0xFF85B7EB),
    primaryLight: Color(0xFF0C447C),
  );

  @override
  BaktazCustomColors copyWith({
    Color? starFilled,
    Color? warning,
    Color? warningOnContainer,
    Color? successOnContainer,
    Color? errorOnContainer,
    Color? badgePendingBg,
    Color? badgePendingText,
    Color? badgeNeutralBg,
    Color? badgeNeutralText,
    Color? primaryMid,
    Color? primaryLight,
  }) => BaktazCustomColors(
    starFilled: starFilled ?? this.starFilled,
    warning: warning ?? this.warning,
    warningOnContainer: warningOnContainer ?? this.warningOnContainer,
    successOnContainer: successOnContainer ?? this.successOnContainer,
    errorOnContainer: errorOnContainer ?? this.errorOnContainer,
    badgePendingBg: badgePendingBg ?? this.badgePendingBg,
    badgePendingText: badgePendingText ?? this.badgePendingText,
    badgeNeutralBg: badgeNeutralBg ?? this.badgeNeutralBg,
    badgeNeutralText: badgeNeutralText ?? this.badgeNeutralText,
    primaryMid: primaryMid ?? this.primaryMid,
    primaryLight: primaryLight ?? this.primaryLight,
  );

  @override
  BaktazCustomColors lerp(ThemeExtension<BaktazCustomColors>? other, double t) {
    if (other is! BaktazCustomColors) return this;
    return BaktazCustomColors(
      starFilled: Color.lerp(starFilled, other.starFilled, t) ?? starFilled,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningOnContainer: Color.lerp(warningOnContainer, other.warningOnContainer, t) ?? warningOnContainer,
      successOnContainer: Color.lerp(successOnContainer, other.successOnContainer, t) ?? successOnContainer,
      errorOnContainer: Color.lerp(errorOnContainer, other.errorOnContainer, t) ?? errorOnContainer,
      badgePendingBg: Color.lerp(badgePendingBg, other.badgePendingBg, t) ?? badgePendingBg,
      badgePendingText: Color.lerp(badgePendingText, other.badgePendingText, t) ?? badgePendingText,
      badgeNeutralBg: Color.lerp(badgeNeutralBg, other.badgeNeutralBg, t) ?? badgeNeutralBg,
      badgeNeutralText: Color.lerp(badgeNeutralText, other.badgeNeutralText, t) ?? badgeNeutralText,
      primaryMid: Color.lerp(primaryMid, other.primaryMid, t) ?? primaryMid,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
    );
  }
}

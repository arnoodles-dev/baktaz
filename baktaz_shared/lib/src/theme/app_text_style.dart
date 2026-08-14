import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Style — DESIGN.md type scale (Inter + Roboto Mono).
abstract final class AppTextStyle {
  static final TextStyle baseTextStyle = GoogleFonts.inter(fontWeight: AppFontWeight.regular);
  static final TextStyle monoBaseStyle = GoogleFonts.robotoMono(fontWeight: AppFontWeight.regular);

  // ── Display ──────────────────────────────────────────────────────────────────
  static final TextStyle displayLarge = baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: AppFontWeight.bold,
    height: 1.21,
    letterSpacing: -0.3,
  );

  static final TextStyle displayMedium = baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: AppFontWeight.semiBold,
    height: 1.25,
    letterSpacing: -0.2,
  );

  // ponytail: not in DESIGN.md; kept for M3 TextTheme slot compatibility.
  static final TextStyle displaySmall = baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: AppFontWeight.semiBold,
    height: 1.3,
  );

  // ── Headline ─────────────────────────────────────────────────────────────────
  static final TextStyle headlineLarge = baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: AppFontWeight.semiBold,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static final TextStyle headlineMedium = baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: AppFontWeight.semiBold,
    height: 1.33,
  );

  // ponytail: not in DESIGN.md; kept for M3 TextTheme slot.
  static final TextStyle headlineSmall = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: AppFontWeight.semiBold,
    height: 1.38,
  );

  // ── Title ─────────────────────────────────────────────────────────────────────
  static final TextStyle titleLarge = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: AppFontWeight.semiBold,
    height: 1.38,
  );

  static final TextStyle titleMedium = baseTextStyle.copyWith(
    fontSize: 15,
    fontWeight: AppFontWeight.medium,
    height: 1.33,
  );

  // ponytail: not in DESIGN.md; kept for M3 TextTheme slot.
  static final TextStyle titleSmall = baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: AppFontWeight.medium,
    height: 1.33,
  );

  // ── Body ──────────────────────────────────────────────────────────────────────
  static final TextStyle bodyLarge = baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: AppFontWeight.regular,
    height: 1.5,
  );

  static final TextStyle bodyMedium = baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: AppFontWeight.regular,
    height: 1.43,
  );

  static final TextStyle bodySmall = baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: AppFontWeight.regular,
    height: 1.33,
  );

  // ── Label ─────────────────────────────────────────────────────────────────────
  static final TextStyle labelLarge = baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: AppFontWeight.semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: AppFontWeight.semiBold,
    height: 1.33,
    letterSpacing: 0.2,
  );

  static final TextStyle labelSmall = baseTextStyle.copyWith(
    fontSize: 10,
    fontWeight: AppFontWeight.medium,
    height: 1.4,
    letterSpacing: 0.3,
  );

  // ── Mono ──────────────────────────────────────────────────────────────────────
  /// Reference codes, IDs, timestamps — Roboto Mono.
  static final TextStyle mono = monoBaseStyle.copyWith(
    fontSize: 13,
    fontWeight: AppFontWeight.regular,
    height: 1.38,
    letterSpacing: 0.08 * 13, // 0.08em
  );

  // ponytail: caption/overline kept for internal compatibility.
  static final TextStyle caption = labelSmall;
  static final TextStyle overline = labelSmall.copyWith(letterSpacing: 1.5);
}

abstract final class AppFontWeight {
  static const FontWeight black = FontWeight.w900;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight thin = FontWeight.w100;
}

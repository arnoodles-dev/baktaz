import 'package:flutter/material.dart';

/// Color tokens from DESIGN.md — Blue + Teal, Light & Dark.
abstract final class AppColors {
  // ── Utility ──────────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const Color lightShimmerHighlight = Color(0xFFE6E8EB);
  static const Color darkShimmerHighlight = Color(0xFF2A2C2E);
  static const Color lightShimmerBase = Color(0xFFF9F9FB);
  static const Color darkShimmerBase = Color(0xFF3A3E3F);

  static const Color defaultTextUrl = Colors.lightBlue;
  static const Color defaultBoxShadow = Color(0x140F1C2E);

  // ── Primary / Blue ──────────────────────────────────────────────────────────
  static const Color colorPrimary = Color(0xFF1A6FD4);
  static const Color colorPrimaryMid = Color(0xFF378ADD);
  static const Color colorPrimaryLight = Color(0xFFB5D4F4);
  static const Color colorPrimarySubtle = Color(0xFFE6F1FB);
  static const Color colorPrimaryDark = Color(0xFF185FA5);

  static const Color darkColorPrimary = Color(0xFF1A6FD4);
  static const Color darkColorPrimaryMid = Color(0xFF85B7EB);
  static const Color darkColorPrimaryLight = Color(0xFF0C447C);
  static const Color darkColorPrimarySubtle = Color(0xFF042C53);
  static const Color darkColorPrimaryDark = Color(0xFFB5D4F4);

  // ── Accent / Teal ────────────────────────────────────────────────────────────
  static const Color colorAccent = Color(0xFF1D9E75);
  static const Color colorAccentMid = Color(0xFF5DCAA5);
  static const Color colorAccentLight = Color(0xFF9FE1CB);
  static const Color colorAccentSubtle = Color(0xFFE1F5EE);

  static const Color darkColorAccent = Color(0xFF5DCAA5);
  static const Color darkColorAccentMid = Color(0xFF1D9E75);
  static const Color darkColorAccentLight = Color(0xFF085041);
  static const Color darkColorAccentSubtle = Color(0xFF04342C);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color colorSuccess = Color(0xFF1D9E75);
  static const Color colorWarning = Color(0xFFEF9F27);
  static const Color colorError = Color(0xFFD32F2F);
  static const Color colorInfo = Color(0xFF378ADD);

  static const Color darkColorSuccess = Color(0xFF5DCAA5);
  static const Color darkColorWarning = Color(0xFFFAC775);
  static const Color darkColorError = Color(0xFFD32F2F);
  static const Color darkColorInfo = Color(0xFF85B7EB);

  static const Color successText = Color(0xFF0F6E56);
  static const Color warningText = Color(0xFF854F0B);
  static const Color errorText = Color(0xFFA32D2D);

  // ── Neutral / Surface & Text ─────────────────────────────────────────────────
  static const Color colorBackground = Color(0xFFF5F8FC);
  static const Color colorSurface = Color(0xFFFFFFFF);
  static const Color colorSurfaceVariant = Color(0xFFEDF2F8);
  static const Color colorBorder = Color(0xFFD0DCEA);
  static const Color colorTextPrimary = Color(0xFF111C2D);
  static const Color colorTextSecondary = Color(0xFF4A6380);
  static const Color colorTextDisabled = Color(0xFF9BAFC5);

  static const Color darkColorBackground = Color(0xFF0F1C2E);
  static const Color darkColorSurface = Color(0xFF162436);
  static const Color darkColorSurfaceVariant = Color(0xFF1A2E44);
  static const Color darkColorBorder = Color(0xFF1E3A5F);
  static const Color darkColorTextPrimary = Color(0xFFE8F0FA);
  static const Color darkColorTextSecondary = Color(0xFF7FA8CC);
  static const Color darkColorTextDisabled = Color(0xFF3A5470);

  // ── Status Badge Variants ─────────────────────────────────────────────────────
  static const Color pendingSubtle = Color(0xFFFAEEDA);
  static const Color neutralSubtle = Color(0xFFF1EFE8);
  static const Color neutralIconText = Color(0xFF5F5E5A);
  static const Color darkNeutralSubtle = Color(0xFF2C2C2A);
  static const Color darkNeutralIconText = Color(0xFFB4B2A9);
  static const Color purpleSubtle = Color(0xFFF3E8FF);
  static const Color purpleText = Color(0xFF6B21A8);

  // ── Shadow helpers ───────────────────────────────────────────────────────────
  static const Color shadow = Color(0x140F1C2E);
  static const Color darkShadow = Color(0x1A0F1C2E);

  // ── ColorSchemes ─────────────────────────────────────────────────────────────
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: colorPrimary,
    onPrimary: white,
    primaryContainer: colorPrimarySubtle,
    onPrimaryContainer: colorPrimaryDark,
    secondary: colorAccent,
    onSecondary: white,
    secondaryContainer: colorAccentSubtle,
    onSecondaryContainer: Color(0xFF0F6E56),
    tertiary: colorAccentMid,
    onTertiary: white,
    tertiaryContainer: colorAccentSubtle,
    onTertiaryContainer: colorAccent,
    error: colorError,
    onError: white,
    errorContainer: Color(0xFFFCEBEB),
    onErrorContainer: Color(0xFFA32D2D),
    surface: colorSurface,
    onSurface: colorTextPrimary,
    onSurfaceVariant: colorTextSecondary,
    outline: colorBorder,
    outlineVariant: Color(0xFFE0EAFA),
    shadow: shadow,
    scrim: black,
    inverseSurface: colorTextPrimary,
    inversePrimary: colorPrimaryMid,
    surfaceTint: colorPrimarySubtle,
    surfaceDim: Color(0xFFEDF2F8),
    surfaceBright: colorSurface,
    surfaceContainerLowest: white,
    surfaceContainerLow: Color(0xFFF5F8FC),
    surfaceContainer: colorSurfaceVariant,
    surfaceContainerHigh: Color(0xFFD0DCEA),
    surfaceContainerHighest: Color(0xFFC0CFE0),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkColorPrimary,
    onPrimary: white,
    primaryContainer: darkColorPrimarySubtle,
    onPrimaryContainer: darkColorPrimaryDark,
    secondary: darkColorAccent,
    onSecondary: Color(0xFF04342C),
    secondaryContainer: darkColorAccentSubtle,
    onSecondaryContainer: darkColorAccentLight,
    tertiary: darkColorAccentMid,
    onTertiary: Color(0xFF04342C),
    tertiaryContainer: darkColorAccentSubtle,
    onTertiaryContainer: darkColorAccent,
    error: darkColorError,
    onError: white,
    errorContainer: Color(0xFF501313),
    onErrorContainer: Color(0xFFF09595),
    surface: darkColorSurface,
    onSurface: darkColorTextPrimary,
    onSurfaceVariant: darkColorTextSecondary,
    outline: darkColorBorder,
    outlineVariant: Color(0xFF1A3050),
    shadow: darkShadow,
    scrim: black,
    inverseSurface: darkColorTextPrimary,
    inversePrimary: colorPrimaryMid,
    surfaceTint: darkColorPrimarySubtle,
    surfaceDim: Color(0xFF0A1422),
    surfaceBright: Color(0xFF1A2E44),
    surfaceContainerLowest: Color(0xFF0A1422),
    surfaceContainerLow: darkColorBackground,
    surfaceContainer: darkColorSurfaceVariant,
    surfaceContainerHigh: Color(0xFF1E3A5F),
    surfaceContainerHighest: Color(0xFF253A55),
  );
}

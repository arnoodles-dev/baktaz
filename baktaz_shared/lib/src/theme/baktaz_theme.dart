import 'package:flutter/material.dart';

/// BaktazTheme — DESIGN.md §0.1
///
/// Emerald Green mapped to Flutter's ColorScheme. Single accent, no ThemeExtension for primary colors.
/// Access via `Theme.of(context).colorScheme`.
final class BaktazTheme {
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
  );

  // Not part of ColorScheme — set directly on ThemeData.scaffoldBackgroundColor.
  static const Color canvasLight = Color(0xFFF6F8F7);
  static const Color canvasDark = Color(0xFF0D0F12);
}

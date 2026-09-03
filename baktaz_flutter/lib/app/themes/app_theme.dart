import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

/// App Theme wired to DESIGN.md tokens.
abstract final class AppTheme extends BaseTheme {
  static final ThemeData light = _buildThemeData(BaktazTheme.light);
  static final ThemeData dark = _buildThemeData(BaktazTheme.dark);

  // ── Proxy BaseTheme Constants ────────────────────────────────────────────────
  static const double defaultRadius = ThemeConstants.defaultRadius;
  static const BorderRadius defaultBorderRadius = ThemeConstants.defaultBorderRadius;
  static const BorderRadius cardBorderRadius = ThemeConstants.cardBorderRadius;
  static const BorderRadius buttonBorderRadius = ThemeConstants.buttonBorderRadius;
  static const BorderRadius inputBorderRadius = ThemeConstants.inputBorderRadius;
  static const BorderRadius searchBorderRadius = ThemeConstants.searchBorderRadius;
  static const BorderRadius avatarBorderRadius = ThemeConstants.avatarBorderRadius;
  static const BorderRadius badgeBorderRadius = ThemeConstants.badgeBorderRadius;

  static const Duration animationCardPress = ThemeConstants.animationCardPress;
  static const Duration animationFast = ThemeConstants.animationFast;
  static const Duration animationNormal = ThemeConstants.animationNormal;
  static const Duration animationSlow = ThemeConstants.animationSlow;
  static const Duration animationSkeleton = ThemeConstants.animationSkeleton;
  static const Duration animationStepPulse = ThemeConstants.animationStepPulse;

  static const Curve easeIn = ThemeConstants.easeIn;
  static const Curve easeOut = ThemeConstants.easeOut;
  static const Curve easeInOut = ThemeConstants.easeInOut;

  static List<BoxShadow> shadowLevel1(ColorScheme colorScheme) => ThemeConstants.shadowLevel1(colorScheme);
  static List<BoxShadow> shadowLevel2(ColorScheme colorScheme) => ThemeConstants.shadowLevel2(colorScheme);
  static List<BoxShadow> shadowLevel3(ColorScheme colorScheme) => ThemeConstants.shadowLevel3(colorScheme);

  // ── Layout constants ──────────────────────────────────────────────────────────
  static const double defaultNavBarHeight = 64; // DESIGN.md: 64dp + safe area
  static final double defaultAppBarHeight = AppBar().preferredSize.height;

  static ThemeData _buildThemeData(ColorScheme colorScheme) => BaseTheme.buildBaseTheme(colorScheme);
}

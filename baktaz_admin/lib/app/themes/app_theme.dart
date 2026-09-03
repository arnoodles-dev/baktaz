import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

/// App Theme wired to DESIGN.md tokens.
abstract final class AppTheme extends BaseTheme {
  static final ThemeData light = _buildThemeData(BaktazTheme.light);
  static final ThemeData dark = _buildThemeData(BaktazTheme.dark);

  // ── Proxy BaseTheme Constants ────────────────────────────────────────────────
  static const double defaultRadius = 8;
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(8));
  static final BorderRadius cardBorderRadius = BaktazRadius.card;
  static final BorderRadius buttonBorderRadius = BaktazRadius.chip;
  static const BorderRadius inputBorderRadius = BorderRadius.all(Radius.circular(BaktazRadius.sm));
  static const BorderRadius searchBorderRadius = BorderRadius.all(Radius.circular(BaktazRadius.sm));
  static final BorderRadius avatarBorderRadius = BaktazRadius.pill;
  static final BorderRadius badgeBorderRadius = BaktazRadius.pill;

  static const Duration animationCardPress = Duration(milliseconds: 80);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSkeleton = Duration(milliseconds: 1200);
  static const Duration animationStepPulse = Duration(milliseconds: 1500);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  static List<BoxShadow> shadowLevel1(ColorScheme colorScheme) => BaktazElevation.surface(colorScheme.brightness);
  static List<BoxShadow> shadowLevel2(ColorScheme colorScheme) => BaktazElevation.active(colorScheme.brightness);
  static List<BoxShadow> shadowLevel3(ColorScheme colorScheme) => BaktazElevation.floatingNav(colorScheme.brightness);

  static const double defaultNavBarHeight = 80;
  static final double defaultAppBarHeight = AppBar().preferredSize.height;

  static ThemeData _buildThemeData(ColorScheme colorScheme) {
    final ThemeData baseTheme = BaseTheme.buildBaseTheme(colorScheme);
    final ColorScheme scheme = colorScheme;

    final Color navRailInactiveColor = scheme.onSurfaceVariant.withValues(alpha: 0.38);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerHigh,
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        hintStyle: baseTheme.textTheme.bodyLarge?.copyWith(
          color: navRailInactiveColor,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedLabelTextStyle: baseTheme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
        ),
        unselectedIconTheme: IconThemeData(color: navRailInactiveColor),
        unselectedLabelTextStyle: baseTheme.textTheme.labelMedium?.copyWith(color: navRailInactiveColor),
      ),
    );
  }
}

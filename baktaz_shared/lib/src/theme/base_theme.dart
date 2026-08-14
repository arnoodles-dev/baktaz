import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

/// Base Theme containing shared tokens and component themes across the monorepo.
abstract base class BaseTheme {
  // ── Text Theme ───────────────────────────────────────────────────────────────
  static final TextTheme textTheme = TextTheme(
    displayLarge: AppTextStyle.displayLarge,
    displayMedium: AppTextStyle.displayMedium,
    displaySmall: AppTextStyle.displaySmall,
    headlineLarge: AppTextStyle.headlineLarge,
    headlineMedium: AppTextStyle.headlineMedium,
    headlineSmall: AppTextStyle.headlineSmall,
    titleLarge: AppTextStyle.titleLarge,
    titleMedium: AppTextStyle.titleMedium,
    titleSmall: AppTextStyle.titleSmall,
    bodyLarge: AppTextStyle.bodyLarge,
    bodyMedium: AppTextStyle.bodyMedium,
    bodySmall: AppTextStyle.bodySmall,
    labelLarge: AppTextStyle.labelLarge,
    labelMedium: AppTextStyle.labelMedium,
    labelSmall: AppTextStyle.labelSmall,
  );

  // ── Shared Component Themes ───────────────────────────────────────────────────
  static ThemeData buildBaseTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    const double buttonMinHeight = 48;
    const EdgeInsets buttonHPadding = EdgeInsets.symmetric(horizontal: AppSizes.xLarge);

    return ThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>{if (isDark) BaktazCustomColors.dark else BaktazCustomColors.light},
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shape: const RoundedRectangleBorder(borderRadius: ThemeConstants.buttonBorderRadius),
          padding: buttonHPadding,
          minimumSize: const Size(0, buttonMinHeight),
          elevation: 2,
          shadowColor: colorScheme.shadow,
          textStyle: AppTextStyle.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: buttonHPadding,
          minimumSize: const Size(0, buttonMinHeight),
          textStyle: AppTextStyle.labelLarge,
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: ThemeConstants.buttonBorderRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainer,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: const RoundedRectangleBorder(borderRadius: ThemeConstants.buttonBorderRadius),
          minimumSize: const Size(0, buttonMinHeight),
          elevation: 0,
          padding: buttonHPadding,
          textStyle: AppTextStyle.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: const RoundedRectangleBorder(borderRadius: ThemeConstants.buttonBorderRadius),
          minimumSize: const Size(0, buttonMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.small, vertical: AppSizes.xSmall),
          textStyle: AppTextStyle.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: const OutlineInputBorder(borderRadius: ThemeConstants.inputBorderRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: ThemeConstants.inputBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ThemeConstants.inputBorderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ThemeConstants.inputBorderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ThemeConstants.inputBorderRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.small),
        hintStyle: AppTextStyle.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: AppTextStyle.bodySmall.copyWith(color: colorScheme.error),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeConstants.cardBorderRadius,
          side: BorderSide(color: colorScheme.outline),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTextStyle.titleLarge.copyWith(color: colorScheme.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyle.labelMedium.copyWith(fontWeight: AppFontWeight.semiBold),
        unselectedLabelStyle: AppTextStyle.labelMedium,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.semiBold),
        unselectedLabelStyle: AppTextStyle.titleMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.outline,
        labelStyle: AppTextStyle.labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x2Small),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline, thickness: 1, space: AppSizes.medium),
    );
  }
}

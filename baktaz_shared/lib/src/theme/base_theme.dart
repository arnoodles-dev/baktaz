import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Base Theme containing shared tokens and component themes across the monorepo.
abstract base class BaseTheme {
  // ── Text Theme — uses TextTheme slots (see DESIGN.md §5) ───────────────────────────────────────
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w700, height: 1.47, letterSpacing: -0.15,
    ), // bodyBold
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
    ), // bodyRegular
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
    ), // bodySubtext
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w700, height: 1.47, letterSpacing: -0.15,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 24, fontWeight: FontWeight.w700, height: 1.17, letterSpacing: -0.48,
    ), // brandLockup
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w700, height: 1.47, letterSpacing: -0.15,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, height: 1.47, letterSpacing: -0.15,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w500, height: 1.38, letterSpacing: 0,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.2,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, height: 1.27, letterSpacing: 0.22,
    ), // navLabel
  );

  // ── Shared Component Themes ───────────────────────────────────────────────────
  static ThemeData buildBaseTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    const double buttonMinHeight = 48;
    const EdgeInsets buttonHPadding = EdgeInsets.symmetric(horizontal: BaktazSpacing.xl);

    return ThemeData(
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>{
        if (isDark) BaktazCustomColors.dark else BaktazCustomColors.light,
      },
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
          padding: buttonHPadding,
          minimumSize: const Size(0, buttonMinHeight),
          elevation: 2,
          shadowColor: colorScheme.shadow,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: buttonHPadding,
          minimumSize: const Size(0, buttonMinHeight),
          textStyle: textTheme.labelLarge,
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainer,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
          minimumSize: const Size(0, buttonMinHeight),
          elevation: 0,
          padding: buttonHPadding,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
          minimumSize: const Size(0, buttonMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.small, vertical: BaktazSpacing.xs),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md, vertical: BaktazSpacing.sm),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BaktazRadius.card,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.titleMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.outline,
        labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
        padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1, space: BaktazSpacing.md),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BaktazType — DESIGN.md §0.2
///
/// Custom/display text styles NOT covered by TextTheme.
/// Common styles use Theme.of(context).textTheme.* (see §5 theming).
final class BaktazType {
  BaktazType._();

  // ── Custom/Display (no TextTheme equivalent) ──────────────────────────────

  static TextStyle displayHero(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 44, fontWeight: FontWeight.w700, height: 1.09,
        letterSpacing: -1.32, color: color,
      );

  static TextStyle metricHero(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w700, height: 1.1,
        letterSpacing: -0.8, color: color,
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

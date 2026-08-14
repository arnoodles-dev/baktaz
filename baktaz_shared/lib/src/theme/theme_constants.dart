import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

abstract final class ThemeConstants {
  // ── Radius constants (DESIGN.md) ──────────────────────────────────────────────
  static const double defaultRadius = AppSizes.radiusMedium;
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(defaultRadius));
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusSmall));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusFull));
  static const BorderRadius inputBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusXSmall));
  static const BorderRadius searchBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusFull));
  static const BorderRadius avatarBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusFull));
  static const BorderRadius badgeBorderRadius = BorderRadius.all(Radius.circular(AppSizes.radiusFull));

  // ── Animation constants (DESIGN.md §8 & §9) ──────────────────────────────────
  static const Duration animationCardPress = Duration(milliseconds: 80);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSkeleton = Duration(milliseconds: 1200);
  static const Duration animationStepPulse = Duration(milliseconds: 1500);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  // ── Shadow helpers (DESIGN.md §6) ────────────────────────────────────────────
  /// Level 1 — default card (DESIGN.md §6: rgba(15,28,46,0.06))
  static List<BoxShadow> shadowLevel1(ColorScheme cs) => <BoxShadow>[
    BoxShadow(color: cs.shadow.withValues(alpha: 0.06), offset: const Offset(0, 1), blurRadius: 3),
  ];

  /// Level 2 — focused card, bottom sheet (DESIGN.md §6: rgba(15,28,46,0.08))
  static List<BoxShadow> shadowLevel2(ColorScheme cs) => <BoxShadow>[
    BoxShadow(color: cs.shadow.withValues(alpha: 0.08), offset: const Offset(0, 4), blurRadius: 12),
  ];

  /// Level 3 — modal dialogs (DESIGN.md §6: rgba(15,28,46,0.12))
  static List<BoxShadow> shadowLevel3(ColorScheme cs) => <BoxShadow>[
    BoxShadow(color: cs.shadow.withValues(alpha: 0.12), offset: const Offset(0, 8), blurRadius: 24),
  ];
}

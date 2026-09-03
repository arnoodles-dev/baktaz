import 'package:flutter/material.dart';

/// Elevation / shadow tokens — DESIGN.md §0.5.
///
/// Light mode: soft ambient `BoxShadow`.
/// Dark mode: 1dp hairline border (via spread) plus, on accent-bearing
/// surfaces, a colored glow.
abstract final class BaktazElevation {
  BaktazElevation._();

  // ── Animation Durations (DESIGN.md §0.5) ─────────────────────────────────────
  static const Duration animationCardPress = Duration(milliseconds: 80);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSkeleton = Duration(milliseconds: 1200);
  static const Duration animationStepPulse = Duration(milliseconds: 1500);

  // ── Curves ────────────────────────────────────────────────────────────────────
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  // ── Shadows ────────────────────────────────────────────────────────────────────
  /// Light mode uses a soft ambient `BoxShadow`; dark mode swaps it for a 1dp
  /// hairline border (via spread) plus, on accent-bearing surfaces, a colored glow.
  static List<BoxShadow> surface(Brightness b) => b == Brightness.light
      ? <BoxShadow>[
          const BoxShadow(
            color: Color(0x0A0D1117),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ]
      : <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.04),
            spreadRadius: 1,
          ),
        ];

  static List<BoxShadow> active(Brightness b) => b == Brightness.light
      ? <BoxShadow>[
          const BoxShadow(
            color: Color(0x3810B981),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ]
      : <BoxShadow>[
          const BoxShadow(
            color: Color(0x3834D399),
            blurRadius: 24,
          ),
        ];

  static List<BoxShadow> floatingNav(Brightness b) => b == Brightness.light
      ? <BoxShadow>[
          const BoxShadow(
            color: Color(0x1A0D1117),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ]
      : <BoxShadow>[
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ];

  static List<BoxShadow> fab(Brightness b) => b == Brightness.light
      ? <BoxShadow>[
          const BoxShadow(
            color: Color(0x5910B981),
            blurRadius: 20,
          ),
        ]
      : <BoxShadow>[
          const BoxShadow(
            color: Color(0x7334D399),
            blurRadius: 20,
          ),
        ];
}

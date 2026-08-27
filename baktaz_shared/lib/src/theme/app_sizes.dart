/// Size & radius tokens — aligned to DESIGN.md.
abstract final class AppSizes {
  static const double zero = 0;

  // Spacing (2–48 named; beyond 48 use Gap.custom())
  static const double x3Small = 2;
  static const double x2Small = 4;
  static const double xSmall = 8;
  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xLarge = 24;
  static const double x2Large = 32;
  static const double x3Large = 40;
  static const double x4Large = 48;
  static const double screenMarginH = 16;

  // ponytail: legacy semantic aliases/sizes kept for call-site compatibility.
  static const double size20 = 20;
  static const double size26 = 26;
  static const double size36 = 36;
  static const double size56 = 56;
  static const double size60 = 60;
  static const double size72 = 72;
  static const double size80 = 80;
  static const double size96 = 96;
  static const double size128 = 128;
  static const double infinity = double.infinity;

  // Border radius
  static const double radiusNone = 0;
  static const double radiusX2Small = 4;
  static const double radiusXSmall = 8;
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusXLarge = 24;
  static const double radiusX2Large = 36;
  static const double radiusFull = 999;

  // Icon sizes
  static const double iconXSmall = 16;
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // Avatar sizes — DESIGN.md §12.8
  static const double avatarXS = 24;
  static const double avatarSM = 36;
  static const double avatarMD = 44;
  static const double avatarLG = 64;
  static const double avatarXL = 88;

  static const double badgeMinSize = 20;

  // Component sizes — see DESIGN.md §component-sizes
  static const double dialogWidth = 400;
  static const double tableSearchWidth = 240;
  static const double chartHeightLarge = 250;
  static const double chartHeightMedium = 200;
  static const double chartBarAreaHeight = 120;
}

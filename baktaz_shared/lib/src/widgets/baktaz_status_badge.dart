import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/theme/app_text_style.dart';
import 'package:baktaz_shared/src/theme/baktaz_custom_colors.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StatusBadge — DESIGN.md §12.5
///
/// Always combines background + icon + label. Never color alone.
/// Colors resolve from `context.baktazColors` (ThemeExtension) — light/dark aware.
class BaktazStatusBadge extends StatelessWidget {
  const BaktazStatusBadge({required this.label, required this.variant, super.key});

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color textColor, IconData icon) = _resolveTokens(context);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x2Small, horizontal: AppSizes.xSmall),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: textColor),
          const Gap(AppSizes.x2Small),
          BaktazText(
            text: label,
            style: AppTextStyle.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _resolveTokens(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BaktazCustomColors customColors =
        Theme.of(context).extension<BaktazCustomColors>() ?? BaktazCustomColors.light;

    return switch (variant) {
      StatusBadgeVariant.available => (colorScheme.secondaryContainer, customColors.successOnContainer, Icons.verified),
      StatusBadgeVariant.confirmed => (
        colorScheme.secondaryContainer,
        customColors.successOnContainer,
        Icons.check_circle,
      ),
      StatusBadgeVariant.active => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer, Icons.refresh),
      StatusBadgeVariant.pending => (customColors.badgePendingBg, customColors.badgePendingText, Icons.access_time),
      StatusBadgeVariant.failed => (colorScheme.errorContainer, colorScheme.onErrorContainer, Icons.cancel),
      StatusBadgeVariant.neutral => (customColors.badgeNeutralBg, customColors.badgeNeutralText, Icons.pause),
    };
  }
}

enum StatusBadgeVariant { available, confirmed, active, pending, failed, neutral }

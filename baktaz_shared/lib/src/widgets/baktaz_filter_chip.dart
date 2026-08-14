import 'package:baktaz_shared/src/theme/app_colors.dart';
import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// FilterChip — DESIGN.md §12.4
///
/// Chips scroll horizontally. Gap between chips: xSmall.
class BaktazFilterChip extends StatelessWidget {
  const BaktazFilterChip({required this.label, required this.isActive, this.onTap, super.key});

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.xSmall),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
          ),
          child: Center(
            child: BaktazText(
              text: label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

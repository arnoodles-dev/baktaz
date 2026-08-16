import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// ProgressBar — DESIGN.md §12.6
///
/// Used for availability percentages, booking completion, upload progress.
/// Always teal for positive progress, colorError for critical/overdue states.
class BaktazProgressBar extends StatelessWidget {
  const BaktazProgressBar({
    required this.progress,
    this.label,
    this.isCritical = false,
    this.height = 5,
    super.key,
  });

  final double progress;
  final String? label;
  final bool isCritical;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fillColor = isCritical ? theme.colorScheme.error : theme.colorScheme.secondary;
    final Color trackColor = isCritical ? theme.colorScheme.errorContainer : theme.colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
          child: Stack(
            children: <Widget>[
              Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label case final String effectiveLabel) ...<Widget>[
          const Gap(AppSizes.x2Small),
          BaktazText(
            text: effectiveLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCritical ? theme.colorScheme.error : theme.colorScheme.secondary,
            ),
          ),
        ],
      ],
    );
  }
}

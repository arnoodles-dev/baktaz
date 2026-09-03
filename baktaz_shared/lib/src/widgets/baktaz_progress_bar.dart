import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// ProgressBar — DESIGN.md §1.7
///
/// Determinate linear progress bar with brand color fill.
class BaktazProgressBar extends StatelessWidget {
  const BaktazProgressBar({required this.progress, this.label, this.isCritical = false, this.height = 8, super.key});

  final double progress;
  final String? label;
  final bool isCritical;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fillColor = isCritical ? scheme.error : scheme.primary;
    final Color trackColor = isCritical ? scheme.errorContainer : scheme.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BaktazRadius.pill,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
          ),
        ),
        if (label case final String effectiveLabel) ...<Widget>[
          const SizedBox(height: BaktazSpacing.xs2),
          BaktazText(
            text: effectiveLabel,
            style: theme.textTheme.labelSmall?.copyWith(color: isCritical ? scheme.error : scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StageProgressBar — DESIGN.md §1.9
///
/// Progress bar with label showing day X of Y (Z%).
/// Track: outlineVariant, fill: primary if <100%, primaryContainer if exceeded.
class BaktazStageProgressBar extends StatelessWidget {
  const BaktazStageProgressBar({
    required this.currentDay,
    required this.totalDays,
    this.height = 8,
    super.key,
  });

  final int currentDay;
  final int totalDays;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    
    final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final bool exceeded = currentDay > totalDays;
    final int percentage = (progress * 100).round();
    
    final String label = 'Day $currentDay of $totalDays ($percentage%)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BaktazRadius.pill,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: scheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              exceeded ? scheme.primaryContainer : scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: BaktazSpacing.xs2),
        BaktazText(
          text: label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

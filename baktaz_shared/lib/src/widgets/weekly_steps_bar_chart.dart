import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// WeeklyStepsBarChart — DESIGN.md §2.7
///
/// 7-day vertical bar chart showing daily step counts.
class WeeklyStepsBarChart extends StatelessWidget {
  const WeeklyStepsBarChart({
    required this.dailySteps,
    this.barWidth = 32,
    this.barSpacing = BaktazSpacing.xs,
    this.showLabels = true,
    this.showValues = false,
    super.key,
  });

  final List<int> dailySteps;
  final double barWidth;
  final double barSpacing;
  final bool showLabels;
  final bool showValues;

  static const List<String> _dayLabels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  int get _maxSteps {
    if (dailySteps.isEmpty) return 1;
    final int max = dailySteps.reduce((int a, int b) => a > b ? a : b);
    return max > 0 ? max : 1;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final List<int> displaySteps = dailySteps.length >= 7
        ? dailySteps.sublist(0, 7)
        : <int>[...dailySteps, ...List<int>.filled(7 - dailySteps.length, 0)];

    final int todayIndex = DateTime.now().weekday - 1; // 0 = Monday

    return SizedBox(
      height: BaktazSpacing.chartBarAreaHeight + BaktazSpacing.xl3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(7, (int i) {
          final int steps = displaySteps[i];
          final double normalizedHeight = _maxSteps > 0
              ? (steps / _maxSteps) * BaktazSpacing.chartBarAreaHeight
              : 0.0;
          final bool isToday = i == todayIndex;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (showValues && steps > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: BaktazSpacing.xs2),
                  child: BaktazText(
                    text: _formatSteps(steps),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Container(
                width: barWidth,
                height: normalizedHeight.clamp(4.0, BaktazSpacing.chartBarAreaHeight),
                decoration: BoxDecoration(
                  color: isToday ? scheme.primaryContainer : scheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(BaktazSpacing.sm),
                    topRight: Radius.circular(BaktazSpacing.sm),
                  ),
                ),
              ),
              if (showLabels) ...<Widget>[
                const SizedBox(height: BaktazSpacing.xs),
                BaktazText(
                  text: _dayLabels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }
}

import 'dart:math' as math;

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class ActivitiesOverviewChart extends StatelessWidget {
  const ActivitiesOverviewChart({
    required this.data,
    required this.selectedFilter,
    required this.selectedTimeFilter,
    required this.onFilterChanged,
    required this.onTimeFilterChanged,
    this.isLoading = false,
    super.key,
  });

  final List<DailyActivityStats> data;
  final bool isLoading;
  final ActivityFilter selectedFilter;
  final TimeFilter selectedTimeFilter;
  final ValueChanged<ActivityFilter> onFilterChanged;
  final ValueChanged<TimeFilter> onTimeFilterChanged;

  static double _computeMaxY(List<DailyActivityStats> items) {
    double maxDataValue = 0;
    for (final DailyActivityStats stat in items) {
      final double inProgress = stat.inProgress.getValue().toDouble();
      final double completed = stat.completed.getValue().toDouble();
      maxDataValue = math.max(maxDataValue, math.max(inProgress, completed));
    }
    return maxDataValue > 0 ? maxDataValue * 1.2 : 10.0;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.textTheme;
    final ColorScheme colorScheme = context.colorScheme;

    final double calculatedMaxY = _computeMaxY(data);
    final double gridInterval = (calculatedMaxY / 4).ceilToDouble();
    final double horizontalInterval = gridInterval > 0 ? gridInterval : 10.0;

    return Container(
      padding: const EdgeInsets.all(BaktazSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.md)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              BaktazText(
                text: context.i18n.dashboard.overview.title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Gap.medium(),
              Expanded(
                child: RepaintBoundary(
                  child: Wrap(
                    spacing: BaktazSpacing.sm,
                    runSpacing: BaktazSpacing.sm,
                    children: ActivityFilter.values.map((ActivityFilter filter) {
                      final bool isSelected = selectedFilter == filter;
                      return ActionChip(
                        label: BaktazText(text: filter.label),
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
                        side: BorderSide(color: isSelected ? colorScheme.primary : colorScheme.outlineVariant),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.xl)),
                        ),
                        onPressed: () => onFilterChanged(filter),
                      );
                    }).toList(),
                  ),
                ),
              ),
              DropdownButton<TimeFilter>(
                value: selectedTimeFilter,
                items: TimeFilter.values
                    .map(
                      (TimeFilter e) => DropdownMenuItem<TimeFilter>(
                        value: e,
                        child: BaktazText(text: e.label, style: textTheme.labelMedium),
                      ),
                    )
                    .toList(),
                onChanged: (TimeFilter? val) {
                  if (val != null) {
                    onTimeFilterChanged(val);
                  }
                },
                underline: const SizedBox(),
                icon: BaktazIcon(icon: right(Icons.arrow_drop_down), size: 16),
              ),
            ],
          ),
          Gap.medium(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _LegendItem(label: context.i18n.dashboard.overview.in_progress, color: colorScheme.primary),
              Gap.medium(),
              _LegendItem(label: context.i18n.dashboard.overview.completed, color: colorScheme.secondary),
            ],
          ),
          Gap.large(),
          RepaintBoundary(
            child: SizedBox(
              height: BaktazSpacing.chartHeightLarge,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: calculatedMaxY,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.toInt();
                          String label = '';
                          if (selectedTimeFilter == TimeFilter.today) {
                            const List<String> times = <String>['12am', '4am', '8am', '12pm', '4pm', '8pm'];
                            if (index >= 0 && index < times.length) {
                              label = times[index];
                            }
                          } else if (selectedTimeFilter == TimeFilter.last7Days) {
                            const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            label = days[index % days.length];
                          } else if (selectedTimeFilter == TimeFilter.last30Days) {
                            const List<String> weeks = <String>['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                            if (index >= 0 && index < weeks.length) {
                              label = weeks[index];
                            }
                          }

                          return Padding(
                            padding: Paddings.topXSmall,
                            child: BaktazText(
                              text: label,
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: horizontalInterval,
                    getDrawingHorizontalLine: (double value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: <int>[4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: isLoading
                      ? <BarChartGroupData>[]
                      : data
                            .map(
                              (DailyActivityStats stat) => _buildBarGroup(
                                stat.dayIndex.getValue().toInt(),
                                stat.inProgress.getValue().toDouble(),
                                stat.completed.getValue().toDouble(),
                                colorScheme,
                              ),
                            )
                            .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int groupIndex, double val1, double val2, ColorScheme colorScheme) =>
      BarChartGroupData(
        x: groupIndex,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: val1,
            color: colorScheme.primary,
            width: 12,
            borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
          ),
          BarChartRodData(
            toY: val2,
            color: colorScheme.secondary,
            width: 12,
            borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
          ),
        ],
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        ),
      ),
      Gap.xSmall(),
      BaktazText(
        text: label,
        style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

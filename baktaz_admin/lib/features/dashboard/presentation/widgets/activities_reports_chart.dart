import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class ActivitiesReportsChart extends StatelessWidget {
  const ActivitiesReportsChart({
    required this.data,
    required this.selectedStatusFilter,
    required this.onStatusFilterChanged,
    super.key,
  });

  final CategoryReportStats data;
  final ActivityStatusFilter selectedStatusFilter;
  final ValueChanged<ActivityStatusFilter> onStatusFilterChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.textTheme;
    final ColorScheme colorScheme = context.colorScheme;

    final num total = data.hero.getValue() + data.express.getValue() + data.shop.getValue() + data.buy.getValue();

    return Container(
      padding: Paddings.allLarge,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              BaktazText(
                text: context.i18n.dashboard.reports.title,
                style: textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
              ),
              DropdownButton<ActivityStatusFilter>(
                value: selectedStatusFilter,
                items: ActivityStatusFilter.values
                    .map(
                      (ActivityStatusFilter e) => DropdownMenuItem<ActivityStatusFilter>(
                        value: e,
                        child: BaktazText(text: e.label, style: textTheme.labelMedium),
                      ),
                    )
                    .toList(),
                onChanged: (ActivityStatusFilter? val) {
                  if (val != null) {
                    onStatusFilterChanged(val);
                  }
                },
                underline: const SizedBox(),
                icon: BaktazIcon(icon: right(Icons.arrow_drop_down), size: 16),
              ),
            ],
          ),
          Gap.xLarge(),
          RepaintBoundary(
            child: SizedBox(
              height: 200,
              child: Stack(
                children: <Widget>[
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 70,
                      sections: _buildPieChartSections(colorScheme, total),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        BaktazText(
                          text: total.toInt().toString(),
                          style: textTheme.displayMedium?.copyWith(
                            fontWeight: AppFontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        BaktazText(
                          text: context.i18n.dashboard.reports.activities.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: AppFontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap.xLarge(),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LegendItem(
                      label: 'Hero',
                      value: data.hero.getValue().toString(),
                      color: colorScheme.primary,
                    ),
                  ),
                  Gap.medium(),
                  Expanded(
                    child: _LegendItem(
                      label: 'Express',
                      value: data.express.getValue().toString(),
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              Gap.medium(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LegendItem(
                      label: 'Shop',
                      value: data.shop.getValue().toString(),
                      color: colorScheme.secondary,
                    ),
                  ),
                  Gap.medium(),
                  Expanded(
                    child: _LegendItem(label: 'Buy', value: data.buy.getValue().toString(), color: colorScheme.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(ColorScheme colorScheme, num total) {
    if (total == 0) return <PieChartSectionData>[];

    return <PieChartSectionData>[
      PieChartSectionData(
        color: colorScheme.primary,
        value: (data.hero.getValue() / total) * 100,
        title: '',
        radius: 12,
      ),
      PieChartSectionData(
        color: colorScheme.tertiary,
        value: (data.express.getValue() / total) * 100,
        title: '',
        radius: 12,
      ),
      PieChartSectionData(
        color: colorScheme.secondary,
        value: (data.shop.getValue() / total) * 100,
        title: '',
        radius: 12,
      ),
      PieChartSectionData(color: colorScheme.error, value: (data.buy.getValue() / total) * 100, title: '', radius: 12),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      Gap.small(),
      Expanded(
        child: BaktazText(
          text: label,
          style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
      BaktazText(
        text: value,
        style: context.textTheme.labelMedium?.copyWith(fontWeight: AppFontWeight.bold),
      ),
    ],
  );
}

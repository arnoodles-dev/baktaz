import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeWeeklyChartHeader extends StatelessWidget {
  const HomeWeeklyChartHeader({required this.averageSteps, super.key});

  final int averageSteps;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BaktazText(
            text: context.i18n.home.weekly_activity,
            style: context.textTheme.titleMedium,
          ),
          BaktazText(
            text: context.i18n.home.weekly_avg(
              avg: StepFormatter.formatSteps(averageSteps, includeUnit: false),
            ),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}

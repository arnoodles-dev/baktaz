import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeWeeklyTotalFooter extends StatelessWidget {
  const HomeWeeklyTotalFooter({required this.totalWeeklySteps, super.key});

  final int totalWeeklySteps;

  @override
  Widget build(BuildContext context) => Center(
    child: BaktazText(
      text: context.i18n.home.weekly_total(total: StepFormatter.formatSteps(totalWeeklySteps, includeUnit: false)),
      style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
    ),
  );
}

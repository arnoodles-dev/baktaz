import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeDailyStepHeader extends StatelessWidget {
  const HomeDailyStepHeader({required this.currentSteps, required this.goalSteps, super.key});

  final int currentSteps;
  final int goalSteps;

  @override
  Widget build(BuildContext context) {
    final double percentage = goalSteps > 0 ? (currentSteps / goalSteps) : 0.0;
    final String formattedPercentage = (percentage * 100).toStringAsFixed(1);
    final String formattedGoal = StepFormatter.formatSteps(goalSteps, includeUnit: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BaktazText(text: context.i18n.home.todays_steps),
        Gap.small(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            BaktazText(text: StepFormatter.formatSteps(currentSteps), style: context.textTheme.headlineLarge),
            BaktazText(
              text: context.i18n.home.goal_percentage(percentage: formattedPercentage, goal: formattedGoal),
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}

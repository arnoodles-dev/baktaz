import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeWeeklyBarItem extends StatelessWidget {
  const HomeWeeklyBarItem({
    required this.steps,
    required this.dayLabel,
    required this.goalTarget,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final int steps;
  final String dayLabel;
  final int goalTarget;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isGoalMet = steps >= goalTarget;
    final double barHeight = (steps / 15000 * 100).clamp(10.0, 100.0);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (isSelected)
            Container(
              padding: Paddings.allSmall,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: BaktazText(text: StepFormatter.formatSteps(steps, includeUnit: false)),
            ),
          Container(
            width: 20,
            height: barHeight,
            decoration: BoxDecoration(
              color: isGoalMet
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          Gap.small(),
          BaktazText(text: dayLabel),
        ],
      ),
    );
  }
}

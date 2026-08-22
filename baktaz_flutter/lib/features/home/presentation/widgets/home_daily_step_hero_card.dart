import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_linear_gauge.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_sync_footer.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeDailyStepHeroCard extends StatelessWidget {
  const HomeDailyStepHeroCard({
    required this.currentSteps,
    required this.goalSteps,
    required this.syncSource,
    required this.lastSyncedText,
    required this.onRefresh,
    super.key,
  });

  final int currentSteps;
  final int goalSteps;
  final String syncSource;
  final String lastSyncedText;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final bool isGoalAchieved = currentSteps >= goalSteps && goalSteps > 0;

    return AnimatedScale(
      scale: isGoalAchieved ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
          border: Border.all(
            color: isGoalAchieved ? context.colorScheme.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: BaktazCard(
          body: Padding(
            padding: Paddings.allLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HomeDailyStepHeader(currentSteps: currentSteps, goalSteps: goalSteps),
                Gap.small(),
                HomeDailyStepLinearGauge(currentSteps: currentSteps, goalSteps: goalSteps),
                Gap.medium(),
                HomeDailyStepSyncFooter(
                  syncSource: syncSource,
                  lastSyncedText: lastSyncedText,
                  onRefresh: onRefresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

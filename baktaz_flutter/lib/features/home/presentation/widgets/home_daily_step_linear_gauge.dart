import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeDailyStepLinearGauge extends StatelessWidget {
  const HomeDailyStepLinearGauge({required this.currentSteps, required this.goalSteps, super.key});

  final int currentSteps;
  final int goalSteps;

  @override
  Widget build(BuildContext context) {
    final double rawProgress = goalSteps > 0 ? (currentSteps / goalSteps) : 0.0;
    final double clampedProgress = rawProgress.clamp(0.0, 1.0);

    return BaktazProgressBar(progress: clampedProgress);
  }
}

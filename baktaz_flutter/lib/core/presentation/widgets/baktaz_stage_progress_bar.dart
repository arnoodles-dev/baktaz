import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazStageProgressBar extends StatelessWidget {
  const BaktazStageProgressBar({required this.currentDay, required this.totalDays, super.key});

  final int currentDay;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final double progress = totalDays > 0 ? (currentDay / totalDays).clamp(0.0, 1.0) : 0.0;
    final int remainingDays = (totalDays - currentDay).clamp(0, totalDays);
    final int percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            BaktazText(text: 'Day $currentDay of $totalDays ($percent%)', style: Theme.of(context).textTheme.bodySmall),
            BaktazText(text: '$remainingDays Days Remaining', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Gap.small(),
        LinearProgressIndicator(value: progress),
      ],
    );
  }
}

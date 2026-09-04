import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeLeaderboardRow extends StatelessWidget {
  const HomeLeaderboardRow({
    required this.rank,
    required this.username,
    required this.steps,
    required this.avgSteps,
    required this.trend,
    required this.maxSteps,
    this.avatarUrl,
    this.isCurrent = false,
    super.key,
  });

  final int rank;
  final String username;
  final int steps;
  final String avgSteps;
  final String trend;
  final int maxSteps;
  final String? avatarUrl;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final double relativeProgress = maxSteps > 0 ? (steps / maxSteps).clamp(0.0, 1.0) : 0.0;
    final String rankPrefix = isCurrent ? '📍 #$rank' : '#$rank';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(width: 45, child: BaktazText(text: rankPrefix)),
          BaktazAvatar(size: BaktazAvatar.sizeXS, imageUrl: avatarUrl),
          Gap.small(),
          SizedBox(width: 70, child: BaktazText(text: username)),
          SizedBox(width: 30, child: RankTrend(change: trend == 'up' ? 1 : (trend == 'down' ? -1 : 0))),
          Expanded(child: LinearProgressIndicator(value: relativeProgress)),
          Gap.small(),
          SizedBox(width: 70, child: BaktazText(text: StepFormatter.formatSteps(steps, includeUnit: false))),
          SizedBox(width: 45, child: BaktazText(text: avgSteps)),
        ],
      ),
    );
  }
}

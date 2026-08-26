import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_leaderboard_row.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeLeaderboardPreview extends StatelessWidget {
  const HomeLeaderboardPreview({required this.topEntries, required this.onViewFull, this.currentUserEntry, super.key});

  final List<LeaderboardEntry> topEntries;
  final LeaderboardEntry? currentUserEntry;
  final VoidCallback onViewFull;

  @override
  Widget build(BuildContext context) {
    final int topSteps = topEntries.isNotEmpty ? topEntries.first.steps : 1;

    return BaktazCard(
      body: Padding(
        padding: Paddings.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BaktazText(text: context.i18n.home.leaderboard.title),
                BaktazButton(
                  buttonType: BaktazButtonType.text,
                  text: context.i18n.home.leaderboard.view_full,
                  onPressed: onViewFull,
                ),
              ],
            ),
            Gap.medium(),
            ...topEntries.map(
              (LeaderboardEntry e) => HomeLeaderboardRow(
                rank: e.rank,
                username: e.username,
                steps: e.steps,
                avgSteps: e.avgSteps,
                trend: e.trend,
                maxSteps: topSteps,
                avatarUrl: e.avatarUrl,
              ),
            ),
            if (currentUserEntry != null && currentUserEntry!.rank > topEntries.length) ...<Widget>[
              const BaktazDivider(),
              HomeLeaderboardRow(
                rank: currentUserEntry!.rank,
                username: currentUserEntry!.username,
                steps: currentUserEntry!.steps,
                avgSteps: currentUserEntry!.avgSteps,
                trend: currentUserEntry!.trend,
                maxSteps: topSteps,
                avatarUrl: currentUserEntry!.avatarUrl,
                isCurrent: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.steps,
    required this.avgSteps,
    required this.trend,
    this.avatarUrl,
  });

  final int rank;
  final String username;
  final int steps;
  final String avgSteps;
  final String trend;
  final String? avatarUrl;
}

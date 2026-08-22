import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_leaders_strip.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_rank_badge.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_stage_progress_bar.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_challenge_discovery_banner.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeActiveChallengeTicker extends StatelessWidget {
  const HomeActiveChallengeTicker({
    required this.isEnrolled,
    required this.onOpenChallenge,
    this.title,
    this.rank,
    this.totalParticipants,
    this.prizePoolText,
    this.gapText,
    this.leaders,
    this.currentDay,
    this.totalDays,
    super.key,
  });

  final bool isEnrolled;
  final String? title;
  final int? rank;
  final int? totalParticipants;
  final String? prizePoolText;
  final String? gapText;
  final List<String>? leaders;
  final int? currentDay;
  final int? totalDays;
  final VoidCallback onOpenChallenge;

  @override
  Widget build(BuildContext context) {
    if (!isEnrolled) {
      return HomeChallengeDiscoveryBanner(onOpenChallenge: onOpenChallenge);
    }

    return BaktazCard(
      body: Padding(
        padding: Paddings.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BaktazText(text: '🏆 ${title ?? ""}'),
                BaktazText(
                  text: context.i18n.home.active_challenge.rank_label(rank: rank ?? 0, total: totalParticipants ?? 0),
                ),
              ],
            ),
            if (prizePoolText != null) ...<Widget>[
              Gap.small(),
              BaktazText(text: context.i18n.home.active_challenge.prize_pool(amount: prizePoolText!)),
            ],
            const BaktazDivider(),
            Row(
              children: <Widget>[
                BaktazRankBadge(rank: rank ?? 0),
                Gap.medium(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (gapText != null) BaktazText(text: gapText!),
                      Gap.small(),
                      if (leaders != null) BaktazLeadersStrip(leaders: leaders!),
                    ],
                  ),
                ),
              ],
            ),
            const BaktazDivider(),
            BaktazStageProgressBar(currentDay: currentDay ?? 0, totalDays: totalDays ?? 0),
            Gap.medium(),
            BaktazButton(text: context.i18n.home.active_challenge.go_to_btn, onPressed: onOpenChallenge),
          ],
        ),
      ),
    );
  }
}

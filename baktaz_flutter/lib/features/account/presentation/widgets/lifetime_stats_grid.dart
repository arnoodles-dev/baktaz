import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// LifetimeStatsGrid — DESIGN.md §2.1
///
/// 4-column stats grid showing challengeStepsTotal, challengesJoined, challengesWon, avgStepsPerDay.
class LifetimeStatsGrid extends StatelessWidget {
  const LifetimeStatsGrid({
    required this.isLoading,
    required this.challengeStepsTotal,
    required this.challengesJoined,
    required this.challengesWon,
    required this.avgStepsPerDay,
    super.key,
  });

  final bool isLoading;
  final int challengeStepsTotal;
  final int challengesJoined;
  final int challengesWon;
  final int avgStepsPerDay;

  @override
  Widget build(BuildContext context) => Skeletonizer(
        enabled: isLoading,
        child: Padding(
          padding: Paddings.screenMarginH,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  value: _formatNumber(challengeStepsTotal),
                  label: context.i18n.account.lifetime_stats_grid.challenge_steps,
                ),
              ),
              Gap.medium(),
              Expanded(
                child: _StatCard(
                  value: _formatNumber(challengesJoined),
                  label: context.i18n.account.lifetime_stats_grid.challenges_joined,
                ),
              ),
              Gap.medium(),
              Expanded(
                child: _StatCard(
                  value: _formatNumber(challengesWon),
                  label: context.i18n.account.lifetime_stats_grid.challenges_won,
                ),
              ),
              Gap.medium(),
              Expanded(
                child: _StatCard(
                  value: _formatNumber(avgStepsPerDay),
                  label: context.i18n.account.lifetime_stats_grid.avg_steps_per_day,
                ),
              ),
            ],
          ),
        ),
      );

  String _formatNumber(int number) => number >= 1000
      ? '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}K'
      : number.toString();
}


class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => BaktazCard(
        body: Padding(
          padding: Paddings.allMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: value,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Gap.xSmall(),
              BaktazText(
                text: label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
}

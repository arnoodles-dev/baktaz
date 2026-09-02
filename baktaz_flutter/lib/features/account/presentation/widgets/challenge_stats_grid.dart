import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChallengeStatsGrid extends StatelessWidget {
  const ChallengeStatsGrid({
    required this.isLoading,
    required this.totalSteps,
    required this.challengesJoined,
    required this.challengesWon,
    required this.winRatePercentage,
    super.key,
  });

  final bool isLoading;
  final int totalSteps;
  final int challengesJoined;
  final int challengesWon;
  final double winRatePercentage;

  @override
  Widget build(BuildContext context) => Padding(
        padding: Paddings.horizontalMedium,
        child: Skeletonizer(
          enabled: isLoading,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  number: '$totalSteps',
                  label: context.l10n.account.total_steps,
                ),
              ),
              const Gap(AppSizes.small),
              Expanded(
                child: _StatCard(
                  number: '$challengesJoined',
                  label: context.l10n.account.challenges_joined,
                ),
              ),
              const Gap(AppSizes.small),
              Expanded(
                child: _StatCard(
                  number: '$challengesWon',
                  label: context.l10n.account.challenges_won,
                ),
              ),
              const Gap(AppSizes.small),
              Expanded(
                child: _StatCard(
                  number: '${(winRatePercentage.isFinite ? winRatePercentage : 0.0).toStringAsFixed(1)}%',
                  label: context.l10n.account.win_rate,
                ),
              ),
            ],
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => BaktazCard(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BaktazText(
              text: number,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppFontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Gap.x2Small(),
            BaktazText(
              text: label,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}

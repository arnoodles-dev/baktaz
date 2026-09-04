import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_hero_card.dart';
import 'package:baktaz_flutter/features/steps/domain/cubit/steps_analytics/steps_analytics_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeStepSection extends StatelessWidget {
  const HomeStepSection({
    required this.state,
    required this.onRefresh,
    this.onConnect,
    super.key,
  });

  final StepsAnalyticsState state;
  final VoidCallback onRefresh;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final DailyStepTelemetry? telemetry = state.dailyTelemetry;

    if (telemetry == null) {
      return _DisconnectedCta(onConnect: onConnect ?? () {});
    }

    return HomeDailyStepHeroCard(
      currentSteps: telemetry.currentSteps.getValue().toInt(),
      goalSteps: telemetry.goalSteps.getValue().toInt(),
      syncSource: telemetry.syncSource.getValue(),
      lastSyncedText: telemetry.lastSyncedAt.value.toLocal().toString().split(' ').first,
      onRefresh: onRefresh,
    );
  }
}

class _DisconnectedCta extends StatelessWidget {
  const _DisconnectedCta({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BaktazCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(
            text: context.i18n.steps.connect_health,
            style: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
          ),
          Gap.small(),
          BaktazText(
            text: context.i18n.steps.connect_desc,
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Gap.medium(),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: BaktazButton(
              onPressed: onConnect,
              text: context.i18n.steps.connect_health,
            ),
          ),
        ],
      ),
    );
  }
}

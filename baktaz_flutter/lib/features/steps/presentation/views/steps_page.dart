import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_hero_card.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_steps_chart.dart';
import 'package:baktaz_flutter/features/steps/config/steps_config.dart';
import 'package:baktaz_flutter/features/steps/data/service/step_telemetry_service.dart';
import 'package:baktaz_flutter/features/steps/domain/cubit/steps_analytics/steps_analytics_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StepsPage extends HookWidget {
  const StepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StepsAnalyticsCubit cubit = context.read<StepsAnalyticsCubit>();

    useEffect(() {
      cubit.fetchAnalytics();
      return null;
    }, <Object?>[]);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
          SliverAppBar.medium(
            title: BaktazText(
              text: context.i18n.steps.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
            ),
            backgroundColor: context.colorScheme.surface,
          ),
        ],
        body: RefreshIndicator(
          onRefresh: cubit.fetchAnalytics,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: Paddings.screenMarginH,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Gap.medium(),
                      BlocSignalBuilder<StepsAnalyticsCubit, StepsAnalyticsState>(
                        builder: (BuildContext context, StepsAnalyticsState state) {
                          final int current = state.dailyTelemetry?.currentSteps.getValue().toInt() ?? 0;
                          final int goal = state.dailyTelemetry?.goalSteps.getValue().toInt() ??
                              StepsConfig.defaultGoalSteps;
                          final String source = state.dailyTelemetry?.syncSource.getValue() ??
                              StepsConfig.defaultProvider;

                          return HomeDailyStepHeroCard(
                            currentSteps: current,
                            goalSteps: goal,
                            syncSource: source,
                            lastSyncedText: state.dailyTelemetry != null
                                ? context.i18n.steps.telemetry.last_synced(
                                    time: state.dailyTelemetry!.lastSyncedAt.value
                                        .toLocal()
                                        .toString()
                                        .split(' ')
                                        .first,
                                  )
                                : context.i18n.steps.status_disconnected,
                            onRefresh: cubit.fetchAnalytics,
                          );
                        },
                      ),
                      Gap.medium(),
                       BlocSignalBuilder<StepsAnalyticsCubit, StepsAnalyticsState>(
                        builder: (BuildContext context, StepsAnalyticsState state) {
                          final List<int> weekly = state.weeklyAnalytics?.weeklySteps ??
                              const <int>[0, 0, 0, 0, 0, 0, 0];
                          final int avg = state.weeklyAnalytics?.averageSteps.getValue().toInt() ?? 0;
                          final int total = state.weeklyAnalytics?.totalWeeklySteps.getValue().toInt() ?? 0;
                          final int goal = state.weeklyAnalytics?.goalTarget.getValue().toInt() ??
                              StepsConfig.defaultGoalSteps;

                          return HomeWeeklyStepsChart(
                            weeklySteps: weekly,
                            averageSteps: avg,
                            totalWeeklySteps: total,
                            goalTarget: goal,
                          );
                        },
                      ),
                      Gap.medium(),
                      BaktazCard(
                        headerTitle: context.i18n.steps.checklist.title,
                        body: Padding(
                          padding: Paddings.allMedium,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _ChecklistItem(
                                title: context.i18n.steps.checklist.morning_walk,
                                isCompleted: true,
                              ),
                              const BaktazDivider(),
                              _ChecklistItem(
                                title: context.i18n.steps.checklist.lunch_break,
                                isCompleted: true,
                              ),
                              const BaktazDivider(),
                              _ChecklistItem(
                                title: context.i18n.steps.checklist.evening_goal,
                                isCompleted: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap.medium(),
                      BlocSignalBuilder<StepsAnalyticsCubit, StepsAnalyticsState>(
                        builder: (BuildContext context, StepsAnalyticsState state) => BaktazCard(
                          headerTitle: context.i18n.steps.connect_health,
                          body: Padding(
                            padding: Paddings.allMedium,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                BaktazText(
                                  text: context.i18n.steps.connect_desc,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Gap.medium(),
                                  BaktazButton(
                                    text: context.i18n.steps.sync_now,
                                    onPressed: () async {
                                      final IStepTelemetryService telemetryService =
                                          getIt<IStepTelemetryService>();
                                      final String provider = telemetryService.providerName;
                                      bool granted = await telemetryService.checkPermissionStatus();
                                      if (!granted) {
                                        granted = await telemetryService.requestPermissions();
                                      }
                                      if (!context.mounted) return;
                                      if (granted) {
                                        await cubit.updateIntegrationStatus(
                                          provider: provider,
                                          status: 'active',
                                        );
                                        if (!context.mounted) return;
                                        final int? steps = await telemetryService.fetchTodaySteps();
                                        if (!context.mounted) return;
                                        if (steps != null) {
                                          await cubit.syncSteps(
                                            steps: steps,
                                            sourceDeviceId: provider,
                                            wasUserEntered: false,
                                          );
                                        }
                                      } else {
                                        await cubit.updateIntegrationStatus(
                                          provider: provider,
                                          status: 'permission_denied',
                                          lastError: 'Permission not granted by user',
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap.large(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.title, required this.isCompleted});

  final String title;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: Paddings.verticalSmall,
        child: Row(
          children: <Widget>[
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
            ),
            Gap.medium(),
            Expanded(
              child: BaktazText(
                text: title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
}

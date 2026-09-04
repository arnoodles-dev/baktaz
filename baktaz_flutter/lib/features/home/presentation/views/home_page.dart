import 'dart:async';

import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_active_challenge_ticker.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_app_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_hero_card.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_leaderboard_preview.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_steps_chart.dart';
import 'package:baktaz_shared/baktaz_shared.dart' hide LeaderboardEntry;
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  void _hidableListener(ScrollController scrollController, HidableCubit hidableCubit) {
    switch (scrollController.position.userScrollDirection) {
      case ScrollDirection.forward:
        hidableCubit.setVisibility(isVisible: true);
      case ScrollDirection.reverse:
        hidableCubit.setVisibility(isVisible: false);
      case ScrollDirection.idle:
        break;
    }
  }

  void _onSideEffect(BuildContext context, HomeStateSideEffect sideEffect) {
    switch (sideEffect) {
      case HomeStateException(:final Exception exception):
        getIt<FailureHandler>().handleException(exception, null);
      case HomeStateInitializeAddress():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = useScrollController();

    useEffect(() {
      final HidableCubit hidableCubit = context.read<HidableCubit>();
      void listener() => _hidableListener(scrollController, hidableCubit);
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, <Object?>[scrollController]);

    useEffect(() {
      final HomeCubit homeCubit = context.read<HomeCubit>();
      final StreamSubscription<HomeStateSideEffect> sub = homeCubit.presentationStream.listen((
        HomeStateSideEffect sideEffect,
      ) {
        if (context.mounted) {
          _onSideEffect(context, sideEffect);
        }
      });
      return sub.cancel;
    }, <Object?>[]);

    return BlocSignalBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) => RepaintBoundary(
        child: Scaffold(
          body: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar.large(
                  scrolledUnderElevation: 0,
                  flexibleSpace: const FlexibleSpaceBar(
                    centerTitle: true,
                    background: HomeAppHeader(),
                    expandedTitleScale: 1,
                  ),
                  forceElevated: innerBoxIsScrolled,
                ),
              ),
            ],
            body: Builder(
              builder: (BuildContext context) => RefreshIndicator(
                onRefresh: () async {
                  final HomeCubit homeCubit = context.read<HomeCubit>();
                  await homeCubit.syncDailySteps();
                },
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: <Widget>[
                    SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                    SliverPadding(
                      padding: Paddings.screenMarginH,
                      sliver: SliverList.list(
                        children: <Widget>[
                          Gap.medium(),
                          RepaintBoundary(
                            child: Skeletonizer(
                              enabled: state.telemetryQueryStatus.isLoading,
                              child: HomeDailyStepHeroCard(
                                currentSteps: state.dailyTelemetry?.currentSteps.getValue().toInt() ?? 0,
                                goalSteps: state.dailyTelemetry?.goalSteps.getValue().toInt() ?? 10000,
                                syncSource: state.dailyTelemetry?.syncSource.getValue() ?? 'Health Connect',
                                lastSyncedText: state.dailyTelemetry != null
                                    ? state.dailyTelemetry!.lastSyncedAt.value.toLocal().toString().split(' ').first
                                    : 'Never synced',
                                onRefresh: () => context.read<HomeCubit>().syncDailySteps(),
                              ),
                            ),
                          ),
                          Gap.medium(),
                          RepaintBoundary(
                            child: Skeletonizer(
                              enabled: state.weeklyQueryStatus.isLoading,
                              child: HomeWeeklyStepsChart(
                                weeklySteps: state.weeklyAnalytics?.weeklySteps ?? List<int>.filled(7, 0),
                                averageSteps: state.weeklyAnalytics?.averageSteps.getValue().toInt() ?? 0,
                                totalWeeklySteps: state.weeklyAnalytics?.totalWeeklySteps.getValue().toInt() ?? 0,
                                goalTarget: state.weeklyAnalytics?.goalTarget.getValue().toInt() ?? 10000,
                              ),
                            ),
                          ),
                          Gap.medium(),
                          RepaintBoundary(
                            child: Skeletonizer(
                              enabled: state.activeChallengeQueryStatus.isLoading,
                              child: HomeActiveChallengeTicker(
                                isEnrolled: state.activeChallenge?.isEnrolled.getValue() ?? false,
                                onOpenChallenge: () {},
                                title: state.activeChallenge?.title?.getValue(),
                                rank: state.activeChallenge?.rank?.getValue().toInt(),
                                totalParticipants: state.activeChallenge?.totalParticipants?.getValue().toInt(),
                                prizePoolText: state.activeChallenge?.prizePoolText?.getValue(),
                                gapText: state.activeChallenge?.gapText?.getValue(),
                                leaders: state.activeChallenge?.leaders?.map((dynamic e) => e.toString()).toList(),
                                currentDay: state.activeChallenge?.currentDay?.getValue().toInt(),
                                totalDays: state.activeChallenge?.totalDays?.getValue().toInt(),
                              ),
                            ),
                          ),
                          if ((state.activeChallenge?.isEnrolled.getValue() ?? false) &&
                              (state.leaderboardQueryStatus.isLoading ||
                                  (state.leaderboardEntries?.isNotEmpty ?? false))) ...<Widget>[
                            Gap.medium(),
                            RepaintBoundary(
                              child: Skeletonizer(
                                enabled: state.leaderboardQueryStatus.isLoading,
                                child: HomeLeaderboardPreview(
                                  topEntries: (state.leaderboardEntries ?? <HomeLeaderboardEntry>[])
                                      .take(5)
                                      .map(
                                        (HomeLeaderboardEntry e) => LeaderboardEntry(
                                          rank: e.rank.getValue().toInt(),
                                          username: e.username.getValue(),
                                          steps: e.steps.getValue().toInt(),
                                          avgSteps: e.avgSteps.getValue(),
                                          trend: e.trend.getValue(),
                                          avatarUrl: e.avatarUrl?.getValue(),
                                        ),
                                      )
                                      .toList(),
                                  onViewFull: () {},
                                ),
                              ),
                            ),
                          ],
                          Gap.large(),
                          Center(child: BaktazText(text: context.i18n.home.thats_all)),
                          Gap.medium(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/entity/active_challenge_summary.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_flutter/features/home/presentation/views/home_page.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart' show signal;
import 'package:uuid/uuid.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../../utils/mock_material_app.dart';

void main() {
  group(HomePage, () {
    late MockHomeCubit homeCubit;
    late MockHidableCubit hidableCubit;

    final serverpod.DailyStepTelemetry mockServerTelemetry = serverpod.DailyStepTelemetry(
      userId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      date: '2026-08-22',
      currentSteps: 7500,
      goalSteps: 10000,
      syncSource: 'Health Connect',
      lastSyncedAt: DateTime.now().toUtc(),
      isFlaggedForReview: false,
    );
    final DailyStepTelemetry mockTelemetry = DailyStepTelemetry.fromServer(mockServerTelemetry);

    final serverpod.WeeklyStepAnalytics mockServerWeekly = serverpod.WeeklyStepAnalytics(
      weeklySteps: const <int>[5000, 7000, 6500, 8000, 7500, 9000, 8500],
      averageSteps: 7357,
      totalWeeklySteps: 51500,
      goalTarget: 10000,
    );
    final WeeklyStepAnalytics mockWeekly = WeeklyStepAnalytics.fromServer(mockServerWeekly);

    final serverpod.ActiveChallengeSummary mockServerChallenge = serverpod.ActiveChallengeSummary(
      isEnrolled: true,
      title: 'Step Master',
      rank: 5,
      totalParticipants: 100,
      prizePoolText: '1,000 pts',
      gapText: '200 steps to #4',
      leaders: const <String>['Alice', 'Bob'],
      currentDay: 3,
      totalDays: 7,
    );
    final ActiveChallengeSummary mockChallenge = ActiveChallengeSummary.fromServer(mockServerChallenge);

    final serverpod.HomeLeaderboardEntry mockServerLeaderboard = serverpod.HomeLeaderboardEntry(
      rank: 1,
      username: 'Alice',
      steps: 12000,
      avgSteps: '10,000',
      trend: 'up',
    );
    final List<HomeLeaderboardEntry> mockLeaderboard = <HomeLeaderboardEntry>[
      HomeLeaderboardEntry.fromServer(mockServerLeaderboard),
    ];

    setUp(() {
      homeCubit = MockHomeCubit();
      hidableCubit = MockHidableCubit();

      final HomeState initialState = HomeState.initial().copyWith(
        telemetryQueryStatus: const QueryStatus.done(),
        weeklyQueryStatus: const QueryStatus.done(),
        activeChallengeQueryStatus: const QueryStatus.done(),
        leaderboardQueryStatus: const QueryStatus.done(),
        dailyTelemetry: mockTelemetry,
        weeklyAnalytics: mockWeekly,
        activeChallenge: mockChallenge,
        leaderboardEntries: mockLeaderboard,
      );

      when(homeCubit.state).thenReturn(signal<HomeState>(initialState));
      when(homeCubit.presentationStream).thenAnswer((_) => const Stream<HomeStateSideEffect>.empty());
    });

    tearDown(() {
      reset(homeCubit);
      reset(hidableCubit);
    });

    testWidgets('renders HomePage with daily steps, weekly activity, challenge and leaderboard', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        BlocSignalProvider<HidableCubit>.value(
          value: hidableCubit,
          child: BlocSignalProvider<HomeCubit>.value(
            value: homeCubit,
            child: const MockMaterialApp(surfaceWidth: 800, surfaceHeight: 1200, child: HomePage()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Baktaz'), findsOneWidget);
      expect(find.text("TODAY'S STEPS"), findsOneWidget);
      expect(find.text('Weekly Activity'), findsOneWidget);
      expect(find.text('🏆 Step Master'), findsOneWidget);
      expect(find.text('Challenge Leaderboard'), findsOneWidget);
    });
  });
}

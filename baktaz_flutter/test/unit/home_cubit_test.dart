import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/entity/active_challenge_summary.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(HomeCubit, () {
    late MockIStepsRepository stepsRepository;
    late MockIChallengeRepository challengeRepository;
    late MockFailureHandler failureHandler;

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
      avatarUrl: Uri.parse('https://example.com/avatar.png'),
    );
    final List<HomeLeaderboardEntry> mockLeaderboard = <HomeLeaderboardEntry>[
      HomeLeaderboardEntry.fromServer(mockServerLeaderboard),
    ];

    setUp(() {
      stepsRepository = MockIStepsRepository();
      challengeRepository = MockIChallengeRepository();
      failureHandler = MockFailureHandler();

      provideDummy<TaskResult<DailyStepTelemetry>>(TaskResult<DailyStepTelemetry>.right(mockTelemetry));
      provideDummy<TaskResult<WeeklyStepAnalytics>>(TaskResult<WeeklyStepAnalytics>.right(mockWeekly));
      provideDummy<TaskResult<ActiveChallengeSummary?>>(TaskResult<ActiveChallengeSummary?>.right(mockChallenge));
      provideDummy<TaskResult<List<HomeLeaderboardEntry>>>(
        TaskResult<List<HomeLeaderboardEntry>>.right(mockLeaderboard),
      );

      when(stepsRepository.getDailyStepTelemetry()).thenReturn(TaskResult<DailyStepTelemetry>.right(mockTelemetry));
      when(stepsRepository.getWeeklyStepAnalytics()).thenReturn(TaskResult<WeeklyStepAnalytics>.right(mockWeekly));
      when(challengeRepository.getActiveChallengeSummary())
          .thenReturn(TaskResult<ActiveChallengeSummary?>.right(mockChallenge));
      when(challengeRepository.getLeaderboardPreview())
          .thenReturn(TaskResult<List<HomeLeaderboardEntry>>.right(mockLeaderboard));
      when(stepsRepository.syncSteps()).thenReturn(TaskResult<DailyStepTelemetry>.right(mockTelemetry));
    });

    tearDown(() {
      reset(stepsRepository);
      reset(challengeRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      test('emits loading then done with data when all repositories succeed', () async {
        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final HomeState state = cubit.stateValue;
        expect(state.queryStatus, isA<QueryStatus>());
        expect(state.dailyTelemetry, equals(mockTelemetry));
        expect(state.weeklyAnalytics, equals(mockWeekly));
        expect(state.activeChallenge, equals(mockChallenge));
        expect(state.leaderboardEntries, equals(mockLeaderboard));

        verify(stepsRepository.getDailyStepTelemetry()).called(1);
        verify(stepsRepository.getWeeklyStepAnalytics()).called(1);
        verify(challengeRepository.getActiveChallengeSummary()).called(1);
        verify(challengeRepository.getLeaderboardPreview()).called(1);
        await cubit.close();
      });

      test('handles failure when getDailyStepTelemetry fails', () async {
        const Failure failure = Failure.serverpod('Telemetry error');
        when(stepsRepository.getDailyStepTelemetry()).thenReturn(TaskResult<DailyStepTelemetry>.left(failure));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleFailure(failure)).called(1);
        await cubit.close();
      });

      test('handles failure when getWeeklyStepAnalytics fails', () async {
        const Failure failure = Failure.serverpod('Weekly error');
        when(stepsRepository.getWeeklyStepAnalytics()).thenReturn(TaskResult<WeeklyStepAnalytics>.left(failure));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleFailure(failure)).called(1);
        await cubit.close();
      });

      test('handles failure when getActiveChallengeSummary fails', () async {
        const Failure failure = Failure.serverpod('Challenge error');
        when(challengeRepository.getActiveChallengeSummary())
            .thenReturn(TaskResult<ActiveChallengeSummary?>.left(failure));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleFailure(failure)).called(1);
        await cubit.close();
      });

      test('handles failure when getLeaderboardPreview fails', () async {
        const Failure failure = Failure.serverpod('Leaderboard error');
        when(challengeRepository.getLeaderboardPreview())
            .thenReturn(TaskResult<List<HomeLeaderboardEntry>>.left(failure));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleFailure(failure)).called(1);
        await cubit.close();
      });

      test('calls handleException on unexpected exception during initialize', () async {
        when(stepsRepository.getDailyStepTelemetry()).thenThrow(Exception('Unexpected error'));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleException(any, any)).called(greaterThanOrEqualTo(1));
        await cubit.close();
      });
    });

    group('syncDailySteps', () {
      test('updates dailyTelemetry when sync succeeds', () async {
        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await cubit.syncDailySteps();

        verify(stepsRepository.syncSteps()).called(1);
        expect(cubit.stateValue.dailyTelemetry, equals(mockTelemetry));
        await cubit.close();
      });

      test('handles failure when sync fails', () async {
        const Failure failure = Failure.serverpod('Sync failed');
        when(stepsRepository.syncSteps()).thenReturn(TaskResult<DailyStepTelemetry>.left(failure));

        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        await cubit.syncDailySteps();

        verify(failureHandler.handleFailure(failure)).called(1);
        await cubit.close();
      });
    });

    group('presentationStream', () {
      test('emits presentation event when emitPresentation is called', () async {
        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);

        final List<HomeStateSideEffect> effects = <HomeStateSideEffect>[];
        cubit.presentationStream.listen(effects.add);

        cubit.emitPresentation(const HomeStateSideEffect.initializeAddress());

        await Future<void>.delayed(Duration.zero);

        expect(effects, isNotEmpty);
        expect(effects.first, isA<HomeStateInitializeAddress>());
        await cubit.close();
      });
    });

    group('close', () {
      test('closes presentation stream controller', () async {
        final HomeCubit cubit = HomeCubit(stepsRepository, challengeRepository, failureHandler);
        await cubit.close();

        expect(cubit.isClosed, isTrue);
      });
    });
  });
}

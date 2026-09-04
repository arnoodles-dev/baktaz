import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/features/steps/domain/cubit/steps_analytics/steps_analytics_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(StepsAnalyticsCubit, () {
    late MockIStepsAnalyticsRepository repository;
    late MockFailureHandler failureHandler;
    late StepsAnalyticsCubit cubit;

    final serverpod.UuidValue userId =
        serverpod.UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000');
    final DateTime now = DateTime(2026, 9, 4);

    final serverpod.DailyStepTelemetry sampleTelemetry =
        serverpod.DailyStepTelemetry(
      userId: userId,
      date: '2026-09-04',
      currentSteps: 5000,
      goalSteps: 10000,
      syncSource: 'apple_health',
      lastSyncedAt: now,
      isFlaggedForReview: false,
    );

    final serverpod.WeeklyStepAnalytics sampleWeeklyAnalytics =
        serverpod.WeeklyStepAnalytics(
      weeklySteps: <int>[4000, 5000, 6000, 7000, 8000, 9000, 10000],
      averageSteps: 7000,
      totalWeeklySteps: 49000,
      goalTarget: 10000,
    );

    setUp(() {
      repository = MockIStepsAnalyticsRepository();
      failureHandler = MockFailureHandler();
      cubit = StepsAnalyticsCubit(repository, failureHandler);

      provideDummy<TaskResult<serverpod.DailyStepTelemetry>>(
        TaskResult<serverpod.DailyStepTelemetry>.right(sampleTelemetry),
      );
      provideDummy<TaskResult<serverpod.WeeklyStepAnalytics>>(
        TaskResult<serverpod.WeeklyStepAnalytics>.right(sampleWeeklyAnalytics),
      );
      provideDummy<TaskResult<bool>>(
        TaskResult<bool>.right(true),
      );
    });

    tearDown(() async {
      await cubit.close();
      reset(repository);
      reset(failureHandler);
    });

    test('initial state is correct', () {
      expect(
        cubit.stateValue,
        equals(StepsAnalyticsState.initial()),
      );
    });

    group('fetchAnalytics', () {
      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'emits done state with daily telemetry and weekly analytics when both succeed',
        build: () {
          when(repository.getDailyTelemetry(any)).thenReturn(
            TaskResult<serverpod.DailyStepTelemetry>.right(sampleTelemetry),
          );
          when(repository.getWeeklyAnalytics()).thenReturn(
            TaskResult<serverpod.WeeklyStepAnalytics>.right(sampleWeeklyAnalytics),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.fetchAnalytics(),
        expect: () => <dynamic>[
          predicate<StepsAnalyticsState>(
            (StepsAnalyticsState state) =>
                state.queryStatus == const QueryStatus.done() &&
                state.dailyTelemetry?.currentSteps.value.getOrElse((_) => -1) == 5000 &&
                state.weeklyAnalytics?.totalWeeklySteps.value.getOrElse((_) => -1) == 49000,
          ),
        ],
        verify: (_) {
          verify(repository.getDailyTelemetry(any)).called(1);
          verify(repository.getWeeklyAnalytics()).called(1);
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles daily telemetry failure via failure handler while updating weekly analytics',
        build: () {
          const Failure failure = Failure.server(StatusCode.serverpod, 'Telemetry error');
          when(repository.getDailyTelemetry(any)).thenReturn(
            TaskResult<serverpod.DailyStepTelemetry>.left(failure),
          );
          when(repository.getWeeklyAnalytics()).thenReturn(
            TaskResult<serverpod.WeeklyStepAnalytics>.right(sampleWeeklyAnalytics),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.fetchAnalytics(),
        expect: () => <dynamic>[
          predicate<StepsAnalyticsState>(
            (StepsAnalyticsState state) =>
                state.queryStatus == const QueryStatus.done() &&
                state.dailyTelemetry == null &&
                state.weeklyAnalytics?.totalWeeklySteps.value.getOrElse((_) => -1) == 49000,
          ),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles weekly analytics failure via failure handler while updating daily telemetry',
        build: () {
          const Failure failure = Failure.server(StatusCode.serverpod, 'Weekly error');
          when(repository.getDailyTelemetry(any)).thenReturn(
            TaskResult<serverpod.DailyStepTelemetry>.right(sampleTelemetry),
          );
          when(repository.getWeeklyAnalytics()).thenReturn(
            TaskResult<serverpod.WeeklyStepAnalytics>.left(failure),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.fetchAnalytics(),
        expect: () => <dynamic>[
          predicate<StepsAnalyticsState>(
            (StepsAnalyticsState state) =>
                state.queryStatus == const QueryStatus.done() &&
                state.dailyTelemetry?.currentSteps.value.getOrElse((_) => -1) == 5000 &&
                state.weeklyAnalytics == null,
          ),
        ],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles exception via failure handler when repository throws during fetchAnalytics',
        build: () {
          when(repository.getDailyTelemetry(any)).thenThrow(Exception('Fetch error'));
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.fetchAnalytics(),
        expect: () => const <StepsAnalyticsState>[],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });

    group('syncSteps', () {
      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'emits done state with updated daily telemetry when sync succeeds',
        build: () {
          when(
            repository.syncSteps(
              steps: anyNamed('steps'),
              sourceDeviceId: anyNamed('sourceDeviceId'),
              wasUserEntered: anyNamed('wasUserEntered'),
              date: anyNamed('date'),
            ),
          ).thenReturn(
            TaskResult<serverpod.DailyStepTelemetry>.right(sampleTelemetry),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.syncSteps(
          steps: 8000,
          sourceDeviceId: 'device_xyz',
          wasUserEntered: false,
        ),
        expect: () => <dynamic>[
          predicate<StepsAnalyticsState>(
            (StepsAnalyticsState state) =>
                state.queryStatus == const QueryStatus.done() &&
                state.dailyTelemetry?.currentSteps.value.getOrElse((_) => -1) == 5000,
          ),
        ],
        verify: (_) {
          verify(
            repository.syncSteps(
              steps: 8000,
              sourceDeviceId: 'device_xyz',
              wasUserEntered: false,
              date: anyNamed('date'),
            ),
          ).called(1);
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles failure via failure handler when sync fails',
        build: () {
          const Failure failure = Failure.server(StatusCode.serverpod, 'Sync failed');
          when(
            repository.syncSteps(
              steps: anyNamed('steps'),
              sourceDeviceId: anyNamed('sourceDeviceId'),
              wasUserEntered: anyNamed('wasUserEntered'),
              date: anyNamed('date'),
            ),
          ).thenReturn(
            TaskResult<serverpod.DailyStepTelemetry>.left(failure),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.syncSteps(
          steps: 8000,
          sourceDeviceId: 'device_xyz',
          wasUserEntered: false,
        ),
        expect: () => const <StepsAnalyticsState>[],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles exception via failure handler when repository throws during syncSteps',
        build: () {
          when(
            repository.syncSteps(
              steps: anyNamed('steps'),
              sourceDeviceId: anyNamed('sourceDeviceId'),
              wasUserEntered: anyNamed('wasUserEntered'),
              date: anyNamed('date'),
            ),
          ).thenThrow(Exception('Unexpected error'));
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.syncSteps(
          steps: 8000,
          sourceDeviceId: 'device_xyz',
          wasUserEntered: false,
        ),
        expect: () => const <StepsAnalyticsState>[],
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });

    group('updateIntegrationStatus', () {
      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'calls repository.updateIntegrationStatus and succeeds without changing state',
        build: () {
          when(
            repository.updateIntegrationStatus(
              provider: anyNamed('provider'),
              status: anyNamed('status'),
              lastError: anyNamed('lastError'),
            ),
          ).thenReturn(
            TaskResult<bool>.right(true),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.updateIntegrationStatus(
          provider: 'health_connect',
          status: 'connected',
        ),
        expect: () => const <StepsAnalyticsState>[],
        verify: (_) {
          verify(
            repository.updateIntegrationStatus(
              provider: 'health_connect',
              status: 'connected',
            ),
          ).called(1);
          verifyNever(failureHandler.handleFailure(any));
        },
      );

      blocSignalTest<StepsAnalyticsCubit, StepsAnalyticsState>(
        'handles failure via failure handler when updateIntegrationStatus fails',
        build: () {
          const Failure failure = Failure.server(StatusCode.serverpod, 'Update status failed');
          when(
            repository.updateIntegrationStatus(
              provider: anyNamed('provider'),
              status: anyNamed('status'),
              lastError: anyNamed('lastError'),
            ),
          ).thenReturn(
            TaskResult<bool>.left(failure),
          );
          return cubit;
        },
        act: (StepsAnalyticsCubit cubit) => cubit.updateIntegrationStatus(
          provider: 'health_connect',
          status: 'connected',
        ),
        expect: () => const <StepsAnalyticsState>[],
        verify: (_) {
          verify(failureHandler.handleFailure(any)).called(1);
        },
      );
    });
  });
}

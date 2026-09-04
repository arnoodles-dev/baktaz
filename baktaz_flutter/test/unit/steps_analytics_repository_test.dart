import 'package:baktaz_client/baktaz_client.dart' as serverpod_dto;
import 'package:baktaz_flutter/features/steps/data/repository/steps_analytics_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:retry/retry.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(StepsAnalyticsRepository, () {
    late MockServerpod serverpod;
    late MockClient client;
    late MockEndpointStep endpointStep;
    late MockTalker talker;
    late StepsAnalyticsRepository repository;

    final serverpod_dto.UuidValue userId =
        serverpod_dto.UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000');
    final DateTime now = DateTime(2026, 9, 4);

    final serverpod_dto.DailyStepTelemetry sampleTelemetry =
        serverpod_dto.DailyStepTelemetry(
      userId: userId,
      date: '2026-09-04',
      currentSteps: 5000,
      goalSteps: 10000,
      syncSource: 'apple_health',
      lastSyncedAt: now,
      isFlaggedForReview: false,
    );

    final serverpod_dto.WeeklyStepAnalytics sampleWeeklyAnalytics =
        serverpod_dto.WeeklyStepAnalytics(
      weeklySteps: <int>[4000, 5000, 6000, 7000, 8000, 9000, 10000],
      averageSteps: 7000,
      totalWeeklySteps: 49000,
      goalTarget: 10000,
    );

    final serverpod_dto.StepSync sampleSyncRecord = serverpod_dto.StepSync(
      userId: userId,
      sourceDeviceId: 'device_123',
      rawSteps: 5000,
      filteredSteps: 5000,
      wasUserEntered: false,
      syncedAt: now,
      date: '2026-09-04',
      syncStatus: 'synced',
    );

    final serverpod_dto.StepIntegration sampleIntegration =
        serverpod_dto.StepIntegration(
      userId: userId,
      provider: 'health_connect',
      status: 'active',
      connectedAt: now,
      updatedAt: now,
    );

    setUp(() {
      serverpod = MockServerpod();
      client = MockClient();
      endpointStep = MockEndpointStep();
      talker = MockTalker();

      when(serverpod.client).thenReturn(client);
      when(client.step).thenReturn(endpointStep);

      repository = StepsAnalyticsRepository(
        serverpod,
        const RetryOptions(maxAttempts: 1),
        talker,
      );
    });

    group('getDailyTelemetry', () {
      test('should return Right(DailyStepTelemetry) when call succeeds', () async {
        when(endpointStep.getDailyTelemetry('2026-09-04'))
            .thenAnswer((_) async => sampleTelemetry);

        final Either<Failure, serverpod_dto.DailyStepTelemetry> result =
            await repository.getDailyTelemetry('2026-09-04').run();

        expect(
          result,
          equals(Right<Failure, serverpod_dto.DailyStepTelemetry>(sampleTelemetry)),
        );
        verify(endpointStep.getDailyTelemetry('2026-09-04')).called(1);
      });

      test('should return Left(Failure.server) when endpoint throws', () async {
        final Exception exception = Exception('Network error');
        when(endpointStep.getDailyTelemetry('2026-09-04')).thenThrow(exception);

        final Either<Failure, serverpod_dto.DailyStepTelemetry> result =
            await repository.getDailyTelemetry('2026-09-04').run();

        expect(
          result,
          equals(
            const Left<Failure, serverpod_dto.DailyStepTelemetry>(
              Failure.server(
                StatusCode.serverpod,
                'Exception: Network error',
              ),
            ),
          ),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('getWeeklyAnalytics', () {
      test('should return Right(WeeklyStepAnalytics) when call succeeds', () async {
        when(endpointStep.getWeeklyAnalytics())
            .thenAnswer((_) async => sampleWeeklyAnalytics);

        final Either<Failure, serverpod_dto.WeeklyStepAnalytics> result =
            await repository.getWeeklyAnalytics().run();

        expect(
          result,
          equals(Right<Failure, serverpod_dto.WeeklyStepAnalytics>(sampleWeeklyAnalytics)),
        );
        verify(endpointStep.getWeeklyAnalytics()).called(1);
      });

      test('should return Left(Failure.server) when endpoint throws', () async {
        final Exception exception = Exception('Server unavailable');
        when(endpointStep.getWeeklyAnalytics()).thenThrow(exception);

        final Either<Failure, serverpod_dto.WeeklyStepAnalytics> result =
            await repository.getWeeklyAnalytics().run();

        expect(
          result,
          equals(
            const Left<Failure, serverpod_dto.WeeklyStepAnalytics>(
              Failure.server(
                StatusCode.serverpod,
                'Exception: Server unavailable',
              ),
            ),
          ),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('syncSteps', () {
      test('should return Right(DailyStepTelemetry) when call succeeds', () async {
        when(
          endpointStep.syncStepData(
            sourceDeviceId: 'device_123',
            rawSteps: 5000,
            wasUserEntered: false,
            date: '2026-09-04',
          ),
        ).thenAnswer((_) async => sampleSyncRecord);
        when(endpointStep.getDailyTelemetry('2026-09-04'))
            .thenAnswer((_) async => sampleTelemetry);

        final Either<Failure, serverpod_dto.DailyStepTelemetry> result =
            await repository
                .syncSteps(
                  steps: 5000,
                  sourceDeviceId: 'device_123',
                  wasUserEntered: false,
                  date: '2026-09-04',
                )
                .run();

        expect(
          result,
          equals(Right<Failure, serverpod_dto.DailyStepTelemetry>(sampleTelemetry)),
        );
        verify(
          endpointStep.syncStepData(
            sourceDeviceId: 'device_123',
            rawSteps: 5000,
            wasUserEntered: false,
            date: '2026-09-04',
          ),
        ).called(1);
        verify(endpointStep.getDailyTelemetry('2026-09-04')).called(1);
      });

      test('should return Left(Failure.server) when syncStepData throws', () async {
        final Exception exception = Exception('Sync failed');
        when(
          endpointStep.syncStepData(
            sourceDeviceId: 'device_123',
            rawSteps: 5000,
            wasUserEntered: false,
            date: '2026-09-04',
          ),
        ).thenThrow(exception);

        final Either<Failure, serverpod_dto.DailyStepTelemetry> result =
            await repository
                .syncSteps(
                  steps: 5000,
                  sourceDeviceId: 'device_123',
                  wasUserEntered: false,
                  date: '2026-09-04',
                )
                .run();

        expect(
          result,
          equals(
            const Left<Failure, serverpod_dto.DailyStepTelemetry>(
              Failure.server(
                StatusCode.serverpod,
                'Exception: Sync failed',
              ),
            ),
          ),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('updateIntegrationStatus', () {
      test('should return Right(true) when call succeeds', () async {
        when(
          endpointStep.updateIntegrationStatus('health_connect', 'active', null),
        ).thenAnswer((_) async => sampleIntegration);

        final Either<Failure, bool> result = await repository
            .updateIntegrationStatus(
              provider: 'health_connect',
              status: 'active',
            )
            .run();

        expect(result, equals(const Right<Failure, bool>(true)));
        verify(
          endpointStep.updateIntegrationStatus('health_connect', 'active', null),
        ).called(1);
      });

      test('should return Left(Failure.server) when endpoint throws', () async {
        final Exception exception = Exception('Integration failed');
        when(
          endpointStep.updateIntegrationStatus('health_connect', 'active', null),
        ).thenThrow(exception);

        final Either<Failure, bool> result = await repository
            .updateIntegrationStatus(
              provider: 'health_connect',
              status: 'active',
            )
            .run();

        expect(
          result,
          equals(
            const Left<Failure, bool>(
              Failure.server(
                StatusCode.serverpod,
                'Exception: Integration failed',
              ),
            ),
          ),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });
  });
}

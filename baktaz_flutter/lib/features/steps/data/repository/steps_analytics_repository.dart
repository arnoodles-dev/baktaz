import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/app/helpers/utils/retry_utils.dart';
import 'package:baktaz_flutter/features/steps/domain/interface/i_steps_analytics_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IStepsAnalyticsRepository)
final class StepsAnalyticsRepository implements IStepsAnalyticsRepository {
  const StepsAnalyticsRepository(this._serverpod, this._retry, this._talker);

  final Serverpod _serverpod;
  final RetryOptions _retry;
  final Talker _talker;

  @override
  TaskResult<serverpod.DailyStepTelemetry> getDailyTelemetry(String date) =>
      TaskResult<serverpod.DailyStepTelemetry>.tryCatch(
        () async {
          final serverpod.DailyStepTelemetry? result = await _retry.retry(
            () => _serverpod.client.step.getDailyTelemetry(date),
            retryIf: RetryUtils.isRetryableException,
          );

          if (result == null) {
            throw const FormatException('Daily step telemetry is null');
          }

          return result;
        },
        (Object error, StackTrace stackTrace) {
          _talker.handle(error, stackTrace);
          return Failure.server(StatusCode.serverpod, error.toString());
        },
      );

  @override
  TaskResult<serverpod.WeeklyStepAnalytics> getWeeklyAnalytics() =>
      TaskResult<serverpod.WeeklyStepAnalytics>.tryCatch(
        () async {
          final serverpod.WeeklyStepAnalytics? result = await _retry.retry(
            () => _serverpod.client.step.getWeeklyAnalytics(),
            retryIf: RetryUtils.isRetryableException,
          );

          if (result == null) {
            throw const FormatException('Weekly step analytics is null');
          }

          return result;
        },
        (Object error, StackTrace stackTrace) {
          _talker.handle(error, stackTrace);
          return Failure.server(StatusCode.serverpod, error.toString());
        },
      );

  @override
  TaskResult<serverpod.DailyStepTelemetry> syncSteps({
    required int steps,
    required String sourceDeviceId,
    required bool wasUserEntered,
    required String date,
  }) => TaskResult<serverpod.DailyStepTelemetry>.tryCatch(
    () async {
      await _retry.retry(
        () => _serverpod.client.step.syncStepData(
          sourceDeviceId: sourceDeviceId,
          rawSteps: steps,
          wasUserEntered: wasUserEntered,
          date: date,
        ),
        retryIf: RetryUtils.isRetryableException,
      );

      final serverpod.DailyStepTelemetry? result = await _retry.retry(
        () => _serverpod.client.step.getDailyTelemetry(date),
        retryIf: RetryUtils.isRetryableException,
      );

      if (result == null) {
        throw const FormatException('Daily step telemetry is null');
      }

      return result;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<bool> updateIntegrationStatus({
    required String provider,
    required String status,
    String? lastError,
  }) => TaskResult<bool>.tryCatch(
    () async {
      await _retry.retry(
        () => _serverpod.client.step.updateIntegrationStatus(
          provider,
          status,
          lastError,
        ),
        retryIf: RetryUtils.isRetryableException,
      );

      return true;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );
}

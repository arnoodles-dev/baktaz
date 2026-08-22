import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/app/helpers/utils/retry_utils.dart';
import 'package:baktaz_flutter/features/home/data/service/sync_steps_service.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_flutter/features/home/domain/interface/i_steps_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IStepsRepository)
final class StepsRepository implements IStepsRepository {
  const StepsRepository(this._serverpod, this._syncStepsService, this._retry, this._talker);

  final Serverpod _serverpod;
  final SyncStepsService _syncStepsService;
  final RetryOptions _retry;
  final Talker _talker;

  @override
  TaskResult<DailyStepTelemetry> getDailyStepTelemetry() => TaskResult<DailyStepTelemetry>.tryCatch(
    () async {
      final serverpod.DailyStepTelemetry? result = await _retry.retry(
        () => _serverpod.client.home.getDailyStepTelemetry(),
        retryIf: RetryUtils.isRetryableException,
      );

      if (result == null) {
        throw const FormatException('Daily step telemetry is null');
      }

      final DailyStepTelemetry telemetry = DailyStepTelemetry.fromServer(result);
      if (telemetry.validate.isSome()) {
        throw telemetry.validate.asSome();
      }

      return telemetry;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.serverpod(error.toString());
    },
  );

  @override
  TaskResult<WeeklyStepAnalytics> getWeeklyStepAnalytics() => TaskResult<WeeklyStepAnalytics>.tryCatch(
    () async {
      final serverpod.WeeklyStepAnalytics? result = await _retry.retry(
        () => _serverpod.client.home.getWeeklyStepAnalytics(),
        retryIf: RetryUtils.isRetryableException,
      );

      if (result == null) {
        throw const FormatException('Weekly step analytics is null');
      }

      final WeeklyStepAnalytics analytics = WeeklyStepAnalytics.fromServer(result);
      if (analytics.validate.isSome()) {
        throw analytics.validate.asSome();
      }

      return analytics;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.serverpod(error.toString());
    },
  );

  @override
  TaskResult<DailyStepTelemetry> syncSteps() => TaskResult<DailyStepTelemetry>.tryCatch(
    () async {
      final int steps = await _syncStepsService.fetchDailySteps('Health Connect');
      final serverpod.DailyStepTelemetry result = await _retry.retry(
        () => _serverpod.client.home.syncSteps(steps, 'Health Connect'),
        retryIf: RetryUtils.isRetryableException,
      );

      return DailyStepTelemetry.fromServer(result);
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.serverpod(error.toString());
    },
  );
}

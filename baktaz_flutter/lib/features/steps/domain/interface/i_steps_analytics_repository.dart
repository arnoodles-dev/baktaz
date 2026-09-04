import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';

abstract interface class IStepsAnalyticsRepository {
  TaskResult<serverpod.DailyStepTelemetry> getDailyTelemetry(String date);
  TaskResult<serverpod.WeeklyStepAnalytics> getWeeklyAnalytics();
  TaskResult<serverpod.DailyStepTelemetry> syncSteps({
    required int steps,
    required String sourceDeviceId,
    required bool wasUserEntered,
    required String date,
  });
  TaskResult<bool> updateIntegrationStatus({
    required String provider,
    required String status,
    String? lastError,
  });
}

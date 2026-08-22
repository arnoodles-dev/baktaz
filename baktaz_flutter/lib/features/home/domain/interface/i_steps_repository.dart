import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract interface class IStepsRepository {
  TaskResult<DailyStepTelemetry> getDailyStepTelemetry();
  TaskResult<WeeklyStepAnalytics> getWeeklyStepAnalytics();
  TaskResult<DailyStepTelemetry> syncSteps();
}

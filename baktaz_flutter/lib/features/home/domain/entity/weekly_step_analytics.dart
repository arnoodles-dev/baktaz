import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_step_analytics.freezed.dart';

@freezed
abstract class WeeklyStepAnalytics with _$WeeklyStepAnalytics {
  const factory WeeklyStepAnalytics({
    required List<int> weeklySteps,
    required Number averageSteps,
    required Number totalWeeklySteps,
    required Number goalTarget,
  }) = _WeeklyStepAnalytics;

  const WeeklyStepAnalytics._();

  factory WeeklyStepAnalytics.fromServer(serverpod.WeeklyStepAnalytics model) => WeeklyStepAnalytics(
    weeklySteps: model.weeklySteps,
    averageSteps: Number(model.averageSteps),
    totalWeeklySteps: Number(model.totalWeeklySteps),
    goalTarget: Number(model.goalTarget),
  );

  Option<Failure> get validate => averageSteps.validate
      .andThen(() => totalWeeklySteps.validate)
      .andThen(() => goalTarget.validate)
      .fold(some, (_) => none());
}

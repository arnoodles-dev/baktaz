part of 'steps_analytics_cubit.dart';

@freezed
sealed class StepsAnalyticsState with _$StepsAnalyticsState {
  const factory StepsAnalyticsState({
    required QueryStatus queryStatus,
    DailyStepTelemetry? dailyTelemetry,
    WeeklyStepAnalytics? weeklyAnalytics,
  }) = _StepsAnalyticsState;

  factory StepsAnalyticsState.initial() => const _StepsAnalyticsState(
        queryStatus: QueryStatus.loading(),
      );
}

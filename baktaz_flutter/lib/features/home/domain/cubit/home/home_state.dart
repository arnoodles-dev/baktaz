part of 'home_cubit.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    required QueryStatus queryStatus,
    required QueryStatus telemetryQueryStatus,
    required QueryStatus weeklyQueryStatus,
    required QueryStatus activeChallengeQueryStatus,
    required QueryStatus leaderboardQueryStatus,
    DailyStepTelemetry? dailyTelemetry,
    WeeklyStepAnalytics? weeklyAnalytics,
    ActiveChallengeSummary? activeChallenge,
    List<HomeLeaderboardEntry>? leaderboardEntries,
  }) = _HomeState;

  const HomeState._();

  factory HomeState.initial() => const _HomeState(
    queryStatus: QueryStatus.loading(),
    telemetryQueryStatus: QueryStatus.loading(),
    weeklyQueryStatus: QueryStatus.loading(),
    activeChallengeQueryStatus: QueryStatus.loading(),
    leaderboardQueryStatus: QueryStatus.loading(),
    leaderboardEntries: <HomeLeaderboardEntry>[],
  );
}

@freezed
sealed class HomeStateSideEffect with _$HomeStateSideEffect {
  const factory HomeStateSideEffect.onException(Exception exception) = HomeStateException;
  const factory HomeStateSideEffect.initializeAddress() = HomeStateInitializeAddress;
}

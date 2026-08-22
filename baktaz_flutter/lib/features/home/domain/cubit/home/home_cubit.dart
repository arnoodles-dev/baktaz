import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/challenge/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_flutter/features/home/domain/entity/active_challenge_summary.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_flutter/features/home/domain/interface/i_steps_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
interface class HomeCubit extends CubitSignal<HomeState>
    with BlocSignalPresentationMixin<HomeStateSideEffect, HomeState> {
  HomeCubit(this._stepsRepository, this._challengeRepository, this._failureHandler)
    : super(initialState: HomeState.initial()) {
    unawaited(initialize());
  }

  final IStepsRepository _stepsRepository;
  final IChallengeRepository _challengeRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.loading()));
        await Future.wait(<Future<void>>[
          fetchDailyStepTelemetry(),
          fetchWeeklyAnalytics(),
          fetchActiveChallengeDashboard(),
          fetchLeaderboardPreview(),
        ]);
        safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.done()));
      },
    );
  }

  Future<void> fetchDailyStepTelemetry() async {
    final Result<DailyStepTelemetry> result = await _stepsRepository.getDailyStepTelemetry().run();
    result.fold(
      (Failure f) {
        _failureHandler.handleFailure(f);
        safeEmit(stateValue.copyWith(telemetryQueryStatus: const QueryStatus.done()));
      },
      (DailyStepTelemetry t) =>
          safeEmit(stateValue.copyWith(dailyTelemetry: t, telemetryQueryStatus: const QueryStatus.done())),
    );
  }

  Future<void> fetchWeeklyAnalytics() async {
    final Result<WeeklyStepAnalytics> result = await _stepsRepository.getWeeklyStepAnalytics().run();
    result.fold(
      (Failure f) {
        _failureHandler.handleFailure(f);
        safeEmit(stateValue.copyWith(weeklyQueryStatus: const QueryStatus.done()));
      },
      (WeeklyStepAnalytics a) =>
          safeEmit(stateValue.copyWith(weeklyAnalytics: a, weeklyQueryStatus: const QueryStatus.done())),
    );
  }

  Future<void> fetchActiveChallengeDashboard() async {
    final Result<ActiveChallengeSummary?> result = await _challengeRepository.getActiveChallengeSummary().run();
    result.fold(
      (Failure f) {
        _failureHandler.handleFailure(f);
        safeEmit(stateValue.copyWith(activeChallengeQueryStatus: const QueryStatus.done()));
      },
      (ActiveChallengeSummary? c) =>
          safeEmit(stateValue.copyWith(activeChallenge: c, activeChallengeQueryStatus: const QueryStatus.done())),
    );
  }

  Future<void> fetchLeaderboardPreview() async {
    final Result<List<HomeLeaderboardEntry>> result = await _challengeRepository.getLeaderboardPreview().run();
    result.fold(
      (Failure f) {
        _failureHandler.handleFailure(f);
        safeEmit(stateValue.copyWith(leaderboardQueryStatus: const QueryStatus.done()));
      },
      (List<HomeLeaderboardEntry> l) =>
          safeEmit(stateValue.copyWith(leaderboardEntries: l, leaderboardQueryStatus: const QueryStatus.done())),
    );
  }

  Future<void> syncDailySteps() async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Result<DailyStepTelemetry> result = await _stepsRepository.syncSteps().run();
        result.fold(
          _failureHandler.handleFailure,
          (DailyStepTelemetry t) => safeEmit(stateValue.copyWith(dailyTelemetry: t)),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/home/domain/entity/daily_step_telemetry.dart';
import 'package:baktaz_flutter/features/home/domain/entity/weekly_step_analytics.dart';
import 'package:baktaz_flutter/features/steps/domain/interface/i_steps_analytics_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'steps_analytics_cubit.freezed.dart';
part 'steps_analytics_state.dart';

@injectable
final class StepsAnalyticsCubit extends CubitSignal<StepsAnalyticsState> {
  StepsAnalyticsCubit(this._stepsAnalyticsRepository, this._failureHandler)
      : super(initialState: StepsAnalyticsState.initial());

  final IStepsAnalyticsRepository _stepsAnalyticsRepository;
  final FailureHandler _failureHandler;

  Future<void> fetchAnalytics() async {
    await safeRun(
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.loading()));
        }
      },
      onException: _failureHandler.handleException,
      action: () async {
        final String todayStr = DateTime.now().toIso8601String().split('T').first;
        final Result<serverpod.DailyStepTelemetry> telemetryResult =
            await _stepsAnalyticsRepository.getDailyTelemetry(todayStr).run();
        final Result<serverpod.WeeklyStepAnalytics> weeklyResult =
            await _stepsAnalyticsRepository.getWeeklyAnalytics().run();

        DailyStepTelemetry? telemetry;
        WeeklyStepAnalytics? weekly;

        telemetryResult.fold(
          _failureHandler.handleFailure,
          (serverpod.DailyStepTelemetry t) => telemetry = DailyStepTelemetry.fromServer(t),
        );

        weeklyResult.fold(
          _failureHandler.handleFailure,
          (serverpod.WeeklyStepAnalytics w) => weekly = WeeklyStepAnalytics.fromServer(w),
        );

        safeEmit(
          stateValue.copyWith(
            queryStatus: const QueryStatus.done(),
            dailyTelemetry: telemetry ?? stateValue.dailyTelemetry,
            weeklyAnalytics: weekly ?? stateValue.weeklyAnalytics,
          ),
        );
      },
    );
  }

  Future<void> syncSteps({
    required int steps,
    required String sourceDeviceId,
    required bool wasUserEntered,
  }) async {
    await safeRun(
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.loading()));
        }
      },
      onException: _failureHandler.handleException,
      action: () async {
        final String todayStr = DateTime.now().toIso8601String().split('T').first;
        final Result<serverpod.DailyStepTelemetry> syncResult = await _stepsAnalyticsRepository
            .syncSteps(
              steps: steps,
              sourceDeviceId: sourceDeviceId,
              wasUserEntered: wasUserEntered,
              date: todayStr,
            )
            .run();

        syncResult.fold(
          _failureHandler.handleFailure,
          (serverpod.DailyStepTelemetry t) {
            safeEmit(
              stateValue.copyWith(
                queryStatus: const QueryStatus.done(),
                dailyTelemetry: DailyStepTelemetry.fromServer(t),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateIntegrationStatus({
    required String provider,
    required String status,
    String? lastError,
  }) async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Result<bool> result = await _stepsAnalyticsRepository
            .updateIntegrationStatus(provider: provider, status: status, lastError: lastError)
            .run();

        result.fold(_failureHandler.handleFailure, (_) {});
      },
    );
  }
}

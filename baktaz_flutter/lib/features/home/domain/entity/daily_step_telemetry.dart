import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_step_telemetry.freezed.dart';

@freezed
abstract class DailyStepTelemetry with _$DailyStepTelemetry {
  const factory DailyStepTelemetry({
    required Number currentSteps,
    required Number goalSteps,
    required ValueString syncSource,
    required LocalDateTime lastSyncedAt,
  }) = _DailyStepTelemetry;

  const DailyStepTelemetry._();

  factory DailyStepTelemetry.fromServer(serverpod.DailyStepTelemetry model) => DailyStepTelemetry(
    currentSteps: Number(model.currentSteps),
    goalSteps: Number(model.goalSteps),
    syncSource: ValueString(model.syncSource, fieldName: 'syncSource'),
    lastSyncedAt: LocalDateTime(model.lastSyncedAt),
  );

  Option<Failure> get validate => currentSteps.validate
      .andThen(() => goalSteps.validate)
      .andThen(() => syncSource.validate)
      .fold(some, (_) => none());
}

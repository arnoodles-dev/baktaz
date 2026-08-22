import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Server-side steps repository. Throws on failure; endpoints translate to
/// client exceptions. Never returns fpdart Either — that is a Flutter pattern.
abstract interface class IStepsRepository {
  Future<DailyStepTelemetry> getDailyStepTelemetry(Session session);

  Future<WeeklyStepAnalytics> getWeeklyStepAnalytics(Session session);

  Future<DailyStepTelemetry> syncSteps(Session session, {required int steps, required String source});
}

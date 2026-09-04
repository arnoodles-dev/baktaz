import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IStepRepository {
  Future<UserDevice> registerDevice(
    Session session, {
    required String deviceModel,
    required String osVersion,
    required String appVersion,
  });

  Future<StepIntegration> updateIntegration(
    Session session, {
    required String provider,
    required String status,
    String? lastError,
  });

  Future<StepSync> syncSteps(
    Session session, {
    required String sourceDeviceId,
    required int rawSteps,
    required bool wasUserEntered,
    required String date,
  });

  Future<DailyStepTelemetry> getDailyTelemetry(Session session, String date);

  Future<WeeklyStepAnalytics> getWeeklyAnalytics(Session session);
}

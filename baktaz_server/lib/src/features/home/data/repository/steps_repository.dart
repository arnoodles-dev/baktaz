import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/home/domain/interface/i_steps_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IStepsRepository)
final class StepsRepository implements IStepsRepository {
  @override
  Future<DailyStepTelemetry> getDailyStepTelemetry(Session session) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw StateError('User not authenticated.');
    }

    final DailyStepTelemetry? result = await DailyStepTelemetry.db.findFirstRow(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId) & t.date.equals(_currentDateKey()),
    );

    if (result == null) {
      return DailyStepTelemetry(
        userId: userId,
        date: _currentDateKey(),
        currentSteps: 0,
        goalSteps: AppConfig.maxDailyStepCeiling,
        syncSource: 'none',
        lastSyncedAt: DateTime.now().toUtc(),
        isFlaggedForReview: false,
      );
    }

    return result;
  }

  @override
  Future<WeeklyStepAnalytics> getWeeklyStepAnalytics(Session session) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw StateError('User not authenticated.');
    }

    final List<DailyStepTelemetry> dailySteps = await DailyStepTelemetry.db.find(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId),
      limit: 7,
      orderBy: (DailyStepTelemetryTable t) => t.lastSyncedAt.desc(),
    );

    if (dailySteps.isEmpty) {
      return WeeklyStepAnalytics(
        weeklySteps: const <int>[0, 0, 0, 0, 0, 0, 0],
        averageSteps: 0,
        totalWeeklySteps: 0,
        goalTarget: AppConfig.maxDailyStepCeiling,
      );
    }

    final List<int> weeklySteps = dailySteps.map((DailyStepTelemetry e) => e.currentSteps).toList();
    final int totalWeeklySteps = weeklySteps.fold<int>(0, (int a, int b) => a + b);
    final int averageSteps = weeklySteps.isEmpty ? 0 : (totalWeeklySteps / weeklySteps.length).round();

    return WeeklyStepAnalytics(
      weeklySteps: weeklySteps,
      averageSteps: averageSteps,
      totalWeeklySteps: totalWeeklySteps,
      goalTarget: AppConfig.maxDailyStepCeiling,
    );
  }

  @override
  Future<DailyStepTelemetry> syncSteps(Session session, {required int steps, required String source}) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw StateError('User not authenticated.');
    }

    if (steps < 0 || steps > AppConfig.maxDailyStepCeiling) {
      throw ArgumentError('Steps out of valid range.');
    }

    final DailyStepTelemetry? existing = await DailyStepTelemetry.db.findFirstRow(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId) & t.date.equals(_currentDateKey()),
    );

    final int newSteps = (existing?.currentSteps ?? 0) > steps ? (existing?.currentSteps ?? 0) : steps;

    final DailyStepTelemetry telemetry = DailyStepTelemetry(
      userId: userId,
      date: _currentDateKey(),
      currentSteps: newSteps,
      goalSteps: existing?.goalSteps ?? AppConfig.maxDailyStepCeiling,
      syncSource: source,
      lastSyncedAt: DateTime.now().toUtc(),
      isFlaggedForReview: steps > AppConfig.maxDailyStepCeiling,
    );

    if (existing != null) {
      await DailyStepTelemetry.db.updateRow(
        session,
        existing.copyWith(
          currentSteps: newSteps,
          syncSource: source,
          lastSyncedAt: DateTime.now().toUtc(),
          isFlaggedForReview: steps > AppConfig.maxDailyStepCeiling,
        ),
      );
    } else {
      await DailyStepTelemetry.db.insertRow(session, telemetry);
    }

    return telemetry;
  }

  String _currentDateKey() => DateTime.now().toLocal().toIso8601String().split('T').first;
}

import 'dart:math' as math;

import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/steps/domain/interface/i_step_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IStepRepository)
final class StepRepository implements IStepRepository {
  UuidValue _getUserId(Session session) {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw ApiException(message: 'User not authenticated', code: ApiExceptionCode.unauthenticated);
    }
    return userId;
  }

  @override
  Future<UserDevice> registerDevice(
    Session session, {
    required String deviceModel,
    required String osVersion,
    required String appVersion,
  }) async {
    final UuidValue userId = _getUserId(session);
    final DateTime now = DateTime.now().toUtc();

    final UserDevice? existing = await UserDevice.db.findFirstRow(
      session,
      where: (UserDeviceTable t) => t.userId.equals(userId) & t.deviceModel.equals(deviceModel),
    );

    if (existing != null) {
      final UserDevice updated = existing.copyWith(osVersion: osVersion, appVersion: appVersion, lastActiveAt: now);
      await UserDevice.db.updateRow(session, updated);
      return updated;
    } else {
      final UserDevice newDevice = UserDevice(
        userId: userId,
        deviceModel: deviceModel,
        osVersion: osVersion,
        appVersion: appVersion,
        lastActiveAt: now,
        createdAt: now,
      );
      return UserDevice.db.insertRow(session, newDevice);
    }
  }

  @override
  Future<StepIntegration> updateIntegration(
    Session session, {
    required String provider,
    required String status,
    String? lastError,
  }) async {
    final UuidValue userId = _getUserId(session);
    final DateTime now = DateTime.now().toUtc();

    final StepIntegration? existing = await StepIntegration.db.findFirstRow(
      session,
      where: (StepIntegrationTable t) => t.userId.equals(userId) & t.provider.equals(provider),
    );

    final DateTime? connectedAt = status == 'connected' ? (existing?.connectedAt ?? now) : existing?.connectedAt;

    if (existing != null) {
      final StepIntegration updated = existing.copyWith(
        status: status,
        lastError: lastError,
        connectedAt: connectedAt,
        updatedAt: now,
      );
      await StepIntegration.db.updateRow(session, updated);
      return updated;
    } else {
      final StepIntegration newIntegration = StepIntegration(
        userId: userId,
        provider: provider,
        status: status,
        lastError: lastError,
        connectedAt: connectedAt,
        updatedAt: now,
      );
      return StepIntegration.db.insertRow(session, newIntegration);
    }
  }

  @override
  Future<StepSync> syncSteps(
    Session session, {
    required String sourceDeviceId,
    required int rawSteps,
    required bool wasUserEntered,
    required String date,
  }) async {
    final UuidValue userId = _getUserId(session);
    final DateTime now = DateTime.now().toUtc();

    final bool isExceedingCeiling = rawSteps > AppConfig.maxDailyStepCeiling;
    final bool isFlagged = wasUserEntered || isExceedingCeiling;

    final int filteredSteps = isFlagged ? 0 : rawSteps;
    final String syncStatus = isFlagged ? 'flagged' : 'synced';
    final String? errorMessage = wasUserEntered
        ? 'User-entered steps are rejected'
        : (isExceedingCeiling ? 'Step count exceeds daily maximum ceiling of ${AppConfig.maxDailyStepCeiling}' : null);

    return session.db.transaction((Transaction transaction) async {
      final StepSync syncRecord = StepSync(
        userId: userId,
        sourceDeviceId: sourceDeviceId,
        rawSteps: rawSteps,
        filteredSteps: filteredSteps,
        wasUserEntered: wasUserEntered,
        syncedAt: now,
        date: date,
        syncStatus: syncStatus,
        errorMessage: errorMessage,
      );
      final StepSync savedSync = await StepSync.db.insertRow(
        session,
        syncRecord,
        transaction: transaction,
      );

      final DailyStepTelemetry? existingTelemetry = await DailyStepTelemetry.db.findFirstRow(
        session,
        where: (DailyStepTelemetryTable t) => t.userId.equals(userId) & t.date.equals(date),
        transaction: transaction,
      );

      final int existingSteps = existingTelemetry?.currentSteps ?? 0;
      final int newSteps = math.max(existingSteps, filteredSteps);

      final bool telemetryFlagged = (existingTelemetry?.isFlaggedForReview ?? false) || isFlagged;

      if (existingTelemetry != null) {
        await DailyStepTelemetry.db.updateRow(
          session,
          existingTelemetry.copyWith(
            currentSteps: newSteps,
            syncSource: sourceDeviceId,
            lastSyncedAt: now,
            isFlaggedForReview: telemetryFlagged,
          ),
          transaction: transaction,
        );
      } else {
        final DailyStepTelemetry newTelemetry = DailyStepTelemetry(
          userId: userId,
          date: date,
          currentSteps: filteredSteps,
          goalSteps: AppConfig.maxDailyStepCeiling,
          syncSource: sourceDeviceId,
          lastSyncedAt: now,
          isFlaggedForReview: telemetryFlagged,
        );
        await DailyStepTelemetry.db.insertRow(
          session,
          newTelemetry,
          transaction: transaction,
        );
      }

      return savedSync;
    });
  }

  @override
  Future<DailyStepTelemetry> getDailyTelemetry(Session session, String date) async {
    final UuidValue userId = _getUserId(session);

    final DailyStepTelemetry? telemetry = await DailyStepTelemetry.db.findFirstRow(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId) & t.date.equals(date),
    );

    if (telemetry != null) {
      return telemetry;
    }

    return DailyStepTelemetry(
      userId: userId,
      date: date,
      currentSteps: 0,
      goalSteps: AppConfig.maxDailyStepCeiling,
      syncSource: 'none',
      lastSyncedAt: DateTime.now().toUtc(),
      isFlaggedForReview: false,
    );
  }

  @override
  Future<WeeklyStepAnalytics> getWeeklyAnalytics(Session session) async {
    final UuidValue userId = _getUserId(session);

    final List<DailyStepTelemetry> dailySteps = await DailyStepTelemetry.db.find(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId),
      limit: 7,
      orderBy: (DailyStepTelemetryTable t) => t.date.desc(),
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
    final int totalWeeklySteps = weeklySteps.fold<int>(0, (int sum, int val) => sum + val);
    final int averageSteps = (totalWeeklySteps / weeklySteps.length).round();

    return WeeklyStepAnalytics(
      weeklySteps: weeklySteps,
      averageSteps: averageSteps,
      totalWeeklySteps: totalWeeklySteps,
      goalTarget: AppConfig.maxDailyStepCeiling,
    );
  }
}

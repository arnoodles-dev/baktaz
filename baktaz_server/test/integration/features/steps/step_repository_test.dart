import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/steps/data/repository/step_repository.dart';
import 'package:baktaz_server/src/features/steps/domain/interface/i_step_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../../fixtures/server_fixtures.dart';
import '../../test_tools/serverpod_test_tools.dart';

void main() {
  if (!GetIt.I.isRegistered<IStepRepository>()) {
    configureDependencies();
  }

  withServerpod(
    'Given StepRepository',
    (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
      late StepRepository repository;
      final UuidValue userId = ServerFixtures.testAuthUserId;

      Session createAuthedSession() => sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              userId.toString(),
              ServerFixtures.userScopes,
            ),
          ).build();

      setUp(() {
        repository = StepRepository();
      });

      group('Authentication guard', () {
        test('throws ApiException when user is not authenticated', () async {
          final Session unauthenticatedSession = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.unauthenticated(),
          ).build();

          expect(
            () => repository.getDailyTelemetry(unauthenticatedSession, '2026-09-04'),
            throwsA(
              isA<ApiException>().having((ApiException e) => e.code, 'code', ApiExceptionCode.unauthenticated),
            ),
          );
        });
      });

      group('registerDevice', () {
        test('creates a new UserDevice when device does not exist', () async {
          final Session session = createAuthedSession();

          final UserDevice device = await repository.registerDevice(
            session,
            deviceModel: 'iPhone 15',
            osVersion: 'iOS 17.4',
            appVersion: '1.0.0',
          );

          expect(device.id, isNotNull);
          expect(device.userId, equals(userId));
          expect(device.deviceModel, equals('iPhone 15'));
          expect(device.osVersion, equals('iOS 17.4'));
          expect(device.appVersion, equals('1.0.0'));

          final UserDevice? stored = await UserDevice.db.findById(session, device.id!);
          expect(stored, isNotNull);
          expect(stored?.deviceModel, equals('iPhone 15'));
        });

        test('updates existing UserDevice when device model matches', () async {
          final Session session = createAuthedSession();

          final UserDevice initial = await repository.registerDevice(
            session,
            deviceModel: 'iPhone 15',
            osVersion: 'iOS 17.0',
            appVersion: '1.0.0',
          );

          final UserDevice updated = await repository.registerDevice(
            session,
            deviceModel: 'iPhone 15',
            osVersion: 'iOS 17.4',
            appVersion: '1.1.0',
          );

          expect(updated.id, equals(initial.id));
          expect(updated.osVersion, equals('iOS 17.4'));
          expect(updated.appVersion, equals('1.1.0'));
        });
      });

      group('updateIntegration', () {
        test('creates new StepIntegration when none exists', () async {
          final Session session = createAuthedSession();

          final StepIntegration integration = await repository.updateIntegration(
            session,
            provider: 'apple_health',
            status: 'connected',
          );

          expect(integration.id, isNotNull);
          expect(integration.userId, equals(userId));
          expect(integration.provider, equals('apple_health'));
          expect(integration.status, equals('connected'));
          expect(integration.connectedAt, isNotNull);
          expect(integration.lastError, isNull);
        });

        test('updates existing StepIntegration status and records last error', () async {
          final Session session = createAuthedSession();

          await repository.updateIntegration(
            session,
            provider: 'google_fit',
            status: 'connected',
          );

          final StepIntegration updated = await repository.updateIntegration(
            session,
            provider: 'google_fit',
            status: 'error',
            lastError: 'Permission denied',
          );

          expect(updated.status, equals('error'));
          expect(updated.lastError, equals('Permission denied'));
        });
      });

      group('syncSteps & Anti-Cheat Logic', () {
        test('flags sync for review when wasUserEntered is true', () async {
          final Session session = createAuthedSession();

          final StepSync syncResult = await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 5000,
            wasUserEntered: true,
            date: '2026-09-04',
          );

          expect(syncResult.syncStatus, equals('flagged_review'));
          expect(syncResult.errorMessage, contains('manually entered'));
          expect(syncResult.filteredSteps, equals(5000));
        });

        test('clamps steps to 30000 ceiling and flags for review when rawSteps > 30000', () async {
          final Session session = createAuthedSession();

          final StepSync syncResult = await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 35000,
            wasUserEntered: false,
            date: '2026-09-04',
          );

          expect(syncResult.syncStatus, equals('flagged_review'));
          expect(syncResult.filteredSteps, equals(AppConfig.maxDailyStepCeiling));
          expect(syncResult.errorMessage, contains('exceeds daily ceiling limit'));

          final DailyStepTelemetry telemetry = await repository.getDailyTelemetry(session, '2026-09-04');
          expect(telemetry.currentSteps, equals(AppConfig.maxDailyStepCeiling));
          expect(telemetry.isFlaggedForReview, isTrue);
        });

        test('successfully syncs valid steps when below ceiling and not manual', () async {
          final Session session = createAuthedSession();

          final StepSync syncResult = await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 8000,
            wasUserEntered: false,
            date: '2026-09-04',
          );

          expect(syncResult.syncStatus, equals('synced'));
          expect(syncResult.filteredSteps, equals(8000));
          expect(syncResult.errorMessage, isNull);

          final DailyStepTelemetry telemetry = await repository.getDailyTelemetry(session, '2026-09-04');
          expect(telemetry.currentSteps, equals(8000));
          expect(telemetry.isFlaggedForReview, isFalse);
        });

        test('enforces monotonic max step updates on DailyStepTelemetry', () async {
          final Session session = createAuthedSession();

          await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 10000,
            wasUserEntered: false,
            date: '2026-09-04',
          );

          // Lower step count attempt for the same date should not reduce currentSteps
          await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 6000,
            wasUserEntered: false,
            date: '2026-09-04',
          );

          final DailyStepTelemetry telemetry = await repository.getDailyTelemetry(session, '2026-09-04');
          expect(telemetry.currentSteps, equals(10000));

          // Higher step count attempt should increase currentSteps
          await repository.syncSteps(
            session,
            sourceDeviceId: 'dev_123',
            rawSteps: 14000,
            wasUserEntered: false,
            date: '2026-09-04',
          );

          final DailyStepTelemetry updatedTelemetry = await repository.getDailyTelemetry(session, '2026-09-04');
          expect(updatedTelemetry.currentSteps, equals(14000));
        });
      });

      group('getDailyTelemetry', () {
        test('returns default DailyStepTelemetry when no entry exists for date', () async {
          final Session session = createAuthedSession();

          final DailyStepTelemetry telemetry = await repository.getDailyTelemetry(session, '2026-09-01');
          expect(telemetry.currentSteps, equals(0));
          expect(telemetry.goalSteps, equals(AppConfig.maxDailyStepCeiling));
          expect(telemetry.syncSource, equals('none'));
          expect(telemetry.isFlaggedForReview, isFalse);
        });
      });

      group('getWeeklyAnalytics', () {
        test('returns default WeeklyStepAnalytics when user has no telemetry history', () async {
          final Session session = createAuthedSession();

          final WeeklyStepAnalytics analytics = await repository.getWeeklyAnalytics(session);
          expect(analytics.weeklySteps, equals(const <int>[0, 0, 0, 0, 0, 0, 0]));
          expect(analytics.averageSteps, equals(0));
          expect(analytics.totalWeeklySteps, equals(0));
          expect(analytics.goalTarget, equals(AppConfig.maxDailyStepCeiling));
        });

        test('computes totalWeeklySteps and averageSteps across daily telemetry entries', () async {
          final Session session = createAuthedSession();

          await DailyStepTelemetry.db.insertRow(
            session,
            DailyStepTelemetry(
              userId: userId,
              date: '2026-09-04',
              currentSteps: 10000,
              goalSteps: AppConfig.maxDailyStepCeiling,
              syncSource: 'apple_health',
              lastSyncedAt: DateTime.now().toUtc(),
              isFlaggedForReview: false,
            ),
          );

          await DailyStepTelemetry.db.insertRow(
            session,
            DailyStepTelemetry(
              userId: userId,
              date: '2026-09-03',
              currentSteps: 4000,
              goalSteps: AppConfig.maxDailyStepCeiling,
              syncSource: 'apple_health',
              lastSyncedAt: DateTime.now().toUtc(),
              isFlaggedForReview: false,
            ),
          );

          final WeeklyStepAnalytics analytics = await repository.getWeeklyAnalytics(session);
          expect(analytics.totalWeeklySteps, equals(14000));
          expect(analytics.averageSteps, equals(7000));
          expect(analytics.weeklySteps.length, equals(2));
        });
      });
    },
  );
}

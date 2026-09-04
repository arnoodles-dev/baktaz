import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/steps/domain/interface/i_step_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class StepEndpoint extends Endpoint {
  StepEndpoint([IStepRepository? stepRepository]) : _stepRepository = stepRepository ?? getIt<IStepRepository>();

  final IStepRepository _stepRepository;
  static final RegExp _dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  @override
  bool get requireLogin => true;

  Future<UserDevice> registerDevice(Session session, String deviceModel, String osVersion, String appVersion) async {
    if (deviceModel.trim().isEmpty || osVersion.trim().isEmpty || appVersion.trim().isEmpty) {
      throw ApiException(message: 'Invalid device parameters', code: ApiExceptionCode.badRequest);
    }
    return _stepRepository.registerDevice(
      session,
      deviceModel: deviceModel,
      osVersion: osVersion,
      appVersion: appVersion,
    );
  }

  Future<StepIntegration> updateIntegrationStatus(
    Session session,
    String provider,
    String status,
    String? lastError,
  ) async {
    if (provider.trim().isEmpty || status.trim().isEmpty) {
      throw ApiException(message: 'Invalid integration parameters', code: ApiExceptionCode.badRequest);
    }
    return _stepRepository.updateIntegration(session, provider: provider, status: status, lastError: lastError);
  }

  Future<StepSync> syncStepData(
    Session session, {
    required String sourceDeviceId,
    required int rawSteps,
    required bool wasUserEntered,
    required String date,
  }) async {
    if (sourceDeviceId.trim().isEmpty || rawSteps < 0) {
      throw ApiException(message: 'Invalid step sync data', code: ApiExceptionCode.badRequest);
    }
    if (!_dateRegExp.hasMatch(date)) {
      throw ApiException(message: 'Invalid date format', code: ApiExceptionCode.badRequest);
    }
    return _stepRepository.syncSteps(
      session,
      sourceDeviceId: sourceDeviceId,
      rawSteps: rawSteps,
      wasUserEntered: wasUserEntered,
      date: date,
    );
  }

  Future<DailyStepTelemetry> getDailyTelemetry(Session session, String date) async {
    if (!_dateRegExp.hasMatch(date)) {
      throw ApiException(message: 'Invalid date format', code: ApiExceptionCode.badRequest);
    }
    return _stepRepository.getDailyTelemetry(session, date);
  }

  Future<WeeklyStepAnalytics> getWeeklyAnalytics(Session session) =>
      _stepRepository.getWeeklyAnalytics(session);
}

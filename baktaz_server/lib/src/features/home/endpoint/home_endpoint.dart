import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/home/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_server/src/features/home/domain/interface/i_steps_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class HomeEndpoint extends Endpoint {
  HomeEndpoint([IStepsRepository? stepsRepository, IChallengeRepository? challengeRepository])
    : _stepsRepository = stepsRepository ?? getIt<IStepsRepository>(),
      _challengeRepository = challengeRepository ?? getIt<IChallengeRepository>();

  final IStepsRepository _stepsRepository;
  final IChallengeRepository _challengeRepository;

  @override
  bool get requireLogin => true;

  Future<DailyStepTelemetry> getDailyStepTelemetry(Session session) async =>
      _stepsRepository.getDailyStepTelemetry(session);

  Future<WeeklyStepAnalytics> getWeeklyStepAnalytics(Session session) async =>
      _stepsRepository.getWeeklyStepAnalytics(session);

  Future<ActiveChallengeSummary?> getActiveChallengeSummary(Session session) async =>
      _challengeRepository.getActiveChallengeSummary(session);

  Future<List<HomeLeaderboardEntry>> getLeaderboardPreview(Session session) async =>
      _challengeRepository.getLeaderboardPreview(session);

  Future<DailyStepTelemetry> syncSteps(Session session, int steps, String source) async =>
      _stepsRepository.syncSteps(session, steps: steps, source: source);
}

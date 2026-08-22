import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Server-side challenge repository. Throws on failure; endpoints translate
/// to client exceptions. Never returns fpdart Either — Flutter-only pattern.
abstract interface class IChallengeRepository {
  Future<ActiveChallengeSummary?> getActiveChallengeSummary(Session session);

  Future<List<HomeLeaderboardEntry>> getLeaderboardPreview(Session session);
}

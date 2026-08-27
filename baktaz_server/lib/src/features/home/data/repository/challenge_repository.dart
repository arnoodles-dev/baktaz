import 'package:baktaz_server/src/features/home/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IChallengeRepository)
final class ChallengeRepository implements IChallengeRepository {
  @override
  Future<ActiveChallengeSummary?> getActiveChallengeSummary(Session session) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw ApiException(message: 'User not authenticated', code: ApiExceptionCode.unauthenticated);
    }

    // TODO: Implement actual logic to fetch active challenge summary
    // For now, return null to indicate no active challenge
    return null;
  }

  @override
  Future<List<HomeLeaderboardEntry>> getLeaderboardPreview(Session session) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) {
      throw ApiException(message: 'User not authenticated', code: ApiExceptionCode.unauthenticated);
    }

    // TODO: Implement actual logic to fetch leaderboard preview
    // For now, return empty list
    return const <HomeLeaderboardEntry>[];
  }
}

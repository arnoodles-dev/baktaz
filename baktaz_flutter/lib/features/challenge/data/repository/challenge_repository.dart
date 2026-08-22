import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/app/helpers/utils/retry_utils.dart';
import 'package:baktaz_flutter/features/challenge/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_flutter/features/home/domain/entity/active_challenge_summary.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IChallengeRepository)
final class ChallengeRepository implements IChallengeRepository {
  const ChallengeRepository(this._serverpod, this._retry, this._talker);

  final Serverpod _serverpod;
  final RetryOptions _retry;
  final Talker _talker;

  @override
  TaskResult<ActiveChallengeSummary?> getActiveChallengeSummary() => TaskResult<ActiveChallengeSummary?>.tryCatch(
    () async {
      final serverpod.ActiveChallengeSummary? result = await _retry.retry(
        () => _serverpod.client.home.getActiveChallengeSummary(),
        retryIf: RetryUtils.isRetryableException,
      );

      if (result == null) {
        return null;
      }

      final ActiveChallengeSummary summary = ActiveChallengeSummary.fromServer(result);
      if (summary.validate.isSome()) {
        throw summary.validate.asSome();
      }

      return summary;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.serverpod(error.toString());
    },
  );

  @override
  TaskResult<List<HomeLeaderboardEntry>> getLeaderboardPreview() => TaskResult<List<HomeLeaderboardEntry>>.tryCatch(
    () async {
      final List<serverpod.HomeLeaderboardEntry> result = await _retry.retry(
        () => _serverpod.client.home.getLeaderboardPreview(),
        retryIf: RetryUtils.isRetryableException,
      );

      return result.map(HomeLeaderboardEntry.fromServer).toList();
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.serverpod(error.toString());
    },
  );
}

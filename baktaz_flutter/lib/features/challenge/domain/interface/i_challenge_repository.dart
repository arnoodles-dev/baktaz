import 'package:baktaz_flutter/features/home/domain/entity/active_challenge_summary.dart';
import 'package:baktaz_flutter/features/home/domain/entity/home_leaderboard_entry.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract interface class IChallengeRepository {
  TaskResult<ActiveChallengeSummary?> getActiveChallengeSummary();
  TaskResult<List<HomeLeaderboardEntry>> getLeaderboardPreview();
}

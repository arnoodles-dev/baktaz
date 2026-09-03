import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_summary.freezed.dart';

@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required serverpod.UuidValue userId,
    required bool isPremium,
    required int totalSteps,
    required int activeChallengeCount,
    required String fullName,
    required String username,
    required String? avatarUrl,
    required int challengesJoined,
    required int challengesWon,
    required double winRatePercentage,
    required bool isHostTier,
    required bool isStepsSyncActive,
    required DateTime? memberSince,
    required int avgStepsPerDay,
    required UserRank rank,
  }) = _AccountSummary;

  const AccountSummary._();

  factory AccountSummary.fromServer(serverpod.AccountSummary accountSummary) => AccountSummary(
        userId: accountSummary.userId,
        isPremium: accountSummary.isPremium,
        totalSteps: accountSummary.totalSteps,
        activeChallengeCount: accountSummary.activeChallengeCount,
        fullName: accountSummary.fullName,
        username: accountSummary.username,
        avatarUrl: accountSummary.avatarUrl,
        challengesJoined: accountSummary.challengesJoined,
        challengesWon: accountSummary.challengesWon,
        winRatePercentage: accountSummary.winRatePercentage,
        isHostTier: accountSummary.isHostTier,
        isStepsSyncActive: accountSummary.isStepsSyncActive,
        memberSince: accountSummary.memberSince,
        avgStepsPerDay: accountSummary.avgStepsPerDay,
        rank: UserRank.fromRank(accountSummary.rank.name),
      );
}

import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountSummary', () {
    test('fromServer maps avgStepsPerDay and rank', () {
      final serverpod.AccountSummary serverSummary = serverpod.AccountSummary(
        userId: serverpod.UuidValue.fromString('12345678-1234-1234-1234-123456789012'),
        isPremium: false,
        totalSteps: 600,
        activeChallengeCount: 1,
        fullName: 'Test User',
        username: 'testuser',
        challengesJoined: 5,
        challengesWon: 3,
        winRatePercentage: 60,
        isHostTier: false,
        isStepsSyncActive: true,
        memberSince: DateTime(2024),
        avgStepsPerDay: 200,
        rank: serverpod.Rank.bronze,
      );

      final AccountSummary summary = AccountSummary.fromServer(serverSummary);
      expect(summary.avgStepsPerDay, 200);
      expect(summary.rank, UserRank.bronze());
    });

    test('fromServer maps all existing fields correctly', () {
      final serverpod.AccountSummary serverSummary = serverpod.AccountSummary(
        userId: serverpod.UuidValue.fromString('12345678-1234-1234-1234-123456789012'),
        isPremium: true,
        totalSteps: 10000,
        activeChallengeCount: 2,
        fullName: 'John Doe',
        username: 'johndoe',
        challengesJoined: 10,
        challengesWon: 5,
        winRatePercentage: 50,
        isHostTier: true,
        isStepsSyncActive: false,
        memberSince: DateTime(2023, 6, 15),
        avatarUrl: 'https://example.com/avatar.jpg',
        avgStepsPerDay: 500,
        rank: serverpod.Rank.gold,
      );

      final AccountSummary summary = AccountSummary.fromServer(serverSummary);
      expect(summary.userId.toString(), '12345678-1234-1234-1234-123456789012');
      expect(summary.isPremium, true);
      expect(summary.totalSteps, 10000);
      expect(summary.challengesJoined, 10);
      expect(summary.challengesWon, 5);
      expect(summary.fullName, 'John Doe');
      expect(summary.username, 'johndoe');
      expect(summary.isHostTier, true);
      expect(summary.isStepsSyncActive, false);
      expect(summary.memberSince, DateTime(2023, 6, 15));
      expect(summary.avatarUrl, 'https://example.com/avatar.jpg');
      expect(summary.rank, UserRank.gold());
    });
  });
}

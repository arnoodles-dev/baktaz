import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Account Models Validation', () {
    test('instantiates AccountSummary correctly and serializes to/from JSON', () {
      final UuidValue userId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');
      final AccountSummary summary = AccountSummary(
        userId: userId,
        isPremium: true,
        totalSteps: 12500,
        activeChallengeCount: 3,
        fullName: '',
        username: '',
        challengesJoined: 0,
        challengesWon: 0,
        winRatePercentage: 0,
        isHostTier: false,
        isStepsSyncActive: false,
        avgStepsPerDay: 0,
        rank: Rank.unknown,
      );

      expect(summary.userId, equals(userId));
      expect(summary.isPremium, isTrue);
      expect(summary.totalSteps, equals(12500));
      expect(summary.activeChallengeCount, equals(3));

      final Map<String, dynamic> json = summary.toJson();
      final AccountSummary restored = AccountSummary.fromJson(json);

      expect(restored.userId, equals(userId));
      expect(restored.isPremium, isTrue);
      expect(restored.totalSteps, equals(12500));
      expect(restored.activeChallengeCount, equals(3));
    });

    test('instantiates UserInfo correctly and handles nullability and JSON serialization', () {
      final UuidValue id = UuidValue.fromString('00000000-0000-4000-8000-000000000002');
      final UuidValue userIdentifier = UuidValue.fromString('00000000-0000-4000-8000-000000000003');
      final DateTime now = DateTime.utc(2026, 8, 31);

      final UserInfo userInfo = UserInfo(
        id: id,
        userIdentifier: userIdentifier,
        email: 'test@example.com',
        firstName: 'Jane',
        lastName: 'Doe',
        username: 'janedoe',
        gender: Gender.female,
        birthday: now,
        mobileNumber: '+1234567890',
        createdAt: now,
        updatedAt: now,
      );

      expect(userInfo.id, equals(id));
      expect(userInfo.userIdentifier, equals(userIdentifier));
      expect(userInfo.email, equals('test@example.com'));
      expect(userInfo.firstName, equals('Jane'));
      expect(userInfo.lastName, equals('Doe'));
      expect(userInfo.username, equals('janedoe'));
      expect(userInfo.gender, equals(Gender.female));
      expect(userInfo.birthday, equals(now));
      expect(userInfo.mobileNumber, equals('+1234567890'));

      final Map<String, dynamic> json = userInfo.toJson();
      final UserInfo restored = UserInfo.fromJson(json);

      expect(restored.id, equals(id));
      expect(restored.userIdentifier, equals(userIdentifier));
      expect(restored.email, equals('test@example.com'));
      expect(restored.username, equals('janedoe'));
      expect(restored.gender, equals(Gender.female));
    });
  });
}

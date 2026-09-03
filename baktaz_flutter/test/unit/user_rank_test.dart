import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRank', () {
    test('unknown has correct label, color, assetPath', () {
      final UserRank rank = UserRank.unknown();
      expect(rank.label, 'Unknown');
      expect(rank.color, const Color(0xFF9E9E9E));
      expect(rank.assetPath, 'assets/rank/unknown.png');
    });

    test('bronze has correct label, color, assetPath', () {
      final UserRank rank = UserRank.bronze();
      expect(rank.label, 'Bronze');
      expect(rank.color, const Color(0xFF8B4513));
      expect(rank.assetPath, 'assets/rank/bronze.png');
    });

    test('silver has correct label, color, assetPath', () {
      final UserRank rank = UserRank.silver();
      expect(rank.label, 'Silver');
      expect(rank.color, const Color(0xFFC0C0C0));
      expect(rank.assetPath, 'assets/rank/silver.png');
    });

    test('gold has correct label, color, assetPath', () {
      final UserRank rank = UserRank.gold();
      expect(rank.label, 'Gold');
      expect(rank.color, const Color(0xFFDAA520));
      expect(rank.assetPath, 'assets/rank/gold.png');
    });

    test('platinum has correct label, color, assetPath', () {
      final UserRank rank = UserRank.platinum();
      expect(rank.label, 'Platinum');
      expect(rank.color, const Color(0xFFB3C9E0));
      expect(rank.assetPath, 'assets/rank/platinum.png');
    });

    test('diamond has correct label, color, assetPath', () {
      final UserRank rank = UserRank.diamond();
      expect(rank.label, 'Diamond');
      expect(rank.color, const Color(0xFF00CED1));
      expect(rank.assetPath, 'assets/rank/diamond.png');
    });

    test('challengers has correct label, color, assetPath', () {
      final UserRank rank = UserRank.challengers();
      expect(rank.label, 'Challengers');
      expect(rank.color, const Color(0xFF800080));
      expect(rank.assetPath, 'assets/rank/challengers.png');
    });

    test('fromRank maps known rank values correctly', () {
      expect(UserRank.fromRank('bronze'), UserRank.bronze());
      expect(UserRank.fromRank('silver'), UserRank.silver());
      expect(UserRank.fromRank('gold'), UserRank.gold());
      expect(UserRank.fromRank('platinum'), UserRank.platinum());
      expect(UserRank.fromRank('diamond'), UserRank.diamond());
      expect(UserRank.fromRank('challengers'), UserRank.challengers());
    });

    test('fromRank returns unknown for unknown values', () {
      expect(UserRank.fromRank('unknown'), UserRank.unknown());
      expect(UserRank.fromRank(''), UserRank.unknown());
    });
  });
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_rank.freezed.dart';

@freezed
abstract class UserRank with _$UserRank {
  const factory UserRank({
    required String label,
    required Color color,
    required String assetPath,
  }) = _UserRank;

  const UserRank._();

  factory UserRank.unknown() => const UserRank(
        label: 'Unknown',
        color: Color(0xFF9E9E9E),
        assetPath: 'assets/rank/unknown.png',
      );

  factory UserRank.bronze() => const UserRank(
        label: 'Bronze',
        color: Color(0xFF8B4513),
        assetPath: 'assets/rank/bronze.png',
      );

  factory UserRank.silver() => const UserRank(
        label: 'Silver',
        color: Color(0xFFC0C0C0),
        assetPath: 'assets/rank/silver.png',
      );

  factory UserRank.gold() => const UserRank(
        label: 'Gold',
        color: Color(0xFFDAA520),
        assetPath: 'assets/rank/gold.png',
      );

  factory UserRank.platinum() => const UserRank(
        label: 'Platinum',
        color: Color(0xFFB3C9E0),
        assetPath: 'assets/rank/platinum.png',
      );

  factory UserRank.diamond() => const UserRank(
        label: 'Diamond',
        color: Color(0xFF00CED1),
        assetPath: 'assets/rank/diamond.png',
      );

  factory UserRank.challengers() => const UserRank(
        label: 'Challengers',
        color: Color(0xFF800080),
        assetPath: 'assets/rank/challengers.png',
      );

  factory UserRank.fromRank(String rankValue) => switch (rankValue) {
    'bronze' => UserRank.bronze(),
    'silver' => UserRank.silver(),
    'gold' => UserRank.gold(),
    'platinum' => UserRank.platinum(),
    'diamond' => UserRank.diamond(),
    'challengers' => UserRank.challengers(),
    _ => UserRank.unknown(),
  };
}

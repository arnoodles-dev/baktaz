/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../../features/account/domain/model/rank.dart' as _i2;

abstract class AccountSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AccountSummary._({
    required this.userId,
    required this.isPremium,
    required this.totalSteps,
    required this.activeChallengeCount,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    required this.challengesJoined,
    required this.challengesWon,
    required this.winRatePercentage,
    required this.isHostTier,
    required this.isStepsSyncActive,
    this.memberSince,
    required this.avgStepsPerDay,
    required this.rank,
  });

  factory AccountSummary({
    required _i1.UuidValue userId,
    required bool isPremium,
    required int totalSteps,
    required int activeChallengeCount,
    required String fullName,
    required String username,
    String? avatarUrl,
    required int challengesJoined,
    required int challengesWon,
    required double winRatePercentage,
    required bool isHostTier,
    required bool isStepsSyncActive,
    DateTime? memberSince,
    required int avgStepsPerDay,
    required _i2.Rank rank,
  }) = _AccountSummaryImpl;

  factory AccountSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountSummary(
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      isPremium: _i1.BoolJsonExtension.fromJson(jsonSerialization['isPremium']),
      totalSteps: jsonSerialization['totalSteps'] as int,
      activeChallengeCount: jsonSerialization['activeChallengeCount'] as int,
      fullName: jsonSerialization['fullName'] as String,
      username: jsonSerialization['username'] as String,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      challengesJoined: jsonSerialization['challengesJoined'] as int,
      challengesWon: jsonSerialization['challengesWon'] as int,
      winRatePercentage: (jsonSerialization['winRatePercentage'] as num)
          .toDouble(),
      isHostTier: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isHostTier'],
      ),
      isStepsSyncActive: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isStepsSyncActive'],
      ),
      memberSince: jsonSerialization['memberSince'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['memberSince'],
            ),
      avgStepsPerDay: jsonSerialization['avgStepsPerDay'] as int,
      rank: _i2.Rank.fromJson((jsonSerialization['rank'] as String)),
    );
  }

  _i1.UuidValue userId;

  bool isPremium;

  int totalSteps;

  int activeChallengeCount;

  String fullName;

  String username;

  String? avatarUrl;

  int challengesJoined;

  int challengesWon;

  double winRatePercentage;

  bool isHostTier;

  bool isStepsSyncActive;

  DateTime? memberSince;

  int avgStepsPerDay;

  _i2.Rank rank;

  /// Returns a shallow copy of this [AccountSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountSummary copyWith({
    _i1.UuidValue? userId,
    bool? isPremium,
    int? totalSteps,
    int? activeChallengeCount,
    String? fullName,
    String? username,
    String? avatarUrl,
    int? challengesJoined,
    int? challengesWon,
    double? winRatePercentage,
    bool? isHostTier,
    bool? isStepsSyncActive,
    DateTime? memberSince,
    int? avgStepsPerDay,
    _i2.Rank? rank,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountSummary',
      'userId': userId.toJson(),
      'isPremium': isPremium,
      'totalSteps': totalSteps,
      'activeChallengeCount': activeChallengeCount,
      'fullName': fullName,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'challengesJoined': challengesJoined,
      'challengesWon': challengesWon,
      'winRatePercentage': winRatePercentage,
      'isHostTier': isHostTier,
      'isStepsSyncActive': isStepsSyncActive,
      if (memberSince != null) 'memberSince': memberSince?.toJson(),
      'avgStepsPerDay': avgStepsPerDay,
      'rank': rank.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountSummary',
      'userId': userId.toJson(),
      'isPremium': isPremium,
      'totalSteps': totalSteps,
      'activeChallengeCount': activeChallengeCount,
      'fullName': fullName,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'challengesJoined': challengesJoined,
      'challengesWon': challengesWon,
      'winRatePercentage': winRatePercentage,
      'isHostTier': isHostTier,
      'isStepsSyncActive': isStepsSyncActive,
      if (memberSince != null) 'memberSince': memberSince?.toJson(),
      'avgStepsPerDay': avgStepsPerDay,
      'rank': rank.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountSummaryImpl extends AccountSummary {
  _AccountSummaryImpl({
    required _i1.UuidValue userId,
    required bool isPremium,
    required int totalSteps,
    required int activeChallengeCount,
    required String fullName,
    required String username,
    String? avatarUrl,
    required int challengesJoined,
    required int challengesWon,
    required double winRatePercentage,
    required bool isHostTier,
    required bool isStepsSyncActive,
    DateTime? memberSince,
    required int avgStepsPerDay,
    required _i2.Rank rank,
  }) : super._(
         userId: userId,
         isPremium: isPremium,
         totalSteps: totalSteps,
         activeChallengeCount: activeChallengeCount,
         fullName: fullName,
         username: username,
         avatarUrl: avatarUrl,
         challengesJoined: challengesJoined,
         challengesWon: challengesWon,
         winRatePercentage: winRatePercentage,
         isHostTier: isHostTier,
         isStepsSyncActive: isStepsSyncActive,
         memberSince: memberSince,
         avgStepsPerDay: avgStepsPerDay,
         rank: rank,
       );

  /// Returns a shallow copy of this [AccountSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountSummary copyWith({
    _i1.UuidValue? userId,
    bool? isPremium,
    int? totalSteps,
    int? activeChallengeCount,
    String? fullName,
    String? username,
    Object? avatarUrl = _Undefined,
    int? challengesJoined,
    int? challengesWon,
    double? winRatePercentage,
    bool? isHostTier,
    bool? isStepsSyncActive,
    Object? memberSince = _Undefined,
    int? avgStepsPerDay,
    _i2.Rank? rank,
  }) {
    return AccountSummary(
      userId: userId ?? this.userId,
      isPremium: isPremium ?? this.isPremium,
      totalSteps: totalSteps ?? this.totalSteps,
      activeChallengeCount: activeChallengeCount ?? this.activeChallengeCount,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      challengesJoined: challengesJoined ?? this.challengesJoined,
      challengesWon: challengesWon ?? this.challengesWon,
      winRatePercentage: winRatePercentage ?? this.winRatePercentage,
      isHostTier: isHostTier ?? this.isHostTier,
      isStepsSyncActive: isStepsSyncActive ?? this.isStepsSyncActive,
      memberSince: memberSince is DateTime? ? memberSince : this.memberSince,
      avgStepsPerDay: avgStepsPerDay ?? this.avgStepsPerDay,
      rank: rank ?? this.rank,
    );
  }
}

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

abstract class HomeLeaderboardEntry
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  HomeLeaderboardEntry._({
    required this.rank,
    required this.username,
    this.avatarUrl,
    required this.steps,
    required this.avgSteps,
    required this.trend,
  });

  factory HomeLeaderboardEntry({
    required int rank,
    required String username,
    Uri? avatarUrl,
    required int steps,
    required String avgSteps,
    required String trend,
  }) = _HomeLeaderboardEntryImpl;

  factory HomeLeaderboardEntry.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HomeLeaderboardEntry(
      rank: jsonSerialization['rank'] as int,
      username: jsonSerialization['username'] as String,
      avatarUrl: jsonSerialization['avatarUrl'] == null
          ? null
          : _i1.UriJsonExtension.fromJson(jsonSerialization['avatarUrl']),
      steps: jsonSerialization['steps'] as int,
      avgSteps: jsonSerialization['avgSteps'] as String,
      trend: jsonSerialization['trend'] as String,
    );
  }

  int rank;

  String username;

  Uri? avatarUrl;

  int steps;

  String avgSteps;

  String trend;

  /// Returns a shallow copy of this [HomeLeaderboardEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HomeLeaderboardEntry copyWith({
    int? rank,
    String? username,
    Uri? avatarUrl,
    int? steps,
    String? avgSteps,
    String? trend,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HomeLeaderboardEntry',
      'rank': rank,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl?.toJson(),
      'steps': steps,
      'avgSteps': avgSteps,
      'trend': trend,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HomeLeaderboardEntry',
      'rank': rank,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl?.toJson(),
      'steps': steps,
      'avgSteps': avgSteps,
      'trend': trend,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HomeLeaderboardEntryImpl extends HomeLeaderboardEntry {
  _HomeLeaderboardEntryImpl({
    required int rank,
    required String username,
    Uri? avatarUrl,
    required int steps,
    required String avgSteps,
    required String trend,
  }) : super._(
         rank: rank,
         username: username,
         avatarUrl: avatarUrl,
         steps: steps,
         avgSteps: avgSteps,
         trend: trend,
       );

  /// Returns a shallow copy of this [HomeLeaderboardEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HomeLeaderboardEntry copyWith({
    int? rank,
    String? username,
    Object? avatarUrl = _Undefined,
    int? steps,
    String? avgSteps,
    String? trend,
  }) {
    return HomeLeaderboardEntry(
      rank: rank ?? this.rank,
      username: username ?? this.username,
      avatarUrl: avatarUrl is Uri? ? avatarUrl : this.avatarUrl,
      steps: steps ?? this.steps,
      avgSteps: avgSteps ?? this.avgSteps,
      trend: trend ?? this.trend,
    );
  }
}

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
import 'package:baktaz_client/src/protocol/protocol.dart' as _i2;

abstract class ActiveChallengeSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ActiveChallengeSummary._({
    required this.isEnrolled,
    this.title,
    this.rank,
    this.totalParticipants,
    this.prizePoolText,
    this.gapText,
    this.leaders,
    this.currentDay,
    this.totalDays,
  });

  factory ActiveChallengeSummary({
    required bool isEnrolled,
    String? title,
    int? rank,
    int? totalParticipants,
    String? prizePoolText,
    String? gapText,
    List<String>? leaders,
    int? currentDay,
    int? totalDays,
  }) = _ActiveChallengeSummaryImpl;

  factory ActiveChallengeSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ActiveChallengeSummary(
      isEnrolled: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isEnrolled'],
      ),
      title: jsonSerialization['title'] as String?,
      rank: jsonSerialization['rank'] as int?,
      totalParticipants: jsonSerialization['totalParticipants'] as int?,
      prizePoolText: jsonSerialization['prizePoolText'] as String?,
      gapText: jsonSerialization['gapText'] as String?,
      leaders: jsonSerialization['leaders'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['leaders'],
            ),
      currentDay: jsonSerialization['currentDay'] as int?,
      totalDays: jsonSerialization['totalDays'] as int?,
    );
  }

  bool isEnrolled;

  String? title;

  int? rank;

  int? totalParticipants;

  String? prizePoolText;

  String? gapText;

  List<String>? leaders;

  int? currentDay;

  int? totalDays;

  /// Returns a shallow copy of this [ActiveChallengeSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ActiveChallengeSummary copyWith({
    bool? isEnrolled,
    String? title,
    int? rank,
    int? totalParticipants,
    String? prizePoolText,
    String? gapText,
    List<String>? leaders,
    int? currentDay,
    int? totalDays,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ActiveChallengeSummary',
      'isEnrolled': isEnrolled,
      if (title != null) 'title': title,
      if (rank != null) 'rank': rank,
      if (totalParticipants != null) 'totalParticipants': totalParticipants,
      if (prizePoolText != null) 'prizePoolText': prizePoolText,
      if (gapText != null) 'gapText': gapText,
      if (leaders != null) 'leaders': leaders?.toJson(),
      if (currentDay != null) 'currentDay': currentDay,
      if (totalDays != null) 'totalDays': totalDays,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ActiveChallengeSummary',
      'isEnrolled': isEnrolled,
      if (title != null) 'title': title,
      if (rank != null) 'rank': rank,
      if (totalParticipants != null) 'totalParticipants': totalParticipants,
      if (prizePoolText != null) 'prizePoolText': prizePoolText,
      if (gapText != null) 'gapText': gapText,
      if (leaders != null) 'leaders': leaders?.toJson(),
      if (currentDay != null) 'currentDay': currentDay,
      if (totalDays != null) 'totalDays': totalDays,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ActiveChallengeSummaryImpl extends ActiveChallengeSummary {
  _ActiveChallengeSummaryImpl({
    required bool isEnrolled,
    String? title,
    int? rank,
    int? totalParticipants,
    String? prizePoolText,
    String? gapText,
    List<String>? leaders,
    int? currentDay,
    int? totalDays,
  }) : super._(
         isEnrolled: isEnrolled,
         title: title,
         rank: rank,
         totalParticipants: totalParticipants,
         prizePoolText: prizePoolText,
         gapText: gapText,
         leaders: leaders,
         currentDay: currentDay,
         totalDays: totalDays,
       );

  /// Returns a shallow copy of this [ActiveChallengeSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ActiveChallengeSummary copyWith({
    bool? isEnrolled,
    Object? title = _Undefined,
    Object? rank = _Undefined,
    Object? totalParticipants = _Undefined,
    Object? prizePoolText = _Undefined,
    Object? gapText = _Undefined,
    Object? leaders = _Undefined,
    Object? currentDay = _Undefined,
    Object? totalDays = _Undefined,
  }) {
    return ActiveChallengeSummary(
      isEnrolled: isEnrolled ?? this.isEnrolled,
      title: title is String? ? title : this.title,
      rank: rank is int? ? rank : this.rank,
      totalParticipants: totalParticipants is int?
          ? totalParticipants
          : this.totalParticipants,
      prizePoolText: prizePoolText is String?
          ? prizePoolText
          : this.prizePoolText,
      gapText: gapText is String? ? gapText : this.gapText,
      leaders: leaders is List<String>?
          ? leaders
          : this.leaders?.map((e0) => e0).toList(),
      currentDay: currentDay is int? ? currentDay : this.currentDay,
      totalDays: totalDays is int? ? totalDays : this.totalDays,
    );
  }
}

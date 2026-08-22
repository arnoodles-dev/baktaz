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

abstract class WeeklyStepAnalytics
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  WeeklyStepAnalytics._({
    required this.weeklySteps,
    required this.averageSteps,
    required this.totalWeeklySteps,
    required this.goalTarget,
  });

  factory WeeklyStepAnalytics({
    required List<int> weeklySteps,
    required int averageSteps,
    required int totalWeeklySteps,
    required int goalTarget,
  }) = _WeeklyStepAnalyticsImpl;

  factory WeeklyStepAnalytics.fromJson(Map<String, dynamic> jsonSerialization) {
    return WeeklyStepAnalytics(
      weeklySteps: _i2.Protocol().deserialize<List<int>>(
        jsonSerialization['weeklySteps'],
      ),
      averageSteps: jsonSerialization['averageSteps'] as int,
      totalWeeklySteps: jsonSerialization['totalWeeklySteps'] as int,
      goalTarget: jsonSerialization['goalTarget'] as int,
    );
  }

  List<int> weeklySteps;

  int averageSteps;

  int totalWeeklySteps;

  int goalTarget;

  /// Returns a shallow copy of this [WeeklyStepAnalytics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WeeklyStepAnalytics copyWith({
    List<int>? weeklySteps,
    int? averageSteps,
    int? totalWeeklySteps,
    int? goalTarget,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WeeklyStepAnalytics',
      'weeklySteps': weeklySteps.toJson(),
      'averageSteps': averageSteps,
      'totalWeeklySteps': totalWeeklySteps,
      'goalTarget': goalTarget,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WeeklyStepAnalytics',
      'weeklySteps': weeklySteps.toJson(),
      'averageSteps': averageSteps,
      'totalWeeklySteps': totalWeeklySteps,
      'goalTarget': goalTarget,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _WeeklyStepAnalyticsImpl extends WeeklyStepAnalytics {
  _WeeklyStepAnalyticsImpl({
    required List<int> weeklySteps,
    required int averageSteps,
    required int totalWeeklySteps,
    required int goalTarget,
  }) : super._(
         weeklySteps: weeklySteps,
         averageSteps: averageSteps,
         totalWeeklySteps: totalWeeklySteps,
         goalTarget: goalTarget,
       );

  /// Returns a shallow copy of this [WeeklyStepAnalytics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WeeklyStepAnalytics copyWith({
    List<int>? weeklySteps,
    int? averageSteps,
    int? totalWeeklySteps,
    int? goalTarget,
  }) {
    return WeeklyStepAnalytics(
      weeklySteps: weeklySteps ?? this.weeklySteps.map((e0) => e0).toList(),
      averageSteps: averageSteps ?? this.averageSteps,
      totalWeeklySteps: totalWeeklySteps ?? this.totalWeeklySteps,
      goalTarget: goalTarget ?? this.goalTarget,
    );
  }
}

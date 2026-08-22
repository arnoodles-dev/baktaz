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

abstract class DailyStepTelemetry
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DailyStepTelemetry._({
    this.id,
    required this.userId,
    required this.date,
    required this.currentSteps,
    required this.goalSteps,
    required this.syncSource,
    required this.lastSyncedAt,
    required this.isFlaggedForReview,
  });

  factory DailyStepTelemetry({
    int? id,
    required _i1.UuidValue userId,
    required String date,
    required int currentSteps,
    required int goalSteps,
    required String syncSource,
    required DateTime lastSyncedAt,
    required bool isFlaggedForReview,
  }) = _DailyStepTelemetryImpl;

  factory DailyStepTelemetry.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyStepTelemetry(
      id: jsonSerialization['id'] as int?,
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      date: jsonSerialization['date'] as String,
      currentSteps: jsonSerialization['currentSteps'] as int,
      goalSteps: jsonSerialization['goalSteps'] as int,
      syncSource: jsonSerialization['syncSource'] as String,
      lastSyncedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSyncedAt'],
      ),
      isFlaggedForReview: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isFlaggedForReview'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue userId;

  String date;

  int currentSteps;

  int goalSteps;

  String syncSource;

  DateTime lastSyncedAt;

  bool isFlaggedForReview;

  /// Returns a shallow copy of this [DailyStepTelemetry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyStepTelemetry copyWith({
    int? id,
    _i1.UuidValue? userId,
    String? date,
    int? currentSteps,
    int? goalSteps,
    String? syncSource,
    DateTime? lastSyncedAt,
    bool? isFlaggedForReview,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyStepTelemetry',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'date': date,
      'currentSteps': currentSteps,
      'goalSteps': goalSteps,
      'syncSource': syncSource,
      'lastSyncedAt': lastSyncedAt.toJson(),
      'isFlaggedForReview': isFlaggedForReview,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyStepTelemetry',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      'date': date,
      'currentSteps': currentSteps,
      'goalSteps': goalSteps,
      'syncSource': syncSource,
      'lastSyncedAt': lastSyncedAt.toJson(),
      'isFlaggedForReview': isFlaggedForReview,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyStepTelemetryImpl extends DailyStepTelemetry {
  _DailyStepTelemetryImpl({
    int? id,
    required _i1.UuidValue userId,
    required String date,
    required int currentSteps,
    required int goalSteps,
    required String syncSource,
    required DateTime lastSyncedAt,
    required bool isFlaggedForReview,
  }) : super._(
         id: id,
         userId: userId,
         date: date,
         currentSteps: currentSteps,
         goalSteps: goalSteps,
         syncSource: syncSource,
         lastSyncedAt: lastSyncedAt,
         isFlaggedForReview: isFlaggedForReview,
       );

  /// Returns a shallow copy of this [DailyStepTelemetry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyStepTelemetry copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    String? date,
    int? currentSteps,
    int? goalSteps,
    String? syncSource,
    DateTime? lastSyncedAt,
    bool? isFlaggedForReview,
  }) {
    return DailyStepTelemetry(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      currentSteps: currentSteps ?? this.currentSteps,
      goalSteps: goalSteps ?? this.goalSteps,
      syncSource: syncSource ?? this.syncSource,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isFlaggedForReview: isFlaggedForReview ?? this.isFlaggedForReview,
    );
  }
}

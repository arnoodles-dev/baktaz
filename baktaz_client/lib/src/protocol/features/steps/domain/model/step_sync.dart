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

abstract class StepSync
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  StepSync._({
    this.id,
    required this.userId,
    required this.sourceDeviceId,
    required this.rawSteps,
    required this.filteredSteps,
    required this.wasUserEntered,
    required this.syncedAt,
    required this.date,
    this.syncStatus,
    this.errorMessage,
  });

  factory StepSync({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String sourceDeviceId,
    required int rawSteps,
    required int filteredSteps,
    required bool wasUserEntered,
    required DateTime syncedAt,
    required String date,
    String? syncStatus,
    String? errorMessage,
  }) = _StepSyncImpl;

  factory StepSync.fromJson(Map<String, dynamic> jsonSerialization) {
    return StepSync(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      sourceDeviceId: jsonSerialization['sourceDeviceId'] as String,
      rawSteps: jsonSerialization['rawSteps'] as int,
      filteredSteps: jsonSerialization['filteredSteps'] as int,
      wasUserEntered: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['wasUserEntered'],
      ),
      syncedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['syncedAt'],
      ),
      date: jsonSerialization['date'] as String,
      syncStatus: jsonSerialization['syncStatus'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue userId;

  String sourceDeviceId;

  int rawSteps;

  int filteredSteps;

  bool wasUserEntered;

  DateTime syncedAt;

  String date;

  String? syncStatus;

  String? errorMessage;

  /// Returns a shallow copy of this [StepSync]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StepSync copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    String? sourceDeviceId,
    int? rawSteps,
    int? filteredSteps,
    bool? wasUserEntered,
    DateTime? syncedAt,
    String? date,
    String? syncStatus,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StepSync',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'sourceDeviceId': sourceDeviceId,
      'rawSteps': rawSteps,
      'filteredSteps': filteredSteps,
      'wasUserEntered': wasUserEntered,
      'syncedAt': syncedAt.toJson(),
      'date': date,
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StepSync',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'sourceDeviceId': sourceDeviceId,
      'rawSteps': rawSteps,
      'filteredSteps': filteredSteps,
      'wasUserEntered': wasUserEntered,
      'syncedAt': syncedAt.toJson(),
      'date': date,
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StepSyncImpl extends StepSync {
  _StepSyncImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String sourceDeviceId,
    required int rawSteps,
    required int filteredSteps,
    required bool wasUserEntered,
    required DateTime syncedAt,
    required String date,
    String? syncStatus,
    String? errorMessage,
  }) : super._(
         id: id,
         userId: userId,
         sourceDeviceId: sourceDeviceId,
         rawSteps: rawSteps,
         filteredSteps: filteredSteps,
         wasUserEntered: wasUserEntered,
         syncedAt: syncedAt,
         date: date,
         syncStatus: syncStatus,
         errorMessage: errorMessage,
       );

  /// Returns a shallow copy of this [StepSync]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StepSync copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    String? sourceDeviceId,
    int? rawSteps,
    int? filteredSteps,
    bool? wasUserEntered,
    DateTime? syncedAt,
    String? date,
    Object? syncStatus = _Undefined,
    Object? errorMessage = _Undefined,
  }) {
    return StepSync(
      id: id is _i1.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      rawSteps: rawSteps ?? this.rawSteps,
      filteredSteps: filteredSteps ?? this.filteredSteps,
      wasUserEntered: wasUserEntered ?? this.wasUserEntered,
      syncedAt: syncedAt ?? this.syncedAt,
      date: date ?? this.date,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}

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

abstract class StepIntegration
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  StepIntegration._({
    this.id,
    required this.userId,
    required this.provider,
    required this.status,
    this.lastError,
    this.connectedAt,
    required this.updatedAt,
  });

  factory StepIntegration({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String provider,
    required String status,
    String? lastError,
    DateTime? connectedAt,
    required DateTime updatedAt,
  }) = _StepIntegrationImpl;

  factory StepIntegration.fromJson(Map<String, dynamic> jsonSerialization) {
    return StepIntegration(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      provider: jsonSerialization['provider'] as String,
      status: jsonSerialization['status'] as String,
      lastError: jsonSerialization['lastError'] as String?,
      connectedAt: jsonSerialization['connectedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['connectedAt'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue userId;

  String provider;

  String status;

  String? lastError;

  DateTime? connectedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [StepIntegration]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StepIntegration copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    String? provider,
    String? status,
    String? lastError,
    DateTime? connectedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StepIntegration',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'provider': provider,
      'status': status,
      if (lastError != null) 'lastError': lastError,
      if (connectedAt != null) 'connectedAt': connectedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StepIntegration',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'provider': provider,
      'status': status,
      if (lastError != null) 'lastError': lastError,
      if (connectedAt != null) 'connectedAt': connectedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StepIntegrationImpl extends StepIntegration {
  _StepIntegrationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String provider,
    required String status,
    String? lastError,
    DateTime? connectedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         provider: provider,
         status: status,
         lastError: lastError,
         connectedAt: connectedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [StepIntegration]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StepIntegration copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    String? provider,
    String? status,
    Object? lastError = _Undefined,
    Object? connectedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return StepIntegration(
      id: id is _i1.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      lastError: lastError is String? ? lastError : this.lastError,
      connectedAt: connectedAt is DateTime? ? connectedAt : this.connectedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

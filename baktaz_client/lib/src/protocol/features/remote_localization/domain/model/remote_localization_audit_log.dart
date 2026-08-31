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

abstract class RemoteLocalizationAuditLog
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteLocalizationAuditLog._({
    this.id,
    required this.timestamp,
    required this.author,
    required this.action,
    required this.details,
    this.previousValue,
    this.newValue,
  });

  factory RemoteLocalizationAuditLog({
    int? id,
    required DateTime timestamp,
    required String author,
    required String action,
    required String details,
    String? previousValue,
    String? newValue,
  }) = _RemoteLocalizationAuditLogImpl;

  factory RemoteLocalizationAuditLog.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RemoteLocalizationAuditLog(
      id: jsonSerialization['id'] as int?,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      author: jsonSerialization['author'] as String,
      action: jsonSerialization['action'] as String,
      details: jsonSerialization['details'] as String,
      previousValue: jsonSerialization['previousValue'] as String?,
      newValue: jsonSerialization['newValue'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  DateTime timestamp;

  String author;

  String action;

  String details;

  String? previousValue;

  String? newValue;

  /// Returns a shallow copy of this [RemoteLocalizationAuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteLocalizationAuditLog copyWith({
    int? id,
    DateTime? timestamp,
    String? author,
    String? action,
    String? details,
    String? previousValue,
    String? newValue,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteLocalizationAuditLog',
      if (id != null) 'id': id,
      'timestamp': timestamp.toJson(),
      'author': author,
      'action': action,
      'details': details,
      if (previousValue != null) 'previousValue': previousValue,
      if (newValue != null) 'newValue': newValue,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteLocalizationAuditLog',
      if (id != null) 'id': id,
      'timestamp': timestamp.toJson(),
      'author': author,
      'action': action,
      'details': details,
      if (previousValue != null) 'previousValue': previousValue,
      if (newValue != null) 'newValue': newValue,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RemoteLocalizationAuditLogImpl extends RemoteLocalizationAuditLog {
  _RemoteLocalizationAuditLogImpl({
    int? id,
    required DateTime timestamp,
    required String author,
    required String action,
    required String details,
    String? previousValue,
    String? newValue,
  }) : super._(
         id: id,
         timestamp: timestamp,
         author: author,
         action: action,
         details: details,
         previousValue: previousValue,
         newValue: newValue,
       );

  /// Returns a shallow copy of this [RemoteLocalizationAuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteLocalizationAuditLog copyWith({
    Object? id = _Undefined,
    DateTime? timestamp,
    String? author,
    String? action,
    String? details,
    Object? previousValue = _Undefined,
    Object? newValue = _Undefined,
  }) {
    return RemoteLocalizationAuditLog(
      id: id is int? ? id : this.id,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      action: action ?? this.action,
      details: details ?? this.details,
      previousValue: previousValue is String?
          ? previousValue
          : this.previousValue,
      newValue: newValue is String? ? newValue : this.newValue,
    );
  }
}

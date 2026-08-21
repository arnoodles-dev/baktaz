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

abstract class SecurityEvent
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SecurityEvent._({
    this.id,
    this.authUserId,
    required this.eventType,
    this.metadata,
    required this.createdAt,
  });

  factory SecurityEvent({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    required String eventType,
    String? metadata,
    required DateTime createdAt,
  }) = _SecurityEventImpl;

  factory SecurityEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return SecurityEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      eventType: jsonSerialization['eventType'] as String,
      metadata: jsonSerialization['metadata'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue? authUserId;

  String eventType;

  String? metadata;

  DateTime createdAt;

  /// Returns a shallow copy of this [SecurityEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SecurityEvent copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? eventType,
    String? metadata,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SecurityEvent',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'eventType': eventType,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SecurityEvent',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      'eventType': eventType,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SecurityEventImpl extends SecurityEvent {
  _SecurityEventImpl({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    required String eventType,
    String? metadata,
    required DateTime createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         eventType: eventType,
         metadata: metadata,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SecurityEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SecurityEvent copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    String? eventType,
    Object? metadata = _Undefined,
    DateTime? createdAt,
  }) {
    return SecurityEvent(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId is _i1.UuidValue? ? authUserId : this.authUserId,
      eventType: eventType ?? this.eventType,
      metadata: metadata is String? ? metadata : this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

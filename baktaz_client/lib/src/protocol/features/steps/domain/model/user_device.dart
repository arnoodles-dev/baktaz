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

abstract class UserDevice
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UserDevice._({
    this.id,
    required this.userId,
    required this.deviceModel,
    required this.osVersion,
    required this.appVersion,
    required this.lastActiveAt,
    required this.createdAt,
  });

  factory UserDevice({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String deviceModel,
    required String osVersion,
    required String appVersion,
    required DateTime lastActiveAt,
    required DateTime createdAt,
  }) = _UserDeviceImpl;

  factory UserDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserDevice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      deviceModel: jsonSerialization['deviceModel'] as String,
      osVersion: jsonSerialization['osVersion'] as String,
      appVersion: jsonSerialization['appVersion'] as String,
      lastActiveAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActiveAt'],
      ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue userId;

  String deviceModel;

  String osVersion;

  String appVersion;

  DateTime lastActiveAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserDevice copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDevice',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'lastActiveAt': lastActiveAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserDevice',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'lastActiveAt': lastActiveAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDeviceImpl extends UserDevice {
  _UserDeviceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required String deviceModel,
    required String osVersion,
    required String appVersion,
    required DateTime lastActiveAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         deviceModel: deviceModel,
         osVersion: osVersion,
         appVersion: appVersion,
         lastActiveAt: lastActiveAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserDevice copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    String? deviceModel,
    String? osVersion,
    String? appVersion,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) {
    return UserDevice(
      id: id is _i1.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

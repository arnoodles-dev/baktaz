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

abstract class ConfigSnapshotVersion
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ConfigSnapshotVersion._({
    this.id,
    required this.versionNumber,
    DateTime? updateTime,
    this.updateUserEmail,
    this.updateOrigin,
    this.updateType,
  }) : updateTime = updateTime ?? DateTime.now();

  factory ConfigSnapshotVersion({
    _i1.UuidValue? id,
    required String versionNumber,
    DateTime? updateTime,
    String? updateUserEmail,
    String? updateOrigin,
    String? updateType,
  }) = _ConfigSnapshotVersionImpl;

  factory ConfigSnapshotVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ConfigSnapshotVersion(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      versionNumber: jsonSerialization['versionNumber'] as String,
      updateTime: jsonSerialization['updateTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updateTime']),
      updateUserEmail: jsonSerialization['updateUserEmail'] as String?,
      updateOrigin: jsonSerialization['updateOrigin'] as String?,
      updateType: jsonSerialization['updateType'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String versionNumber;

  DateTime updateTime;

  String? updateUserEmail;

  String? updateOrigin;

  String? updateType;

  /// Returns a shallow copy of this [ConfigSnapshotVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConfigSnapshotVersion copyWith({
    _i1.UuidValue? id,
    String? versionNumber,
    DateTime? updateTime,
    String? updateUserEmail,
    String? updateOrigin,
    String? updateType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConfigSnapshotVersion',
      if (id != null) 'id': id?.toJson(),
      'versionNumber': versionNumber,
      'updateTime': updateTime.toJson(),
      if (updateUserEmail != null) 'updateUserEmail': updateUserEmail,
      if (updateOrigin != null) 'updateOrigin': updateOrigin,
      if (updateType != null) 'updateType': updateType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConfigSnapshotVersion',
      if (id != null) 'id': id?.toJson(),
      'versionNumber': versionNumber,
      'updateTime': updateTime.toJson(),
      if (updateUserEmail != null) 'updateUserEmail': updateUserEmail,
      if (updateOrigin != null) 'updateOrigin': updateOrigin,
      if (updateType != null) 'updateType': updateType,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConfigSnapshotVersionImpl extends ConfigSnapshotVersion {
  _ConfigSnapshotVersionImpl({
    _i1.UuidValue? id,
    required String versionNumber,
    DateTime? updateTime,
    String? updateUserEmail,
    String? updateOrigin,
    String? updateType,
  }) : super._(
         id: id,
         versionNumber: versionNumber,
         updateTime: updateTime,
         updateUserEmail: updateUserEmail,
         updateOrigin: updateOrigin,
         updateType: updateType,
       );

  /// Returns a shallow copy of this [ConfigSnapshotVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConfigSnapshotVersion copyWith({
    Object? id = _Undefined,
    String? versionNumber,
    DateTime? updateTime,
    Object? updateUserEmail = _Undefined,
    Object? updateOrigin = _Undefined,
    Object? updateType = _Undefined,
  }) {
    return ConfigSnapshotVersion(
      id: id is _i1.UuidValue? ? id : this.id,
      versionNumber: versionNumber ?? this.versionNumber,
      updateTime: updateTime ?? this.updateTime,
      updateUserEmail: updateUserEmail is String?
          ? updateUserEmail
          : this.updateUserEmail,
      updateOrigin: updateOrigin is String? ? updateOrigin : this.updateOrigin,
      updateType: updateType is String? ? updateType : this.updateType,
    );
  }
}

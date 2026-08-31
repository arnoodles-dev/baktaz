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
import '../../../../features/remote_config/domain/model/remote_config_value_type.dart'
    as _i2;

abstract class ConfigKey
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ConfigKey._({
    this.id,
    required this.key,
    required this.valueType,
    required this.defaultValue,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ConfigKey({
    _i1.UuidValue? id,
    required String key,
    required _i2.RemoteConfigValueType valueType,
    required String defaultValue,
    String? description,
    DateTime? createdAt,
  }) = _ConfigKeyImpl;

  factory ConfigKey.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConfigKey(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      key: jsonSerialization['key'] as String,
      valueType: _i2.RemoteConfigValueType.fromJson(
        (jsonSerialization['valueType'] as String),
      ),
      defaultValue: jsonSerialization['defaultValue'] as String,
      description: jsonSerialization['description'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String key;

  _i2.RemoteConfigValueType valueType;

  String defaultValue;

  String? description;

  DateTime createdAt;

  /// Returns a shallow copy of this [ConfigKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConfigKey copyWith({
    _i1.UuidValue? id,
    String? key,
    _i2.RemoteConfigValueType? valueType,
    String? defaultValue,
    String? description,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConfigKey',
      if (id != null) 'id': id?.toJson(),
      'key': key,
      'valueType': valueType.toJson(),
      'defaultValue': defaultValue,
      if (description != null) 'description': description,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConfigKey',
      if (id != null) 'id': id?.toJson(),
      'key': key,
      'valueType': valueType.toJson(),
      'defaultValue': defaultValue,
      if (description != null) 'description': description,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConfigKeyImpl extends ConfigKey {
  _ConfigKeyImpl({
    _i1.UuidValue? id,
    required String key,
    required _i2.RemoteConfigValueType valueType,
    required String defaultValue,
    String? description,
    DateTime? createdAt,
  }) : super._(
         id: id,
         key: key,
         valueType: valueType,
         defaultValue: defaultValue,
         description: description,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ConfigKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConfigKey copyWith({
    Object? id = _Undefined,
    String? key,
    _i2.RemoteConfigValueType? valueType,
    String? defaultValue,
    Object? description = _Undefined,
    DateTime? createdAt,
  }) {
    return ConfigKey(
      id: id is _i1.UuidValue? ? id : this.id,
      key: key ?? this.key,
      valueType: valueType ?? this.valueType,
      defaultValue: defaultValue ?? this.defaultValue,
      description: description is String? ? description : this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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
import '../../../../features/remote_config/domain/model/config_key.dart' as _i2;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i3;

abstract class TargetingOverride
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TargetingOverride._({
    this.id,
    required this.configKeyId,
    this.configKey,
    required this.priority,
    this.appVersionConstraint,
    this.userTiers,
    this.customSegmentValues,
    this.rolloutPercentage,
    required this.servedValue,
    required this.isActive,
  });

  factory TargetingOverride({
    _i1.UuidValue? id,
    required _i1.UuidValue configKeyId,
    _i2.ConfigKey? configKey,
    required int priority,
    String? appVersionConstraint,
    List<String>? userTiers,
    List<String>? customSegmentValues,
    int? rolloutPercentage,
    required String servedValue,
    required bool isActive,
  }) = _TargetingOverrideImpl;

  factory TargetingOverride.fromJson(Map<String, dynamic> jsonSerialization) {
    return TargetingOverride(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      configKeyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['configKeyId'],
      ),
      configKey: jsonSerialization['configKey'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.ConfigKey>(
              jsonSerialization['configKey'],
            ),
      priority: jsonSerialization['priority'] as int,
      appVersionConstraint:
          jsonSerialization['appVersionConstraint'] as String?,
      userTiers: jsonSerialization['userTiers'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['userTiers'],
            ),
      customSegmentValues: jsonSerialization['customSegmentValues'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['customSegmentValues'],
            ),
      rolloutPercentage: jsonSerialization['rolloutPercentage'] as int?,
      servedValue: jsonSerialization['servedValue'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue configKeyId;

  _i2.ConfigKey? configKey;

  int priority;

  String? appVersionConstraint;

  List<String>? userTiers;

  List<String>? customSegmentValues;

  int? rolloutPercentage;

  String servedValue;

  bool isActive;

  /// Returns a shallow copy of this [TargetingOverride]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TargetingOverride copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? configKeyId,
    _i2.ConfigKey? configKey,
    int? priority,
    String? appVersionConstraint,
    List<String>? userTiers,
    List<String>? customSegmentValues,
    int? rolloutPercentage,
    String? servedValue,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TargetingOverride',
      if (id != null) 'id': id?.toJson(),
      'configKeyId': configKeyId.toJson(),
      if (configKey != null) 'configKey': configKey?.toJson(),
      'priority': priority,
      if (appVersionConstraint != null)
        'appVersionConstraint': appVersionConstraint,
      if (userTiers != null) 'userTiers': userTiers?.toJson(),
      if (customSegmentValues != null)
        'customSegmentValues': customSegmentValues?.toJson(),
      if (rolloutPercentage != null) 'rolloutPercentage': rolloutPercentage,
      'servedValue': servedValue,
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TargetingOverride',
      if (id != null) 'id': id?.toJson(),
      'configKeyId': configKeyId.toJson(),
      if (configKey != null) 'configKey': configKey?.toJsonForProtocol(),
      'priority': priority,
      if (appVersionConstraint != null)
        'appVersionConstraint': appVersionConstraint,
      if (userTiers != null) 'userTiers': userTiers?.toJson(),
      if (customSegmentValues != null)
        'customSegmentValues': customSegmentValues?.toJson(),
      if (rolloutPercentage != null) 'rolloutPercentage': rolloutPercentage,
      'servedValue': servedValue,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TargetingOverrideImpl extends TargetingOverride {
  _TargetingOverrideImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue configKeyId,
    _i2.ConfigKey? configKey,
    required int priority,
    String? appVersionConstraint,
    List<String>? userTiers,
    List<String>? customSegmentValues,
    int? rolloutPercentage,
    required String servedValue,
    required bool isActive,
  }) : super._(
         id: id,
         configKeyId: configKeyId,
         configKey: configKey,
         priority: priority,
         appVersionConstraint: appVersionConstraint,
         userTiers: userTiers,
         customSegmentValues: customSegmentValues,
         rolloutPercentage: rolloutPercentage,
         servedValue: servedValue,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [TargetingOverride]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TargetingOverride copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? configKeyId,
    Object? configKey = _Undefined,
    int? priority,
    Object? appVersionConstraint = _Undefined,
    Object? userTiers = _Undefined,
    Object? customSegmentValues = _Undefined,
    Object? rolloutPercentage = _Undefined,
    String? servedValue,
    bool? isActive,
  }) {
    return TargetingOverride(
      id: id is _i1.UuidValue? ? id : this.id,
      configKeyId: configKeyId ?? this.configKeyId,
      configKey: configKey is _i2.ConfigKey?
          ? configKey
          : this.configKey?.copyWith(),
      priority: priority ?? this.priority,
      appVersionConstraint: appVersionConstraint is String?
          ? appVersionConstraint
          : this.appVersionConstraint,
      userTiers: userTiers is List<String>?
          ? userTiers
          : this.userTiers?.map((e0) => e0).toList(),
      customSegmentValues: customSegmentValues is List<String>?
          ? customSegmentValues
          : this.customSegmentValues?.map((e0) => e0).toList(),
      rolloutPercentage: rolloutPercentage is int?
          ? rolloutPercentage
          : this.rolloutPercentage,
      servedValue: servedValue ?? this.servedValue,
      isActive: isActive ?? this.isActive,
    );
  }
}

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
import '../../../../features/remote_config/domain/model/remote_config_default_value.dart'
    as _i2;
import '../../../../features/remote_config/domain/model/remote_config_value_type.dart'
    as _i3;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i4;

abstract class RemoteConfigValue
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteConfigValue._({
    required this.defaultValue,
    required this.valueType,
    required this.value,
  });

  factory RemoteConfigValue({
    required _i2.RemoteConfigDefaultValue defaultValue,
    required _i3.RemoteConfigValueType valueType,
    required String value,
  }) = _RemoteConfigValueImpl;

  factory RemoteConfigValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return RemoteConfigValue(
      defaultValue: _i4.Protocol().deserialize<_i2.RemoteConfigDefaultValue>(
        jsonSerialization['defaultValue'],
      ),
      valueType: _i3.RemoteConfigValueType.fromJson(
        (jsonSerialization['valueType'] as String),
      ),
      value: jsonSerialization['value'] as String,
    );
  }

  _i2.RemoteConfigDefaultValue defaultValue;

  _i3.RemoteConfigValueType valueType;

  String value;

  /// Returns a shallow copy of this [RemoteConfigValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteConfigValue copyWith({
    _i2.RemoteConfigDefaultValue? defaultValue,
    _i3.RemoteConfigValueType? valueType,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteConfigValue',
      'defaultValue': defaultValue.toJson(),
      'valueType': valueType.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteConfigValue',
      'defaultValue': defaultValue.toJsonForProtocol(),
      'valueType': valueType.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RemoteConfigValueImpl extends RemoteConfigValue {
  _RemoteConfigValueImpl({
    required _i2.RemoteConfigDefaultValue defaultValue,
    required _i3.RemoteConfigValueType valueType,
    required String value,
  }) : super._(
         defaultValue: defaultValue,
         valueType: valueType,
         value: value,
       );

  /// Returns a shallow copy of this [RemoteConfigValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteConfigValue copyWith({
    _i2.RemoteConfigDefaultValue? defaultValue,
    _i3.RemoteConfigValueType? valueType,
    String? value,
  }) {
    return RemoteConfigValue(
      defaultValue: defaultValue ?? this.defaultValue.copyWith(),
      valueType: valueType ?? this.valueType,
      value: value ?? this.value,
    );
  }
}

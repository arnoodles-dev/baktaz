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
import '../../../../features/remote_config/domain/model/remote_config_value.dart'
    as _i2;
import '../../../../features/remote_config/domain/model/public_config_version.dart'
    as _i3;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i4;

abstract class RemoteConfig
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteConfig._({
    required this.config,
    required this.version,
  });

  factory RemoteConfig({
    required Map<String, _i2.RemoteConfigValue> config,
    required _i3.PublicConfigVersion version,
  }) = _RemoteConfigImpl;

  factory RemoteConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return RemoteConfig(
      config: _i4.Protocol().deserialize<Map<String, _i2.RemoteConfigValue>>(
        jsonSerialization['config'],
      ),
      version: _i4.Protocol().deserialize<_i3.PublicConfigVersion>(
        jsonSerialization['version'],
      ),
    );
  }

  Map<String, _i2.RemoteConfigValue> config;

  _i3.PublicConfigVersion version;

  /// Returns a shallow copy of this [RemoteConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteConfig copyWith({
    Map<String, _i2.RemoteConfigValue>? config,
    _i3.PublicConfigVersion? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteConfig',
      'config': config.toJson(valueToJson: (v) => v.toJson()),
      'version': version.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteConfig',
      'config': config.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'version': version.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RemoteConfigImpl extends RemoteConfig {
  _RemoteConfigImpl({
    required Map<String, _i2.RemoteConfigValue> config,
    required _i3.PublicConfigVersion version,
  }) : super._(
         config: config,
         version: version,
       );

  /// Returns a shallow copy of this [RemoteConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteConfig copyWith({
    Map<String, _i2.RemoteConfigValue>? config,
    _i3.PublicConfigVersion? version,
  }) {
    return RemoteConfig(
      config:
          config ??
          this.config.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0.copyWith(),
            ),
          ),
      version: version ?? this.version.copyWith(),
    );
  }
}

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

abstract class RemoteLocalizationResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteLocalizationResponse._({
    required this.version,
    required this.updated,
    this.checksum,
    this.overridesJson,
  });

  factory RemoteLocalizationResponse({
    required int version,
    required bool updated,
    String? checksum,
    String? overridesJson,
  }) = _RemoteLocalizationResponseImpl;

  factory RemoteLocalizationResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RemoteLocalizationResponse(
      version: jsonSerialization['version'] as int,
      updated: _i1.BoolJsonExtension.fromJson(jsonSerialization['updated']),
      checksum: jsonSerialization['checksum'] as String?,
      overridesJson: jsonSerialization['overridesJson'] as String?,
    );
  }

  int version;

  bool updated;

  String? checksum;

  String? overridesJson;

  /// Returns a shallow copy of this [RemoteLocalizationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteLocalizationResponse copyWith({
    int? version,
    bool? updated,
    String? checksum,
    String? overridesJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteLocalizationResponse',
      'version': version,
      'updated': updated,
      if (checksum != null) 'checksum': checksum,
      if (overridesJson != null) 'overridesJson': overridesJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteLocalizationResponse',
      'version': version,
      'updated': updated,
      if (checksum != null) 'checksum': checksum,
      if (overridesJson != null) 'overridesJson': overridesJson,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RemoteLocalizationResponseImpl extends RemoteLocalizationResponse {
  _RemoteLocalizationResponseImpl({
    required int version,
    required bool updated,
    String? checksum,
    String? overridesJson,
  }) : super._(
         version: version,
         updated: updated,
         checksum: checksum,
         overridesJson: overridesJson,
       );

  /// Returns a shallow copy of this [RemoteLocalizationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteLocalizationResponse copyWith({
    int? version,
    bool? updated,
    Object? checksum = _Undefined,
    Object? overridesJson = _Undefined,
  }) {
    return RemoteLocalizationResponse(
      version: version ?? this.version,
      updated: updated ?? this.updated,
      checksum: checksum is String? ? checksum : this.checksum,
      overridesJson: overridesJson is String?
          ? overridesJson
          : this.overridesJson,
    );
  }
}

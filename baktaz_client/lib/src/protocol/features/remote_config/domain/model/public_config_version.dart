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

abstract class PublicConfigVersion
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PublicConfigVersion._({
    required this.versionNumber,
    required this.updateTime,
  });

  factory PublicConfigVersion({
    required String versionNumber,
    required DateTime updateTime,
  }) = _PublicConfigVersionImpl;

  factory PublicConfigVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicConfigVersion(
      versionNumber: jsonSerialization['versionNumber'] as String,
      updateTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updateTime'],
      ),
    );
  }

  String versionNumber;

  DateTime updateTime;

  /// Returns a shallow copy of this [PublicConfigVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublicConfigVersion copyWith({
    String? versionNumber,
    DateTime? updateTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublicConfigVersion',
      'versionNumber': versionNumber,
      'updateTime': updateTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PublicConfigVersion',
      'versionNumber': versionNumber,
      'updateTime': updateTime.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PublicConfigVersionImpl extends PublicConfigVersion {
  _PublicConfigVersionImpl({
    required String versionNumber,
    required DateTime updateTime,
  }) : super._(
         versionNumber: versionNumber,
         updateTime: updateTime,
       );

  /// Returns a shallow copy of this [PublicConfigVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublicConfigVersion copyWith({
    String? versionNumber,
    DateTime? updateTime,
  }) {
    return PublicConfigVersion(
      versionNumber: versionNumber ?? this.versionNumber,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}

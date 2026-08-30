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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i2;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i3;

abstract class OtpVerificationResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  OtpVerificationResult._({
    this.id,
    required this.isNewUser,
    this.authInfo,
    this.registrationToken,
  });

  factory OtpVerificationResult({
    int? id,
    required bool isNewUser,
    _i2.AuthSuccess? authInfo,
    String? registrationToken,
  }) = _OtpVerificationResultImpl;

  factory OtpVerificationResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return OtpVerificationResult(
      id: jsonSerialization['id'] as int?,
      isNewUser: _i1.BoolJsonExtension.fromJson(jsonSerialization['isNewUser']),
      authInfo: jsonSerialization['authInfo'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthSuccess>(
              jsonSerialization['authInfo'],
            ),
      registrationToken: jsonSerialization['registrationToken'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  bool isNewUser;

  _i2.AuthSuccess? authInfo;

  String? registrationToken;

  /// Returns a shallow copy of this [OtpVerificationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OtpVerificationResult copyWith({
    int? id,
    bool? isNewUser,
    _i2.AuthSuccess? authInfo,
    String? registrationToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OtpVerificationResult',
      if (id != null) 'id': id,
      'isNewUser': isNewUser,
      if (authInfo != null) 'authInfo': authInfo?.toJson(),
      if (registrationToken != null) 'registrationToken': registrationToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OtpVerificationResult',
      if (id != null) 'id': id,
      'isNewUser': isNewUser,
      if (authInfo != null) 'authInfo': authInfo?.toJson(),
      if (registrationToken != null) 'registrationToken': registrationToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OtpVerificationResultImpl extends OtpVerificationResult {
  _OtpVerificationResultImpl({
    int? id,
    required bool isNewUser,
    _i2.AuthSuccess? authInfo,
    String? registrationToken,
  }) : super._(
         id: id,
         isNewUser: isNewUser,
         authInfo: authInfo,
         registrationToken: registrationToken,
       );

  /// Returns a shallow copy of this [OtpVerificationResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OtpVerificationResult copyWith({
    Object? id = _Undefined,
    bool? isNewUser,
    Object? authInfo = _Undefined,
    Object? registrationToken = _Undefined,
  }) {
    return OtpVerificationResult(
      id: id is int? ? id : this.id,
      isNewUser: isNewUser ?? this.isNewUser,
      authInfo: authInfo is _i2.AuthSuccess?
          ? authInfo
          : this.authInfo?.copyWith(),
      registrationToken: registrationToken is String?
          ? registrationToken
          : this.registrationToken,
    );
  }
}

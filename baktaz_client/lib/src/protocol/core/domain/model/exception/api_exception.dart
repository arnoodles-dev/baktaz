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
import '../../../../core/domain/model/exception/api_exception_code.dart' as _i2;

abstract class ApiException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  ApiException._({
    required this.message,
    required this.code,
  });

  factory ApiException({
    required String message,
    required _i2.ApiExceptionCode code,
  }) = _ApiExceptionImpl;

  factory ApiException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiException(
      message: jsonSerialization['message'] as String,
      code: _i2.ApiExceptionCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
    );
  }

  String message;

  _i2.ApiExceptionCode code;

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiException copyWith({
    String? message,
    _i2.ApiExceptionCode? code,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiException',
      'message': message,
      'code': code.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ApiException',
      'message': message,
      'code': code.toJson(),
    };
  }

  @override
  String toString() {
    return 'ApiException(message: $message, code: $code)';
  }
}

class _ApiExceptionImpl extends ApiException {
  _ApiExceptionImpl({
    required String message,
    required _i2.ApiExceptionCode code,
  }) : super._(
         message: message,
         code: code,
       );

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiException copyWith({
    String? message,
    _i2.ApiExceptionCode? code,
  }) {
    return ApiException(
      message: message ?? this.message,
      code: code ?? this.code,
    );
  }
}

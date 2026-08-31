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

abstract class RemoteConfigDefaultValue
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteConfigDefaultValue._({required this.value});

  factory RemoteConfigDefaultValue({required String value}) =
      _RemoteConfigDefaultValueImpl;

  factory RemoteConfigDefaultValue.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RemoteConfigDefaultValue(
      value: jsonSerialization['value'] as String,
    );
  }

  String value;

  /// Returns a shallow copy of this [RemoteConfigDefaultValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteConfigDefaultValue copyWith({String? value});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteConfigDefaultValue',
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteConfigDefaultValue',
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RemoteConfigDefaultValueImpl extends RemoteConfigDefaultValue {
  _RemoteConfigDefaultValueImpl({required String value})
    : super._(value: value);

  /// Returns a shallow copy of this [RemoteConfigDefaultValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteConfigDefaultValue copyWith({String? value}) {
    return RemoteConfigDefaultValue(value: value ?? this.value);
  }
}

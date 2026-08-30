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

abstract class RegistrationForm
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RegistrationForm._({
    required this.email,
    required this.name,
    required this.gender,
    required this.registrationToken,
    this.birthday,
  });

  factory RegistrationForm({
    required String email,
    required String name,
    required String gender,
    required String registrationToken,
    DateTime? birthday,
  }) = _RegistrationFormImpl;

  factory RegistrationForm.fromJson(Map<String, dynamic> jsonSerialization) {
    return RegistrationForm(
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String,
      gender: jsonSerialization['gender'] as String,
      registrationToken: jsonSerialization['registrationToken'] as String,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
    );
  }

  String email;

  String name;

  String gender;

  String registrationToken;

  DateTime? birthday;

  /// Returns a shallow copy of this [RegistrationForm]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RegistrationForm copyWith({
    String? email,
    String? name,
    String? gender,
    String? registrationToken,
    DateTime? birthday,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RegistrationForm',
      'email': email,
      'name': name,
      'gender': gender,
      'registrationToken': registrationToken,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RegistrationForm',
      'email': email,
      'name': name,
      'gender': gender,
      'registrationToken': registrationToken,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RegistrationFormImpl extends RegistrationForm {
  _RegistrationFormImpl({
    required String email,
    required String name,
    required String gender,
    required String registrationToken,
    DateTime? birthday,
  }) : super._(
         email: email,
         name: name,
         gender: gender,
         registrationToken: registrationToken,
         birthday: birthday,
       );

  /// Returns a shallow copy of this [RegistrationForm]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RegistrationForm copyWith({
    String? email,
    String? name,
    String? gender,
    String? registrationToken,
    Object? birthday = _Undefined,
  }) {
    return RegistrationForm(
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      registrationToken: registrationToken ?? this.registrationToken,
      birthday: birthday is DateTime? ? birthday : this.birthday,
    );
  }
}

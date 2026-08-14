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
import '../../../../core/domain/model/enum/gender.dart' as _i2;

abstract class Profile
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Profile._({
    required this.fullName,
    required this.gender,
    this.email,
    this.mobileNumber,
    this.birthday,
    this.age,
    this.imageUrl,
    this.updatedAt,
  });

  factory Profile({
    required String fullName,
    required _i2.Gender gender,
    String? email,
    String? mobileNumber,
    DateTime? birthday,
    int? age,
    Uri? imageUrl,
    DateTime? updatedAt,
  }) = _ProfileImpl;

  factory Profile.fromJson(Map<String, dynamic> jsonSerialization) {
    return Profile(
      fullName: jsonSerialization['fullName'] as String,
      gender: _i2.Gender.fromJson((jsonSerialization['gender'] as String)),
      email: jsonSerialization['email'] as String?,
      mobileNumber: jsonSerialization['mobileNumber'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      age: jsonSerialization['age'] as int?,
      imageUrl: jsonSerialization['imageUrl'] == null
          ? null
          : _i1.UriJsonExtension.fromJson(jsonSerialization['imageUrl']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  String fullName;

  _i2.Gender gender;

  String? email;

  String? mobileNumber;

  DateTime? birthday;

  int? age;

  Uri? imageUrl;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Profile copyWith({
    String? fullName,
    _i2.Gender? gender,
    String? email,
    String? mobileNumber,
    DateTime? birthday,
    int? age,
    Uri? imageUrl,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Profile',
      'fullName': fullName,
      'gender': gender.toJson(),
      if (email != null) 'email': email,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (age != null) 'age': age,
      if (imageUrl != null) 'imageUrl': imageUrl?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Profile',
      'fullName': fullName,
      'gender': gender.toJson(),
      if (email != null) 'email': email,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (age != null) 'age': age,
      if (imageUrl != null) 'imageUrl': imageUrl?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileImpl extends Profile {
  _ProfileImpl({
    required String fullName,
    required _i2.Gender gender,
    String? email,
    String? mobileNumber,
    DateTime? birthday,
    int? age,
    Uri? imageUrl,
    DateTime? updatedAt,
  }) : super._(
         fullName: fullName,
         gender: gender,
         email: email,
         mobileNumber: mobileNumber,
         birthday: birthday,
         age: age,
         imageUrl: imageUrl,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Profile copyWith({
    String? fullName,
    _i2.Gender? gender,
    Object? email = _Undefined,
    Object? mobileNumber = _Undefined,
    Object? birthday = _Undefined,
    Object? age = _Undefined,
    Object? imageUrl = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Profile(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      email: email is String? ? email : this.email,
      mobileNumber: mobileNumber is String? ? mobileNumber : this.mobileNumber,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      age: age is int? ? age : this.age,
      imageUrl: imageUrl is Uri? ? imageUrl : this.imageUrl,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

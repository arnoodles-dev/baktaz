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

abstract class UserInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UserInfo._({
    this.id,
    _i2.Gender? gender,
    this.birthday,
    this.updatedAt,
    this.mobileNumber,
  }) : gender = gender ?? _i2.Gender.unknown;

  factory UserInfo({
    _i1.UuidValue? id,
    _i2.Gender? gender,
    DateTime? birthday,
    DateTime? updatedAt,
    String? mobileNumber,
  }) = _UserInfoImpl;

  factory UserInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserInfo(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      gender: jsonSerialization['gender'] == null
          ? null
          : _i2.Gender.fromJson((jsonSerialization['gender'] as String)),
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      mobileNumber: jsonSerialization['mobileNumber'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i2.Gender gender;

  DateTime? birthday;

  DateTime? updatedAt;

  String? mobileNumber;

  /// Returns a shallow copy of this [UserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserInfo copyWith({
    _i1.UuidValue? id,
    _i2.Gender? gender,
    DateTime? birthday,
    DateTime? updatedAt,
    String? mobileNumber,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserInfo',
      if (id != null) 'id': id?.toJson(),
      'gender': gender.toJson(),
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserInfo',
      if (id != null) 'id': id?.toJson(),
      'gender': gender.toJson(),
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserInfoImpl extends UserInfo {
  _UserInfoImpl({
    _i1.UuidValue? id,
    _i2.Gender? gender,
    DateTime? birthday,
    DateTime? updatedAt,
    String? mobileNumber,
  }) : super._(
         id: id,
         gender: gender,
         birthday: birthday,
         updatedAt: updatedAt,
         mobileNumber: mobileNumber,
       );

  /// Returns a shallow copy of this [UserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserInfo copyWith({
    Object? id = _Undefined,
    _i2.Gender? gender,
    Object? birthday = _Undefined,
    Object? updatedAt = _Undefined,
    Object? mobileNumber = _Undefined,
  }) {
    return UserInfo(
      id: id is _i1.UuidValue? ? id : this.id,
      gender: gender ?? this.gender,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      mobileNumber: mobileNumber is String? ? mobileNumber : this.mobileNumber,
    );
  }
}

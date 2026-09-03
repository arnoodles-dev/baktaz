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
    required this.userIdentifier,
    required this.email,
    this.firstName,
    this.lastName,
    required this.username,
    _i2.Gender? gender,
    this.birthday,
    this.mobileNumber,
    this.avatarUrl,
    DateTime? createdAt,
    this.updatedAt,
  }) : gender = gender ?? _i2.Gender.unknown,
       createdAt = createdAt ?? DateTime.now();

  factory UserInfo({
    _i1.UuidValue? id,
    required _i1.UuidValue userIdentifier,
    required String email,
    String? firstName,
    String? lastName,
    required String username,
    _i2.Gender? gender,
    DateTime? birthday,
    String? mobileNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserInfoImpl;

  factory UserInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserInfo(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userIdentifier: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['userIdentifier'],
      ),
      email: jsonSerialization['email'] as String,
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      username: jsonSerialization['username'] as String,
      gender: jsonSerialization['gender'] == null
          ? null
          : _i2.Gender.fromJson((jsonSerialization['gender'] as String)),
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      mobileNumber: jsonSerialization['mobileNumber'] as String?,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue userIdentifier;

  String email;

  String? firstName;

  String? lastName;

  String username;

  _i2.Gender gender;

  DateTime? birthday;

  String? mobileNumber;

  String? avatarUrl;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [UserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserInfo copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userIdentifier,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    _i2.Gender? gender,
    DateTime? birthday,
    String? mobileNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserInfo',
      if (id != null) 'id': id?.toJson(),
      'userIdentifier': userIdentifier.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'username': username,
      'gender': gender.toJson(),
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserInfo',
      if (id != null) 'id': id?.toJson(),
      'userIdentifier': userIdentifier.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'username': username,
      'gender': gender.toJson(),
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
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
    required _i1.UuidValue userIdentifier,
    required String email,
    String? firstName,
    String? lastName,
    required String username,
    _i2.Gender? gender,
    DateTime? birthday,
    String? mobileNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userIdentifier: userIdentifier,
         email: email,
         firstName: firstName,
         lastName: lastName,
         username: username,
         gender: gender,
         birthday: birthday,
         mobileNumber: mobileNumber,
         avatarUrl: avatarUrl,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserInfo copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userIdentifier,
    String? email,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    String? username,
    _i2.Gender? gender,
    Object? birthday = _Undefined,
    Object? mobileNumber = _Undefined,
    Object? avatarUrl = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return UserInfo(
      id: id is _i1.UuidValue? ? id : this.id,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      email: email ?? this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      mobileNumber: mobileNumber is String? ? mobileNumber : this.mobileNumber,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

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
import '../../../../features/account/domain/model/user_info.dart' as _i3;
import '../../../../features/wallet/domain/model/wallet.dart' as _i4;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i5;

abstract class Account
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Account._({
    this.id,
    this.authUserId,
    this.authUser,
    this.userProfileId,
    this.userProfile,
    this.userInfoId,
    this.userInfo,
    this.walletId,
    this.wallet,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Account({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i1.UuidValue? userProfileId,
    _i2.UserProfile? userProfile,
    _i1.UuidValue? userInfoId,
    _i3.UserInfo? userInfo,
    _i1.UuidValue? walletId,
    _i4.Wallet? wallet,
    DateTime? createdAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      userProfileId: jsonSerialization['userProfileId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['userProfileId'],
            ),
      userProfile: jsonSerialization['userProfile'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.UserProfile>(
              jsonSerialization['userProfile'],
            ),
      userInfoId: jsonSerialization['userInfoId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['userInfoId'],
            ),
      userInfo: jsonSerialization['userInfo'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.UserInfo>(
              jsonSerialization['userInfo'],
            ),
      walletId: jsonSerialization['walletId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['walletId']),
      wallet: jsonSerialization['wallet'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.Wallet>(jsonSerialization['wallet']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue? authUserId;

  _i2.AuthUser? authUser;

  _i1.UuidValue? userProfileId;

  _i2.UserProfile? userProfile;

  _i1.UuidValue? userInfoId;

  _i3.UserInfo? userInfo;

  _i1.UuidValue? walletId;

  _i4.Wallet? wallet;

  DateTime createdAt;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Account copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i1.UuidValue? userProfileId,
    _i2.UserProfile? userProfile,
    _i1.UuidValue? userInfoId,
    _i3.UserInfo? userInfo,
    _i1.UuidValue? walletId,
    _i4.Wallet? wallet,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (userProfileId != null) 'userProfileId': userProfileId?.toJson(),
      if (userProfile != null) 'userProfile': userProfile?.toJson(),
      if (userInfoId != null) 'userInfoId': userInfoId?.toJson(),
      if (userInfo != null) 'userInfo': userInfo?.toJson(),
      if (walletId != null) 'walletId': walletId?.toJson(),
      if (wallet != null) 'wallet': wallet?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (userProfileId != null) 'userProfileId': userProfileId?.toJson(),
      if (userProfile != null) 'userProfile': userProfile?.toJson(),
      if (userInfoId != null) 'userInfoId': userInfoId?.toJson(),
      if (userInfo != null) 'userInfo': userInfo?.toJsonForProtocol(),
      if (walletId != null) 'walletId': walletId?.toJson(),
      if (wallet != null) 'wallet': wallet?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountImpl extends Account {
  _AccountImpl({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i1.UuidValue? userProfileId,
    _i2.UserProfile? userProfile,
    _i1.UuidValue? userInfoId,
    _i3.UserInfo? userInfo,
    _i1.UuidValue? walletId,
    _i4.Wallet? wallet,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         userProfileId: userProfileId,
         userProfile: userProfile,
         userInfoId: userInfoId,
         userInfo: userInfo,
         walletId: walletId,
         wallet: wallet,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Account copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    Object? userProfileId = _Undefined,
    Object? userProfile = _Undefined,
    Object? userInfoId = _Undefined,
    Object? userInfo = _Undefined,
    Object? walletId = _Undefined,
    Object? wallet = _Undefined,
    DateTime? createdAt,
  }) {
    return Account(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId is _i1.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      userProfileId: userProfileId is _i1.UuidValue?
          ? userProfileId
          : this.userProfileId,
      userProfile: userProfile is _i2.UserProfile?
          ? userProfile
          : this.userProfile?.copyWith(),
      userInfoId: userInfoId is _i1.UuidValue? ? userInfoId : this.userInfoId,
      userInfo: userInfo is _i3.UserInfo?
          ? userInfo
          : this.userInfo?.copyWith(),
      walletId: walletId is _i1.UuidValue? ? walletId : this.walletId,
      wallet: wallet is _i4.Wallet? ? wallet : this.wallet?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

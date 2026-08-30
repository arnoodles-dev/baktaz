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
import '../../../../features/account/domain/model/account.dart' as _i2;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i3;

abstract class Contact
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Contact._({
    this.id,
    required this.accountId,
    this.account,
    required this.mobileNumber,
    this.email,
  });

  factory Contact({
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    _i2.Account? account,
    required String mobileNumber,
    String? email,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      account: jsonSerialization['account'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Account>(
              jsonSerialization['account'],
            ),
      mobileNumber: jsonSerialization['mobileNumber'] as String,
      email: jsonSerialization['email'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue accountId;

  _i2.Account? account;

  String mobileNumber;

  String? email;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Contact copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? accountId,
    _i2.Account? account,
    String? mobileNumber,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      if (account != null) 'account': account?.toJson(),
      'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      if (account != null) 'account': account?.toJsonForProtocol(),
      'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactImpl extends Contact {
  _ContactImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    _i2.Account? account,
    required String mobileNumber,
    String? email,
  }) : super._(
         id: id,
         accountId: accountId,
         account: account,
         mobileNumber: mobileNumber,
         email: email,
       );

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Contact copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountId,
    Object? account = _Undefined,
    String? mobileNumber,
    Object? email = _Undefined,
  }) {
    return Contact(
      id: id is _i1.UuidValue? ? id : this.id,
      accountId: accountId ?? this.accountId,
      account: account is _i2.Account? ? account : this.account?.copyWith(),
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email is String? ? email : this.email,
    );
  }
}

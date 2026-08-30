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
import '../../../../features/account/domain/model/account_summary.dart' as _i3;
import '../../../../features/account/domain/model/profile.dart' as _i4;
import '../../../../features/account/domain/model/address.dart' as _i5;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i6;

abstract class AccountState
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AccountState._({
    required this.account,
    required this.summary,
    required this.profile,
    this.defaultAddress,
  });

  factory AccountState({
    required _i2.Account account,
    required _i3.AccountSummary summary,
    required _i4.Profile profile,
    _i5.Address? defaultAddress,
  }) = _AccountStateImpl;

  factory AccountState.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountState(
      account: _i6.Protocol().deserialize<_i2.Account>(
        jsonSerialization['account'],
      ),
      summary: _i6.Protocol().deserialize<_i3.AccountSummary>(
        jsonSerialization['summary'],
      ),
      profile: _i6.Protocol().deserialize<_i4.Profile>(
        jsonSerialization['profile'],
      ),
      defaultAddress: jsonSerialization['defaultAddress'] == null
          ? null
          : _i6.Protocol().deserialize<_i5.Address>(
              jsonSerialization['defaultAddress'],
            ),
    );
  }

  _i2.Account account;

  _i3.AccountSummary summary;

  _i4.Profile profile;

  _i5.Address? defaultAddress;

  /// Returns a shallow copy of this [AccountState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountState copyWith({
    _i2.Account? account,
    _i3.AccountSummary? summary,
    _i4.Profile? profile,
    _i5.Address? defaultAddress,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountState',
      'account': account.toJson(),
      'summary': summary.toJson(),
      'profile': profile.toJson(),
      if (defaultAddress != null) 'defaultAddress': defaultAddress?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountState',
      'account': account.toJsonForProtocol(),
      'summary': summary.toJsonForProtocol(),
      'profile': profile.toJsonForProtocol(),
      if (defaultAddress != null)
        'defaultAddress': defaultAddress?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountStateImpl extends AccountState {
  _AccountStateImpl({
    required _i2.Account account,
    required _i3.AccountSummary summary,
    required _i4.Profile profile,
    _i5.Address? defaultAddress,
  }) : super._(
         account: account,
         summary: summary,
         profile: profile,
         defaultAddress: defaultAddress,
       );

  /// Returns a shallow copy of this [AccountState]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountState copyWith({
    _i2.Account? account,
    _i3.AccountSummary? summary,
    _i4.Profile? profile,
    Object? defaultAddress = _Undefined,
  }) {
    return AccountState(
      account: account ?? this.account.copyWith(),
      summary: summary ?? this.summary.copyWith(),
      profile: profile ?? this.profile.copyWith(),
      defaultAddress: defaultAddress is _i5.Address?
          ? defaultAddress
          : this.defaultAddress?.copyWith(),
    );
  }
}

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
import '../../../../features/wallet/domain/model/wallet_transactions.dart'
    as _i2;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i3;

abstract class Wallet
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Wallet._({
    this.id,
    double? cashBalance,
    int? connectBalance,
    this.transactions,
  }) : cashBalance = cashBalance ?? 0.0,
       connectBalance = connectBalance ?? 0;

  factory Wallet({
    _i1.UuidValue? id,
    double? cashBalance,
    int? connectBalance,
    List<_i2.WalletTransactions>? transactions,
  }) = _WalletImpl;

  factory Wallet.fromJson(Map<String, dynamic> jsonSerialization) {
    return Wallet(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      cashBalance: (jsonSerialization['cashBalance'] as num?)?.toDouble(),
      connectBalance: jsonSerialization['connectBalance'] as int?,
      transactions: jsonSerialization['transactions'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.WalletTransactions>>(
              jsonSerialization['transactions'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  double cashBalance;

  int connectBalance;

  List<_i2.WalletTransactions>? transactions;

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Wallet copyWith({
    _i1.UuidValue? id,
    double? cashBalance,
    int? connectBalance,
    List<_i2.WalletTransactions>? transactions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'cashBalance': cashBalance,
      'connectBalance': connectBalance,
      if (transactions != null)
        'transactions': transactions?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'cashBalance': cashBalance,
      'connectBalance': connectBalance,
      if (transactions != null)
        'transactions': transactions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletImpl extends Wallet {
  _WalletImpl({
    _i1.UuidValue? id,
    double? cashBalance,
    int? connectBalance,
    List<_i2.WalletTransactions>? transactions,
  }) : super._(
         id: id,
         cashBalance: cashBalance,
         connectBalance: connectBalance,
         transactions: transactions,
       );

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Wallet copyWith({
    Object? id = _Undefined,
    double? cashBalance,
    int? connectBalance,
    Object? transactions = _Undefined,
  }) {
    return Wallet(
      id: id is _i1.UuidValue? ? id : this.id,
      cashBalance: cashBalance ?? this.cashBalance,
      connectBalance: connectBalance ?? this.connectBalance,
      transactions: transactions is List<_i2.WalletTransactions>?
          ? transactions
          : this.transactions?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

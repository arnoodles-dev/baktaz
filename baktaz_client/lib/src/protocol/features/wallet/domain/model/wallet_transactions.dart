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
import '../../../../features/wallet/domain/model/wallet.dart' as _i2;
import '../../../../core/domain/model/enum/transaction_type.dart' as _i3;
import 'package:baktaz_client/src/protocol/protocol.dart' as _i4;

abstract class WalletTransactions
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  WalletTransactions._({
    this.id,
    required this.walletId,
    this.wallet,
    required this.amount,
    required this.transactionDate,
    required this.transactionType,
  });

  factory WalletTransactions({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    _i2.Wallet? wallet,
    required double amount,
    required DateTime transactionDate,
    required _i3.TransactionType transactionType,
  }) = _WalletTransactionsImpl;

  factory WalletTransactions.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletTransactions(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      wallet: jsonSerialization['wallet'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Wallet>(jsonSerialization['wallet']),
      amount: (jsonSerialization['amount'] as num).toDouble(),
      transactionDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionDate'],
      ),
      transactionType: _i3.TransactionType.fromJson(
        (jsonSerialization['transactionType'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue walletId;

  _i2.Wallet? wallet;

  double amount;

  DateTime transactionDate;

  _i3.TransactionType transactionType;

  /// Returns a shallow copy of this [WalletTransactions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WalletTransactions copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? walletId,
    _i2.Wallet? wallet,
    double? amount,
    DateTime? transactionDate,
    _i3.TransactionType? transactionType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletTransactions',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      if (wallet != null) 'wallet': wallet?.toJson(),
      'amount': amount,
      'transactionDate': transactionDate.toJson(),
      'transactionType': transactionType.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletTransactions',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      if (wallet != null) 'wallet': wallet?.toJsonForProtocol(),
      'amount': amount,
      'transactionDate': transactionDate.toJson(),
      'transactionType': transactionType.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletTransactionsImpl extends WalletTransactions {
  _WalletTransactionsImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    _i2.Wallet? wallet,
    required double amount,
    required DateTime transactionDate,
    required _i3.TransactionType transactionType,
  }) : super._(
         id: id,
         walletId: walletId,
         wallet: wallet,
         amount: amount,
         transactionDate: transactionDate,
         transactionType: transactionType,
       );

  /// Returns a shallow copy of this [WalletTransactions]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WalletTransactions copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? walletId,
    Object? wallet = _Undefined,
    double? amount,
    DateTime? transactionDate,
    _i3.TransactionType? transactionType,
  }) {
    return WalletTransactions(
      id: id is _i1.UuidValue? ? id : this.id,
      walletId: walletId ?? this.walletId,
      wallet: wallet is _i2.Wallet? ? wallet : this.wallet?.copyWith(),
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}

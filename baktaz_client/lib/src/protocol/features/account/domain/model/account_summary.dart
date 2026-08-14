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

abstract class AccountSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AccountSummary._({
    required this.name,
    this.imageUrl,
    required this.cashBalance,
    required this.connectBalance,
  });

  factory AccountSummary({
    required String name,
    Uri? imageUrl,
    required double cashBalance,
    required int connectBalance,
  }) = _AccountSummaryImpl;

  factory AccountSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountSummary(
      name: jsonSerialization['name'] as String,
      imageUrl: jsonSerialization['imageUrl'] == null
          ? null
          : _i1.UriJsonExtension.fromJson(jsonSerialization['imageUrl']),
      cashBalance: (jsonSerialization['cashBalance'] as num).toDouble(),
      connectBalance: jsonSerialization['connectBalance'] as int,
    );
  }

  String name;

  Uri? imageUrl;

  double cashBalance;

  int connectBalance;

  /// Returns a shallow copy of this [AccountSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AccountSummary copyWith({
    String? name,
    Uri? imageUrl,
    double? cashBalance,
    int? connectBalance,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountSummary',
      'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl?.toJson(),
      'cashBalance': cashBalance,
      'connectBalance': connectBalance,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountSummary',
      'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl?.toJson(),
      'cashBalance': cashBalance,
      'connectBalance': connectBalance,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountSummaryImpl extends AccountSummary {
  _AccountSummaryImpl({
    required String name,
    Uri? imageUrl,
    required double cashBalance,
    required int connectBalance,
  }) : super._(
         name: name,
         imageUrl: imageUrl,
         cashBalance: cashBalance,
         connectBalance: connectBalance,
       );

  /// Returns a shallow copy of this [AccountSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AccountSummary copyWith({
    String? name,
    Object? imageUrl = _Undefined,
    double? cashBalance,
    int? connectBalance,
  }) {
    return AccountSummary(
      name: name ?? this.name,
      imageUrl: imageUrl is Uri? ? imageUrl : this.imageUrl,
      cashBalance: cashBalance ?? this.cashBalance,
      connectBalance: connectBalance ?? this.connectBalance,
    );
  }
}

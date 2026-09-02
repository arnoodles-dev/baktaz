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

enum Rank implements _i1.SerializableModel {
  unknown,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  challengers,
  ;

  static Rank fromJson(String name) {
    switch (name) {
      case 'unknown':
        return Rank.unknown;
      case 'bronze':
        return Rank.bronze;
      case 'silver':
        return Rank.silver;
      case 'gold':
        return Rank.gold;
      case 'platinum':
        return Rank.platinum;
      case 'diamond':
        return Rank.diamond;
      case 'challengers':
        return Rank.challengers;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "Rank"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

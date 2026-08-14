import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_summary.freezed.dart';

@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required ValueName name,
    required Money balance,
    required Number connect,
    Url? imageUrl,
  }) = _AccountSummary;

  const AccountSummary._();

  factory AccountSummary.fromServer(serverpod.AccountSummary accountSummary) => AccountSummary(
    name: ValueName(accountSummary.name),
    balance: Money(accountSummary.cashBalance),
    connect: Number(accountSummary.connectBalance),
    imageUrl: accountSummary.imageUrl.let((Uri uri) => Url(uri.toString())),
  );

  Option<Failure> get validate => name.validate
      .andThen(() => imageUrl?.validate ?? right(unit))
      .andThen(() => balance.validate)
      .andThen(() => connect.validate)
      .fold(some, (_) => none());
}

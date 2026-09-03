import 'dart:async';
import 'dart:io';

import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:retry/retry.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IAccountRepository)
final class AccountRepository implements IAccountRepository {
  const AccountRepository(this._serverpod, this._retry, this._talker);

  final Serverpod _serverpod;
  final RetryOptions _retry;
  final Talker _talker;

  @override
  TaskResult<AccountSummary> getAccountSummary() => TaskResult<AccountSummary>.tryCatch(
    () async {
      final serverpod.AccountSummary result = await _retry.retry(
        () => _serverpod.client.account.getSummary(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      return AccountSummary.fromServer(result);
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<Profile> getProfile() => TaskResult<Profile>.tryCatch(
    () async {
      final serverpod.UserInfo? result = await _retry.retry(
        () => _serverpod.client.profile.getProfile(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );

      if (result == null) {
        throw const FormatException('Profile is null');
      }

      final Profile possibleFailure = Profile.fromServer(result);
      if (possibleFailure.validate.isSome()) {
        throw possibleFailure.validate.asSome();
      }

      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<Unit> addAddress(Address address) => TaskResult<Unit>.left(const Failure.unexpected('Not implemented'));

  @override
  TaskResult<Address?> getDefaultAddress() => TaskResult<Address?>.right(null);

  @override
  TaskResult<Unit> deleteAccount() => TaskResult<Unit>.tryCatch(
    () async {
      await _retry.retry(
        () => _serverpod.client.account.deleteAccount(),
        retryIf: (Exception exception) => exception is SocketException || exception is TimeoutException,
      );
      return unit;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );
}

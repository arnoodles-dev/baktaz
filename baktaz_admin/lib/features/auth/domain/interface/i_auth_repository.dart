import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

abstract interface class IAuthRepository {
  bool get isAuthenticated;

  Future<void> login({
    required EmailAddress email,
    required Password password,
    required void Function(AuthSuccess?) onAuthenticated,
    required void Function(Failure) onError,
  });

  TaskResult<Unit> logout();

  TaskResult<Account> getCurrentAccount();
}

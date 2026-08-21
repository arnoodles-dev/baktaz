import 'package:baktaz_admin/app/config/serverpod_config.dart';
import 'package:baktaz_admin/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IAuthRepository)
final class AuthRepository implements IAuthRepository {
  const AuthRepository(this._serverpod, this._talker);

  final Serverpod _serverpod;
  final Talker _talker;

  @override
  bool get isAuthenticated => _serverpod.sessionManager.isAuthenticated;

  @override
  Future<void> login({
    required EmailAddress email,
    required Password password,
    required void Function(AuthSuccess?) onAuthenticated,
    required void Function(Failure) onError,
  }) async {
    try {
      final EmailAuthController controller = EmailAuthController(
        client: _serverpod.client,
        onAuthenticated: () {
          final AuthSuccess? authInfo = _serverpod.sessionManager.authInfo;
          onAuthenticated(authInfo);
        },
        onError: (Object error) => onError(Failure.authentication(error.toString())),
      );
      controller.emailController.text = email.getValue();
      controller.passwordController.text = password.getValue();
      await controller.login();
    } on Object catch (error, stackTrace) {
      _talker.handle(error, stackTrace);
      onError(Failure.unexpected(error.toString()));
    }
  }

  @override
  TaskResult<Unit> logout() => TaskResult<Unit>.tryCatch(
    () async {
      await _serverpod.sessionManager.signOutDevice();
      return unit;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      if (error is Failure) return error;
      return Failure.unexpected(error.toString());
    },
  );

  @override
  TaskResult<Account> getCurrentAccount() => TaskResult<Account>.tryCatch(
    () async {
      final Account? account = await _serverpod.client.account.getCurrentAccount();
      if (account == null) throw const FormatException('Account not found');
      return account;
    },
    (Object error, StackTrace stackTrace) {
      _talker.handle(error, stackTrace);
      if (error is Failure) return error;
      return Failure.unexpected(error.toString());
    },
  );
}

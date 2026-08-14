import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

abstract interface class IAuthRepository {
  AuthSuccess? get authInfo;

  Future<void> loginWithProvider({
    required LoginProvider provider,
    required void Function(AuthSuccess?) onAuthenticated,
    required void Function(Failure) onError,
    MobileNumber? mobileNumber,
  });

  TaskResult<Unit> logout();
}

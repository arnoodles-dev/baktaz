import 'package:baktaz_server/src/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';

final class AuthEndpoint extends Endpoint {
  AuthEndpoint([IAuthRepository? authRepository])
    : _authRepository =
          authRepository ??
          (GetIt.I.isRegistered<IAuthRepository>()
              ? GetIt.I<IAuthRepository>()
              : AuthRepository(GetIt.I.isRegistered<SecurityLogger>() ? GetIt.I<SecurityLogger>() : SecurityLogger()));

  final IAuthRepository _authRepository;

  @override
  bool get requireLogin => false;

  Future<OtpVerificationResult> completeRegistration(
    Session session, {
    required String email,
    required String name,
    required String gender,
    required String registrationToken,
    DateTime? birthday,
  }) async => _authRepository.completeRegistration(
    session,
    email: email,
    name: name,
    gender: gender,
    registrationToken: registrationToken,
    birthday: birthday,
  );
}

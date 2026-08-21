import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

abstract interface class IAuthRepository {
  AuthSuccess? get authInfo;

  TaskResult<Unit> sendOtp({required String email});

  TaskResult<AuthSuccess?> loginWithGoogle();

  TaskResult<AuthSuccess?> loginWithFacebook();

  TaskResult<OtpVerificationResult> verifyOtp({required String email, required String code});

  TaskResult<AuthSuccess> completeRegistration({
    required String email,
    required String name,
    required String gender,
    required String registrationToken,
    DateTime? birthday,
  });

  TaskResult<Unit> logout();
}

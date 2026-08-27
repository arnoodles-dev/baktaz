import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/config/app_config.dart';
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_idp_flutter_facebook/serverpod_auth_idp_flutter_facebook.dart';
import 'package:talker/talker.dart';

@LazySingleton(as: IAuthRepository)
final class AuthRepository implements IAuthRepository {
  AuthRepository(this._serverpod, this._talker);

  final Serverpod _serverpod;
  final Talker _talker;

  @override
  AuthSuccess? get authInfo => _serverpod.sessionManager.authInfo;

  @override
  TaskResult<Unit> sendOtp({required String email}) => TaskResult<Unit>.tryCatch(
    () async {
      if (email.trim().isEmpty) {
        throw const Failure.authentication('Email is required for email login');
      }
      await _serverpod.client.otp.sendOtp(email: email.trim());
      return unit;
    },
    (Object error, StackTrace stackTrace) {
      if (error is Failure) return error;
      _talker.handle(error, stackTrace);
      return Failure.authentication(error.toString());
    },
  );

  @override
  TaskResult<AuthSuccess?> loginWithGoogle() => TaskResult<AuthSuccess?>.tryCatch(
    () async {
      final Completer<AuthSuccess?> completer = Completer<AuthSuccess?>();
      await GoogleAuthController(
        client: _serverpod.client,
        onAuthenticated: () async {
          final AuthSuccess? authInfo = _serverpod.sessionManager.authInfo;
          if (_serverpod.sessionManager.isAuthenticated && authInfo != null) {
            completer.complete(authInfo);
          } else {
            completer.complete(null);
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(Failure.authentication(error.toString()));
          }
        },
      ).signIn();
      return completer.future;
    },
    (Object error, StackTrace stackTrace) {
      if (error is Failure) return error;
      _talker.handle(error, stackTrace);
      return Failure.unexpected(error.toString());
    },
  );

  // ponytail: Facebook sign-in wired up but SDK integration unverified.
  // Ceiling = unvalidated prod flow. Upgrade = test with real FB app credentials.
  // TODO: Validate and smoke-test Facebook sign-in end-to-end before release.
  @override
  TaskResult<AuthSuccess?> loginWithFacebook() => TaskResult<AuthSuccess?>.tryCatch(
    () async {
      final Completer<AuthSuccess?> completer = Completer<AuthSuccess?>();
      final FacebookAuthController controller = FacebookAuthController(
        client: _serverpod.client,
        onAuthenticated: () async {
          final AuthSuccess? authInfo = _serverpod.sessionManager.authInfo;
          if (_serverpod.sessionManager.isAuthenticated && authInfo != null) {
            completer.complete(authInfo);
          } else {
            completer.complete(null);
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(Failure.authentication(error.toString()));
          }
        },
      );
      await controller.client.auth.initializeFacebookSignIn(appId: AppConfig.facebookAppId);
      await controller.signIn();
      return completer.future;
    },
    (Object error, StackTrace stackTrace) {
      if (error is Failure) return error;
      _talker.handle(error, stackTrace);
      return Failure.unexpected(error.toString());
    },
  );

  @override
  TaskResult<OtpVerificationResult> verifyOtp({required String email, required String code}) =>
      TaskResult<OtpVerificationResult>.tryCatch(
        () async {
          final OtpVerificationResult result = await _serverpod.client.otp.verifyOtp(email: email, code: code);
          if (result.authInfo != null) {
            await _serverpod.sessionManager.updateSignedInUser(result.authInfo);
          }
          return result;
        },
        (Object error, StackTrace stackTrace) {
          if (error is Failure) return error;
          if (error is OtpException) {
            _talker.handle(error, stackTrace);
            final bool isAdminBlock = error.message.contains('Admin accounts cannot use OTP login');
            final bool isBlocked =
                isAdminBlock || error.message.contains('blocked') || error.message.contains('Too many attempts');
            return Failure.authentication(error.message, blocked: isBlocked);
          }
          _talker.handle(error, stackTrace);
          final String message = error.toString();
          if (error is StateError && message.contains('Admin accounts cannot use OTP login')) {
            return const Failure.authentication('Admin accounts cannot use OTP login', blocked: true);
          }
          if (message.contains('blocked') || error is StateError || message.contains('AuthUserBlockedException')) {
            return const Failure.authentication('Account blocked', blocked: true);
          }
          return Failure.authentication(message);
        },
      );

  @override
  TaskResult<AuthSuccess> completeRegistration(RegistrationForm form) => TaskResult<AuthSuccess>.tryCatch(
    () async {
      final OtpVerificationResult result = await _serverpod.client.auth.completeRegistration(form);
      if (result.authInfo != null) {
        await _serverpod.sessionManager.updateSignedInUser(result.authInfo);
        return result.authInfo!;
      }
      throw const Failure.authentication('Registration failed to return auth info');
    },
    (Object error, StackTrace stackTrace) {
      if (error is Failure) return error;
      if (error is OtpException) {
        _talker.handle(error, stackTrace);
        final bool isAdminBlock = error.message.contains('Admin accounts cannot use OTP login');
        final bool isBlocked =
            isAdminBlock || error.message.contains('blocked') || error.message.contains('Too many attempts');
        return Failure.authentication(error.message, blocked: isBlocked);
      }
      _talker.handle(error, stackTrace);
      final String message = error.toString();
      if (error is StateError && message.contains('Admin accounts cannot use OTP login')) {
        return const Failure.authentication('Admin accounts cannot use OTP login', blocked: true);
      }
      return Failure.authentication(message);
    },
  );

  @override
  TaskResult<Unit> logout() => TaskResult<Unit>.tryCatch(
    () async {
      await _serverpod.sessionManager.signOutDevice();
      return unit;
    },
    (Object error, StackTrace stackTrace) {
      if (error is Failure) return error;
      _talker.handle(error, stackTrace);
      return Failure.unexpected(error.toString());
    },
  );
}

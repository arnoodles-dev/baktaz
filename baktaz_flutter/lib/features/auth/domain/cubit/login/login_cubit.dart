import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends CubitSignal<LoginState> with BlocSignalPresentationMixin<LoginStateSideEffect, LoginState> {
  LoginCubit(this._authRepository, this._analyticsService, this._failureHandler)
    : super(initialState: const LoginState.idle());

  final IAuthRepository _authRepository;
  final IAnalyticsService _analyticsService;
  final FailureHandler _failureHandler;

  Future<void> loginWithProvider(LoginProvider provider, {String? email}) async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (stateValue is LoginStateIdle) {
          safeEmit(LoginState.idle(isLoading: isLoading));
        }
      },
      action: () async {
        final TaskResult<dynamic> taskResult = switch (provider) {
          LoginProvider.google => _authRepository.loginWithGoogle(),
          LoginProvider.facebook => _authRepository.loginWithFacebook(),
          LoginProvider.email => _authRepository.sendOtp(email: email ?? ''),
        };

        final Either<Failure, dynamic> result = await taskResult.run();
        result.fold(_onAuthError, (dynamic value) {
          switch (provider) {
            case LoginProvider.google:
            case LoginProvider.facebook:
              _onAuthenticated(value as AuthSuccess?, provider);
            case LoginProvider.email:
              if (email != null && email.trim().isNotEmpty) {
                safeEmit(LoginState.codeSent(email));
              }
          }
        });
      },
    );
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(LoginState.verifying(email: email));
        }
      },
      action: () async {
        final Either<Failure, OtpVerificationResult> result = await _authRepository
            .verifyOtp(email: email, code: code)
            .run();
        result.fold(_onAuthError, (OtpVerificationResult verificationResult) {
          safeEmit(LoginState.verified(verificationResult));
          if (verificationResult.authInfo != null) {
            _onAuthenticated(verificationResult.authInfo, LoginProvider.email);
          }
        });
      },
    );
  }

  Future<void> completeRegistration(RegistrationForm form) async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Either<Failure, AuthSuccess> result = await _authRepository.completeRegistration(form).run();
        result.fold(_onAuthError, (AuthSuccess authInfo) {
          safeEmit(LoginState.registrationCompleted(authInfo));
          _onAuthenticated(authInfo, LoginProvider.email);
        });
      },
    );
  }

  void _onAuthenticated(AuthSuccess? authInfo, LoginProvider provider) {
    unawaited(_analyticsService.logLogin(provider.name));
    if (authInfo != null) {
      safeEmit(LoginState.success(authInfo));
    }
  }

  void _onAuthError(Failure failure) {
    _failureHandler.handleFailure(failure); // global toast via ErrorActions
    if (failure is AuthenticationFailure && failure.blocked) {
      safeEmit(const LoginState.blocked());
      return;
    }
    // Contextual inline error for OTP screen (side-effect, NOT state):
    final String message = failure.message ?? 'Authentication failed';
    emitPresentation(LoginStateOtpError(message));
  }
}

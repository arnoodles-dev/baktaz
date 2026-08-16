import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends CubitSignal<LoginState> {
  LoginCubit(this._authRepository, this._analyticsService, this._failureHandler)
    : super(initialState: const LoginState.idle());

  final IAuthRepository _authRepository;
  final IAnalyticsService _analyticsService;
  final FailureHandler _failureHandler;

  Future<void> loginWithMobile(String countryCode, String mobileNumber) async {
    await safeRun(
      onException: _failureHandler.handleException,

      action: () async {
        await _authRepository.loginWithProvider(
          provider: LoginProvider.mobile,
          mobileNumber: MobileNumber(mobileNumber),
          onAuthenticated: (AuthSuccess? authInfo) => _onAuthenticated(authInfo, LoginProvider.mobile),
          onError: _onAuthError,
        );
      },
    );
  }

  Future<void> loginWithProvider(LoginProvider provider, {MobileNumber? mobileNumber}) async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (state is LoginStateIdle) {
          safeEmit(LoginState.idle(isLoading: isLoading));
        }
      },
      action: () async {
        await Future<void>.delayed(const Duration(seconds: 2));
        await _authRepository.loginWithProvider(
          provider: provider,
          mobileNumber: mobileNumber,
          onAuthenticated: (AuthSuccess? authInfo) => _onAuthenticated(authInfo, provider),
          onError: _onAuthError,
        );
      },
    );
  }

  void _onAuthenticated(AuthSuccess? authInfo, LoginProvider provider) {
    unawaited(_analyticsService.logLogin(provider.name));
    if (authInfo == null) {
      safeEmit(const LoginState.registrationRequired());
    } else {
      safeEmit(LoginState.success(authInfo));
    }
  }

  void _onAuthError(Failure failure) {
    _failureHandler.handleFailure(failure);
    safeEmit(LoginState.failed(failure));
    // emit the initial state to reset the error
    safeEmit(const LoginState.idle());
  }
}

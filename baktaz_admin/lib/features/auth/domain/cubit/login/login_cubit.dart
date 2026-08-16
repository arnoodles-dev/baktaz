import 'dart:async';

import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_admin/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends CubitSignal<LoginState> {
  LoginCubit(
    this._authRepository,
    this._localStorageRepository,
    this._failureHandler,
  ) : super(initialState: LoginState.initial());

  final IAuthRepository _authRepository;
  final ILocalStorageRepository _localStorageRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      action: () async {
        final Result<String?> possibleFailure = await _localStorageRepository.getLastLoggedInUsername().run();
        possibleFailure.fold(_failureHandler.handleFailure, (String? email) {
          safeEmit(stateValue.copyWith(email: email));
        });
      },
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) => safeEmit(stateValue.copyWith(isLoading: isLoading)),
    );
  }

  Future<void> login(String emailInput, String passwordInput) async {
    await safeRun(
      action: () async {
        safeEmit(stateValue.copyWith(email: emailInput));

        final EmailAddress email = EmailAddress(emailInput);
        final Password password = Password(passwordInput);

        if (email.isValid && password.isValid) {
          await _authRepository.login(
            email: email,
            password: password,
            onAuthenticated: _onAuthenticated,
            onError: _onAuthError,
          );
        } else {
          _onAuthError(!email.isValid ? email.value.asLeft() : password.value.asLeft());
        }
      },
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) => safeEmit(stateValue.copyWith(isLoading: isLoading)),
    );
  }

  void _onAuthenticated(AuthSuccess? authInfo) {
    if (authInfo != null) {
      if (getIt.isRegistered<AuthCubit>()) {
        try {
          unawaited(getIt<AuthCubit>().authenticate());
        } on Exception catch (_) {}
      }
    } else {
      _onAuthError(const Failure.authentication('Authentication failed'));
    }
  }

  void _onAuthError(Failure failure) {
    _failureHandler.handleFailure(failure);
  }

  void onEmailChanged(String email) => safeEmit(stateValue.copyWith(email: email, isLoading: false));
}

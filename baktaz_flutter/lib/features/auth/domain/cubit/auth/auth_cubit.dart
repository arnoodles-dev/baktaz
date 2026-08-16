import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

@lazySingleton
class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(
    this._authRepository,
    this._crashlyticsService,
    this._failureHandler,
  ) : super(initialState: const AuthState.initial());

  final IAuthRepository _authRepository;
  final ICrashlyticsService _crashlyticsService;
  final FailureHandler _failureHandler;

  Future<void> initialize({bool isOnboardingDone = true}) async {
    await safeRun(
      onException: (Exception error, StackTrace? stackTrace) {
        _failureHandler.handleException(error, stackTrace);
        _emitError(Failure.authentication(error.toString()));
      },
      action: () async {
        isOnboardingDone
            ? _emitAuthState(_authRepository.authInfo, isLogout: true)
            : safeEmit(const AuthState.unauthenticated());
      },
    );
  }

  void authenticate(AuthSuccess authInfo) {
    safeRun(
      action: () {
        _crashlyticsService.setUserId(authInfo.authUserId.uuid);
        safeEmit(AuthState.authenticated(authInfo: authInfo));
      },
      onException: (Exception error, StackTrace? stackTrace) {
        _failureHandler.handleException(error, stackTrace);
        _emitError(Failure.authentication(error.toString()));
      },
    );
  }

  Future<void> terminateSession({bool isLogout = true}) async {
    await safeRun(
      onException: (Exception error, StackTrace? stackTrace) {
        _failureHandler.handleException(error, stackTrace);
        _emitError(Failure.authentication(error.toString()));
      },

      action: () async {
        if (isLogout) {
          final Result<Unit> possibleFailure = await _authRepository.logout().run();
          possibleFailure.fold(_failureHandler.handleFailure, (_) {
            safeEmit(const AuthState.unauthenticated());
          });
        }
      },
    );
  }

  /// if isLogout = true then logout app on Failure else retain current screen
  void _emitAuthState(AuthSuccess? authInfo, {bool isLogout = false}) {
    if (authInfo != null) {
      _crashlyticsService.setUserId(authInfo.authUserId.uuid);
      safeEmit(AuthState.authenticated(authInfo: authInfo));
    } else {
      if (isLogout) {
        safeEmit(const AuthState.unauthenticated());
      }
    }
  }

  void _emitError(Failure failure) {
    _failureHandler.handleFailure(failure);
  }
}

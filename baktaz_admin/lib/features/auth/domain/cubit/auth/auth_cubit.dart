import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

@lazySingleton
class AuthCubit extends CubitSignal<AuthState> {
  AuthCubit(
    this._authRepository,
    this._failureHandler,
  ) : super(initialState: const AuthState.initial());

  final IAuthRepository _authRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      action: () async {
        safeEmit(const AuthState.initial());
        if (_authRepository.isAuthenticated) {
          _emitAuthState(await _authRepository.getCurrentAccount().run(), isLogout: true);
        } else {
          safeEmit(const AuthState.unauthenticated());
        }
      },
      onException: (Exception error, StackTrace? stackTrace) => _emitError(right(error), stackTrace: stackTrace),
    );
  }

  Future<void> getUser() async {
    await safeRun(
      action: () async {
        safeEmit(const AuthState.loading());
        _emitAuthState(await _authRepository.getCurrentAccount().run());
      },
      onException: (Exception error, StackTrace? stackTrace) =>
          _emitError(right(error), isLogout: false, stackTrace: stackTrace),
    );
  }

  Future<void> authenticate() async {
    await safeRun(
      action: () async {
        safeEmit(const AuthState.loading());
        _emitAuthState(await _authRepository.getCurrentAccount().run(), isLogout: true);
      },
      onException: (Exception error, StackTrace? stackTrace) => _emitError(right(error), stackTrace: stackTrace),
    );
  }

  Future<void> logout() async {
    await safeRun(
      action: () async {
        safeEmit(const AuthState.loading());
        final Result<Unit> possibleFailure = await _authRepository.logout().run();
        possibleFailure.fold(
          (Failure failure) => _emitError(left(failure)),
          (_) => safeEmit(const AuthState.unauthenticated()),
        );
      },
      onException: (Exception error, StackTrace? stackTrace) => _emitError(right(error), stackTrace: stackTrace),
    );
  }

  void _emitAuthState(Result<Account> possibleFailure, {bool isLogout = false}) {
    possibleFailure.fold((Failure failure) {
      _emitError(left(failure), isLogout: isLogout);
    }, (Account account) => safeEmit(AuthState.authenticated(account: account)));
  }

  void _emitError(Result<Object> failureOrError, {bool isLogout = true, StackTrace? stackTrace}) {
    if (isLogout) {
      safeEmit(const AuthState.unauthenticated());
    }
    failureOrError.fold(_failureHandler.handleFailure, (Object error) {
      _failureHandler.handleException(error as Exception, stackTrace);
    });
  }
}

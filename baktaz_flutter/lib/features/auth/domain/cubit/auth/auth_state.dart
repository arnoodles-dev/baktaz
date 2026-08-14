part of 'auth_cubit.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated({AuthSuccess? authInfo}) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;

  const AuthState._();
}

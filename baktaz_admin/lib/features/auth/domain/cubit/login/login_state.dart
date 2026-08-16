part of 'login_cubit.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({required bool isLoading, String? email}) = _LoginState;

  factory LoginState.initial() => const _LoginState(isLoading: true);

  const LoginState._();
}

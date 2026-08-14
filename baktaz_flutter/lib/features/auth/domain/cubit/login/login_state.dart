part of 'login_cubit.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.idle({@Default(false) bool isLoading}) = LoginStateIdle;
  const factory LoginState.success(AuthSuccess authInfo) = _Success;
  const factory LoginState.registrationRequired() = _RegistrationRequired;
  const factory LoginState.failed(Failure failure) = _Failed;

  const LoginState._();
}

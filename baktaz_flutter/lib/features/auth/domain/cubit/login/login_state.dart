part of 'login_cubit.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.idle({@Default(false) bool isLoading}) = LoginStateIdle;
  const factory LoginState.codeSent(String email) = LoginStateCodeSent;
  const factory LoginState.verifying({required String email}) = LoginStateVerifying;
  const factory LoginState.verified(OtpVerificationResult result) = LoginStateVerified;
  const factory LoginState.registrationCompleted(AuthSuccess authInfo) = LoginStateRegistrationCompleted;
  const factory LoginState.success(AuthSuccess authInfo) = LoginStateSuccess;
  const factory LoginState.blocked() = LoginStateBlocked;
  const LoginState._();
}

@freezed
sealed class LoginStateSideEffect with _$LoginStateSideEffect {
  const factory LoginStateSideEffect.onOtpError(String message) = LoginStateOtpError;
}

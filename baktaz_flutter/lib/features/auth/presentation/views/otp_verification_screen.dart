import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/baktaz_otp_screen.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OtpVerificationScreen extends HookWidget {
  const OtpVerificationScreen({required this.email, super.key});

  final String email;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String?> otpError = useState<String?>(null);

    return BlocSignalProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocSignalPresentationListener<LoginCubit, LoginStateSideEffect>(
          listener: (BuildContext context, LoginStateSideEffect event) {
            event.when(onOtpError: (String message) => otpError.value = message);
          },
          child: BaktazOtpScreen(
            email: email,
            otpError: otpError.value,
            onOtpVerified: (String code) {
              otpError.value = null;
              context.read<LoginCubit>().verifyOtp(email: email, code: code);
            },
            onResend: () {
              otpError.value = null;
              context.read<LoginCubit>().loginWithProvider(LoginProvider.email, email: email);
            },
          ),
        ),
      ),
    );
  }
}

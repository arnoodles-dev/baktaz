import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/utils/error_message_utils.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/baktaz_otp_screen.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class OtpVerificationScreen extends HookWidget {
  const OtpVerificationScreen({required this.email, super.key});

  final String email;

  void _onStateChangedListener(BuildContext context, LoginState state, ValueNotifier<String?> otpError) {
    state.whenOrNull(
      idle: (bool isLoading) {
        isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();
      },
      verifying: (_) => context.loaderOverlay.show(),
      verified: (OtpVerificationResult result) {
        context.loaderOverlay.hide();
        if (result.isNewUser) {
          RegistrationRoute(email: email, registrationToken: result.registrationToken ?? '').push<void>(context);
        }
      },
      registrationCompleted: (AuthSuccess authInfo) {
        context.loaderOverlay.hide();
        context.read<AuthCubit>().authenticate(authInfo);
      },
      success: (AuthSuccess authInfo) {
        context.loaderOverlay.hide();
        context.read<AuthCubit>().authenticate(authInfo);
      },
      blocked: () {
        context.loaderOverlay.hide();
        const BlockedRoute().push<void>(context);
      },
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        otpError.value = ErrorMessageUtils.generate(context, failure);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String?> otpError = useState<String?>(null);

    return BlocSignalProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocSignalListener<LoginCubit, LoginState>(
          listener: (BuildContext context, LoginState state) => _onStateChangedListener(context, state, otpError),
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

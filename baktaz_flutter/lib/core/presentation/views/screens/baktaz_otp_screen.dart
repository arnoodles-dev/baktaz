import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pinput/pinput.dart';

class BaktazOtpScreen extends HookWidget {
  const BaktazOtpScreen({required this.email, this.otpError, this.onOtpVerified, this.onResend, super.key});

  final String email;
  final String? otpError;
  final ValueChanged<String>? onOtpVerified;
  final VoidCallback? onResend;

  static const int otpLength = 6;

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinController = useTextEditingController();
    final FocusNode focusNode = useFocusNode();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      resizeToAvoidBottomInset: false,
      body: FractionallySizedBox(
        widthFactor: 1,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: context.padding.top + AppSizes.medium,
            left: AppSizes.large,
            right: AppSizes.large,
          ),
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.colorScheme.secondaryContainer),
                child: BackButton(color: context.colorScheme.onSecondaryContainer),
              ),
            ),
            Gap.xLarge(),
            Center(
              child: BaktazText(
                text: context.i18n.otp.header,
                style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.secondary),
              ),
            ),
            Gap.medium(),
            Center(
              child: BaktazText(
                textType: TextType.styled,
                textAlign: TextAlign.center,
                text: context.i18n.otp.email_description(email: email),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: AppFontWeight.regular,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            Gap.xLarge(),
            RepaintBoundary(
              child: _OtpForm(
                pinController: pinController,
                focusNode: focusNode,
                otpError: otpError,
                onOtpVerified: onOtpVerified,
                onResend: onResend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpForm extends HookWidget {
  const _OtpForm({
    required this.pinController,
    required this.focusNode,
    required this.otpError,
    this.onOtpVerified,
    this.onResend,
  });

  final TextEditingController pinController;
  final FocusNode focusNode;
  final String? otpError;
  final ValueChanged<String>? onOtpVerified;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = context.colorScheme.surfaceContainerHighest;
    final PinTheme defaultPinTheme = PinTheme(
      width: AppSizes.size56,
      height: AppSizes.size60,
      textStyle: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.secondary),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        border: const Border.fromBorderSide(BorderSide.none),
      ),
    );

    return Column(
      children: <Widget>[
        Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            length: BaktazOtpScreen.otpLength,
            controller: pinController,
            focusNode: focusNode,
            defaultPinTheme: defaultPinTheme,
            forceErrorState: otpError != null,
            separatorBuilder: (int index) => Gap.small(),
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onCompleted: (String pin) {
              onOtpVerified?.call(pin);
            },
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: context.colorScheme.primary)),
            ),
            errorPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: context.colorScheme.error)),
            ),
          ),
        ),
        Gap.large(),
        if (otpError != null) ...<Widget>[
          Center(
            child: BaktazText(
              text: otpError!,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: AppFontWeight.semiBold,
                color: context.colorScheme.error,
              ),
            ),
          ),
          Gap.xLarge(),
        ] else
          Gap.xLarge(),
        Center(
          child: GestureDetector(
            onTap: onResend,
            child: BaktazText(
              text: context.i18n.otp.resend,
              style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }
}

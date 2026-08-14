import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pinput/pinput.dart';

class BaktazOtpScreen extends HookWidget {
  const BaktazOtpScreen({super.key});

  static const int otpLength = 6;

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinController = useTextEditingController();
    final FocusNode focusNode = useFocusNode();

    final ValueNotifier<bool> canSubmit = useState<bool>(false);
    final ValueNotifier<String?> otpError = useState<String?>(null);

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
                text: context.i18n.otp.description(phoneNumber: '+91*****6210'),
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
                canSubmit: canSubmit,
                otpError: otpError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpForm extends StatelessWidget {
  const _OtpForm({
    required this.pinController,
    required this.focusNode,
    required this.canSubmit,
    required this.otpError,
  });

  final TextEditingController pinController;
  final FocusNode focusNode;
  final ValueNotifier<bool> canSubmit;
  final ValueNotifier<String?> otpError;

  Future<void> _onSubmitTap(BuildContext context) async {
    context.loaderOverlay.show();
    await Future<void>.delayed(const Duration(seconds: 1));
    if (pinController.text != '123456' && context.mounted) {
      otpError.value = context.i18n.otp.error.incorrect_code;
      context.loaderOverlay.hide();
    } else {
      if (context.mounted) {
        context.loaderOverlay.hide();
        Navigator.pop(context);
      }
    }
  }

  void _onPinChanged(String text) {
    final bool validPinLength = pinController.length == BaktazOtpScreen.otpLength;
    if (canSubmit.value != validPinLength) {
      canSubmit.value = validPinLength;
      if (otpError.value != null && !canSubmit.value) {
        otpError.value = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = context.colorScheme.primary;
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
            forceErrorState: otpError.value != null,
            separatorBuilder: (int index) => Gap.small(),
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            onChanged: _onPinChanged,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: borderColor)),
            ),
            errorPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: context.colorScheme.error)),
            ),
          ),
        ),
        Gap.x2Large(),
        ValueListenableBuilder<bool>(
          valueListenable: canSubmit,
          builder: (BuildContext context, bool canSubmitValue, _) => BaktazButton(
            isExpanded: true,
            text: context.i18n.otp.button.verify,
            textStyle: context.textTheme.bodyLarge?.copyWith(
              color: canSubmitValue ? context.colorScheme.onPrimary : context.colorScheme.outline,
            ),
            onPressed: canSubmitValue
                ? () {
                    focusNode.unfocus();
                    _onSubmitTap(context);
                  }
                : null,
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: otpError,
          builder: (BuildContext context, String? errorValue, _) {
            if (errorValue != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.medium, bottom: AppSizes.xSmall),
                  child: BaktazText(
                    text: errorValue,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.error,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ),
              );
            }
            return Gap.xLarge();
          },
        ),
        Center(
          child: BaktazText(
            text: context.i18n.otp.resend,
            style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.outline),
          ),
        ),
      ],
    );
  }
}

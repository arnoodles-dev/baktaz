import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.message,
    required this.negativeButtonText,
    required this.positiveButtonText,
    this.title,
    this.titleColor,
    this.onNegativePressed,
    this.onPositivePressed,
    this.negativeButtonTextColor,
    this.positiveButtonTextColor,
    super.key,
  });

  final String message;
  final String? title;
  final Color? titleColor;
  final String negativeButtonText;
  final String positiveButtonText;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;

  final Color? negativeButtonTextColor;
  final Color? positiveButtonTextColor;

  @override
  Widget build(BuildContext context) {
    final String? title = this.title;
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium))),
      title: title != null ? BaktazText(text: title, style: context.textTheme.titleMedium) : null,
      content: Padding(
        padding: title != null ? EdgeInsets.zero : Paddings.topX3Small,
        child: BaktazText(
          text: message,
          style: context.textTheme.bodyMedium?.copyWith(color: titleColor),
        ),
      ),
      actions: <Widget>[
        BaktazButton(
          text: negativeButtonText,
          buttonType: ButtonType.text,
          onPressed: onNegativePressed ?? () => context.navigator.pop(),
          padding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          textStyle: AppTextStyle.labelLarge.copyWith(color: negativeButtonTextColor ?? context.colorScheme.primary),
        ),
        BaktazButton(
          text: positiveButtonText,
          buttonType: ButtonType.text,
          onPressed: onPositivePressed ?? () => context.navigator.pop(),
          padding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          textStyle: AppTextStyle.labelLarge.copyWith(color: positiveButtonTextColor ?? context.colorScheme.primary),
        ),
      ],
      actionsPadding: Paddings.horizontalMedium,
      buttonPadding: EdgeInsets.zero,
    );
  }
}

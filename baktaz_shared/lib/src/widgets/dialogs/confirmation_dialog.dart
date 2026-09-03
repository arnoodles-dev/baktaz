import 'package:baktaz_shared/src/entity/enum/button_type.dart';
import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_button.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
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
  final String negativeButtonText;
  final String positiveButtonText;
  final String? title;
  final Color? titleColor;
  final VoidCallback? onNegativePressed;
  final VoidCallback? onPositivePressed;
  final Color? negativeButtonTextColor;
  final Color? positiveButtonTextColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? title = this.title;
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.md))),
      title: title != null ? BaktazText(text: title, style: theme.textTheme.titleMedium) : null,
      content: Padding(
        padding: title != null ? EdgeInsets.zero : const EdgeInsets.only(top: BaktazSpacing.xs),
        child: BaktazText(
          text: message,
          style: theme.textTheme.bodyMedium?.copyWith(color: titleColor),
        ),
      ),
      actions: <Widget>[
        BaktazButton(
          text: negativeButtonText,
          buttonType: ButtonType.text,
          onPressed: onNegativePressed ?? () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          textStyle: theme.textTheme.labelLarge?.copyWith(color: negativeButtonTextColor ?? theme.colorScheme.primary),
        ),
        BaktazButton(
          text: positiveButtonText,
          buttonType: ButtonType.text,
          onPressed: onPositivePressed ?? () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          textStyle: theme.textTheme.labelLarge?.copyWith(color: positiveButtonTextColor ?? theme.colorScheme.primary),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md),
      buttonPadding: EdgeInsets.zero,
    );
  }
}

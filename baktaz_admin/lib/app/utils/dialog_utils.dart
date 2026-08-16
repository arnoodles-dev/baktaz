import 'dart:async';

import 'package:animations/animations.dart';
import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/app/themes/app_theme.dart';
import 'package:baktaz_admin/app/utils/app_utils.dart';
import 'package:baktaz_admin/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:toastification/toastification.dart';

// ignore_for_file: long-method,long-parameter-list
final class DialogUtils {
  DialogUtils._();

  static Future<bool> showExitDialog(BuildContext context) async =>
      await DialogUtils.showConfirmationDialog(
        context,
        message: context.i18n.dialog.exit_message,
        onPositivePressed: AppUtils.closeApp,
      ) ??
      false;

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String message,
    String? title,
    String? negativeButtonText,
    String? positiveButtonText,
    VoidCallback? onNegativePressed,
    VoidCallback? onPositivePressed,
    Color? negativeButtonTextColor,
    Color? positiveButtonTextColor,
    Color? titleColor,
  }) => showModal<bool?>(
    context: context,
    builder: (BuildContext context) => ConfirmationDialog(
      message: message,
      title: title,
      titleColor: titleColor,
      negativeButtonText: negativeButtonText ?? context.i18n.common.no.toUpperCase(),
      positiveButtonText: positiveButtonText ?? context.i18n.common.yes.toUpperCase(),
      onNegativePressed: onNegativePressed,
      onPositivePressed: onPositivePressed,
      negativeButtonTextColor: negativeButtonTextColor,
      positiveButtonTextColor: positiveButtonTextColor,
    ),
  );

  static ToastificationItem showError(
    String message, {
    Widget? icon,
    Duration? duration,
    bool isDismissable = true,
    Alignment alignment = Alignment.topCenter,
    BuildContext? context,
  }) => toastification.show(
    title: BaktazText(text: message, overflow: TextOverflow.ellipsis, maxLines: 3),
    icon: Padding(
      padding: const EdgeInsets.only(left: AppSizes.small, right: AppSizes.xSmall),
      child: icon ?? BaktazIcon(icon: right(Icons.error_outline)),
    ),
    autoCloseDuration: isDismissable ? duration ?? Constant.longDelay : null,
    style: ToastificationStyle.flatColored,
    type: ToastificationType.custom('app_error', _getErrorColor(context), Icons.error_outline),
    alignment: alignment,
    closeOnClick: isDismissable,
    dragToClose: isDismissable,
    closeButton: isDismissable ? const ToastCloseButton() : const ToastCloseButton(showType: CloseButtonShowType.none),
    dismissDirection: isDismissable ? null : DismissDirection.none,
  );

  static Color _getErrorColor([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).colorScheme.error;
    }
    // Fallback when no context available — use pre-built theme color schemes
    return getIt<ThemeCubit>().stateValue == ThemeMode.dark
        ? AppTheme.dark.colorScheme.error
        : AppTheme.light.colorScheme.error;
  }
}

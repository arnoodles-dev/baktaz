// ignore_for_file: avoid-returning-widgets,

import 'package:baktaz_shared/src/entity/enum/button_type.dart';
import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_limiter/flutter_event_limiter.dart';

typedef Throttler = void Function()? Function(void Function()?);

final class BaktazButton extends StatelessWidget {
  const BaktazButton({
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.isExpanded = false,
    this.buttonType = ButtonType.filled,
    this.buttonStyle,
    this.textStyle,
    this.padding,
    this.contentPadding,
    this.icon,
    this.iconPadding,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final bool isExpanded;
  final ButtonType buttonType;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final Widget? icon;
  final EdgeInsets? iconPadding;

  Widget _buildContent(BuildContext context, ThemeData theme, {bool hasIcon = false}) => _ButtonContent(
    contentPadding: contentPadding,
    isLoading: isLoading,
    text: text,
    hasIcon: hasIcon,
    textStyle: buttonType == ButtonType.tonal
        ? textStyle?.copyWith(color: theme.colorScheme.onSecondaryContainer)
        : textStyle,
    isExpanded: isExpanded,
  );

  Widget? _buildIcon() {
    if (icon == null) return null;

    return Padding(
      padding:
          iconPadding ?? const EdgeInsets.fromLTRB(AppSizes.medium, AppSizes.medium, AppSizes.zero, AppSizes.medium),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      key: Key(text),
      enabled: isEnabled && !isLoading,
      button: true,
      label: text,
      child: SizedBox(
        width: isExpanded ? AppSizes.infinity : null,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: ThrottledBuilder(
            builder: (BuildContext context, Throttler throttle) {
              final VoidCallback? throttledCallback = throttle((isEnabled && !isLoading) ? onPressed : null);
              final Widget? iconWidget = _buildIcon();
              final Widget childWidget = _buildContent(context, theme, hasIcon: iconWidget != null);

              switch (buttonType) {
                case ButtonType.destructive:
                  final ButtonStyle destructiveStyle = FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ).merge(buttonStyle);

                  return iconWidget != null
                      ? FilledButton.icon(
                          onPressed: throttledCallback,
                          style: destructiveStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : FilledButton(onPressed: throttledCallback, style: destructiveStyle, child: childWidget);
                case ButtonType.elevated:
                  return iconWidget != null
                      ? ElevatedButton.icon(
                          onPressed: throttledCallback,
                          style: buttonStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : ElevatedButton(onPressed: throttledCallback, style: buttonStyle, child: childWidget);
                case ButtonType.filled:
                  return iconWidget != null
                      ? FilledButton.icon(
                          onPressed: throttledCallback,
                          style: buttonStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : FilledButton(onPressed: throttledCallback, style: buttonStyle, child: childWidget);
                case ButtonType.tonal:
                  final ButtonStyle tonalStyle = FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ).merge(buttonStyle);

                  return iconWidget != null
                      ? FilledButton.icon(
                          onPressed: throttledCallback,
                          style: tonalStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : FilledButton(onPressed: throttledCallback, style: tonalStyle, child: childWidget);
                case ButtonType.outlined:
                  return iconWidget != null
                      ? OutlinedButton.icon(
                          onPressed: throttledCallback,
                          style: buttonStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : OutlinedButton(onPressed: throttledCallback, style: buttonStyle, child: childWidget);
                case ButtonType.text:
                  return iconWidget != null
                      ? TextButton.icon(
                          onPressed: throttledCallback,
                          style: buttonStyle,
                          icon: iconWidget,
                          label: childWidget,
                        )
                      : TextButton(onPressed: throttledCallback, style: buttonStyle, child: childWidget);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.isLoading,
    required this.text,
    this.hasIcon = false,
    this.textStyle,
    this.isExpanded = false,
    this.contentPadding,
  });

  final bool isLoading;
  final String text;
  final bool hasIcon;
  final TextStyle? textStyle;
  final bool isExpanded;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EdgeInsets defaultPadding = hasIcon
        ? const EdgeInsets.fromLTRB(AppSizes.zero, AppSizes.medium, AppSizes.medium, AppSizes.medium)
        : Paddings.allMedium;

    return SizedBox(
      width: isExpanded ? AppSizes.infinity : null,
      child: Padding(
        padding: contentPadding ?? defaultPadding,
        child: !isLoading
            ? BaktazText(text: text, style: textStyle, textAlign: TextAlign.center)
            : Center(
                child: SizedBox.square(
                  dimension: textStyle?.fontSize ?? theme.textTheme.bodyLarge?.fontSize,
                  child: const CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}

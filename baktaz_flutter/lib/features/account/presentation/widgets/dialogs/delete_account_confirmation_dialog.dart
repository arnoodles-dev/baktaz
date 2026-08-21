import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Right;

class DeleteAccountConfirmationDialog extends StatelessWidget {
  const DeleteAccountConfirmationDialog({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Padding(
    padding: Paddings.allMedium,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Gap.x2Large(),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.colorScheme.errorContainer),
            child: Center(
              child: BaktazIcon(
                icon: const Right<String, IconData>(Icons.delete_forever_rounded),
                color: context.colorScheme.onErrorContainer,
                size: AppSizes.iconXLarge,
              ),
            ),
          ),
        ),
        Gap.x2Large(),
        BaktazText(
          text: context.i18n.account.delete_dialog.title,
          style: context.textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
        ),
        Gap.xSmall(),
        BaktazText(
          text: context.i18n.account.delete_dialog.subtitle,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.regular),
        ),
        Gap.large(),
        BaktazButton(text: context.i18n.account.button.delete_account, isExpanded: true, onPressed: onConfirm),
        Gap.medium(),
        BaktazButton(
          text: context.i18n.common.cancel.capitalize(),
          isExpanded: true,
          buttonType: ButtonType.tonal,
          onPressed: () => Navigator.pop(context),
        ),
        Gap.medium(),
      ],
    ),
  );
}

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class LocalizationPendingChangesBanner extends StatelessWidget {
  const LocalizationPendingChangesBanner({
    required this.changeCount,
    required this.onPublish,
    required this.onDiscard,
    super.key,
  });

  final int changeCount;
  final VoidCallback onPublish;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) => Container(
    margin: Paddings.bottomXLarge,
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.medium),
    decoration: BoxDecoration(
      color: context.colorScheme.primaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusXSmall)),
      border: Border.fromBorderSide(BorderSide(color: context.baktazColors.primaryLight)),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: AppSizes.size36,
          height: AppSizes.size36,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.size20)),
          ),
          child: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.sync),
            size: AppSizes.iconSmall,
            color: context.colorScheme.onPrimary,
          ),
        ),
        Gap.medium(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.pending_changes.title,
                style: AppTextStyle.labelLarge.copyWith(
                  fontWeight: AppFontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Gap.x2Small(),
              BaktazText(
                text: context.i18n.localization.pending_changes.description(changeCount: changeCount),
                style: AppTextStyle.bodySmall.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Gap.small(),
        BaktazButton(
          onPressed: () => _showDiscardConfirmation(context),
          text: context.i18n.localization.pending_changes.discard,
          textStyle: AppTextStyle.labelLarge.copyWith(fontWeight: AppFontWeight.semiBold),
          buttonType: ButtonType.text,
          buttonStyle: TextButton.styleFrom(foregroundColor: context.colorScheme.primary),
        ),
        Gap.xSmall(),
        BaktazButton(
          onPressed: onPublish,
          text: context.i18n.localization.pending_changes.publish,
          textStyle: AppTextStyle.labelLarge.copyWith(fontWeight: AppFontWeight.semiBold),
          buttonType: ButtonType.elevated,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
          ),
        ),
      ],
    ),
  );

  Future<void> _showDiscardConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall))),
        title: BaktazText(
          text: context.i18n.localization.pending_changes.discard_title,
          style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
        ),
        content: BaktazText(text: context.i18n.localization.pending_changes.discard_message),
        actions: <Widget>[
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            text: context.i18n.localization.pending_changes.cancel,
            buttonType: ButtonType.text,
          ),
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            text: context.i18n.localization.pending_changes.discard,
            buttonType: ButtonType.elevated,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onDiscard();
    }
  }
}

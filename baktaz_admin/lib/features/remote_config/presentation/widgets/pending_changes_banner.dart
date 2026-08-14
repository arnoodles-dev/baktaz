import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class PendingChangesBanner extends StatelessWidget {
  const PendingChangesBanner({required this.changeCount, required this.onPublish, required this.onDiscard, super.key});

  final int changeCount;
  final VoidCallback onPublish;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) => Container(
    margin: Paddings.bottomXLarge,
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.medium),
    decoration: const BoxDecoration(
      color: AppColors.colorPrimarySubtle,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXSmall)),
      border: Border.fromBorderSide(BorderSide(color: AppColors.colorPrimaryLight)),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: AppSizes.size36,
          height: AppSizes.size36,
          decoration: const BoxDecoration(
            color: AppColors.colorPrimary,
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.size20)),
          ),
          child: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.sync),
            size: AppSizes.iconSmall,
            color: AppColors.white,
          ),
        ),
        Gap.medium(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: context.i18n.remote_config.pending_changes.title,
                style: AppTextStyle.labelLarge.copyWith(
                  fontWeight: AppFontWeight.bold,
                  color: AppColors.colorTextPrimary,
                ),
              ),
              Gap.x2Small(),
              BaktazText(
                text: context.i18n.remote_config.pending_changes.description(changeCount: changeCount),
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
              ),
            ],
          ),
        ),
        Gap.small(),
        BaktazButton(
          onPressed: () => _showDiscardConfirmation(context),
          text: context.i18n.remote_config.pending_changes.discard,
          textStyle: AppTextStyle.labelLarge.copyWith(fontWeight: AppFontWeight.semiBold),
          buttonType: ButtonType.text,
          buttonStyle: TextButton.styleFrom(foregroundColor: AppColors.colorPrimary),
        ),
        Gap.xSmall(),
        BaktazButton(
          onPressed: onPublish,
          text: context.i18n.remote_config.pending_changes.publish,
          textStyle: AppTextStyle.labelLarge.copyWith(fontWeight: AppFontWeight.semiBold),
          buttonType: ButtonType.elevated,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorPrimary,
            foregroundColor: AppColors.white,
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
          text: context.i18n.remote_config.pending_changes.discard_title,
          style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
        ),
        content: BaktazText(text: context.i18n.remote_config.pending_changes.discard_message),
        actions: <Widget>[
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            text: context.i18n.remote_config.pending_changes.cancel,
            buttonType: ButtonType.text,
          ),
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            text: context.i18n.remote_config.pending_changes.discard,
            buttonType: ButtonType.elevated,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorError,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXLarge)),
              ),
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

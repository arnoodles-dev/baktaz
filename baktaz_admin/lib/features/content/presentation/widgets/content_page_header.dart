import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ContentPageHeader extends StatelessWidget {
  const ContentPageHeader({
    required this.onSaveDraft,
    required this.onPublish,
    this.isPublishing = false,
    this.hasPendingChanges = false,
    super.key,
  });

  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;
  final bool isPublishing;
  final bool hasPendingChanges;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BaktazText(
              text: context.i18n.content.title,
              style: AppTextStyle.headlineLarge.copyWith(fontWeight: AppFontWeight.bold),
            ),
            const Gap(AppSizes.x2Small),
            BaktazText(
              text: context.i18n.content.description,
              style: AppTextStyle.bodyLarge.copyWith(color: AppColors.colorTextSecondary),
            ),
          ],
        ),
      ),
      Row(
        children: <Widget>[
          BaktazButton(
            text: context.i18n.content.header.save_draft,
            buttonType: ButtonType.outlined,
            onPressed: isPublishing ? null : onSaveDraft,
          ),
          const Gap(AppSizes.small),
          BaktazButton(
            text: context.i18n.content.header.publish,
            isLoading: isPublishing,
            isEnabled: hasPendingChanges && !isPublishing,
            onPressed: onPublish,
          ),
        ],
      ),
    ],
  );
}

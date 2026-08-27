import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EditTranslationDialog extends HookWidget {
  const EditTranslationDialog({
    required this.localizationKey,
    required this.locale,
    required this.currentTranslation,
    required this.onSave,
    this.onDelete,
    super.key,
  });

  final LocalizationKey localizationKey;
  final String locale;
  final String? currentTranslation;
  final void Function(String translation) onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController(
      text: currentTranslation ?? (locale == 'en' ? localizationKey.defaultValueEn : ''),
    );
    final ValueNotifier<bool> isValid = useState(controller.text.trim().isNotEmpty);

    useEffect(() {
      void listener() {
        isValid.value = controller.text.trim().isNotEmpty;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, <Object?>[controller]);

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium))),
      title: BaktazText(
        text: '${context.i18n.localization.edit_dialog.title(key: localizationKey.key)} (${locale.toUpperCase()})',
        style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.dialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BaktazText(
              text: context.i18n.localization.edit_dialog.namespace_label,
              style: AppTextStyle.labelMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            Gap.x2Small(),
            BaktazText(
              text: localizationKey.namespace,
              style: AppTextStyle.bodyMedium.copyWith(color: context.colorScheme.onSurface),
            ),
            Gap.medium(),
            BaktazText(
              text: context.i18n.localization.edit_dialog.default_value_label,
              style: AppTextStyle.labelMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            Gap.x2Small(),
            BaktazText(
              text: localizationKey.defaultValueEn,
              style: AppTextStyle.bodyMedium.copyWith(color: context.colorScheme.onSurface),
            ),
            Gap.medium(),
            BaktazText(
              text: '${context.i18n.localization.edit_dialog.value_label.split('(').first}(${locale.toUpperCase()})',
              style: AppTextStyle.labelMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            Gap.xSmall(),
            BaktazTextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorText: isValid.value ? null : context.i18n.localization.edit_dialog.error_required,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        if (onDelete != null)
          BaktazButton(
            onPressed: () {
              onDelete!();
              Navigator.of(context).pop();
            },
            text: context.i18n.remote_config.delete_dialog.action,
            buttonType: ButtonType.text,
            buttonStyle: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
          ),
        BaktazButton(
          onPressed: () => Navigator.of(context).pop(),
          text: context.i18n.localization.edit_dialog.cancel,
          buttonType: ButtonType.text,
        ),
        BaktazButton(
          onPressed: isValid.value
              ? () {
                  onSave(controller.text);
                  Navigator.of(context).pop();
                }
              : null,
          text: context.i18n.localization.edit_dialog.save,
          buttonType: ButtonType.elevated,
        ),
      ],
    );
  }
}

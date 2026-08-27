import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddTranslationDialog extends HookWidget {
  const AddTranslationDialog({required this.onSave, required this.existingKeys, super.key});

  final void Function(String key, String namespace, String valueEn) onSave;
  final Set<String> existingKeys;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final TextEditingController keyController = useTextEditingController();
    final TextEditingController namespaceController = useTextEditingController(text: 'common');
    final TextEditingController valueController = useTextEditingController();

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium))),
      title: BaktazText(
        text: context.i18n.localization.add_dialog.title,
        style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.dialogWidth),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: context.i18n.localization.add_dialog.key_label,
                style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorTextSecondary),
              ),
              Gap.xSmall(),
              TextFormField(
                controller: keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: context.i18n.localization.add_dialog.key_hint,
                  helperText: 'Use dot notation for nested keys, e.g. login.title',
                  helperStyle: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.i18n.localization.add_dialog.error_key_required;
                  }
                  final String ns = namespaceController.text.trim();
                  final String fullKey = '$ns.${value.trim()}';
                  if (existingKeys.contains(fullKey)) {
                    return context.i18n.localization.add_dialog.error_key_exists;
                  }
                  return null;
                },
              ),
              Gap.medium(),
              BaktazText(
                text: context.i18n.localization.add_dialog.namespace_label,
                style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorTextSecondary),
              ),
              Gap.xSmall(),
              TextFormField(
                controller: namespaceController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: context.i18n.localization.add_dialog.namespace_hint,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.i18n.localization.add_dialog.error_namespace_required;
                  }
                  return null;
                },
              ),
              Gap.medium(),
              BaktazText(
                text: context.i18n.localization.add_dialog.value_label,
                style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorTextSecondary),
              ),
              Gap.xSmall(),
              TextFormField(
                controller: valueController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.i18n.localization.add_dialog.error_value_required;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        BaktazButton(
          onPressed: () => Navigator.of(context).pop(),
          text: context.i18n.localization.add_dialog.cancel,
          buttonType: ButtonType.text,
        ),
        BaktazButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              onSave(keyController.text.trim(), namespaceController.text.trim(), valueController.text.trim());
              Navigator.of(context).pop();
            }
          },
          text: context.i18n.localization.add_dialog.add,
          buttonType: ButtonType.elevated,
        ),
      ],
    );
  }
}

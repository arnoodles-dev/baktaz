import 'dart:convert';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddParameterDialog extends HookWidget {
  const AddParameterDialog({required this.onSave, super.key});

  final void Function(String, RemoteConfigValue) onSave;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final TextEditingController keyController = useTextEditingController();
    final TextEditingController valueController = useTextEditingController();
    final TextEditingController descriptionController = useTextEditingController();
    final ValueNotifier<ConfigValueType> selectedType = useState<ConfigValueType>(ConfigValueType.string);

    return AlertDialog(
      title: BaktazText(text: context.i18n.remote_config.add_dialog.title, style: AppTextStyle.headlineMedium),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: context.i18n.remote_config.add_dialog.key_label,
                  hintText: context.i18n.remote_config.add_dialog.key_hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.i18n.remote_config.add_dialog.error_key_required;
                  }
                  final RegExp regExp = RegExp(r'^[a-zA-Z0-9_]+$');
                  if (!regExp.hasMatch(value)) {
                    return context.i18n.remote_config.add_dialog.error_key_format;
                  }
                  return null;
                },
              ),
              Gap.medium(),
              DropdownButtonFormField<ConfigValueType>(
                initialValue: selectedType.value,
                decoration: InputDecoration(
                  labelText: context.i18n.remote_config.add_dialog.value_type_label,
                  border: const OutlineInputBorder(),
                ),
                items: ConfigValueType.values
                    .map(
                      (ConfigValueType type) => DropdownMenuItem<ConfigValueType>(
                        value: type,
                        child: BaktazText(text: type.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (ConfigValueType? value) {
                  if (value != null) {
                    selectedType.value = value;
                    if (value == ConfigValueType.boolean) {
                      valueController.text = 'false';
                    } else {
                      valueController.clear();
                    }
                  }
                },
              ),
              Gap.medium(),
              if (selectedType.value == ConfigValueType.boolean)
                DropdownButtonFormField<String>(
                  initialValue: valueController.text.isEmpty ? 'false' : valueController.text,
                  decoration: InputDecoration(
                    labelText: context.i18n.remote_config.edit_dialog.value_label,
                    border: const OutlineInputBorder(),
                  ),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'true',
                      child: BaktazText(text: context.i18n.remote_config.edit_dialog.true_value),
                    ),
                    DropdownMenuItem<String>(
                      value: 'false',
                      child: BaktazText(text: context.i18n.remote_config.edit_dialog.false_value),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      valueController.text = value;
                    }
                  },
                )
              else
                TextFormField(
                  controller: valueController,
                  maxLines: selectedType.value == ConfigValueType.json ? 4 : 1,
                  decoration: InputDecoration(
                    labelText: context.i18n.remote_config.edit_dialog.value_type_label(
                      type: selectedType.value.name.toUpperCase(),
                    ),
                    border: const OutlineInputBorder(),
                    hintText: selectedType.value == ConfigValueType.json ? '{"key": "value"}' : null,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.i18n.remote_config.edit_dialog.error_required;
                    }
                    if (selectedType.value == ConfigValueType.number) {
                      final double? parsed = double.tryParse(value);
                      if (parsed == null) {
                        return context.i18n.remote_config.edit_dialog.error_number;
                      }
                    }
                    if (selectedType.value == ConfigValueType.json) {
                      try {
                        json.decode(value);
                      } on FormatException catch (_) {
                        return context.i18n.remote_config.edit_dialog.error_json;
                      }
                    }
                    return null;
                  },
                ),
              Gap.medium(),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: context.i18n.remote_config.edit_dialog.description_label,
                  hintText: context.i18n.remote_config.edit_dialog.description_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        BaktazButton(
          onPressed: () => Navigator.of(context).pop(),
          text: context.i18n.remote_config.edit_dialog.cancel,
          buttonType: ButtonType.text,
        ),
        BaktazButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              final RemoteConfigValue configValue = RemoteConfigValue(
                defaultValue: ConfigDefaultValue(value: ValueString(valueController.text.trim(), fieldName: 'value')),
                valueType: selectedType.value,
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : ValueString(descriptionController.text.trim(), fieldName: 'description'),
              );
              onSave(keyController.text.trim(), configValue);
              Navigator.of(context).pop();
            }
          },
          text: context.i18n.remote_config.add_dialog.title,
          textStyle: AppTextStyle.labelLarge.copyWith(color: AppColors.white),
          buttonType: ButtonType.elevated,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: AppColors.colorPrimary,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXLarge))),
          ),
        ),
      ],
    );
  }
}

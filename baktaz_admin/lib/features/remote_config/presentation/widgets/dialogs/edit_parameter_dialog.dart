import 'dart:convert';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EditParameterDialog extends HookWidget {
  const EditParameterDialog({
    required this.parameterKey,
    required this.currentValue,
    required this.onSave,
    this.initialDescription,
    super.key,
  });

  final String parameterKey;
  final RemoteConfigValue currentValue;
  final void Function(String, RemoteConfigValue) onSave;
  final String? initialDescription;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final TextEditingController valueController = useTextEditingController(text: currentValue.rawValue);
    final TextEditingController descriptionController = useTextEditingController(
      text: currentValue.description?.getValue() ?? initialDescription ?? '',
    );

    return AlertDialog(
      title: BaktazText(
        text: context.i18n.remote_config.edit_dialog.title(key: parameterKey),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (currentValue.valueType == ConfigValueType.boolean)
                DropdownButtonFormField<String>(
                  initialValue: valueController.text == 'true' ? 'true' : 'false',
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
                  maxLines: currentValue.valueType == ConfigValueType.json ? 4 : 1,
                  decoration: InputDecoration(
                    labelText: context.i18n.remote_config.edit_dialog.value_type_label(
                      type: currentValue.valueType.name.toUpperCase(),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.i18n.remote_config.edit_dialog.error_required;
                    }
                    if (currentValue.valueType == ConfigValueType.number) {
                      final double? parsed = double.tryParse(value);
                      if (parsed == null) {
                        return context.i18n.remote_config.edit_dialog.error_number;
                      }
                    }
                    if (currentValue.valueType == ConfigValueType.json) {
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
              final RemoteConfigValue updatedValue = currentValue.copyWith(
                defaultValue: ConfigDefaultValue(value: ValueString(valueController.text.trim(), fieldName: 'value')),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : ValueString(descriptionController.text.trim(), fieldName: 'description'),
              );
              onSave(parameterKey, updatedValue);
              Navigator.of(context).pop();
            }
          },
          text: context.i18n.remote_config.edit_dialog.save,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
          buttonType: ButtonType.elevated,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.xl))),
          ),
        ),
      ],
    );
  }
}

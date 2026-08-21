import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart' hide Gender;
import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({this.value, this.onChanged, this.validator, this.enabled = true, super.key});

  final Gender? value;
  final ValueChanged<Gender?>? onChanged;
  final FormFieldValidator<Gender>? validator;
  final bool enabled;

  String _genderLabel(Gender gender) => switch (gender) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.unknown => 'Other / Unknown',
  };

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<Gender>(
    initialValue: value,
    onChanged: enabled ? onChanged : null,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      hintText: context.i18n.register.hint.gender,
      filled: true,
      fillColor: enabled ? context.colorScheme.surfaceContainerHighest : context.colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.small),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        borderSide: BorderSide(color: context.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        borderSide: BorderSide(color: context.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        borderSide: BorderSide(color: context.colorScheme.error, width: 2),
      ),
    ),
    items: Gender.values
        .map(
          (Gender gender) => DropdownMenuItem<Gender>(
            value: gender,
            child: BaktazText(text: _genderLabel(gender), style: context.textTheme.bodyLarge),
          ),
        )
        .toList(),
  );
}

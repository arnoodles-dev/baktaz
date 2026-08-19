import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:fpdart/fpdart.dart';

class BaktazMobileNumberField extends HookWidget {
  const BaktazMobileNumberField({
    required this.controller,
    required this.focusNode,
    required this.selectedCountryCode,
    this.showFlag = true,
    this.isPickerDisabled = false,
    this.isDisabled = false,
    this.onSelectCountry,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<PhoneCountryData> selectedCountryCode;
  final bool showFlag;
  final bool isPickerDisabled;
  final bool isDisabled;
  final Future<PhoneCountryData?> Function(BuildContext context)? onSelectCountry;
  final String? Function(String? value, String phoneMask)? validator;

  void _onChanged(String value) {
    final PhoneCountryData phoneCountryData = selectedCountryCode.value;
    final String rawPhoneCode = phoneCountryData.phoneCode ?? '';
    final String maskedPhoneCode =
        formatAsPhoneNumber(
          rawPhoneCode,
          defaultMask: phoneCountryData.phoneMask,
          defaultCountryCode: phoneCountryData.countryCode,
        ) ??
        '';

    if (value == maskedPhoneCode) {
      return;
    } else if (!controller.text.startsWith(maskedPhoneCode)) {
      controller.text = maskedPhoneCode;
    } else {
      controller.text = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String phoneCode = '+${selectedCountryCode.value.phoneCode} ';
    final TextEditingValue defaultValue = TextEditingValue(
      text: phoneCode,
      selection: TextSelection.fromPosition(TextPosition(offset: phoneCode.length)),
    );
    final String phoneMask = selectedCountryCode.value.phoneMask ?? '+00 000 000 0000';
    final String countryCode = selectedCountryCode.value.countryCode ?? 'PH';

    useEffect(() {
      if (controller.text.isEmpty) {
        controller.value = defaultValue;
      }
      PhoneInputFormatter.replacePhoneMask(countryCode: countryCode, newMask: phoneMask);
      return null;
    }, <Object?>[]);

    return IgnorePointer(
      ignoring: isDisabled,
      child: BaktazTextField(
        textFieldType: TextFieldType.form,
        contentPadding: Paddings.allMedium,
        controller: controller,
        keyboardType: TextInputType.phone,
        focusNode: focusNode,
        isDisabled: isDisabled,
        validator: validator != null ? (String? value) => validator!(value, phoneMask) : null,
        onChanged: _onChanged,
        inputFormatters: <TextInputFormatter>[
          PhoneInputFormatter(
            defaultCountryCode: selectedCountryCode.value.countryCode,
            onCountrySelected: (PhoneCountryData? value) {
              if (value != null) {
                selectedCountryCode.value = value;
              }
            },
          ),
        ],
        prefix: _CountryCodePicker(
          selectedCountryCode: selectedCountryCode,
          isPickerDisabled: isPickerDisabled,
          showFlag: showFlag,
          controller: controller,
          isDisabled: isDisabled,
          focusNode: focusNode,
          onSelectCountry: onSelectCountry,
        ),
      ),
    );
  }
}

class _CountryCodePicker extends StatelessWidget {
  const _CountryCodePicker({
    required this.selectedCountryCode,
    required this.isPickerDisabled,
    required this.showFlag,
    required this.controller,
    required this.isDisabled,
    required this.focusNode,
    this.onSelectCountry,
  });

  final ValueNotifier<PhoneCountryData> selectedCountryCode;
  final bool isPickerDisabled;
  final bool showFlag;
  final TextEditingController controller;
  final bool isDisabled;
  final FocusNode focusNode;
  final Future<PhoneCountryData?> Function(BuildContext context)? onSelectCountry;

  Future<void> _onTap(BuildContext context) async {
    if (onSelectCountry == null) return;
    final PhoneCountryData? phoneCountryData = await onSelectCountry!(context);
    if (phoneCountryData != null) {
      selectedCountryCode.value = phoneCountryData;
      final String maskedPhoneCode =
          formatAsPhoneNumber(
            phoneCountryData.phoneCode!,
            defaultMask: phoneCountryData.phoneMask,
            defaultCountryCode: phoneCountryData.countryCode,
          ) ??
          '';
      if (!controller.text.startsWith(maskedPhoneCode)) {
        controller.text = maskedPhoneCode;
      }
      // ignore: use_build_context_synchronously
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isPickerDisabled || isDisabled ? null : () => _onTap(context),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Gap.medium(),
        if (showFlag) _CountryFlag(countryId: selectedCountryCode.value.countryCode ?? 'US'),
        if (!isPickerDisabled) ...<Widget>[
          Gap.x2Small(),
          BaktazIcon(icon: Either<String, IconData>.right(Icons.arrow_drop_down)),
        ],
        Gap.x2Small(),
      ],
    ),
  );
}

class _CountryFlag extends StatelessWidget {
  const _CountryFlag({required this.countryId});

  final String countryId;

  String get _countryId => countryId.toLowerCase();

  String get _flagPath => 'flags/png/$_countryId.png';

  @override
  Widget build(BuildContext context) => Container(
    height: AppSizes.size20,
    width: AppSizes.size26,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      image: DecorationImage(
        image: AssetImage(_flagPath, package: 'flutter_multi_formatter'),
        fit: BoxFit.fill,
      ),
    ),
  );
}

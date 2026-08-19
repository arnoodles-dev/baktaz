// ignore_for_file: avoid-returning-widgets

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  final PhoneCountryData usCountryData = PhoneCodes.getPhoneCountryDataByCountryCode('US')!;

  group(BaktazMobileNumberField, () {
    goldenTest(
      'renders correctly across different states',
      fileName: 'baktaz_mobile_number_field'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default US empty',
            child: _buildPhoneField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              selectedCountry: usCountryData,
            ),
          ),
          GoldenTestScenario(
            name: 'US with number',
            child: _buildPhoneField(
              controller: TextEditingController(text: '+1 (123) 456-7890'),
              focusNode: FocusNode(),
              selectedCountry: usCountryData,
            ),
          ),
          GoldenTestScenario(
            name: 'disabled',
            child: _buildPhoneField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              selectedCountry: usCountryData,
              isDisabled: true,
            ),
          ),
          GoldenTestScenario(
            name: 'without flag',
            child: _buildPhoneField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              selectedCountry: usCountryData,
              showFlag: false,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildPhoneField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required PhoneCountryData selectedCountry,
  bool showFlag = true,
  bool isDisabled = false,
}) => SizedBox(
  width: 300,
  child: BaktazMobileNumberField(
    controller: controller,
    focusNode: focusNode,
    selectedCountryCode: ValueNotifier<PhoneCountryData>(selectedCountry),
    showFlag: showFlag,
    isDisabled: isDisabled,
  ),
);

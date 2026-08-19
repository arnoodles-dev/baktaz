import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(ConfirmationDialog, () {
    goldenTest(
      'renders correctly across different variants',
      fileName: 'confirmation_dialog'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default dialog',
            child: const ConfirmationDialog(
              message: SharedFixtures.sampleText,
              negativeButtonText: 'Cancel',
              positiveButtonText: 'Confirm',
            ),
          ),
          GoldenTestScenario(
            name: 'with title',
            child: const ConfirmationDialog(
              title: 'Delete Item',
              message: 'Are you sure you want to delete this item? This action cannot be undone.',
              negativeButtonText: 'Cancel',
              positiveButtonText: 'Delete',
            ),
          ),
          GoldenTestScenario(
            name: 'custom button colors',
            child: const ConfirmationDialog(
              message: 'Custom colored buttons',
              negativeButtonText: 'No',
              positiveButtonText: 'Yes',
              negativeButtonTextColor: Colors.grey,
              positiveButtonTextColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  });
}

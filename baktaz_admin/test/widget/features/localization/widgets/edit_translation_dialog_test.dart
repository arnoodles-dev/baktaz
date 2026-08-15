import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/dialogs/edit_translation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';

void main() {
  group('EditTranslationDialog Golden Tests', () {
    const LocalizationKey mockKey = LocalizationKey(
      id: 1,
      namespace: 'common',
      key: 'hello',
      defaultValueEn: 'Hello World',
    );

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'edit_translation_dialog',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with current translation',
            child: MockMaterialApp(
              child: EditTranslationDialog(
                localizationKey: mockKey,
                locale: 'en',
                currentTranslation: 'Existing Translation',
                onSave: (String _) {},
                onDelete: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'without current translation (uses default)',
            child: MockMaterialApp(
              child: EditTranslationDialog(
                localizationKey: mockKey,
                locale: 'en',
                currentTranslation: null,
                onSave: (String _) {},
                onDelete: () {},
              ),
            ),
          ),
        ],
      ),
    );
  });
}

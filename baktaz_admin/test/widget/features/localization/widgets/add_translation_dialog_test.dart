import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/dialogs/add_translation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(AddTranslationDialog, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'add_translation_dialog'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'empty form',
            child: MockMaterialApp(
              child: Builder(
                builder: (BuildContext context) => AddTranslationDialog(
                  onSave: (String key, String namespace, String value) {},
                  existingKeys: const <String>{},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with existing keys',
            child: MockMaterialApp(
              child: Builder(
                builder: (BuildContext context) => AddTranslationDialog(
                  onSave: (String key, String namespace, String value) {},
                  existingKeys: const <String>{'common.hello', 'common.goodbye'},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  const LocalizationKey testKey = LocalizationKey(
    id: 1,
    namespace: 'auth',
    key: 'login.title',
    defaultValueEn: 'Login Title',
    description: 'Title for login screen',
  );

  group(LocalizationTableRow, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_table_row'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'namespace row collapsed',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 100,
              child: LocalizationTableRow(namespace: 'auth', count: 5, isCollapsed: true, onToggle: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'nested group header expanded',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 100,
              child: NestedGroupHeaderRow(
                name: 'login',
                fullPath: 'auth.login',
                depth: 1,
                isCollapsed: false,
                onToggle: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'localization row unmodified',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: LocalizationRow(
                localizationKey: testKey,
                displayName: 'login.title',
                depth: 1,
                pendingTranslation: null,
                isModified: false,
                isNew: false,
                selectedLocale: 'en',
                onEdit: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'localization row modified',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: LocalizationRow(
                localizationKey: testKey,
                displayName: 'login.title',
                depth: 1,
                pendingTranslation: const LocalizationTranslation(keyId: 1, locale: 'en', value: 'Updated Login'),
                isModified: true,
                isNew: false,
                selectedLocale: 'en',
                onEdit: () {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'localization row new',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: LocalizationRow(
                localizationKey: testKey,
                displayName: 'login.title',
                depth: 1,
                pendingTranslation: const LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Login'),
                isModified: false,
                isNew: true,
                selectedLocale: 'en',
                onEdit: () {},
              ),
            ),
          ),
        ],
      ),
    );
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(LocalizationTableHeader, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_table_header'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'header default',
            child: MockMaterialApp(
              surfaceWidth: 900,
              surfaceHeight: 120,
              child: LocalizationTableHeader(
                totalCount: 42,
                locales: const <String>['en', 'es', 'de'],
                selectedLocale: 'en',
                onLocaleSelected: (_) {},
                searchQuery: '',
                onSearchChanged: (_) {},
                onDownload: () {},
                pendingChanges: const <String, LocalizationTranslation>{},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'table column headers',
            child: const MockMaterialApp(
              surfaceWidth: 900,
              surfaceHeight: 60,
              child: TableColumnHeaders(selectedLocale: 'en'),
            ),
          ),
        ],
      ),
    );
  });
}

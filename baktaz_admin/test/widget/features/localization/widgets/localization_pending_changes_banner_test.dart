import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_pending_changes_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(LocalizationPendingChangesBanner, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_pending_changes_banner'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'single change',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 200,
              child: LocalizationPendingChangesBanner(changeCount: 1, onPublish: () {}, onDiscard: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'multiple changes',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 200,
              child: LocalizationPendingChangesBanner(changeCount: 5, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
    );
  });
}

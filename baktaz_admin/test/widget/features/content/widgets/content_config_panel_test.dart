import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_config_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/admin_fixtures.dart';
import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ContentConfigPanel, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_config_panel'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'add new content',
            child: MockMaterialApp(
              surfaceWidth: 450,
              surfaceHeight: 700,
              child: SingleChildScrollView(
                child: ContentConfigPanel(asset: null, onSave: (_) {}, onCancel: () {}),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'edit existing content',
            child: MockMaterialApp(
              surfaceWidth: 450,
              surfaceHeight: 700,
              child: SingleChildScrollView(
                child: ContentConfigPanel(asset: AdminFixtures.contentAssetBanner, onSave: (_) {}, onCancel: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

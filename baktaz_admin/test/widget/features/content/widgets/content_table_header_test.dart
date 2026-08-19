import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ContentTableHeader, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_table_header'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'all selected',
            child: MockMaterialApp(
              surfaceWidth: 900,
              surfaceHeight: 80,
              child: ContentTableHeader(
                selectedType: null,
                selectedPlacement: null,
                searchQuery: '',
                onTypeFilterChanged: (_) {},
                onPlacementFilterChanged: (_) {},
                onSearchChanged: (_) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'type and placement selected',
            child: MockMaterialApp(
              surfaceWidth: 900,
              surfaceHeight: 80,
              child: ContentTableHeader(
                selectedType: ContentAssetType.banner,
                selectedPlacement: ContentPlacementGroup.home,
                searchQuery: 'Summer',
                onTypeFilterChanged: (_) {},
                onPlacementFilterChanged: (_) {},
                onSearchChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
    );
  });
}

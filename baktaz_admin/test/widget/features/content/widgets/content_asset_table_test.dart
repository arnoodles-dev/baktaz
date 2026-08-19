import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_asset_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/admin_fixtures.dart';
import '../../../../utils/mock_material_app.dart';

void main() {
  final List<MapEntry<ContentPlacementGroup, List<ContentAsset>>> tGroupedCarousels =
      <MapEntry<ContentPlacementGroup, List<ContentAsset>>>[
        MapEntry<ContentPlacementGroup, List<ContentAsset>>(ContentPlacementGroup.home, <ContentAsset>[
          AdminFixtures.contentAssetBanner,
        ]),
        MapEntry<ContentPlacementGroup, List<ContentAsset>>(ContentPlacementGroup.account, <ContentAsset>[
          AdminFixtures.contentAssetDraft,
        ]),
      ];

  Widget buildWidget({
    List<MapEntry<ContentPlacementGroup, List<ContentAsset>>>? groupedCarousels,
    String? selectedAssetId,
    Set<String>? expandedGroups,
    ValueChanged<String>? onAssetSelected,
    ValueChanged<String>? onToggleGroup,
  }) => MockMaterialApp(
    child: Scaffold(
      body: ContentAssetTable(
        groupedCarousels: groupedCarousels ?? tGroupedCarousels,
        selectedAssetId: selectedAssetId,
        expandedGroups: expandedGroups ?? <String>{'home'},
        onAssetSelected: onAssetSelected ?? (_) {},
        onToggleGroup: onToggleGroup ?? (_) {},
      ),
    ),
  );

  group('ContentAssetTable Widget Tests', () {
    testWidgets('renders empty state when groupedCarousels is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(groupedCarousels: <MapEntry<ContentPlacementGroup, List<ContentAsset>>>[]));
      await tester.pumpAndSettle();

      expect(find.byType(ContentAssetTable), findsOneWidget);
    });

    testWidgets('renders carousel groups and assets when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Home'), findsWidgets);
      expect(find.text('Summer Promo Banner'), findsOneWidget);
    });

    testWidgets('triggers onAssetSelected when row is tapped', (WidgetTester tester) async {
      String? selectedId;

      await tester.pumpWidget(
        buildWidget(
          onAssetSelected: (String id) {
            selectedId = id;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Summer Promo Banner'));
      await tester.pumpAndSettle();

      expect(selectedId, equals('asset_1'));
    });

    testWidgets('triggers onToggleGroup when group header is tapped', (WidgetTester tester) async {
      String? toggledGroup;

      await tester.pumpWidget(
        buildWidget(
          onToggleGroup: (String group) {
            toggledGroup = group;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(toggledGroup, equals('home'));
    });
  });

  group('ContentAssetTable Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_asset_table',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with expanded group',
            child: buildWidget(expandedGroups: <String>{'home'}),
          ),
          GoldenTestScenario(
            name: 'empty carousels',
            child: buildWidget(groupedCarousels: <MapEntry<ContentPlacementGroup, List<ContentAsset>>>[]),
          ),
        ],
      ),
    );
  });
}

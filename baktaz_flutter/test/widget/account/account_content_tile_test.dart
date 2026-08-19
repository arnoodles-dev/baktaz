import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(AccountContentTile, () {
    goldenTest(
      'renders profile tile correctly',
      fileName: 'account_content_tile_profile'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'profile option',
            child: MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(
                body: AccountContentTile(title: 'profile', onTap: () {}, optionKey: AccountHeader.myAccount),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'addresses option',
            child: MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(
                body: AccountContentTile(title: 'addresses', onTap: () {}, optionKey: AccountHeader.myAccount),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'helpCenter option',
            child: MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(
                body: AccountContentTile(title: 'helpCenter', onTap: () {}, optionKey: AccountHeader.support),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'language option',
            child: MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(
                body: AccountContentTile(title: 'language', onTap: () {}, optionKey: AccountHeader.settings),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool? tapped;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: AccountContentTile(
              title: 'profile',
              onTap: () {
                tapped = true;
              },
              optionKey: AccountHeader.myAccount,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder tileFinder = find.byType(GestureDetector);
      expect(tileFinder, findsOneWidget);

      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}

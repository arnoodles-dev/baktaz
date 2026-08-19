import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazIconTile, () {
    goldenTest(
      'renders icon tile correctly with icon and label',
      fileName: 'baktaz_icon_tile'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default tile',
            child: const BaktazIconTile(icon: Icons.wifi, label: 'Wi-Fi'),
          ),
          GoldenTestScenario(
            name: 'tappable tile',
            child: BaktazIconTile(icon: Icons.pool, label: 'Swimming Pool', onTap: () {}),
          ),
        ],
      ),
    );

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazIconTile(icon: Icons.local_parking, label: 'Parking', onTap: () => wasTapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Parking'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });
  });
}

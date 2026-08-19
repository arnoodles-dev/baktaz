import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazFilterChip, () {
    goldenTest(
      'renders active and inactive filter chips correctly',
      fileName: 'baktaz_filter_chip'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'inactive chip',
            child: const BaktazFilterChip(label: 'All Items', isActive: false),
          ),
          GoldenTestScenario(
            name: 'active chip',
            child: const BaktazFilterChip(label: 'Active Only', isActive: true),
          ),
        ],
      ),
    );

    testWidgets('triggers onTap callback when chip is clicked', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazFilterChip(label: 'Category', isActive: false, onTap: () => wasTapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });
  });
}

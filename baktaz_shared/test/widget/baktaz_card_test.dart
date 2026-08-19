import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(BaktazCard, () {
    goldenTest(
      'renders correctly with different header and footer combinations',
      fileName: 'baktaz_card'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'card with body only',
            child: const SizedBox(width: 300, child: BaktazCard(body: Text(SharedFixtures.sampleText))),
          ),
          GoldenTestScenario(
            name: 'card with header and action',
            child: SizedBox(
              width: 300,
              child: BaktazCard(
                headerTitle: 'Card Header',
                headerIcon: Icons.info_outline,
                headerAction: IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                body: const Text(SharedFixtures.sampleText),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'card with header, body and footer',
            child: const SizedBox(
              width: 300,
              child: BaktazCard(
                headerTitle: 'Card Header',
                headerIcon: Icons.star,
                body: Text(SharedFixtures.sampleText),
                footer: Text('Footer Content'),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('renders child body and footer widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BaktazCard(
              headerTitle: 'Test Card Title',
              body: Text('Card Body Content'),
              footer: Text('Card Footer Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Card Title'), findsOneWidget);
      expect(find.text('Card Body Content'), findsOneWidget);
      expect(find.text('Card Footer Content'), findsOneWidget);
    });
  });
}

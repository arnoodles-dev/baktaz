import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(BaktazText, () {
    goldenTest(
      'renders correctly across all text types',
      pumpBeforeTest: (WidgetTester tester) async => tester.pumpAndSettle(),
      fileName: 'baktaz_text'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'regular text',
            child: const BaktazText(text: SharedFixtures.sampleText),
          ),
          GoldenTestScenario(
            name: 'styled text',
            child: const BaktazText(
              text: SharedFixtures.sampleStyledText,
              textType: TextType.styled,
              styledTextIcon: Icons.star,
            ),
          ),
          // GoldenTestScenario(
          //   name: 'markdown text',
          //   child: const BaktazText(
          //     text: SharedFixtures.sampleMarkdownText,
          //     textType: TextType.markdown,
          //   ),
          // ),
          GoldenTestScenario(
            name: 'selectable text',
            child: const BaktazText(text: SharedFixtures.sampleText, textType: TextType.selectable),
          ),
        ],
      ),
    );

    testWidgets('triggers onLinkPressed when link is tapped in styled text', (WidgetTester tester) async {
      String? pressedLink;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazText(
              text: '<link href="https://example.com">Click Link</link>',
              textType: TextType.styled,
              onLinkPressed: (String url) => pressedLink = url,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Link', findRichText: true));
      await tester.pump(const Duration(milliseconds: 100));

      expect(pressedLink, equals('https://example.com'));
    });
  });
}

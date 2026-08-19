import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(BaktazAvatar, () {
    goldenTest(
      'renders correctly with initials, icons, and sizing variants',
      fileName: 'baktaz_avatar'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'avatar with initials XS',
            child: const BaktazAvatar(size: BaktazAvatar.sizeXS, initials: SharedFixtures.initials),
          ),
          GoldenTestScenario(
            name: 'avatar with initials MD',
            child: const BaktazAvatar(size: BaktazAvatar.sizeMD, initials: SharedFixtures.initials),
          ),
          GoldenTestScenario(
            name: 'avatar with initials XL',
            child: const BaktazAvatar(size: BaktazAvatar.sizeXL, initials: SharedFixtures.initials),
          ),
          GoldenTestScenario(
            name: 'default icon avatar',
            child: const BaktazAvatar(size: BaktazAvatar.sizeMD),
          ),
        ],
      ),
    );

    testWidgets('renders upper-cased first 2 characters of initials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BaktazAvatar(size: BaktazAvatar.sizeMD, initials: 'john doe'),
          ),
        ),
      );

      expect(find.text('JO'), findsOneWidget);
    });
  });
}

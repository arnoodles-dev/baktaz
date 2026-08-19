import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazProgressBar, () {
    goldenTest(
      'renders progress bar across different values and critical state',
      fileName: 'baktaz_progress_bar'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'normal progress bar 50%',
            child: const SizedBox(width: 250, child: BaktazProgressBar(progress: 0.5, label: '50% Complete')),
          ),
          GoldenTestScenario(
            name: 'critical progress bar 90%',
            child: const SizedBox(
              width: 250,
              child: BaktazProgressBar(progress: 0.9, label: '90% Storage Used', isCritical: true),
            ),
          ),
        ],
      ),
    );

    testWidgets('renders progress bar with label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BaktazProgressBar(progress: 0.75, label: '75% Uploaded')),
        ),
      );

      expect(find.text('75% Uploaded'), findsOneWidget);
    });
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazStatusBadge, () {
    goldenTest(
      'renders status badge across all status variants',
      fileName: 'baktaz_status_badge'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'available badge',
            child: const BaktazStatusBadge(label: 'Available', variant: StatusBadgeVariant.available),
          ),
          GoldenTestScenario(
            name: 'confirmed badge',
            child: const BaktazStatusBadge(label: 'Confirmed', variant: StatusBadgeVariant.confirmed),
          ),
          GoldenTestScenario(
            name: 'active badge',
            child: const BaktazStatusBadge(label: 'Active', variant: StatusBadgeVariant.active),
          ),
          GoldenTestScenario(
            name: 'pending badge',
            child: const BaktazStatusBadge(label: 'Pending', variant: StatusBadgeVariant.pending),
          ),
          GoldenTestScenario(
            name: 'failed badge',
            child: const BaktazStatusBadge(label: 'Failed', variant: StatusBadgeVariant.failed),
          ),
          GoldenTestScenario(
            name: 'neutral badge',
            child: const BaktazStatusBadge(label: 'Paused', variant: StatusBadgeVariant.neutral),
          ),
        ],
      ),
    );

    testWidgets('renders badge with label and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BaktazStatusBadge(label: 'Completed', variant: StatusBadgeVariant.confirmed),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}

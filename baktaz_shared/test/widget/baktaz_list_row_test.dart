import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazListRow, () {
    goldenTest(
      'renders list row variants correctly',
      fileName: 'baktaz_list_row'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'simple list row',
            child: const SizedBox(
              width: 350,
              child: BaktazListRow(
                label: 'Account Settings',
                leadingIcon: Icons.person_outline,
                trailingIcon: Icons.chevron_right,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'list row with subtitle',
            child: const SizedBox(
              width: 350,
              child: BaktazListRow(
                label: 'Notifications',
                subtitle: 'Manage app notifications and alerts',
                leadingIcon: Icons.notifications_none,
                trailingIcon: Icons.chevron_right,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'destructive list row',
            child: const SizedBox(
              width: 350,
              child: BaktazListRow(
                label: 'Delete Account',
                subtitle: 'Permanently remove your data',
                leadingIcon: Icons.delete_outline,
                isDestructive: true,
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onTap callback when row is clicked', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazListRow(label: 'Privacy Settings', onTap: () => wasTapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Privacy Settings'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });
  });
}

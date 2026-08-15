import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/pending_changes_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';

void main() {
  group('PendingChangesBanner Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'pending_changes_banner',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default state',
            child: MockMaterialApp(
              child: PendingChangesBanner(changeCount: 3, onPublish: () {}, onDiscard: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'change count 1',
            child: MockMaterialApp(
              child: PendingChangesBanner(changeCount: 1, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
    );

    // ignore: discarded_futures
    goldenTest(
      'renders with discard confirmation dialog',
      fileName: 'pending_changes_banner_dialog',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'discard dialog',
            child: MockMaterialApp(
              child: PendingChangesBanner(changeCount: 3, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
      whilePerforming: (WidgetTester tester) async {
        await tester.tap(find.text('Discard'));
        await tester.pump();
        return () async {};
      },
    );

    // ignore: discarded_futures
    goldenTest(
      'cancels discard confirmation dialog',
      fileName: 'pending_changes_banner_dialog_cancel',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'cancel discard',
            child: MockMaterialApp(
              child: PendingChangesBanner(changeCount: 3, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
      whilePerforming: (WidgetTester tester) async {
        await tester.tap(find.text('Discard'));
        await tester.pump();
        await tester.tap(find.text('Cancel'));
        await tester.pump();
        return () async {};
      },
    );

    // ignore: discarded_futures
    goldenTest(
      'confirms discard confirmation dialog',
      fileName: 'pending_changes_banner_dialog_confirm',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'confirm discard',
            child: MockMaterialApp(
              child: PendingChangesBanner(changeCount: 3, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
      whilePerforming: (WidgetTester tester) async {
        await tester.tap(find.text('Discard'));
        await tester.pump();
        await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Discard')));
        await tester.pump();
        return () async {};
      },
    );
  });
}

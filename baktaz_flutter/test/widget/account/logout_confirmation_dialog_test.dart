import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/dialogs/logout_confirmation_dialog.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(LogoutConfirmationDialog, () {
    goldenTest(
      'renders correctly',
      fileName: 'logout_confirmation_dialog'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default logout confirmation dialog',
            child: MockMaterialApp(
              surfaceHeight: 500,
              child: Dialog(child: LogoutConfirmationDialog(onLogout: () {})),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onLogout callback when logout button is pressed', (WidgetTester tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MockMaterialApp(
          child: Builder(
            builder: (BuildContext context) => Scaffold(
              body: LogoutConfirmationDialog(
                onLogout: () {
                  logoutCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder logoutButtonFinder = find.widgetWithText(BaktazButton, 'Log Out');
      expect(logoutButtonFinder, findsOneWidget);

      await tester.tap(logoutButtonFinder);
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
    });

    testWidgets('dismisses dialog when cancel button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext dialogContext) => Dialog(child: LogoutConfirmationDialog(onLogout: () {})),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);

      final Finder cancelButton = find.widgetWithText(BaktazButton, 'Cancel');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(LogoutConfirmationDialog), findsNothing);
    });
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/my_account_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/settings_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_widget.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  setUpAll(setupInjection);

  group(AccountContentWidget, () {
    final Map<AccountHeader, List<String>> sampleGroupedOptions = <AccountHeader, List<String>>{
      AccountHeader.myAccount: MyAccountOption.values.map((MyAccountOption option) => option.name).toList(),
      AccountHeader.support: SupportOption.values.map((SupportOption option) => option.name).toList(),
      AccountHeader.settings: SettingsOption.values.map((SettingsOption option) => option.name).toList(),
    };

    goldenTest(
      'renders correctly',
      fileName: 'account_content_widget'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default with grouped options',
            child: MockMaterialApp(
              surfaceHeight: 1200,
              child: Scaffold(
                body: AccountContentWidget(groupedOptions: sampleGroupedOptions, onOptionsTap: (_) {}),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'single category options',
            child: MockMaterialApp(
              surfaceHeight: 400,
              child: Scaffold(
                body: AccountContentWidget(
                  groupedOptions: <AccountHeader, List<String>>{
                    AccountHeader.myAccount: <String>[MyAccountOption.profile.name, MyAccountOption.contacts.name],
                  },
                  onOptionsTap: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onOptionsTap callback when an option tile is tapped', (WidgetTester tester) async {
      String? tappedOption;

      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: AccountContentWidget(
              groupedOptions: <AccountHeader, List<String>>{
                AccountHeader.myAccount: <String>[MyAccountOption.profile.name],
              },
              onOptionsTap: (String option) {
                tappedOption = option;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder tileFinder = find.text(MyAccountOption.profile.name.camelToSentence());
      expect(tileFinder, findsOneWidget);

      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(tappedOption, equals(MyAccountOption.profile.name));
    });
  });
}

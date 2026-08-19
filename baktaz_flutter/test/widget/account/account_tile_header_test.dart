import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_tile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(AccountTileHeader, () {
    goldenTest(
      'renders correctly for all headers',
      fileName: 'account_tile_header'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'myAccount header',
            child: const MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(body: AccountTileHeader(header: AccountHeader.myAccount)),
            ),
          ),
          GoldenTestScenario(
            name: 'support header',
            child: const MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(body: AccountTileHeader(header: AccountHeader.support)),
            ),
          ),
          GoldenTestScenario(
            name: 'settings header',
            child: const MockMaterialApp(
              surfaceHeight: 100,
              child: Scaffold(body: AccountTileHeader(header: AccountHeader.settings)),
            ),
          ),
        ],
      ),
    );
  });
}

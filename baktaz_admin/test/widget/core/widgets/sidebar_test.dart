import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/core/presentation/widgets/baktaz_nav_item_data.dart';
import 'package:baktaz_admin/core/presentation/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/mock_material_app.dart';
import '../../../utils/test_utils.dart';

void main() {
  group(Sidebar, () {
    final List<BaktazNavItemData> testNavItems = <BaktazNavItemData>[
      const BaktazNavItemData(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard'),
      const BaktazNavItemData(icon: Icons.settings_outlined, label: 'Settings', route: '/settings'),
      const BaktazNavItemData(icon: Icons.person_outline, label: 'Profile', route: '/profile'),
    ];

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'sidebar'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'extended with first selected',
            child: MockMaterialApp(
              child: SizedBox(
                width: Sidebar.extendedWidth,
                height: 600,
                child: Sidebar(
                  selectedIndex: 0,
                  onDestinationSelected: (int _) {},
                  navItems: testNavItems,
                  extended: true,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'compact with second selected',
            child: MockMaterialApp(
              child: SizedBox(
                width: Sidebar.compactWidth,
                height: 600,
                child: Sidebar(
                  selectedIndex: 1,
                  onDestinationSelected: (int _) {},
                  navItems: testNavItems,
                  extended: false,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'extended with no selection',
            child: MockMaterialApp(
              child: SizedBox(
                width: Sidebar.extendedWidth,
                height: 600,
                child: Sidebar(
                  selectedIndex: -1,
                  onDestinationSelected: (int _) {},
                  navItems: testNavItems,
                  extended: true,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'compact with single item',
            child: MockMaterialApp(
              child: SizedBox(
                width: Sidebar.compactWidth,
                height: 600,
                child: Sidebar(
                  selectedIndex: 0,
                  onDestinationSelected: (int _) {},
                  navItems: const <BaktazNavItemData>[
                    BaktazNavItemData(icon: Icons.home_outlined, label: 'Home', route: '/'),
                  ],
                  extended: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

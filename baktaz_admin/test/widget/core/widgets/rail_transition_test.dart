import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/core/presentation/widgets/rail_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/mock_material_app.dart';
import '../../../utils/test_utils.dart';

void main() {
  group(RailTransition, () {
    final NavigationRail testChild = NavigationRail(
      selectedIndex: 0,
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'rail_transition'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'expanded',
            child: MockMaterialApp(
              child: SizedBox(
                height: 600,
                child: RailTransition(
                  animation: const AlwaysStoppedAnimation<double>(1),
                  backgroundColor: Colors.white,
                  child: testChild,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'collapsed',
            child: MockMaterialApp(
              child: SizedBox(
                height: 600,
                child: RailTransition(
                  animation: const AlwaysStoppedAnimation<double>(0),
                  backgroundColor: Colors.white,
                  child: testChild,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'mid transition',
            child: MockMaterialApp(
              child: SizedBox(
                height: 600,
                child: RailTransition(
                  animation: const AlwaysStoppedAnimation<double>(0.5),
                  backgroundColor: Colors.white,
                  child: testChild,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'dark background',
            child: MockMaterialApp(
              child: SizedBox(
                height: 600,
                child: RailTransition(
                  animation: const AlwaysStoppedAnimation<double>(1),
                  backgroundColor: Colors.grey.shade900,
                  child: testChild,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

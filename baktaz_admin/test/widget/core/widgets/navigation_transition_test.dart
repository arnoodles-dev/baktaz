import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/core/presentation/widgets/navigation_transition.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/mock_material_app.dart';
import '../../../utils/test_utils.dart';

void main() {
  late StreamController<ConnectionStatus> connectivityStream;

  setUp(() {
    connectivityStream = StreamController<ConnectionStatus>.broadcast();
    ConnectivityUtils.instance = ConnectivityUtils.testing(connectivityStream.stream);
  });

  tearDown(() async {
    await connectivityStream.close();
  });

  group(NavigationTransition, () {
    final PreferredSizeWidget testAppBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(title: const Text('Test AppBar')),
    );

    final NavigationRail testRail = NavigationRail(
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
      fileName: 'navigation_transition'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'basic layout',
            child: MockMaterialApp(
              child: SizedBox(
                width: 1200,
                height: 800,
                child: NavigationTransition(
                  railAnimation: const AlwaysStoppedAnimation<double>(1),
                  appBar: testAppBar,
                  body: const Center(child: Text('Body Content')),
                  navigationRail: testRail,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'collapsed rail',
            child: MockMaterialApp(
              child: SizedBox(
                width: 1200,
                height: 800,
                child: NavigationTransition(
                  railAnimation: const AlwaysStoppedAnimation<double>(0),
                  appBar: testAppBar,
                  body: const Center(child: Text('Body Content')),
                  navigationRail: testRail,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'different body content',
            child: MockMaterialApp(
              child: SizedBox(
                width: 1200,
                height: 800,
                child: NavigationTransition(
                  railAnimation: const AlwaysStoppedAnimation<double>(1),
                  appBar: testAppBar,
                  body: const Column(
                    children: <Widget>[
                      Card(
                        child: Padding(padding: Paddings.allMedium, child: Text('Card 1')),
                      ),
                      Card(
                        child: Padding(padding: Paddings.allMedium, child: Text('Card 2')),
                      ),
                    ],
                  ),
                  navigationRail: NavigationRail(
                    selectedIndex: 1,
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_utils.dart';

void main() {
  group(StatCard, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'stat_card'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default',
            child: const StatCard(title: 'Users', value: '150', icon: Icons.people_outline, color: Colors.blue),
          ),
          GoldenTestScenario(
            name: 'with status dot',
            child: const StatCard(
              title: 'Server Status',
              value: 'Online',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              isStatus: true,
            ),
          ),
          GoldenTestScenario(
            name: 'with custom colors',
            child: const StatCard(title: 'System Load', value: '24%', icon: Icons.dns_outlined, color: Colors.orange),
          ),
          GoldenTestScenario(
            name: 'with growth positive',
            child: const StatCard(
              title: 'Revenue',
              value: r'$12,450',
              icon: Icons.trending_up,
              color: Colors.green,
              growth: '+12% increase',
            ),
          ),
          GoldenTestScenario(
            name: 'with growth negative',
            child: const StatCard(
              title: 'Bounce Rate',
              value: '24%',
              icon: Icons.trending_down,
              color: Colors.red,
              growth: '-2% decrease',
            ),
          ),
        ],
      ),
    );
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/recent_activities_table.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(RecentActivitiesTable, () {
    final List<RecentActivity> mockActivities = <RecentActivity>[
      RecentActivity(
        id: UniqueId.fromUniqueString('1'),
        name: ValueName('Delivery Order'),
        date: DateTime(2026, 7),
        totalAmount: Money(150),
        status: ActivityStatus.completed,
        customers: Number(2),
        customerAvatars: <Url>[],
      ),
      RecentActivity(
        id: UniqueId.fromUniqueString('2'),
        name: ValueName('Shop Purchase'),
        date: DateTime(2026, 7, 2),
        totalAmount: Money(90),
        status: ActivityStatus.processing,
        customers: Number(1),
        customerAvatars: <Url>[],
      ),
      RecentActivity(
        id: UniqueId.fromUniqueString('3'),
        name: ValueName('Service Request'),
        date: DateTime(2026, 7, 3),
        totalAmount: Money(200),
        status: ActivityStatus.pending,
        customers: Number(3),
        customerAvatars: <Url>[],
      ),
    ];

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'recent_activities_table'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with activities',
            child: MockMaterialApp(child: RecentActivitiesTable(activities: mockActivities)),
          ),
          GoldenTestScenario(
            name: 'empty activities',
            child: const MockMaterialApp(child: RecentActivitiesTable(activities: <RecentActivity>[])),
          ),
          GoldenTestScenario(
            name: 'single activity',
            child: MockMaterialApp(child: RecentActivitiesTable(activities: <RecentActivity>[mockActivities.first])),
          ),
          GoldenTestScenario(
            name: 'all statuses',
            child: MockMaterialApp(
              child: RecentActivitiesTable(
                activities: <RecentActivity>[
                  RecentActivity(
                    id: UniqueId.fromUniqueString('10'),
                    name: ValueName('Completed Task'),
                    date: DateTime(2026, 7, 10),
                    totalAmount: Money(100),
                    status: ActivityStatus.completed,
                    customers: Number(1),
                    customerAvatars: <Url>[],
                  ),
                  RecentActivity(
                    id: UniqueId.fromUniqueString('11'),
                    name: ValueName('Processing Task'),
                    date: DateTime(2026, 7, 11),
                    totalAmount: Money(200),
                    status: ActivityStatus.processing,
                    customers: Number(2),
                    customerAvatars: <Url>[],
                  ),
                  RecentActivity(
                    id: UniqueId.fromUniqueString('12'),
                    name: ValueName('Pending Task'),
                    date: DateTime(2026, 7, 12),
                    totalAmount: Money(300),
                    status: ActivityStatus.pending,
                    customers: Number(3),
                    customerAvatars: <Url>[],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/activities_overview_chart.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ActivitiesOverviewChart, () {
    final List<DailyActivityStats> testData = List<DailyActivityStats>.generate(
      7,
      (int i) => DailyActivityStats(dayIndex: Number(i), inProgress: Number(i * 5 + 10), completed: Number(i * 3 + 20)),
    );

    final List<DailyActivityStats> emptyData = <DailyActivityStats>[];

    final List<DailyActivityStats> singleItemData = <DailyActivityStats>[
      DailyActivityStats(dayIndex: Number(0), inProgress: Number(5), completed: Number(15)),
    ];

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'activities_overview_chart'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with data - all filter - last 7 days',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: testData,
                  selectedFilter: ActivityFilter.all,
                  selectedTimeFilter: TimeFilter.last7Days,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with data - hero filter - today',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: testData,
                  selectedFilter: ActivityFilter.hero,
                  selectedTimeFilter: TimeFilter.today,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with data - last 30 days',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: testData,
                  selectedFilter: ActivityFilter.all,
                  selectedTimeFilter: TimeFilter.last30Days,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'empty data',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: emptyData,
                  selectedFilter: ActivityFilter.all,
                  selectedTimeFilter: TimeFilter.last7Days,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'loading state',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: emptyData,
                  selectedFilter: ActivityFilter.all,
                  selectedTimeFilter: TimeFilter.last7Days,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                  isLoading: true,
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'single data point',
            child: MockMaterialApp(
              child: SizedBox(
                width: 800,
                height: 450,
                child: ActivitiesOverviewChart(
                  data: singleItemData,
                  selectedFilter: ActivityFilter.shop,
                  selectedTimeFilter: TimeFilter.last7Days,
                  onFilterChanged: (ActivityFilter _) {},
                  onTimeFilterChanged: (TimeFilter _) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

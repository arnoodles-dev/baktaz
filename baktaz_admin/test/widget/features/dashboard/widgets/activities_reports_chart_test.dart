import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/activities_reports_chart.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ActivitiesReportsChart, () {
    final CategoryReportStats mockData = CategoryReportStats(
      hero: Number(100),
      express: Number(75),
      shop: Number(50),
      buy: Number(25),
    );

    final CategoryReportStats zeroData = CategoryReportStats(
      hero: Number(0),
      express: Number(0),
      shop: Number(0),
      buy: Number(0),
    );

    final CategoryReportStats singleCategoryData = CategoryReportStats(
      hero: Number(200),
      express: Number(0),
      shop: Number(0),
      buy: Number(0),
    );

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'activities_reports_chart'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with data - all status',
            child: MockMaterialApp(
              child: SizedBox(
                width: 500,
                height: 450,
                child: ActivitiesReportsChart(
                  data: mockData,
                  selectedStatusFilter: ActivityStatusFilter.all,
                  onStatusFilterChanged: (ActivityStatusFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with data - in progress filter',
            child: MockMaterialApp(
              child: SizedBox(
                width: 500,
                height: 450,
                child: ActivitiesReportsChart(
                  data: mockData,
                  selectedStatusFilter: ActivityStatusFilter.inProgress,
                  onStatusFilterChanged: (ActivityStatusFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'zero data',
            child: MockMaterialApp(
              child: SizedBox(
                width: 500,
                height: 450,
                child: ActivitiesReportsChart(
                  data: zeroData,
                  selectedStatusFilter: ActivityStatusFilter.all,
                  onStatusFilterChanged: (ActivityStatusFilter _) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'single category dominant',
            child: MockMaterialApp(
              child: SizedBox(
                width: 500,
                height: 450,
                child: ActivitiesReportsChart(
                  data: singleCategoryData,
                  selectedStatusFilter: ActivityStatusFilter.completed,
                  onStatusFilterChanged: (ActivityStatusFilter _) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

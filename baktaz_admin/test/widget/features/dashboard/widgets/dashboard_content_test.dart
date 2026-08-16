import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_cubit.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_state.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(DashboardContent, () {
    late MockDashboardCubit mockCubit;

    final DashboardStats mockStats = DashboardStats(
      totalActivities: Number(1234),
      ongoingActivities: Number(123),
      completedActivities: Number(1111),
      totalRevenue: Money(12345),
      totalActivitiesGrowth: '+12% increase',
      ongoingActivitiesGrowth: '-2% decrease',
      completedActivitiesGrowth: '+5% increase',
      totalRevenueGrowth: '+15% increase',
    );

    final CategoryReportStats mockReports = CategoryReportStats(
      hero: Number(100),
      express: Number(100),
      shop: Number(100),
      buy: Number(100),
    );

    final List<DailyActivityStats> mockOverview = List<DailyActivityStats>.generate(
      7,
      (int index) => DailyActivityStats(dayIndex: Number(index), inProgress: Number(10), completed: Number(20)),
    );

    final List<RecentActivity> mockActivities = List<RecentActivity>.generate(
      5,
      (int index) => RecentActivity(
        id: UniqueId.fromUniqueString('${index + 1}'),
        name: ValueName('Activity ${index + 1}'),
        date: DateTime(2026, 7, index + 1),
        totalAmount: Money((index + 1) * 100),
        status: ActivityStatus.values[index % ActivityStatus.values.length],
        customers: Number(index + 1),
        customerAvatars: <Url>[],
      ),
    );

    setUp(() {
      mockCubit = MockDashboardCubit();
    });

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'dashboard_content'.goldensVersion,
      pumpBeforeTest: (WidgetTester tester) async {
        await tester.pump(const Duration(seconds: 1));
      },
      builder: () {
        final DashboardState loadedState = DashboardState(
          status: const QueryStatus.done(),
          activities: mockActivities,
          stats: mockStats,
          overviewChart: mockOverview,
          reportsChart: mockReports,
        );

        const DashboardState loadingState = DashboardState(status: QueryStatus.loading());

        return GoldenTestGroup(
          children: <Widget>[
            GoldenTestScenario(
              name: 'loaded state',
              child: MockMaterialApp(
                surfaceWidth: 1600,
                child: BlocSignalProvider<DashboardCubit>.value(
                  value: mockCubit..mockState(loadedState),
                  child: DashboardContent(account: mockAccount),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'loading state with shimmer',
              child: MockMaterialApp(
                surfaceWidth: 1600,
                child: BlocSignalProvider<DashboardCubit>.value(
                  value: mockCubit..mockState(loadingState),
                  child: DashboardContent(account: mockAccount),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'partial data state',
              child: MockMaterialApp(
                surfaceWidth: 1600,
                child: BlocSignalProvider<DashboardCubit>.value(
                  value: mockCubit..mockState(loadedState.copyWith(activities: null, overviewChart: null)),
                  child: DashboardContent(account: mockAccount),
                ),
              ),
            ),
          ],
        );
      },
    );
  });
}

extension on MockDashboardCubit {
  void mockState(DashboardState mockedState) {
    when(state).thenReturn(signal(mockedState));
    when(stateValue).thenReturn(mockedState);
  }
}

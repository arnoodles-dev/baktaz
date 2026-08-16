import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_cubit.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_state.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../utils/generated_mocks.mocks.dart';

void main() {
  late MockIDashboardRepository mockDashboardRepository;
  late FailureHandler failureHandler;
  late MockTalker mockTalker;

  setUp(() {
    provideDummy<TaskResult<List<DailyActivityStats>>>(
      TaskEither<Failure, List<DailyActivityStats>>.right(const <DailyActivityStats>[]),
    );
    provideDummy<TaskResult<CategoryReportStats>>(
      TaskEither<Failure, CategoryReportStats>.right(
        CategoryReportStats(hero: Number(0), express: Number(0), shop: Number(0), buy: Number(0)),
      ),
    );
    provideDummy<TaskResult<DashboardStats>>(
      TaskEither<Failure, DashboardStats>.right(
        DashboardStats(
          totalActivities: Number(0),
          ongoingActivities: Number(0),
          completedActivities: Number(0),
          totalRevenue: Money(0),
        ),
      ),
    );
    provideDummy<TaskResult<List<RecentActivity>>>(TaskEither<Failure, List<RecentActivity>>.right(<RecentActivity>[]));

    mockDashboardRepository = MockIDashboardRepository();
    mockTalker = MockTalker();
    failureHandler = FailureHandler(mockTalker);
  });

  group('DashboardCubit', () {
    blocSignalTest<DashboardCubit, DashboardState>(
      'initialize emits loading and done states',
      build: () {
        when(mockDashboardRepository.getRecentActivities())
            .thenAnswer((_) => TaskEither<Failure, List<RecentActivity>>.right(<RecentActivity>[]));
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(<DailyActivityStats>[]));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer(
          (_) => TaskEither<Failure, CategoryReportStats>.right(
            CategoryReportStats(hero: Number(0), express: Number(0), shop: Number(0), buy: Number(0)),
          ),
        );
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter'))).thenAnswer(
          (_) => TaskEither<Failure, DashboardStats>.right(
            DashboardStats(
              totalActivities: Number(0),
              ongoingActivities: Number(0),
              completedActivities: Number(0),
              totalRevenue: Money(0),
            ),
          ),
        );
        return DashboardCubit(mockDashboardRepository, failureHandler);
      },
      act: (DashboardCubit cubit) => cubit.initialize(),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(status: const QueryStatus.loading()),
        DashboardState.initial().copyWith(activities: <RecentActivity>[], status: const QueryStatus.done()),
      ],
      wait: const Duration(milliseconds: 100),
    );

    final List<DailyActivityStats> tOverview = <DailyActivityStats>[
      DailyActivityStats(dayIndex: Number(1), inProgress: Number(5), completed: Number(5)),
    ];
    final CategoryReportStats tReports = CategoryReportStats(
      hero: Number(5),
      express: Number(2),
      shop: Number(3),
      buy: Number(1),
    );
    final DashboardStats tStats = DashboardStats(
      totalActivities: Number(100),
      ongoingActivities: Number(50),
      completedActivities: Number(50),
      totalRevenue: Money(5000),
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setActivityFilter emits loading and done with new data',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(tOverview));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.right(tReports));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.right(tStats));
        return DashboardCubit(mockDashboardRepository, failureHandler);
      },
      act: (DashboardCubit cubit) => cubit.setActivityFilter(ActivityFilter.shop),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedActivityFilter: ActivityFilter.shop,
          selectedReportStatusFilter: ActivityStatusFilter.all,
          filterStatus: const QueryStatus.loading(),
        ),
        DashboardState.initial().copyWith(
          selectedActivityFilter: ActivityFilter.shop,
          selectedReportStatusFilter: ActivityStatusFilter.all,
          filterStatus: const QueryStatus.done(),
          overviewChart: tOverview,
          reportsChart: tReports,
          stats: tStats,
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setActivityFilter with same filter does nothing (early return)',
      build: () => DashboardCubit(mockDashboardRepository, failureHandler),
      act: (DashboardCubit cubit) {
        cubit
          ..setActivityFilter(ActivityFilter.all)
          ..setActivityFilter(ActivityFilter.all);
      },
      expect: () => <dynamic>[],
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setTimeFilter emits loading and done',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(tOverview));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.right(tReports));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.right(tStats));
        return DashboardCubit(mockDashboardRepository, failureHandler);
      },
      act: (DashboardCubit cubit) => cubit.setTimeFilter(TimeFilter.last30Days),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedTimeFilter: TimeFilter.last30Days,
          filterStatus: const QueryStatus.loading(),
        ),
        DashboardState.initial().copyWith(
          selectedTimeFilter: TimeFilter.last30Days,
          filterStatus: const QueryStatus.done(),
          overviewChart: tOverview,
          reportsChart: tReports,
          stats: tStats,
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setTimeFilter with same filter does nothing',
      build: () => DashboardCubit(mockDashboardRepository, failureHandler),
      act: (DashboardCubit cubit) {
        cubit
          ..setTimeFilter(TimeFilter.last7Days)
          ..setTimeFilter(TimeFilter.last7Days);
      },
      expect: () => <dynamic>[],
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setReportStatusFilter emits loading and done',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(tOverview));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.right(tReports));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.right(tStats));
        return DashboardCubit(mockDashboardRepository, failureHandler);
      },
      act: (DashboardCubit cubit) => cubit.setReportStatusFilter(ActivityStatusFilter.completed),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedReportStatusFilter: ActivityStatusFilter.completed,
          filterStatus: const QueryStatus.loading(),
        ),
        DashboardState.initial().copyWith(
          selectedReportStatusFilter: ActivityStatusFilter.completed,
          filterStatus: const QueryStatus.done(),
          overviewChart: tOverview,
          reportsChart: tReports,
          stats: tStats,
        ),
      ],
      wait: const Duration(milliseconds: 100),
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'setReportStatusFilter with same filter does nothing',
      build: () => DashboardCubit(mockDashboardRepository, failureHandler),
      act: (DashboardCubit cubit) {
        cubit
          ..setReportStatusFilter(ActivityStatusFilter.all)
          ..setReportStatusFilter(ActivityStatusFilter.all);
      },
      expect: () => <dynamic>[],
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'overview fetch failure is handled',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer(
          (_) => TaskEither<Failure, List<DailyActivityStats>>.left(const Failure.unexpected('overview error')),
        );
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.right(tReports));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.right(tStats));
        return DashboardCubit(mockDashboardRepository, MockFailureHandler());
      },
      act: (DashboardCubit cubit) => cubit.setTimeFilter(TimeFilter.last30Days),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedTimeFilter: TimeFilter.last30Days,
          filterStatus: const QueryStatus.loading(),
        ),
      ],
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'reports fetch failure is handled',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(tOverview));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.left(const Failure.unexpected('reports error')));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.right(tStats));
        return DashboardCubit(mockDashboardRepository, MockFailureHandler());
      },
      act: (DashboardCubit cubit) => cubit.setTimeFilter(TimeFilter.last30Days),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedTimeFilter: TimeFilter.last30Days,
          filterStatus: const QueryStatus.loading(),
        ),
      ],
    );

    blocSignalTest<DashboardCubit, DashboardState>(
      'stats fetch failure is handled',
      build: () {
        when(
          mockDashboardRepository.getOverviewChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, List<DailyActivityStats>>.right(tOverview));
        when(
          mockDashboardRepository.getReportsChartData(
            timeFilter: anyNamed('timeFilter'),
            activityFilter: anyNamed('activityFilter'),
            statusFilter: anyNamed('statusFilter'),
          ),
        ).thenAnswer((_) => TaskEither<Failure, CategoryReportStats>.right(tReports));
        when(mockDashboardRepository.getDashboardStats(timeFilter: anyNamed('timeFilter')))
            .thenAnswer((_) => TaskEither<Failure, DashboardStats>.left(const Failure.unexpected('stats error')));
        return DashboardCubit(mockDashboardRepository, MockFailureHandler());
      },
      act: (DashboardCubit cubit) => cubit.setTimeFilter(TimeFilter.last30Days),
      expect: () => <DashboardState>[
        DashboardState.initial().copyWith(
          selectedTimeFilter: TimeFilter.last30Days,
          filterStatus: const QueryStatus.loading(),
        ),
      ],
    );
  });
}

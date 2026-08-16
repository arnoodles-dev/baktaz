import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_cubit.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_state.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/activities_overview_chart.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/activities_reports_chart.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/recent_activities_table.dart';
import 'package:baktaz_admin/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.account, super.key});

  final Account account;

  static final DashboardStats _mockStats = DashboardStats(
    totalActivities: Number(1234),
    ongoingActivities: Number(123),
    completedActivities: Number(1111),
    totalRevenue: Money(12345),
    totalActivitiesGrowth: '+12% increase',
    ongoingActivitiesGrowth: '-2% decrease',
    completedActivitiesGrowth: '+5% increase',
    totalRevenueGrowth: '+15% increase',
  );

  static final CategoryReportStats _mockReports = CategoryReportStats(
    hero: Number(100),
    express: Number(100),
    shop: Number(100),
    buy: Number(100),
  );

  static final List<DailyActivityStats> _mockOverview = <DailyActivityStats>[
    DailyActivityStats(dayIndex: Number(0), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(1), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(2), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(3), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(4), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(5), inProgress: Number(0), completed: Number(0)),
    DailyActivityStats(dayIndex: Number(6), inProgress: Number(0), completed: Number(0)),
  ];

  static final List<RecentActivity> _mockActivities = List<RecentActivity>.generate(
    7,
    (int index) => RecentActivity(
      id: UniqueId.fromUniqueString('${index + 1}'),
      name: ValueName('Mock Activity ${index + 1}'),
      date: DateTime.now(),
      totalAmount: Money(100),
      status: ActivityStatus.completed,
      customers: Number(1),
      customerAvatars: <Url>[],
    ),
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: Paddings.allLarge,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        BlocSignalBuilder<DashboardCubit, DashboardState>(
          builder: (BuildContext context, DashboardState state) {
            final bool isLoading =
                state.status.isLoading ||
                state.activities == null ||
                state.stats == null ||
                state.overviewChart == null ||
                state.reportsChart == null;

            final Widget layout = _DashboardLayout(
              activities: state.activities ?? _mockActivities,
              stats: state.stats ?? _mockStats,
              overviewChart: state.overviewChart ?? _mockOverview,
              reportsChart: state.reportsChart ?? _mockReports,
              selectedFilter: state.selectedActivityFilter,
              selectedTimeFilter: state.selectedTimeFilter,
              selectedReportStatusFilter: state.selectedReportStatusFilter,
              onFilterChanged: context.read<DashboardCubit>().setActivityFilter,
              onTimeFilterChanged: context.read<DashboardCubit>().setTimeFilter,
              onReportStatusFilterChanged: context.read<DashboardCubit>().setReportStatusFilter,
              isFilterLoading: state.filterStatus.isLoading,
            );

            return isLoading ? Shimmer(child: layout) : layout;
          },
        ),
      ],
    ),
  );
}

class _DashboardLayout extends StatelessWidget {
  const _DashboardLayout({
    required this.activities,
    required this.stats,
    required this.overviewChart,
    required this.reportsChart,
    required this.selectedFilter,
    required this.selectedTimeFilter,
    required this.selectedReportStatusFilter,
    required this.onFilterChanged,
    required this.onTimeFilterChanged,
    required this.onReportStatusFilterChanged,
    required this.isFilterLoading,
  });

  final List<RecentActivity> activities;
  final DashboardStats stats;
  final List<DailyActivityStats> overviewChart;
  final CategoryReportStats reportsChart;
  final ActivityFilter selectedFilter;
  final TimeFilter selectedTimeFilter;
  final ActivityStatusFilter selectedReportStatusFilter;
  final ValueChanged<ActivityFilter> onFilterChanged;
  final ValueChanged<TimeFilter> onTimeFilterChanged;
  final ValueChanged<ActivityStatusFilter> onReportStatusFilterChanged;
  final bool isFilterLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                title: context.i18n.dashboard.stats.total_activities,
                value: NumberFormat.decimalPattern().format(stats.totalActivities.getValue()),
                growth: stats.totalActivitiesGrowth,
                icon: Icons.reorder,
                color: colorScheme.primary,
              ),
            ),
            Gap.large(),
            Expanded(
              child: StatCard(
                title: context.i18n.dashboard.stats.ongoing_activities,
                value: NumberFormat.decimalPattern().format(stats.ongoingActivities.getValue()),
                growth: stats.ongoingActivitiesGrowth,
                icon: Icons.pending_actions,
                color: colorScheme.error,
              ),
            ),
            Gap.large(),
            Expanded(
              child: StatCard(
                title: context.i18n.dashboard.stats.completed_activities,
                value: NumberFormat.decimalPattern().format(stats.completedActivities.getValue()),
                growth: stats.completedActivitiesGrowth,
                icon: Icons.check_circle,
                color: colorScheme.secondary,
              ),
            ),
            Gap.large(),
            Expanded(
              child: StatCard(
                title: context.i18n.dashboard.stats.total_revenue,
                value: '\$${NumberFormat.decimalPattern().format(stats.totalRevenue.getValue())}',
                growth: stats.totalRevenueGrowth,
                icon: Icons.payments,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        Gap.xLarge(),

        // Charts Row
        if (isFilterLoading)
          Shimmer(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: ActivitiesOverviewChart(
                      data: overviewChart,
                      isLoading: true,
                      selectedFilter: selectedFilter,
                      selectedTimeFilter: selectedTimeFilter,
                      onFilterChanged: onFilterChanged,
                      onTimeFilterChanged: onTimeFilterChanged,
                    ),
                  ),
                  Gap.large(),
                  Expanded(
                    child: ActivitiesReportsChart(
                      data: reportsChart,
                      selectedStatusFilter: selectedReportStatusFilter,
                      onStatusFilterChanged: onReportStatusFilterChanged,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: ActivitiesOverviewChart(
                    data: overviewChart,
                    selectedFilter: selectedFilter,
                    selectedTimeFilter: selectedTimeFilter,
                    onFilterChanged: onFilterChanged,
                    onTimeFilterChanged: onTimeFilterChanged,
                  ),
                ),
                Gap.large(),
                Expanded(
                  child: ActivitiesReportsChart(
                    data: reportsChart,
                    selectedStatusFilter: selectedReportStatusFilter,
                    onStatusFilterChanged: onReportStatusFilterChanged,
                  ),
                ),
              ],
            ),
          ),
        Gap.xLarge(),

        // Recent Activities Table
        RecentActivitiesTable(activities: activities),
      ],
    );
  }
}

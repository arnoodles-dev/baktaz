import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_shared/baktaz_shared.dart';

abstract interface class IDashboardRepository {
  TaskResult<List<RecentActivity>> getRecentActivities();
  TaskResult<DashboardStats> getDashboardStats({required TimeFilter timeFilter});
  TaskResult<List<DailyActivityStats>> getOverviewChartData({
    required TimeFilter timeFilter,
    required ActivityFilter activityFilter,
  });
  TaskResult<CategoryReportStats> getReportsChartData({
    required TimeFilter timeFilter,
    required ActivityFilter activityFilter,
    required ActivityStatusFilter statusFilter,
  });
}

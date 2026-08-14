import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(QueryStatus.initial()) QueryStatus status,
    @Default(QueryStatus.initial()) QueryStatus filterStatus,
    @Default(ActivityFilter.all) ActivityFilter selectedActivityFilter,
    @Default(ActivityStatusFilter.all) ActivityStatusFilter selectedReportStatusFilter,
    @Default(TimeFilter.last7Days) TimeFilter selectedTimeFilter,
    List<RecentActivity>? activities,
    DashboardStats? stats,
    List<DailyActivityStats>? overviewChart,
    CategoryReportStats? reportsChart,
  }) = _DashboardState;

  const DashboardState._();

  factory DashboardState.initial() => const DashboardState();
}

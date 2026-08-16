import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/dashboard/domain/cubit/dashboard/dashboard_state.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_admin/features/dashboard/domain/interface/i_dashboard_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardCubit extends CubitSignal<DashboardState> {
  DashboardCubit(this._dashboardRepository, this._failureHandler) : super(initialState: DashboardState.initial());

  final IDashboardRepository _dashboardRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    safeEmit(stateValue.copyWith(status: const QueryStatus.loading()));

    unawaited(_fetchRecentActivities());
    unawaited(_fetchOverviewChartData());
  }

  void setActivityFilter(ActivityFilter filter) {
    if (stateValue.selectedActivityFilter == filter) return;

    safeEmit(
      stateValue.copyWith(
        selectedActivityFilter: filter,
        selectedReportStatusFilter: ActivityStatusFilter.all,
        filterStatus: const QueryStatus.loading(),
      ),
    );

    unawaited(_simulateFilterUpdate());
  }

  void setTimeFilter(TimeFilter filter) {
    if (stateValue.selectedTimeFilter == filter) return;

    safeEmit(stateValue.copyWith(selectedTimeFilter: filter, filterStatus: const QueryStatus.loading()));

    unawaited(_simulateFilterUpdate());
  }

  void setReportStatusFilter(ActivityStatusFilter filter) {
    if (stateValue.selectedReportStatusFilter == filter) return;

    safeEmit(stateValue.copyWith(selectedReportStatusFilter: filter, filterStatus: const QueryStatus.loading()));

    unawaited(_simulateFilterUpdate());
  }

  Future<void> _simulateFilterUpdate() async {
    final ActivityFilter activityFilter = stateValue.selectedActivityFilter;
    final TimeFilter timeFilter = stateValue.selectedTimeFilter;
    final ActivityStatusFilter reportStatusFilter = stateValue.selectedReportStatusFilter;

    await safeRun(
      action: () async {
        final Either<Failure, List<DailyActivityStats>> overviewResult = await _dashboardRepository
            .getOverviewChartData(timeFilter: timeFilter, activityFilter: activityFilter)
            .run();

        if (overviewResult.isLeft()) {
          return _failureHandler.handleFailure(overviewResult.getLeft().toNullable()!);
        }

        final Either<Failure, CategoryReportStats> reportsResult = await _dashboardRepository
            .getReportsChartData(
              timeFilter: timeFilter,
              activityFilter: activityFilter,
              statusFilter: reportStatusFilter,
            )
            .run();

        if (reportsResult.isLeft()) {
          return _failureHandler.handleFailure(reportsResult.getLeft().toNullable()!);
        }

        final Either<Failure, DashboardStats> statsResult = await _dashboardRepository
            .getDashboardStats(timeFilter: timeFilter)
            .run();

        if (statsResult.isLeft()) {
          return _failureHandler.handleFailure(statsResult.getLeft().toNullable()!);
        }

        safeEmit(
          stateValue.copyWith(
            overviewChart: overviewResult.getRight().toNullable(),
            reportsChart: reportsResult.getRight().toNullable(),
            stats: statsResult.getRight().toNullable(),
            filterStatus: const QueryStatus.done(),
          ),
        );
      },
      onException: (Exception error, StackTrace? stackTrace) =>
          _failureHandler.handleFailure(Failure.unexpected(error.toString())),
    );
  }

  Future<void> _fetchRecentActivities() async {
    await safeRun(
      action: () async {
        final Either<Failure, List<RecentActivity>> result = await _dashboardRepository.getRecentActivities().run();
        result.fold(
          _failureHandler.handleFailure,
          (List<RecentActivity> data) =>
              safeEmit(stateValue.copyWith(activities: data, status: const QueryStatus.done())),
        );
      },
      onException: (Exception error, StackTrace? stackTrace) =>
          _failureHandler.handleFailure(Failure.unexpected(error.toString())),
    );
  }

  Future<void> _fetchOverviewChartData() async {
    // We mock the first fetch with delay to match the previous repository behavior
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    // Since _simulateFilterUpdate handles the overview and reports chart data, we just call it.
    unawaited(_simulateFilterUpdate());
    safeEmit(stateValue.copyWith(status: const QueryStatus.done()));
  }
}

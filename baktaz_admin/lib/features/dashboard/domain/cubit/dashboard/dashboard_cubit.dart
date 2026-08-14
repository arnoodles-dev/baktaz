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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._dashboardRepository, this._failureHandler) : super(DashboardState.initial());

  final IDashboardRepository _dashboardRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    safeEmit(state.copyWith(status: const QueryStatus.loading()));

    unawaited(_fetchRecentActivities());
    unawaited(_fetchOverviewChartData());
  }

  void setActivityFilter(ActivityFilter filter) {
    if (state.selectedActivityFilter == filter) return;

    safeEmit(
      state.copyWith(
        selectedActivityFilter: filter,
        selectedReportStatusFilter: ActivityStatusFilter.all,
        filterStatus: const QueryStatus.loading(),
      ),
    );

    unawaited(_simulateFilterUpdate());
  }

  void setTimeFilter(TimeFilter filter) {
    if (state.selectedTimeFilter == filter) return;

    safeEmit(state.copyWith(selectedTimeFilter: filter, filterStatus: const QueryStatus.loading()));

    unawaited(_simulateFilterUpdate());
  }

  void setReportStatusFilter(ActivityStatusFilter filter) {
    if (state.selectedReportStatusFilter == filter) return;

    safeEmit(state.copyWith(selectedReportStatusFilter: filter, filterStatus: const QueryStatus.loading()));

    unawaited(_simulateFilterUpdate());
  }

  Future<void> _simulateFilterUpdate() async {
    final ActivityFilter activityFilter = state.selectedActivityFilter;
    final TimeFilter timeFilter = state.selectedTimeFilter;
    final ActivityStatusFilter reportStatusFilter = state.selectedReportStatusFilter;

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
          state.copyWith(
            filterStatus: const QueryStatus.done(),
            overviewChart: overviewResult.getRight().toNullable(),
            reportsChart: reportsResult.getRight().toNullable(),
            stats: statsResult.getRight().toNullable(),
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
          (List<RecentActivity> data) => safeEmit(state.copyWith(activities: data, status: const QueryStatus.done())),
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
    safeEmit(state.copyWith(status: const QueryStatus.done()));
  }
}

import 'package:baktaz_admin/features/dashboard/data/repository/dashboard_repository.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  late DashboardRepository repository;

  setUp(() {
    repository = const DashboardRepository();
  });

  group('getRecentActivities', () {
    test('returns list of 8 recent activities', () async {
      final Either<Failure, List<RecentActivity>> result = await repository.getRecentActivities().run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (List<RecentActivity> activities) {
        expect(activities, hasLength(8));
        expect(activities.first.id, isA<UniqueId>());
        expect(activities.first.name, isA<ValueName>());
        expect(activities.first.totalAmount, isA<Money>());
        expect(activities.first.status, isA<ActivityStatus>());
      });
    });
  });

  group('getDashboardStats', () {
    test('returns stats for today filter', () async {
      final Either<Failure, DashboardStats> result = await repository
          .getDashboardStats(timeFilter: TimeFilter.today)
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (DashboardStats stats) {
        expect(stats.totalActivities, isA<Number>());
        expect(stats.ongoingActivities, isA<Number>());
        expect(stats.completedActivities, isA<Number>());
        expect(stats.totalRevenue, isA<Money>());
      });
    });

    test('returns stats for last7Days filter', () async {
      final Either<Failure, DashboardStats> result = await repository
          .getDashboardStats(timeFilter: TimeFilter.last7Days)
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (_) {});
    });

    test('returns stats for last30Days filter', () async {
      final Either<Failure, DashboardStats> result = await repository
          .getDashboardStats(timeFilter: TimeFilter.last30Days)
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (_) {});
    });
  });

  group('getOverviewChartData', () {
    test('returns daily stats for all activities', () async {
      final Either<Failure, List<DailyActivityStats>> result = await repository
          .getOverviewChartData(timeFilter: TimeFilter.last7Days, activityFilter: ActivityFilter.all)
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (List<DailyActivityStats> data) {
        expect(data, isNotEmpty);
        expect(data.first.dayIndex, isA<Number>());
        expect(data.first.inProgress, isA<Number>());
        expect(data.first.completed, isA<Number>());
      });
    });

    test('returns daily stats filtered by hero', () async {
      final Either<Failure, List<DailyActivityStats>> result = await repository
          .getOverviewChartData(timeFilter: TimeFilter.last7Days, activityFilter: ActivityFilter.hero)
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (_) {});
    });
  });

  group('getReportsChartData', () {
    test('returns category stats for all filters', () async {
      final Either<Failure, CategoryReportStats> result = await repository
          .getReportsChartData(
            timeFilter: TimeFilter.last7Days,
            activityFilter: ActivityFilter.all,
            statusFilter: ActivityStatusFilter.all,
          )
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (CategoryReportStats stats) {
        expect(stats.hero, isA<Number>());
        expect(stats.express, isA<Number>());
        expect(stats.shop, isA<Number>());
        expect(stats.buy, isA<Number>());
      });
    });

    test('returns category stats with inProgress and express filter', () async {
      final Either<Failure, CategoryReportStats> result = await repository
          .getReportsChartData(
            timeFilter: TimeFilter.last7Days,
            activityFilter: ActivityFilter.express,
            statusFilter: ActivityStatusFilter.inProgress,
          )
          .run();

      result.fold((Failure l) => fail('Expected Right but got Left: $l'), (_) {});
    });
  });
}

import 'package:baktaz_admin/features/dashboard/domain/entity/category_report_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/daily_activity_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/dashboard_stats.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/time_filter.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_admin/features/dashboard/domain/interface/i_dashboard_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IDashboardRepository)
class DashboardRepository implements IDashboardRepository {
  const DashboardRepository();

  @override
  TaskResult<List<RecentActivity>> getRecentActivities() => TaskResult<List<RecentActivity>>.tryCatch(
    () async {
      // Mock loading with delay for at least 1-2 secs
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      final List<RecentActivity> activities = <RecentActivity>[
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8291'),
          date: DateTime(2023, 10, 24),
          name: ValueName('Urban Kayak Expedition'),
          customers: Number(2),
          customerAvatars: <Url>[
            Url(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDIMHWao_CS2tPJA9kfowqNyvvl48A5ifQ9tD0MTD1dyipIiF67w82DJPhtYv9_NIa3i4oDUrc-oxI0-CQRjkn0fzZgUftRL6fXJ3ark6ULKVhdGwJ1ieijaU6md6fY3sSxSbt_B2mxkaL8dU2O_i_BGyPoWVm1Q4R6vZZ_ZfI1R7w8E-wECBQ3ZtjGGhWZI_gGtHbxG69qvGE61KGFXXvV1VDNgvPlus3CnU_PLMu6qvoKs0tDb5XpQ-zj6RPX-kLwDfzDYxBOy48',
            ),
            Url(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDBZF4mkPr8mi4AEUT8jdZkm-5NuzudeTJgIeGmzwxZSW18z73U_NX-yj4znCq20RcvMQdXBG8-oOgjgvMaSHX2E1HnVAKZliY6ywL0ig8Z-L3VABZ2dYFFFG1nK7vnpypc0Qq8XZIHIBO3ukJq8dF91Tm8GyzUUAA_3Tu3nBaY-v-UkLeqq2Pd7xvVbPplqo7PoAnbZ_Nuws-n48gsXqjeONIoVLPTST9-GbRk8t_xL4UHpCkDtwsnlxWRyiByAfr6TGv_t7NQNEY',
            ),
          ],
          totalAmount: Money(450),
          status: ActivityStatus.completed,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8295'),
          date: DateTime(2023, 10, 25),
          name: ValueName('Sunset Yoga Session'),
          customers: Number(8),
          customerAvatars: <Url>[
            Url(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCsXIugvwc1SC7hDP7cxnjm5yYhMVLNLsRtRdQHbvzojwztmZCWlhE0Awxx2k0HGiU-BsXfi-G8mqKE-dp5An9Q-X0yfF8PK_1FBFH8PQBEucfqcExAzzggJPv2edKbs8FblzzVFJAHfRN1AchKRGRh1j5hVAgyGf5If1RHsIkUSJfp7wTX9mSqc5Tm8ajXuuQYgXk3QpQ6P28ZAzhrcNgHSbDiy7tlT_4JG_9QfSJHTIP-1dXFpWwdPn_Zmft5chj2e5vT_Uq9tas',
            ),
          ],
          totalAmount: Money(120),
          status: ActivityStatus.processing,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8298'),
          date: DateTime(2023, 10, 25),
          name: ValueName('Mountain Bike Tour'),
          customers: Number(1),
          customerAvatars: <Url>[
            Url(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDNk5flHewuK3nRnEHnzQCkUHvJFK9K0pzJfFD96cBcMeaqC31tVdTAfAk1tNagJaGeJ5guUfHlsHS3FQWcLRSGNy71-uW52d_KG0wGKEiXtyC-iPoryN270FOE1uPGwS2NMZvNkZuo02vzyLY4jcs-WeinkAM2e5DfRUSNcgObV5v2UVp8rOujcgiIN5tp_BmHIB0KFyRAw1FksJLXyu5YeOI6zFz0WzsDu_L9v4hkNDgxRmxvmWbCon2pK06EIsij4SSV4x-IlhA',
            ),
          ],
          totalAmount: Money(890),
          status: ActivityStatus.pending,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8301'),
          date: DateTime(2023, 10, 26),
          name: ValueName('City Walk'),
          customers: Number(3),
          customerAvatars: <Url>[],
          totalAmount: Money(300),
          status: ActivityStatus.completed,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8302'),
          date: DateTime(2023, 10, 26),
          name: ValueName('Forest Hike'),
          customers: Number(4),
          customerAvatars: <Url>[],
          totalAmount: Money(400),
          status: ActivityStatus.processing,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8303'),
          date: DateTime(2023, 10, 27),
          name: ValueName('River Rafting'),
          customers: Number(5),
          customerAvatars: <Url>[],
          totalAmount: Money(500),
          status: ActivityStatus.pending,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8304'),
          date: DateTime(2023, 10, 27),
          name: ValueName('Desert Safari'),
          customers: Number(6),
          customerAvatars: <Url>[],
          totalAmount: Money(600),
          status: ActivityStatus.completed,
        ),
        RecentActivity(
          id: UniqueId.fromUniqueString('#ACT-8305'),
          date: DateTime(2023, 10, 28),
          name: ValueName('Ski Resort Trip'),
          customers: Number(2),
          customerAvatars: <Url>[],
          totalAmount: Money(200),
          status: ActivityStatus.processing,
        ),
      ];
      for (final RecentActivity activity in activities) {
        if (activity.validate.isSome()) {
          throw activity.validate.asSome();
        }
      }
      return activities;
    },
    (Object error, StackTrace stackTrace) =>
        error is Failure ? error : const Failure.unexpected('Failed to fetch recent activities'),
  );

  @override
  TaskResult<DashboardStats> getDashboardStats({required TimeFilter timeFilter}) => TaskResult<DashboardStats>.tryCatch(
    () async {
      // Mock loading with delay for at least 1-2 secs
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      final List<_MockDayData> filteredData = _getFilteredMockData(timeFilter);
      int inProgress = 0;
      int completed = 0;
      for (final _MockDayData day in filteredData) {
        inProgress += day.heroInProgress + day.expressInProgress + day.shopInProgress + day.buyInProgress;
        completed += day.heroCompleted + day.expressCompleted + day.shopCompleted + day.buyCompleted;
      }
      final int total = inProgress + completed;
      final double revenue = total * 35.5; // Random formula for revenue based on total

      final DashboardStats possibleFailure = DashboardStats(
        totalActivities: Number(total),
        ongoingActivities: Number(inProgress),
        completedActivities: Number(completed),
        totalRevenue: Money(revenue),
        totalActivitiesGrowth: '+12% increase',
        ongoingActivitiesGrowth: '-2% decrease',
        completedActivitiesGrowth: '+5% increase',
        totalRevenueGrowth: '+15% increase',
      );

      if (possibleFailure.validate.isSome()) {
        throw possibleFailure.validate.asSome();
      }

      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) =>
        error is Failure ? error : const Failure.unexpected('Failed to fetch dashboard stats'),
  );

  @override
  TaskResult<List<DailyActivityStats>> getOverviewChartData({
    required TimeFilter timeFilter,
    required ActivityFilter activityFilter,
  }) => TaskResult<List<DailyActivityStats>>.tryCatch(
    () async {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final List<_MockDayData> filteredData = _getFilteredMockData(timeFilter);

      return filteredData.map((_MockDayData day) {
        int inProgress = 0;
        int completed = 0;

        if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.hero) {
          inProgress += day.heroInProgress;
          completed += day.heroCompleted;
        }
        if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.express) {
          inProgress += day.expressInProgress;
          completed += day.expressCompleted;
        }
        if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.shop) {
          inProgress += day.shopInProgress;
          completed += day.shopCompleted;
        }
        if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.buy) {
          inProgress += day.buyInProgress;
          completed += day.buyCompleted;
        }

        final DailyActivityStats possibleFailure = DailyActivityStats(
          dayIndex: Number(day.dayIndex),
          inProgress: Number(inProgress),
          completed: Number(completed),
        );
        if (possibleFailure.validate.isSome()) {
          throw possibleFailure.validate.asSome();
        }
        return possibleFailure;
      }).toList();
    },
    (Object error, StackTrace stackTrace) =>
        error is Failure ? error : const Failure.unexpected('Failed to fetch overview chart data'),
  );

  @override
  TaskResult<CategoryReportStats> getReportsChartData({
    required TimeFilter timeFilter,
    required ActivityFilter activityFilter,
    required ActivityStatusFilter statusFilter,
  }) => TaskResult<CategoryReportStats>.tryCatch(
    () async {
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final List<_MockDayData> filteredData = _getFilteredMockData(timeFilter);
      int totalHero = 0;
      int totalExpress = 0;
      int totalShop = 0;
      int totalBuy = 0;

      for (final _MockDayData day in filteredData) {
        if (statusFilter == ActivityStatusFilter.all || statusFilter == ActivityStatusFilter.inProgress) {
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.hero) {
            totalHero += day.heroInProgress;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.express) {
            totalExpress += day.expressInProgress;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.shop) {
            totalShop += day.shopInProgress;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.buy) {
            totalBuy += day.buyInProgress;
          }
        }
        if (statusFilter == ActivityStatusFilter.all || statusFilter == ActivityStatusFilter.completed) {
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.hero) {
            totalHero += day.heroCompleted;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.express) {
            totalExpress += day.expressCompleted;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.shop) {
            totalShop += day.shopCompleted;
          }
          if (activityFilter == ActivityFilter.all || activityFilter == ActivityFilter.buy) {
            totalBuy += day.buyCompleted;
          }
        }
      }

      final CategoryReportStats possibleFailure = CategoryReportStats(
        hero: Number(totalHero),
        express: Number(totalExpress),
        shop: Number(totalShop),
        buy: Number(totalBuy),
      );
      if (possibleFailure.validate.isSome()) {
        throw possibleFailure.validate.asSome();
      }
      return possibleFailure;
    },
    (Object error, StackTrace stackTrace) =>
        error is Failure ? error : const Failure.unexpected('Failed to fetch reports chart data'),
  );

  List<_MockDayData> _getFilteredMockData(TimeFilter timeFilter) {
    if (timeFilter == TimeFilter.today) {
      return _rawMockData.take(6).toList();
    } else if (timeFilter == TimeFilter.last7Days) {
      return _rawMockData.take(7).toList();
    } else if (timeFilter == TimeFilter.last30Days) {
      final List<_MockDayData> thirtyDays = _rawMockData.take(30).toList();
      final List<_MockDayData> aggregated = <_MockDayData>[];
      for (int weekIndex = 0; weekIndex < 4; weekIndex++) {
        final int start = weekIndex * 7;
        final int end = weekIndex == 3 ? 30 : (weekIndex + 1) * 7;
        final List<_MockDayData> weekDays = thirtyDays.sublist(start, end);

        int heroInProg = 0;
        int heroComp = 0;
        int expressInProg = 0;
        int expressComp = 0;
        int shopInProg = 0;
        int shopComp = 0;
        int buyInProg = 0;
        int buyComp = 0;
        for (final _MockDayData day in weekDays) {
          heroInProg += day.heroInProgress;
          heroComp += day.heroCompleted;
          expressInProg += day.expressInProgress;
          expressComp += day.expressCompleted;
          shopInProg += day.shopInProgress;
          shopComp += day.shopCompleted;
          buyInProg += day.buyInProgress;
          buyComp += day.buyCompleted;
        }
        aggregated.add(
          _MockDayData(
            dayIndex: weekIndex,
            heroInProgress: heroInProg,
            heroCompleted: heroComp,
            expressInProgress: expressInProg,
            expressCompleted: expressComp,
            shopInProgress: shopInProg,
            shopCompleted: shopComp,
            buyInProgress: buyInProg,
            buyCompleted: buyComp,
          ),
        );
      }
      return aggregated;
    }
    return _rawMockData.take(7).toList();
  }
}

class _MockDayData {
  const _MockDayData({
    required this.dayIndex,
    required this.heroInProgress,
    required this.heroCompleted,
    required this.expressInProgress,
    required this.expressCompleted,
    required this.shopInProgress,
    required this.shopCompleted,
    required this.buyInProgress,
    required this.buyCompleted,
  });

  final int dayIndex;
  final int heroInProgress;
  final int heroCompleted;
  final int expressInProgress;
  final int expressCompleted;
  final int shopInProgress;
  final int shopCompleted;
  final int buyInProgress;
  final int buyCompleted;
}

final List<_MockDayData> _rawMockData = List<_MockDayData>.generate(
  30,
  (int index) => _MockDayData(
    dayIndex: index,
    heroInProgress: (index * 2) % 15 + 10,
    heroCompleted: (index * 3) % 25 + 20,
    expressInProgress: (index * 4) % 10 + 5,
    expressCompleted: (index * 2) % 20 + 15,
    shopInProgress: (index * 1) % 5 + 2,
    shopCompleted: (index * 5) % 15 + 10,
    buyInProgress: (index * 3) % 12 + 8,
    buyCompleted: (index * 4) % 30 + 25,
  ),
);

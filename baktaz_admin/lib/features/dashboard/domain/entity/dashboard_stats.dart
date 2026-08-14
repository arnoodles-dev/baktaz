import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalActivities,
    required this.ongoingActivities,
    required this.completedActivities,
    required this.totalRevenue,
    this.totalActivitiesGrowth,
    this.ongoingActivitiesGrowth,
    this.completedActivitiesGrowth,
    this.totalRevenueGrowth,
  });

  final Number totalActivities;
  final Number ongoingActivities;
  final Number completedActivities;
  final Money totalRevenue;
  final String? totalActivitiesGrowth;
  final String? ongoingActivitiesGrowth;
  final String? completedActivitiesGrowth;
  final String? totalRevenueGrowth;

  Option<Failure> get validate => totalActivities.validate
      .andThen(() => ongoingActivities.validate)
      .andThen(() => completedActivities.validate)
      .andThen(() => totalRevenue.validate)
      .fold(some, (_) => none());
}

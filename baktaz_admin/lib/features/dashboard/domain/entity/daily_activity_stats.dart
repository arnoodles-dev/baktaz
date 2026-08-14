import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

class DailyActivityStats {
  const DailyActivityStats({required this.dayIndex, required this.inProgress, required this.completed});

  final Number dayIndex;
  final Number inProgress;
  final Number completed;

  Option<Failure> get validate =>
      dayIndex.validate.andThen(() => inProgress.validate).andThen(() => completed.validate).fold(some, (_) => none());
}

import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.date,
    required this.name,
    required this.customers,
    required this.customerAvatars,
    required this.totalAmount,
    required this.status,
  });

  final UniqueId id;
  final DateTime date;
  final ValueName name;
  final Number customers;
  final List<Url> customerAvatars;
  final Money totalAmount;
  final ActivityStatus status;

  Option<Failure> get validate => id.validate
      .andThen(() => name.validate)
      .andThen(() => customers.validate)
      .andThen(() => totalAmount.validate)
      .andThen(() {
        for (final Url avatar in customerAvatars) {
          final Either<Failure, Unit> result = avatar.validate;
          if (result.isLeft()) return result;
        }
        return right(unit);
      })
      .fold(some, (_) => none());
}

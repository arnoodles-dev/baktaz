import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

/// Domain repository interface for user account and profile operations in Flutter client app.
abstract interface class IAccountRepository {
  /// Retrieves account summary details ([AccountSummary]).
  TaskResult<AccountSummary> getAccountSummary();

  /// Retrieves user profile details ([Profile]).
  TaskResult<Profile> getProfile();

  /// Adds a new user [address].
  TaskResult<Unit> addAddress(Address address);

  /// Retrieves the default user address if available.
  TaskResult<Address?> getDefaultAddress();

  /// Deletes the user account.
  TaskResult<Unit> deleteAccount();
}

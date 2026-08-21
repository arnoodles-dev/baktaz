import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAccountRepository {
  TaskResult<AccountSummary> getAccountSummary();
  TaskResult<Profile> getProfile();
  TaskResult<Unit> addAddress(Address address);
  TaskResult<Address?> getDefaultAddress();
  TaskResult<Unit> deleteAccount();
}

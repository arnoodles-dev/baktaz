import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Repository interface for account operations on serverpod backend.
abstract interface class IAccountRepository {
  /// Fetches [AccountSummary] for specified [userId].
  Future<AccountSummary> getAccountSummary(Session session, UuidValue userId);

  /// Retrieves the [Account] entity for specified [userId].
  Future<Account?> getCurrentAccount(Session session, UuidValue userId);

  /// Deletes account associated with specified [userId].
  Future<void> deleteAccount(Session session, UuidValue userId);
}

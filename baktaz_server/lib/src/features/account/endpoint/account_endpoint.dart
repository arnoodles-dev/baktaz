import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Endpoint for account management operations such as summary fetching and account deletion.
final class AccountEndpoint extends Endpoint {
  /// Creates an [AccountEndpoint] instance with optional repository override.
  AccountEndpoint([IAccountRepository? accountRepository])
    : _accountRepository = accountRepository ?? getIt<IAccountRepository>();

  final IAccountRepository _accountRepository;

  @override
  bool get requireLogin => true;

  /// Retrieves summary information ([AccountSummary]) for the currently authenticated user.
  Future<AccountSummary> getSummary(Session session) async {
    final UuidValue userId = session.authenticated!.authUserId;
    session.log('Fetching account summary for user $userId');
    return _accountRepository.getAccountSummary(session, userId);
  }

  /// Retrieves the full [Account] entity for the currently authenticated user.
  Future<Account?> getCurrentAccount(Session session) async {
    final UuidValue userId = session.authenticated!.authUserId;
    session.log('Fetching current account for user $userId');
    return _accountRepository.getCurrentAccount(session, userId);
  }

  /// Deletes the account of the currently authenticated user.
  Future<void> deleteAccount(Session session) async {
    final UuidValue userId = session.authenticated!.authUserId;
    session.log('Deleting account for user $userId');
    return _accountRepository.deleteAccount(session, userId);
  }
}

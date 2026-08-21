import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:injectable/injectable.dart' hide Scope;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IAdminRepository)
final class AdminRepository implements IAdminRepository {
  AdminRepository(this._securityLogger);

  final SecurityLogger _securityLogger;

  @override
  Future<List<AdminUser>> listAdminUsers(Session session) async {
    final List<UserProfileModel> userProfiles = await AuthServices.instance.userProfiles.admin.listUserProfiles(
      session,
    );
    if (userProfiles.isEmpty) {
      return <AdminUser>[];
    }

    final List<AuthUserModel> authUsers = await Future.wait(
      userProfiles.map(
        (UserProfileModel userProfile) =>
            AuthServices.instance.authUsers.get(session, authUserId: userProfile.authUserId),
      ),
    );

    return List<AdminUser>.generate(
      userProfiles.length,
      (int index) => (authUser: authUsers[index], userProfile: userProfiles[index]),
    );
  }

  @override
  Future<List<AuthUserModel>> listAuthUsers(Session session) async => AuthServices.instance.authUsers.list(session);

  @override
  Future<void> blockUser(Session session, UuidValue authUserId) async {
    await AuthServices.instance.authUsers.update(session, authUserId: authUserId, blocked: true);
    await _securityLogger.log(session, 'admin_block', authUserId: authUserId);
  }

  @override
  Future<void> unblockUser(Session session, UuidValue authUserId) async {
    await AuthServices.instance.authUsers.update(session, authUserId: authUserId, blocked: false);
    await _securityLogger.log(session, 'admin_unblock', authUserId: authUserId);
  }

  @override
  Future<void> updateUserScope(Session session, UuidValue authUserId, Set<Scope> scopes) async {
    await AuthServices.instance.authUsers.update(session, authUserId: authUserId, scopes: scopes);
    await _securityLogger.log(
      session,
      'admin_scope_change',
      authUserId: authUserId,
      metadata: '{"scopes": "${scopes.map((Scope s) => s.name).toList()}"}',
    );
  }
}

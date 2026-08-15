import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

typedef AdminUser = ({AuthUserModel authUser, UserProfileModel userProfile});

abstract interface class IAdminRepository {
  Future<List<AdminUser>> listAdminUsers(Session session);
  Future<List<AuthUserModel>> listAuthUsers(Session session);
  Future<void> blockUser(Session session, UuidValue authUserId);
  Future<void> unblockUser(Session session, UuidValue authUserId);
  Future<void> updateUserScope(Session session, UuidValue authUserId, Set<Scope> scopes);
}

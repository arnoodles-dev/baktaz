import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/core/endpoint/admin_endpoint_base.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

class AdminEndpoint extends AdminEndpointBase {
  AdminEndpoint([IAdminRepository? adminService]) : _adminService = adminService ?? getIt<IAdminRepository>();

  final IAdminRepository _adminService;

  Future<List<AdminUser>> listAdminUsers(Session session) async => _adminService.listAdminUsers(session);

  Future<List<AuthUserModel>> listAuthUsers(Session session) async => _adminService.listAuthUsers(session);

  Future<void> blockUser(Session session, UuidValue authUserId) async => _adminService.blockUser(session, authUserId);

  Future<void> unblockUser(Session session, UuidValue authUserId) async =>
      _adminService.unblockUser(session, authUserId);

  Future<void> updateUserScope(Session session, UuidValue authUserId, List<String> scopeNames) async {
    if (scopeNames.isEmpty) {
      throw Exception('Scope names list cannot be empty');
    }
    return _adminService.updateUserScope(session, authUserId, scopeNames.map(Scope.new).toSet());
  }
}

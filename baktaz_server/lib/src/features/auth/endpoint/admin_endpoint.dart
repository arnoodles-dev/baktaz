import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/core/endpoint/admin_endpoint_base.dart';
import 'package:baktaz_server/src/features/auth/data/repository/admin_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

class AdminEndpoint extends AdminEndpointBase {
  AdminEndpoint([IAdminRepository? adminRepository])
    : _adminRepository =
          adminRepository ??
          (getIt.isRegistered<IAdminRepository>()
              ? getIt<IAdminRepository>()
              : AdminRepository(getIt.isRegistered<SecurityLogger>() ? getIt<SecurityLogger>() : SecurityLogger()));

  final IAdminRepository _adminRepository;

  Future<List<AdminUser>> listAdminUsers(Session session) async => _adminRepository.listAdminUsers(session);

  Future<List<AuthUserModel>> listAuthUsers(Session session) async => _adminRepository.listAuthUsers(session);

  Future<void> blockUser(Session session, UuidValue authUserId) async => _adminRepository.blockUser(session, authUserId);

  Future<void> unblockUser(Session session, UuidValue authUserId) async =>
      _adminRepository.unblockUser(session, authUserId);

  Future<void> updateUserScope(Session session, UuidValue authUserId, List<String> scopeNames) async {
    if (scopeNames.isEmpty) {
      throw ApiException(message: 'Scope names list cannot be empty', code: ApiExceptionCode.badRequest);
    }
    return _adminRepository.updateUserScope(session, authUserId, scopeNames.map(Scope.new).toSet());
  }
}

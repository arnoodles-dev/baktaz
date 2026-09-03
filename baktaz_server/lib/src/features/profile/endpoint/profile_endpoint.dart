import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/profile/domain/interface/i_profile_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Endpoint for user profile management including retrieving, updating profiles, and checking username availability.
final class ProfileEndpoint extends Endpoint {
  /// Creates a [ProfileEndpoint] instance with optional repository override.
  ProfileEndpoint([IProfileRepository? profileRepository])
    : _profileRepository = profileRepository ?? getIt<IProfileRepository>();

  final IProfileRepository _profileRepository;

  @override
  bool get requireLogin => true;

  /// Fetches [UserInfo] profile details for the currently authenticated user.
  Future<UserInfo?> getProfile(Session session) async {
    final UuidValue userId = session.authenticated!.authUserId;
    return _profileRepository.getUserInfo(session, userId);
  }

  /// Updates profile information ([firstName], [lastName], [username]) for the currently authenticated user.
  Future<UserInfo?> updateProfile(
    Session session,
    String? firstName,
    String? lastName,
    String? username,
  ) async {
    final UuidValue userId = session.authenticated!.authUserId;
    session.log('Updating profile for user $userId');
    if (firstName != null && firstName.trim().isEmpty) {
      throw ApiException(message: 'First name cannot be empty', code: ApiExceptionCode.badRequest);
    }
    if (lastName != null && lastName.trim().isEmpty) {
      throw ApiException(message: 'Last name cannot be empty', code: ApiExceptionCode.badRequest);
    }
    if (username != null) {
      final String trimmedUsername = username.trim();
      if (trimmedUsername.length < 3 || trimmedUsername.length > 30) {
        throw ApiException(
          message: 'Username must be between 3 and 30 characters',
          code: ApiExceptionCode.badRequest,
        );
      }
    }
    return _profileRepository.updateProfile(session, userId, firstName, lastName, username);
  }

  /// Checks whether [username] is available for registration or update.
  Future<bool> checkUsernameAvailability(Session session, String username) async =>
      _profileRepository.isUsernameAvailable(session, username);
}

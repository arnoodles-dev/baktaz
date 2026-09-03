import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Repository interface for user profile operations on serverpod backend.
abstract interface class IProfileRepository {
  /// Fetches [UserInfo] profile by [userId].
  Future<UserInfo?> getUserInfo(Session session, UuidValue userId);

  /// Updates profile details ([firstName], [lastName], [username]) for specified [userId].
  Future<UserInfo?> updateProfile(
    Session session,
    UuidValue userId,
    String? firstName,
    String? lastName,
    String? username,
  );

  /// Returns true if [username] is available for specified session.
  Future<bool> isUsernameAvailable(Session session, String username);
}

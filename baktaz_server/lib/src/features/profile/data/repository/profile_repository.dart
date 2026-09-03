import 'package:baktaz_server/src/app/utils/username_utils.dart';
import 'package:baktaz_server/src/features/profile/domain/interface/i_profile_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

@LazySingleton(as: IProfileRepository)
final class ProfileRepository implements IProfileRepository {
  @override
  Future<UserInfo?> getUserInfo(Session session, UuidValue userId) async {
    final UserInfo? userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.userIdentifier.equals(userId),
    );
    if (userInfo != null) return userInfo;

    final Account? account = await Account.db.findFirstRow(
      session,
      where: (AccountTable t) => t.authUserId.equals(userId),
      include: Account.include(userInfo: UserInfo.include()),
    );
    return account?.userInfo;
  }

  @override
  Future<bool> isUsernameAvailable(Session session, String username) async {
    final String cleanUsername = UsernameUtils.sanitizeUsername(username);
    final UserInfo? existing = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.username.equals(cleanUsername),
    );
    return existing == null;
  }

  @override
  Future<UserInfo?> updateProfile(
    Session session,
    UuidValue userId,
    String? firstName,
    String? lastName,
    String? username,
  ) async {
    final UserInfo? existingInfo = await getUserInfo(session, userId);
    if (existingInfo == null) {
      throw ApiException(message: 'User profile not found', code: ApiExceptionCode.notFound);
    }

    String? newUsername = existingInfo.username;
    if (username != null && username.trim().isNotEmpty) {
      final String sanitized = UsernameUtils.sanitizeUsername(username);
      if (sanitized != existingInfo.username) {
        final bool available = await isUsernameAvailable(session, sanitized);
        if (!available) {
          throw ApiException(message: 'Username is already taken', code: ApiExceptionCode.badRequest);
        }
        newUsername = sanitized;
      }
    }

    final UserInfo updated = existingInfo.copyWith(
      firstName: firstName ?? existingInfo.firstName,
      lastName: lastName ?? existingInfo.lastName,
      username: newUsername,
      updatedAt: DateTime.now(),
    );

    return UserInfo.db.updateRow(session, updated);
  }
}

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

extension SessionExt on Session {
  String get authId {
    final String? authUserId = authenticated?.authUserId.toString();
    if (authUserId == null) {
      throw Exception('User is not authenticated');
    }
    return authUserId;
  }
}

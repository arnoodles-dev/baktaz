import 'package:baktaz_server/src/core/endpoint/admin_endpoint_base.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class SecurityEndpoint extends AdminEndpointBase {
  Future<List<SecurityEvent>> listSecurityEvents(
    Session session, {
    int limit = 50,
    int offset = 0,
    String? eventType,
    UuidValue? authUserId,
  }) async {
    Expression<dynamic> Function(SecurityEventTable t)? where;
    if (eventType != null && authUserId != null) {
      where = (SecurityEventTable t) => t.eventType.equals(eventType) & t.authUserId.equals(authUserId);
    } else if (eventType != null) {
      where = (SecurityEventTable t) => t.eventType.equals(eventType);
    } else if (authUserId != null) {
      where = (SecurityEventTable t) => t.authUserId.equals(authUserId);
    }

    return SecurityEvent.db.find(
      session,
      where: where,
      limit: limit,
      offset: offset,
      orderBy: (SecurityEventTable t) => t.createdAt.desc(),
    );
  }
}

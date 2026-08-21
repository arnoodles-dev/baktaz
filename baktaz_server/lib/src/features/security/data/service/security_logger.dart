import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

@lazySingleton
class SecurityLogger {
  Future<void> log(
    Session session,
    String eventType, {
    UuidValue? authUserId,
    String? metadata,
    Transaction? transaction,
  }) async {
    try {
      final SecurityEvent event = SecurityEvent(
        authUserId: authUserId,
        eventType: eventType,
        metadata: metadata,
        createdAt: DateTime.now(),
      );
      await SecurityEvent.db.insertRow(session, event, transaction: transaction);
    } on Exception catch (e) {
      session.log('Failed to record security event: $e', level: LogLevel.warning);
    }
  }
}

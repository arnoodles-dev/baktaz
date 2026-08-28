# Chat Module — Server Endpoints, Repository & System Events

- **Date**: 2026-08-24
- **Updated**: 2026-08-28 (Unread status computation & mark-read endpoints, IEventRepository dispatch architecture, Presigned upload URL)
- **Parent spec**: `2026-08-24-00-overview.md`
- **Package**: `baktaz_server`

## MessageEndpoint, EventAdminEndpoint, EventRepository, Real-Time Architecture

### 3.3 MessageEndpoint

File: `baktaz_server/lib/src/features/message/endpoint/message_endpoint.dart`

```dart
final class MessageEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the chat room for the user's active challenge, or null.
  Future<ChatRoom?> getChatRoom(Session session, UuidValue challengeId) async;

  /// Returns computed unread chat message and system event counts for the user.
  Future<ChatUnreadStatus> getUnreadCounts(Session session, UuidValue challengeId) async;

  /// Marks chat messages as read for user (updates lastReadMessageAt = DateTime.now()).
  Future<void> markMessagesRead(Session session, UuidValue chatRoomId) async;

  /// Marks system events as read for user (updates lastReadEventAt = DateTime.now()).
  Future<void> markEventsRead(Session session, UuidValue challengeId) async;

  /// Request a presigned S3 upload URL for direct client photo upload.
  Future<UploadIntent> getUploadUrl(
    Session session,
    UuidValue chatRoomId,
    String mimeType,
    int sizeBytes,
  ) async;

  /// Send a chat message (text, photo attachments, or both).
  Future<ChatMessage> sendChatMessage(
    Session session,
    UuidValue chatRoomId,
    String? content,
    List<ChatAttachment>? attachments,
  ) async;

  /// Paginated history — oldest first. limit defaults to 50.
  Future<List<ChatMessage>> getChatHistory(
    Session session,
    UuidValue chatRoomId,
    {int limit = 50, DateTime? before}
  ) async;

  /// Paginated system event history for Events tab.
  Future<List<EventMessage>> getEventHistory(
    Session session,
    UuidValue challengeId,
    {int limit = 50, DateTime? before}
  ) async;

  /// Stream: real-time user messages (ChatMessage).
  Stream<ChatMessage> watchChatMessages(Session session, UuidValue chatRoomId) async*;

  /// Stream: system events (EventMessage).
  Stream<EventMessage> watchSystemEvents(Session session, UuidValue challengeId) async*;

  /// Returns room participants with online presence.
  Future<List<ChatParticipant>> getChatParticipants(Session session, UuidValue chatRoomId) async;

  /// Client heartbeat — call every presenceHeartbeatInterval while chat is open.
  Future<void> pingPresence(Session session) async;
}
```

### 3.4 EventAdminEndpoint (Admin Management)

File: `baktaz_server/lib/src/features/message/endpoint/event_admin_endpoint.dart`

```dart
final class EventAdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<List<EventTemplate>> listEventTemplates(Session session) async;
  Future<EventTemplate> updateEventTemplate(Session session, EventTemplate template) async;
  Future<EventTemplate> resetEventTemplate(Session session, String eventKey) async;
}
```

### 3.5 Session Extension for Broadcasting

File: `baktaz_server/lib/src/features/message/domain/extensions/session_extensions.dart`

```dart
extension ChatRoomMessageExtension on Session {
  void broadcastChatMessage(UuidValue chatRoomId, ChatMessage message) {
    postMessage('chat_room_messages_${chatRoomId.uuid}', message);
  }

  void broadcastSystemEvent(UuidValue challengeId, EventMessage event) {
    postMessage('challenge_events_${challengeId.uuid}', event);
  }
}
```

### 3.6 EventRepository Dispatch Architecture

File: `baktaz_server/lib/src/features/message/domain/interface/i_event_repository.dart`

Per `.agents/rules/serverpod-architecture.md`, system event triggering lives in `IEventRepository` / `EventRepository` (data layer), NOT a separate service. Other feature repositories (`ChallengeRepository`, `StepsRepository`, `PaymentRepository`) inject `IEventRepository` and call `dispatchEvent()`.

```dart
abstract interface class IEventRepository {
  Future<EventMessage?> dispatchEvent(
    Session session, {
    required UuidValue challengeId,
    required String eventKey,
    Map<String, dynamic>? payload,
  });

  Future<List<EventMessage>> getEventHistory(
    Session session,
    UuidValue challengeId, {
    int limit = 50,
    DateTime? before,
  });
}
```

---

### 3.7 Server-Side Unread Count Computation

When `getUnreadCounts(session, challengeId)` is called:
1. Server finds `ChatParticipant` row for `(chatRoomId, userId)`.
2. `unreadChatCount` = `SELECT COUNT(*) FROM chat_message WHERE chatRoomId = :roomId AND createdAt > :lastReadMessageAt` (or 0 if `lastReadMessageAt == null`).
3. `unreadEventsCount` = `SELECT COUNT(*) FROM event_message WHERE challengeId = :challengeId AND createdAt > :lastReadEventAt` (or 0 if `lastReadEventAt == null`).
4. Returns `ChatUnreadStatus(unreadChatCount: x, unreadEventsCount: y)`.

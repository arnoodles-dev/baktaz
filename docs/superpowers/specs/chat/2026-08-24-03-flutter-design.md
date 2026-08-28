# Chat Module — Flutter Design (Entities, Repository, Cubit, Unread Badges)

- **Date**: 2026-08-24
- **Updated**: 2026-08-28 (Photo attachments, S3 upload flow, EventMessage separation, End-to-End Unread Sync)
- **Parent spec**: `2026-08-24-00-overview.md`
- **Package**: `baktaz_flutter`

## 4. Flutter Design

### 4.1 Directory Structure

```
baktaz_flutter/lib/features/message/
├── cubit/
│   ├── chat_cubit.dart
│   └── chat_state.dart
├── entity/
│   ├── chat_message.dart
│   ├── chat_attachment.dart
│   ├── event_message.dart
│   ├── chat_room.dart
│   └── chat_participant.dart
├── repository/
│   └── chat_repository.dart
├── interface/
│   └── i_chat_repository.dart
└── presentation/
    ├── views/
    │   ├── chat_page.dart
    │   └── events_page.dart
    └── widgets/
        ├── message_tile.dart
        ├── message_input_bar.dart
        ├── attachment_picker_preview.dart
        ├── room_header.dart
        ├── participant_side_panel.dart
        └── empty_chat_page.dart
```

### 4.2 Entities (Freezed)

**`chat_message.dart`**
```dart
@freezed
abstract class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String id,
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required Url? senderAvatarUrl,
    required String? content,
    required List<AttachmentEntity> attachments,
    required DateTime createdAt,
  }) = _MessageEntity;

  factory MessageEntity.fromServer(ChatMessage server);
  Option<Failure> get validate;
}
```

**`chat_attachment.dart`**
```dart
@freezed
abstract class AttachmentEntity with _$AttachmentEntity {
  const factory AttachmentEntity({
    required String id,
    required String chatMessageId,
    required Url url,
    required Url? thumbnailUrl,
    required String mediaType,
    required int sizeBytes,
    required int? width,
    required int? height,
    required DateTime createdAt,
  }) = _AttachmentEntity;

  factory AttachmentEntity.fromServer(ChatAttachment server);
  Option<Failure> get validate;
}
```

**`event_message.dart`**
```dart
@freezed
abstract class EventMessageEntity with _$EventMessageEntity {
  const factory EventMessageEntity({
    required String id,
    required String challengeId,
    required String eventKey,
    required String title,
    required String body,
    required String? icon,
    required Map<String, dynamic>? payload,
    required DateTime createdAt,
  }) = _EventMessageEntity;

  factory EventMessageEntity.fromServer(EventMessage server);
  Option<Failure> get validate;
}
```

### 4.3 Flutter Repository

**`i_message_repository.dart`**
```dart
abstract interface class IMessageRepository {
  Future<RoomEntity?> getChatRoom(UuidValue challengeId);
  Future<ChatUnreadStatus> getUnreadCounts(UuidValue challengeId);
  Future<void> markMessagesRead(UuidValue chatRoomId);
  Future<void> markEventsRead(UuidValue challengeId);
  Future<UploadIntent> getUploadUrl({
    required UuidValue chatRoomId,
    required String mimeType,
    required int sizeBytes,
  });
  Future<MessageEntity> sendMessage({
    required UuidValue chatRoomId,
    String? content,
    List<AttachmentEntity>? attachments,
  });
  Future<(List<MessageEntity>, bool)> getChatMessages({
    required UuidValue chatRoomId,
    required int limit,
    DateTime? before,
  });
  Future<(List<EventMessageEntity>, bool)> getEventHistory({
    required UuidValue challengeId,
    required int limit,
    DateTime? before,
  });
  Stream<MessageEntity> watchChatMessages(UuidValue chatRoomId);
  Stream<EventMessageEntity> watchSystemEvents(UuidValue challengeId);
  Future<List<ParticipantEntity>> getChatParticipants(UuidValue chatRoomId);
  Future<void> pingPresence();
}
```

### 4.4 Photo Upload Workflow (Client-Side)

1. User selects 1–5 images via `ImagePicker`.
2. Client compresses images locally using `flutter_image_compress` (1080p, 80% JPEG, max 2MB).
3. Client requests presigned URL: `repository.getUploadUrl(chatRoomId, mimeType, sizeBytes)`.
4. Client uploads compressed bytes directly to S3 via HTTP PUT.
5. Client calls `sendMessage(chatRoomId, content, attachments)`.
6. Message inserts to DB and broadcasts over WebSocket stream to all room members.

---

### 4.5 Unread Badge State & Server Sync (`MessageCubit`)

**`MessageState` Unread Fields:**
```dart
@freezed
sealed class MessageState with _$MessageState {
  const factory MessageState({
    required QueryStatus roomStatus,
    required QueryStatus messagesStatus,
    required QueryStatus participantsStatus,
    required QueryStatus eventsStatus,
    RoomEntity? room,
    List<MessageEntity> messages,
    List<EventMessageEntity> systemEvents,
    List<ParticipantEntity> participants,
    @Default(0) int unreadChatCount,
    @Default(0) int unreadEventsCount,
    @Default(0) int activeSubTabIndex, // 0 = Chat, 1 = Events
  }) = _MessageState;

  const MessageState._();

  /// Returns true if either chat or events has unread items (powers bottom nav red dot).
  bool get hasUnread => unreadChatCount > 0 || unreadEventsCount > 0;
}
```

**Unread Synchronization (`MessageCubit`):**
1. **Init Sync**: `initialize(challengeId)` calls `repository.getUnreadCounts(challengeId)` to fetch cross-device unread counts from Serverpod.
2. **WebSocket Ingestion**:
   - `ChatMessage` received → if user is on Chat sub-tab → `unreadChatCount = 0`, calls `repository.markMessagesRead(chatRoomId)`. Else → `unreadChatCount += 1`.
   - `EventMessage` received → if user is on Events sub-tab → `unreadEventsCount = 0`, calls `repository.markEventsRead(challengeId)`. Else → `unreadEventsCount += 1`.
3. **Sub-Tab Switch**:
   - User selects `Chat` tab → `unreadChatCount = 0`, calls `repository.markMessagesRead(chatRoomId)` (server updates `lastReadMessageAt`).
   - User selects `Events` tab → `unreadEventsCount = 0`, calls `repository.markEventsRead(challengeId)` (server updates `lastReadEventAt`).

---

### 4.6 Configuration

```dart
// baktaz_flutter/lib/app/config/app_config.dart
static const int maxChatAttachments = 5;
static const int maxImageUploadSizeBytes = 2 * 1024 * 1024; // 2MB
static const int presenceHeartbeatIntervalSeconds = 30;
```

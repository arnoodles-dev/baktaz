# Chat Module — Design Spec

**Date**: 2026-08-24
**Status**: Approved for implementation planning
**Scope**: `baktaz_server`, `baktaz_flutter`

---

## 1. Overview

The Chat Module provides real-time group messaging within active challenges. When a user joins a challenge, they are automatically added to the challenge's group chat room. The Chat screen is accessible via the bottom navigation bar (tab 3: Chat) and presents two sub-tabs:

1. **Chat tab** — real-time group messages for enrolled challenge participants
2. **Events tab** — read-only system event messages (rank changes, milestones, challenge lifecycle)

Chat is **tightly coupled** to the challenge feature: if the user has no active challenge, chat shows an empty state with a CTA to join a challenge.

---

## 2. Goals / Non-Goals

**Goals**
- Real-time group messaging for active challenge participants via Serverpod streams.
- System event feed (read-only) broadcast on challenge lifecycle milestones.
- Tight coupling to challenge enrollment — no chat without an active challenge.
- Denormalized sender metadata to avoid JOINs on message fetch.
- Cursor-based pagination for message history.

**Non-Goals (V2)**
- Photo/image sharing (file upload + storage).
- Voice messages.
- Pin messages.
- Read receipts.
- Typing indicators.
- Direct 1-on-1 messaging.
- Message search.
- Push notifications for chat.

---

## 3. Server Design

### 3.1 Directory Structure

```
baktaz_server/lib/src/features/message/
├── endpoint/
│   └── message_endpoint.dart
├── domain/
│   ├── model/
│   │   ├── chat_room.spy.yaml
│   │   ├── chat_message.spy.yaml
│   │   ├── chat_message_kind.spy.yaml
│   │   └── chat_participant.spy.yaml
│   ├── interface/
│   │   └── i_chat_repository.dart
│   └── extensions/
│       └── session_extensions.dart
└── data/
    └── repository/
        └── chat_repository.dart
```

### 3.2 Models (.spy.yaml)

**`chat_room.spy.yaml`**
```yaml
class: ChatRoom
table: chat_room
fields:
  id: UuidValue?
  challengeId: UuidValue
  name: String
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
indexes:
  challenge_id_index:
    fields: challengeId
    unique: true
  created_at_index:
    fields: createdAt
```

**`chat_message.spy.yaml`**
```yaml
class: ChatMessage
table: chat_message
fields:
  id: UuidValue?
  chatRoomId: UuidValue
  senderId: UuidValue
  senderName: String
  senderAvatarUrl: Uri?
  content: String
  kind: ChatMessageKind
  createdAt: DateTime, default=now
indexes:
  room_created_index:
    fields: [chatRoomId, createdAt]
  kind_index:
    fields: kind
```

**`chat_message_kind.spy.yaml`**
```yaml
class: ChatMessageKind
values:
  - text
  - system
```

**`chat_participant.spy.yaml`** (read-only DTO, no table)
```yaml
class: ChatParticipant
table: none
fields:
  userId: UuidValue
  displayName: String
  avatarUrl: Uri?
  isOnline: bool
```

### 3.3 MessageEndpoint

File: `baktaz_server/lib/src/features/message/endpoint/message_endpoint.dart`

```dart
final class MessageEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the chat room for the user's active challenge, or null.
  Future<ChatRoom?> getChatRoom(Session session, UuidValue challengeId) async;

  /// Send a text message to a chat room.
  Future<ChatMessage> sendChatMessage(
    Session session,
    UuidValue chatRoomId,
    String content,
  ) async;

  /// Paginated history — oldest first. limit defaults to 50.
  Future<List<ChatMessage>> getChatHistory(
    Session session,
    UuidValue chatRoomId,
    {int limit = 50, DateTime? before}
  ) async;

  /// Stream: real-time user messages (text kind only).
  Stream<ChatMessage> listChatMessages(Session session, UuidValue chatRoomId) async*;

  /// Stream: system events (system kind only).
  Stream<ChatMessage> listSystemEvents(Session session, UuidValue chatRoomId) async*;

  /// Returns room participants with online presence.
  Future<List<ChatParticipant>> getChatParticipants(Session session, UuidValue chatRoomId) async;

  /// Client heartbeat — call every presenceHeartbeatInterval while chat is open.
  Future<void> pingPresence(Session session) async;
}
```

### 3.4 Session Extension for Broadcasting

File: `baktaz_server/lib/src/features/message/domain/extensions/session_extensions.dart`

```dart
extension ChatRoomMessageExtension on Session {
  void broadcastChatMessage(UuidValue chatRoomId, ChatMessage message) {
    postMessage('chat_room_messages_${chatRoomId.uuid}', message);
  }

  void broadcastSystemEvent(UuidValue chatRoomId, ChatMessage message) {
    postMessage('chat_room_events_${chatRoomId.uuid}', message);
  }
}
```

### 3.5 Real-Time Architecture

- **Two separate WebSocket channels** per room:
  - `chat_room_messages_{roomId}` — user text messages
  - `chat_room_events_{roomId}` — system events
- `listChatMessages` subscribes to user messages channel
- `listSystemEvents` subscribes to events channel
- `sendChatMessage` inserts to DB then broadcasts to user channel
- System events are pushed by other endpoints (ChallengeEndpoint, StepsEndpoint) via the extension

### 3.6 System Event Types

| Event | Trigger | Source |
|-------|---------|--------|
| `challenge_started` | Push | ChallengeEndpoint |
| `participant_joined` | Push | ChallengeEndpoint |
| `participant_left` | Push | ChallengeEndpoint |
| `lead_changed` | Push | ChallengeEndpoint |
| `milestone_reached` | Push | StepsEndpoint |
| `halfway_mark` | Cron | FutureCall |
| `daily_reminder` | Cron | FutureCall |
| `challenge_completed` | Push | ChallengeEndpoint |
| `final_countdown` | Cron | FutureCall |

### 3.7 Chat Repository (Server-Side)

```dart
@LazySingleton(as: IChatRepository)
final class ChatRepository implements IChatRepository {
  @override
  Future<ChatRoom?> getChatRoom(Session session, UuidValue challengeId) async {
    final UuidValue? userId = session.authenticated?.authUserId;
    if (userId == null) throw StateError('User not authenticated.');
    return ChatRoom.db.findFirstRow(
      session,
      where: (ChatRoomTable t) => t.challengeId.equals(challengeId),
    );
  }

  @override
  Future<ChatMessage> sendMessage(
    Session session,
    UuidValue chatRoomId,
    UuidValue senderId,
    String senderName,
    String? senderAvatarUrl,
    String content,
  ) async {
    if (content.trim().isEmpty || content.length > AppConfig.maxChatMessageLength) {
      throw ArgumentError('Message content invalid.');
    }
    final ChatMessage message = ChatMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: content.trim(),
      kind: ChatMessageKind.text,
    );
    await ChatMessage.db.insertRow(session, message);
    return message;
  }

  @override
  Future<(List<ChatMessage>, bool)> getChatHistory(
    Session session,
    UuidValue chatRoomId,
    {int limit = AppConfig.chatHistoryLimit, DateTime? before}
  ) async {
    final DateTime? beforeBound = before ?? DateTime.now().toUtc();
    final List<ChatMessage> messages = await ChatMessage.db.find(
      session,
      where: (ChatMessageTable t) =>
          t.chatRoomId.equals(chatRoomId) & t.createdAt.isLessThan(beforeBound),
      limit: limit + 1,
      orderBy: (ChatMessageTable t) => t.createdAt.desc(),
    );
    final bool hasMore = messages.length > limit;
    if (hasMore) messages.removeLast();
    return (messages.reversed.toList(), hasMore);
  }
}
```

---

## 4. Flutter Design

### 4.1 Directory Structure

```
baktaz_flutter/lib/features/message/
├── domain/
│   ├── cubit/
│   │   ├── chat_cubit.dart
│   │   └── chat_state.dart
│   ├── entity/
│   │   ├── chat_room.entity.dart
│   │   ├── chat_message.entity.dart
│   │   └── chat_participant.entity.dart
│   └── interface/
│       └── i_chat_repository.dart
├── data/
│   └── repository/
│       └── chat_repository.dart
└── presentation/
    ├── views/
    │   ├── chat_page.dart
    │   └── events_page.dart
    └── widgets/
        ├── chat_message_tile.dart
        ├── chat_input_bar.dart
        ├── chat_room_header.dart
        ├── participant_side_panel.dart
        └── empty_chat_page.dart
```

### 4.2 Entities (Freezed)

**`chat_message.entity.dart`**
```dart
@freezed
abstract class ChatMessageEntity with _$ChatMessageEntity {
  const factory ChatMessageEntity({
    required String id,
    required String chatRoomId,
    required String senderId,
    required ValueString senderName,
    Url? senderAvatarUrl,
    required ValueString content,
    required ChatMessageKind kind,
    required DateTime createdAt,
  }) = _ChatMessageEntity;

  const ChatMessageEntity._();

  factory ChatMessageEntity.fromServer(serverpod.ChatMessage model) => ChatMessageEntity(
    id: model.id.uuid,
    chatRoomId: model.chatRoomId.uuid,
    senderId: model.senderId.uuid,
    senderName: ValueString(model.senderName, fieldName: 'senderName'),
    senderAvatarUrl: model.senderAvatarUrl != null ? Url(model.senderAvatarUrl!.toString()) : null,
    content: ValueString(model.content, fieldName: 'content'),
    kind: model.kind,
    createdAt: model.createdAt,
  );

  Option<Failure> get validate => senderName.validate
      .andThen(() => content.validate)
      .andThen(() => id.validate)
      .fold(some, (_) => none());
}
```

**`chat_room.entity.dart`**
```dart
@freezed
abstract class ChatRoomEntity with _$ChatRoomEntity {
  const factory ChatRoomEntity({
    required String id,
    required String challengeId,
    required ValueString name,
    required DateTime createdAt,
  }) = _ChatRoomEntity;

  const ChatRoomEntity._();

  factory ChatRoomEntity.fromServer(serverpod.ChatRoom model) => ChatRoomEntity(
    id: model.id.uuid,
    challengeId: model.challengeId.uuid,
    name: ValueString(model.name, fieldName: 'name'),
    createdAt: model.createdAt,
  );

  Option<Failure> get validate => name.validate.fold(some, (_) => none());
}
```

**`chat_participant.entity.dart`**
```dart
@freezed
abstract class ChatParticipantEntity with _$ChatParticipantEntity {
  const factory ChatParticipantEntity({
    required String userId,
    required String displayName,
    Url? avatarUrl,
    required bool isOnline,
  }) = _ChatParticipantEntity;

  factory ChatParticipantEntity.fromServer(serverpod.ChatParticipant model) => ChatParticipantEntity(
    userId: model.userId.uuid,
    displayName: model.displayName,
    avatarUrl: model.avatarUrl != null ? Url(model.avatarUrl!.toString()) : null,
    isOnline: model.isOnline,
  );
}
```

### 4.3 Repository Interface

```dart
abstract interface class IChatRepository {
  TaskResult<ChatRoomEntity?> getChatRoom();
  TaskResult<ChatMessageEntity> sendMessage(String roomId, String content);
  TaskResult<List<ChatMessageEntity>> getChatHistory(String roomId, {int limit, DateTime? before});
  Stream<ChatMessageEntity> getMessagesStream(String roomId);
  Stream<ChatMessageEntity> getSystemEventsStream(String roomId);
  TaskResult<List<ChatParticipantEntity>> getParticipants(String roomId);
  TaskResult<void> pingPresence();
}
```

### 4.4 ChatCubit

```dart
@injectable
interface class ChatCubit extends CubitSignal<ChatState>
    with BlocSignalPresentationMixin<ChatStateSideEffect, ChatState> {
  ChatCubit(this._repository, this._failureHandler) : super(initialState: ChatState.initial());

  final IChatRepository _repository;
  final FailureHandler _failureHandler;
  Timer? _heartbeatTimer;

  StreamSubscription<ChatMessageEntity>? _messagesSubscription;
  StreamSubscription<ChatMessageEntity>? _eventsSubscription;

  Future<void> initialize() async { ... }
  Future<void> sendMessage(String content) async { ... }
  Future<void> loadHistory({DateTime? before}) async { ... }
  Future<void> loadParticipants() async { ... }
  void togglePanel() { ... }
  void _subscribeToStream(String roomId) { ... }
  void _startHeartbeat() { ... }
  @override
  void close() {
    _heartbeatTimer?.cancel();
    _messagesSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.close();
  }
}
```

### 4.5 ChatState

```dart
@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState({
    required QueryStatus queryStatus,
    ChatRoomEntity? room,
    List<ChatMessageEntity> messages,
    List<ChatMessageEntity> systemEvents,
    List<ChatParticipantEntity> participants,
    bool isPanelOpen,
  }) = _ChatState;

  const ChatState._();

  factory ChatState.initial() => const _ChatState(
    queryStatus: QueryStatus.loading(),
    messages: <ChatMessageEntity>[],
    systemEvents: <ChatMessageEntity>[],
    participants: <ChatParticipantEntity>[],
    isPanelOpen: false,
  );
}

@freezed
sealed class ChatStateSideEffect with _$ChatStateSideEffect {
  const factory ChatStateSideEffect.onException(Exception exception) = ChatStateException;
}
```

### 4.6 UI Components

**ChatPage** — replaces existing stub
- Checks `room` null → shows `EmptyChatPage`
- If enrolled: loads room, subscribes to streams via `BlocSignalBuilder<ChatCubit, ChatState>`
- Two tabs via `MessageAppBar` (Chat | Events)
- `_ChatBody` with `useEffect` auto-scroll-to-bottom on message load/append

**ChatMessageTile**
- Shows avatar (BaktazAvatar with `imageUrl` or initials) + senderName + content bubble
- System messages: gray background (`secondaryContainer`), icon prefix
- Own messages: `primaryContainer`, right-aligned
- `isOwn = message.senderId == currentUserId` (from AuthCubit)

**ChatInputBar**
- BaktazTextField + BaktazButton
- Disabled while loading
- 500 char max, trim whitespace
- Empty send prevention

**ParticipantSidePanel**
- Persistent Drawer with BlocSignalBuilder
- Shows participant list with online status (green dot / outline)
- Taps panel to close

**EventsPage** — replaces existing stub
- Shows system event stream via BlocSignalBuilder
- Read-only, chronological (newest first)
- Empty state with i18n key

**EmptyChatPage**
- "Join challenge to unlock chat" with CTA
- "Explore Challenges" button → `ChallengeRoute`

### 4.7 Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Sender data | Denormalized `senderName` + `senderAvatarUrl` | Avoids JOIN on every fetch |
| Channels | Two separate WebSocket channels | Cleaner client code, no filter logic |
| Room lifecycle | Tightly coupled to challenge | No orphan rooms, auto-create |
| Pagination | Cursor-based (`before` timestamp) | Chronological, no offset drift |
| Message editing | Not supported | Simpler, immutability fits context |
| Online presence | Serverpod heartbeat (30s) + disconnect cleanup | Low overhead, sufficient for MVP |
| Name format | `"$firstName $lastInitial."` from UserInfo | Consistent display, no schema migration risk |
| Entity value types | `ValueString` for display strings, `Url?` for URLs | Matches codebase pattern (HomeLeaderboardEntry) |
| Repository pattern | `_retry.retry()` + `.validate.isSome()` on every method | Matches StepsRepository/ChallengeRepository |
| Provider ownership | `BlocSignalProvider(create: (_) => getIt<ChatCubit>())` | ChatCubit is `@injectable` |

### 4.8 Implementation Steps

1. **Server models** — create `.spy.yaml` files (ChatMessageKind, ChatRoom, ChatMessage, ChatParticipant)
2. **Server UserInfo extension** — add firstName/lastName fields, parse fullName on creation
3. **Server AppConfig** — add chat constants (maxChatMessageLength=500, chatHistoryLimit=50, presence intervals)
4. **Server IChatRepository + ChatRepository** — implement all methods
5. **Server Session extension** — broadcastChatMessage + broadcastSystemEvent
6. **Server MessageEndpoint** — 7 methods
7. **Migration** — `serverpod create_migration` → `apply_migrations`
8. **Codegen** — `serverpod generate`
9. **Flutter entities** — freezed classes with fromServer + validate
10. **Flutter IChatRepository** — interface
11. **Flutter ChatRepository** — with retry + validation
12. **Flutter ChatState** — sealed class
13. **Flutter ChatCubit** — with stream lifecycle, heartbeat, tests
14. **Flutter ChatParticipantEntity** — freezed
15. **Flutter widgets** — ChatMessageTile, ChatInputBar, ChatRoomHeader, ParticipantSidePanel, EmptyChatPage
16. **Flutter ChatPage** — replace stub
17. **Flutter EventsPage** — replace stub
18. **Flutter i18n** — add keys, run slang
19. **Flutter Golden tests** — Alchemist for 5 widgets
20. **Flutter Routing** — verify routes
21. **Flutter BlocSignalProvider** — register in MainScreen
22. **Flutter mocks** — update generated_mocks.dart
23. **Verification** — analyze, format, test, smoke test

### 4.9 Out of Scope (V2)

- Photo/image sharing (file upload + storage)
- Voice messages
- Pin messages
- Read receipts
- Typing indicators
- Direct 1-on-1 messaging
- Message search
- Push notifications for chat

### 4.10 File Locations

**Server:**
- `baktaz_server/lib/src/features/message/domain/model/chat_room.spy.yaml`
- `baktaz_server/lib/src/features/message/domain/model/chat_message.spy.yaml`
- `baktaz_server/lib/src/features/message/domain/model/chat_message_kind.spy.yaml`
- `baktaz_server/lib/src/features/message/domain/model/chat_participant.spy.yaml`
- `baktaz_server/lib/src/features/message/endpoint/message_endpoint.dart`
- `baktaz_server/lib/src/features/message/domain/extensions/session_extensions.dart`
- `baktaz_server/lib/src/features/message/domain/interface/i_chat_repository.dart`
- `baktaz_server/lib/src/features/message/data/repository/chat_repository.dart`
- `baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml` (modified)
- `baktaz_server/lib/src/app/config/app_config.dart` (modified)
- `baktaz_server/lib/src/app/utils/auth_utils.dart` (modified)
- `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart` (modified)

**Flutter:**
- `baktaz_flutter/lib/features/message/domain/cubit/chat_cubit.dart`
- `baktaz_flutter/lib/features/message/domain/cubit/chat_state.dart`
- `baktaz_flutter/lib/features/message/domain/entity/chat_room.entity.dart`
- `baktaz_flutter/lib/features/message/domain/entity/chat_message.entity.dart`
- `baktaz_flutter/lib/features/message/domain/entity/chat_participant.entity.dart`
- `baktaz_flutter/lib/features/message/domain/interface/i_chat_repository.dart`
- `baktaz_flutter/lib/features/message/data/repository/chat_repository.dart`
- `baktaz_flutter/lib/features/message/presentation/views/chat_page.dart` (replace stub)
- `baktaz_flutter/lib/features/message/presentation/views/events_page.dart` (replace stub)
- `baktaz_flutter/lib/features/message/presentation/widgets/chat_message_tile.dart`
- `baktaz_flutter/lib/features/message/presentation/widgets/chat_input_bar.dart`
- `baktaz_flutter/lib/features/message/presentation/widgets/chat_room_header.dart`
- `baktaz_flutter/lib/features/message/presentation/widgets/participant_side_panel.dart`
- `baktaz_flutter/lib/features/message/presentation/widgets/empty_chat_page.dart`
- `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart` (modify — add BlocSignalProvider)
- `baktaz_flutter/test/widget/message/chat_widgets_test.dart` (new)
- `baktaz_flutter/test/unit/chat_cubit_test.dart` (new)
- `baktaz_flutter/test/utils/generated_mocks.dart` (modify)
- `baktaz_flutter/lib/l10n/` (modify — add chat keys)

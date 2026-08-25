# Chat Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Real-time in-app messaging between challenge participants — chat rooms per active challenge, user/system message streams via Serverpod postMessage, paginated history, participant list with online presence, and a full Flutter UI (chat page + events page).

**Architecture:** Serverpod `MessageEndpoint` exposes `ChatRoom`, `ChatMessage`, and `ChatMessageKind` models with stream methods. A session extension broadcasts on channel keys derived from `chatRoomId`. Flutter side: `@freezed` entities (ChatRoomEntity, ChatMessageEntity with ValueString/Url), `IChatRepository` / `ChatRepository` with retry + validation, `ChatCubit` (CubitSignal with stream subscription lifecycle), and a page + five widgets built from `baktaz_shared` components.

**Tech Stack:** Serverpod 2.x, `serverpod/serverpod.dart`, `serverpod_auth_idp_server/core.dart`, Flutter, `bloc_signals`, `freezed`, `injectable`, `go_router`, `fpdart`, `chopper`, `talker`, `mockito`, `alchemist`.

**Spec:** `docs/superpowers/specs/2026-08-24-chat-module-design.md`

## Global Constraints

- Dart SDK >=3.13.0; `very_good_analysis` + `dart_code_metrics` `--fatal-infos`; line width 120.
- No hardcoded user-facing strings (localization). **Exception:** `*_server`.
- Follow AGENTS.md, `.agents/rules/{code-quality,flutter-architecture,serverpod-architecture,naming-convention,testing,design-system}`.
- Codegen order: `slang` → `build_runner` → `serverpod generate`.
- Use serverpod MCP for `create_migration` / `apply_migrations` / `hot_restart`. Never start server (user runs `serverpod start`).
- TDD: failing test → run → implement → pass → commit. Run `dart analyze` after every change.
- Chat is **tightly coupled** to challenge feature: `getChatRoom()` returns null when no active challenge; chat page shows `EmptyChatPage` with CTA to `ChallengeRoute`.
- `ChatParticipant` is a read-only DTO (`table: none`) — assembled from challenge participant data + presence cache.
- `UserInfo` model extended with `firstName` and `lastName` nullable String fields. `UserProfile.fullName` is split into these at registration time.
- Sender display name format: `"$firstName $lastInitial."` (e.g., "John Doe" → "John D.", "Maria" → "Maria").
- Message length: max 500 characters (`AppConfig.maxChatMessageLength`).
- Pagination: cursor-based via `before` timestamp, 50 messages per page. Server returns `(List<ChatMessage>, bool hasMore)`. Endpoint unwraps tuple, returns `List<ChatMessage>` to client.
- Two separate WebSocket channels: `chat_room_messages_{id}` (user messages), `chat_room_events_{id}` (system events).
- Online presence: 30s heartbeat via `pingPresence()` endpoint. Stored in `session.caches.local` with 60s TTL.
- ChatCubit is `@injectable` → registered in `main_screen.dart` as `BlocSignalProvider<ChatCubit>(lazy: false, create: (_) => getIt<ChatCubit>())`.
- ChatRepository wraps every serverpod call in `_retry.retry()` with `RetryUtils.isRetryableException`, validates entities post-construction with `.validate.isSome()`, handles errors via `_talker.handle()`.
- ChatState has fields: `queryStatus`, `room`, `messages`, `systemEvents`, `participants`, `isPanelOpen`.
- All user-facing strings use `context.i18n.*`.

---

## Task 1: Server — ChatMessageKind Enum

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_message_kind.spy.yaml`

```yaml
class: ChatMessageKind
values:
  - text
  - system
```

- [ ] **Step 1: Create file**

Create the enum file with the YAML content above.

- [ ] **Step 2: Commit** — `git add baktaz_server/lib/src/features/message/domain/model/chat_message_kind.spy.yaml && git commit -m "feat(server): add ChatMessageKind enum"`

---

## Task 2: Server — ChatRoom Model

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_room.spy.yaml`

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

- [ ] **Step 1: Create file**

Create the ChatRoom `.spy.yaml` with the schema above.

- [ ] **Step 2: Commit** — `git commit -m "feat(server): add ChatRoom model"`

---

## Task 2.5: Server — UserInfo Extension (firstName/lastName)

**Files:**
- Modify: `baktaz_server/lib/src/features/account/domain/model/user_info.spy.yaml`
- Modify: `baktaz_server/lib/src/app/utils/auth_utils.dart`
- Modify: `baktaz_server/lib/src/features/auth/data/repository/auth_repository.dart`

**Changes:**
- Add `firstName: String?` and `lastName: String?` to `user_info` table
- In `auth_utils.dart`, update `_createUserInfo` to accept `String? fullName` and parse it:
  ```dart
  static (String?, String?) _parseFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return (null, null);
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, null);
    return (parts.first, parts.last);
  }
  ```
- In `auth_repository.dart`, update `completeRegistration` to set firstName/lastName when updating UserInfo

- [ ] **Step 1: Update spy.yaml**

Add `firstName: String?` and `lastName: String?` fields to the `user_info` model.

- [ ] **Step 2: Update auth_utils.dart**

Add `_parseFullName` helper and update `_createUserInfo` signature to accept `String? fullName`.

- [ ] **Step 3: Update auth_repository.dart**

Call `_parseFullName` and set `firstName`/`lastName` on the UserInfo update.

- [ ] **Step 4: Commit** — `git commit -m "feat(server): add firstName/lastName to UserInfo model"`

---

## Task 3: Server — ChatMessage Model

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_message.spy.yaml`

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

- [ ] **Step 1: Create file**

Create the ChatMessage `.spy.yaml` with the schema above.

- [ ] **Step 2: Commit** — `git commit -m "feat(server): add ChatMessage model"`

---

## Task 4: Server — Extend AppConfig with Chat Constants

**Files:**
- Modify: `baktaz_server/lib/src/app/config/app_config.dart`

Add after existing constants:
```dart
  // Chat Configuration
  static const int maxChatMessageLength = 500;
  static const int chatHistoryLimit = 50;
  static const Duration chatStreamTimeout = Duration(minutes: 5);
  static const Duration presenceHeartbeatInterval = Duration(seconds: 30);
  static const Duration presenceTtl = Duration(seconds: 60);
```

- [ ] **Step 1: Append constants**

Add the chat configuration constants to `AppConfig`.

- [ ] **Step 2: Analyze** — `cd baktaz_server && fvm dart analyze lib/src/app/config/app_config.dart`

- [ ] **Step 3: Commit** — `git commit -m "feat(server): add chat constants to AppConfig"`

---

## Task 5: Server — Chat Repository Interface + Implementation + Migration

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/interface/i_chat_repository.dart`
- Create: `baktaz_server/lib/src/features/message/data/repository/chat_repository.dart`
- Create: migration via `serverpod create_migration`

**IChatRepository:**
```dart
abstract interface class IChatRepository {
  Future<ChatRoom?> getChatRoom(Session session, UuidValue challengeId);
  Future<ChatMessage> sendMessage(
    Session session,
    UuidValue chatRoomId,
    UuidValue senderId,
    String senderName,
    String? senderAvatarUrl,
    String content,
  );
  Future<(List<ChatMessage>, bool)> getChatHistory(
    Session session,
    UuidValue chatRoomId,
    {int limit, DateTime? before});
  Future<List<ChatParticipant>> getChatParticipants(Session session, UuidValue chatRoomId);
  Future<void> pingPresence(Session session);
}
```

**ChatRepository implementation:**
- `getChatRoom`: find by challengeId
- `sendMessage`: validate content (empty check + length <= maxChatMessageLength), insert row
- `getChatHistory`: query with `limit + 1`, detect hasMore, reverse for chronological order
- `getChatParticipants`: resolve room → get challenge participants → fetch accounts → format display names → check presence cache
- `pingPresence`: write timestamp to `session.caches.local` with TTL

- [ ] **Step 1: Create interface**

Create `IChatRepository` with the abstract methods above.

- [ ] **Step 2: Create repository**

Implement `ChatRepository` with all methods. Use `session.caches.local` for presence. Throw typed exceptions for validation failures.

- [ ] **Step 3: Create migration** — via serverpod MCP (`create_migration`)

- [ ] **Step 4: Apply migration** — via serverpod MCP (`apply_migrations`)

- [ ] **Step 5: Commit** — `git commit -m "feat(server): implement ChatRepository"`

---

## Task 6: Server — Session Extension for Broadcasting

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/extensions/session_extensions.dart`
- Test: `baktaz_server/test/unit/session_extensions_test.dart`

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

- [ ] **Step 1: Create extension**

Create the session extension with both broadcast methods.

- [ ] **Step 2: Create unit test**

Verify channel keys are correctly derived from `chatRoomId.uuid`.

- [ ] **Step 3: Commit** — `git commit -m "feat(server): add session broadcast extension"`

---

## Task 7: Server — MessageEndpoint

**Files:**
- Create: `baktaz_server/lib/src/features/message/endpoint/message_endpoint.dart`
- Test: `baktaz_server/test/unit/message_endpoint_test.dart`

Methods:
- `getChatRoom(session, challengeId)` — delegates to repo, throws `UnauthenticatedException` if not logged in
- `sendChatMessage(session, chatRoomId, content)` — resolves sender from Account + UserInfo, formats display name, calls repo, broadcasts
- `getChatHistory(session, chatRoomId, {limit, before})` — delegates to repo (unwraps tuple, returns list to client)
- `listChatMessages(session, chatRoomId) async*` — subscribes to channel, yields text-kinded messages
- `listSystemEvents(session, chatRoomId) async*` — subscribes to channel, yields system-kinded messages
- `getChatParticipants(session, chatRoomId)` — delegates to repo
- `pingPresence(session)` — delegates to repo

Display name helper:
```dart
static String _formatDisplayName(String? firstName, String? lastName, String? fallback) {
  if (firstName != null && firstName.isNotEmpty) {
    final String initial = lastName?.isNotEmpty == true ? '${lastName![0]}.' : '';
    return '$firstName$initial'.trim();
  }
  return fallback ?? 'Unknown';
}
```

- [ ] **Step 1: Create endpoint**

Implement `MessageEndpoint` with all 7 methods.

- [ ] **Step 2: Create unit test**

Mock repo, verify broadcasts and display name formatting.

- [ ] **Step 3: Analyze** — `cd baktaz_server && fvm dart analyze lib/src/features/message/`

- [ ] **Step 4: Commit** — `git commit -m "feat(server): add MessageEndpoint"`

---

## Task 8: Server — Register Endpoint + Analyze

- [ ] **Step 1: Analyze** — `cd baktaz_server && fvm dart analyze`

Fix any errors reported.

- [ ] **Step 2: Format** — `cd baktaz_server && fvm dart format lib/src/features/message/ test/`

- [ ] **Step 3: Commit any fixes**

Commit only if analysis/formatting revealed issues that were fixed.

---

## Task 9: Flutter — Chat Room & Chat Message Entities

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_room.entity.dart`
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_message.entity.dart`

Both use `@freezed`, import `baktaz_client` as `serverpod`, use `ValueString` for display strings (`name`, `senderName`, `content`), `Url?` for `senderAvatarUrl`, `String` for IDs. Each has `fromServer()` factory and `get validate` with `Option<Failure>`.

- [ ] **Step 1: Create entities**

Create both `@freezed` entities with `fromServer()` factories and `validate` getters.

- [ ] **Step 2: Run codegen** — `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add ChatRoomEntity and ChatMessageEntity"`

---

## Task 10: Flutter — IChatRepository Interface

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/interface/i_chat_repository.dart`

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

- [ ] **Step 1: Create interface**

Create the `IChatRepository` interface with all methods.

- [ ] **Step 2: Commit** — `git commit -m "feat(flutter): add IChatRepository interface"`

---

## Task 11: Flutter — ChatRepository Implementation

**Files:**
- Create: `baktaz_flutter/lib/features/message/data/repository/chat_repository.dart`
- Test: `baktaz_flutter/test/unit/chat_repository_test.dart`

Constructor: `const ChatRepository(this._serverpod, this._retry, this._talker)`
Each method: `_retry.retry(() => _serverpod.client.message.<method>(), retryIf: RetryUtils.isRetryableException)` wrapped in `TaskResult.tryCatch`. Post-construction validation: `if (entity.validate.isSome()) throw entity.validate.asSome()`.

- [ ] **Step 1: Create repository**

Implement `ChatRepository` with retry, validation, and error handling.

- [ ] **Step 2: Create unit test**

Test retry behavior, validation failures, and error mapping.

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): implement ChatRepository"`

---

## Task 12: Flutter — ChatState

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/cubit/chat_state.dart`

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

- [ ] **Step 1: Create file**

Create `ChatState` and `ChatStateSideEffect` with `@freezed`.

- [ ] **Step 2: Commit** — `git commit -m "feat(flutter): add ChatState"`

---

## Task 13: Flutter — ChatCubit + Unit Tests

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/cubit/chat_cubit.dart`
- Create: `baktaz_flutter/test/unit/chat_cubit_test.dart`

Cubit extends `CubitSignal<ChatState>` with `BlocSignalPresentationMixin`. Methods:
- `initialize()` — loads room, subscribes to streams, starts heartbeat
- `sendMessage(content)` — validates, optimistic send
- `loadHistory({before})` — paginates older messages
- `loadParticipants()` — fetches participant list
- `togglePanel()` — opens/closes, loads participants on open
- `_subscribeToStream(roomId)` — subscribes to both streams
- `_startHeartbeat()` — 30s periodic pingPresence
- `close()` — cancels timer + subscriptions

- [ ] **Step 1: Create cubit**

Implement `ChatCubit` with full stream lifecycle management.

- [ ] **Step 2: Create unit tests**

Mock repo, test state transitions for initialize, sendMessage, loadHistory, togglePanel.

- [ ] **Step 3: Add mock to generated_mocks.dart**

Add `MockSpec<IChatRepository>()` to `test/utils/generated_mocks.dart`.

- [ ] **Step 4: Run codegen** — `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run tests** — `cd baktaz_flutter && fvm dart test test/unit/chat_cubit_test.dart`

- [ ] **Step 6: Commit** — `git commit -m "feat(flutter): add ChatCubit with unit tests"`

---

## Task 13.5: Flutter — ChatParticipantEntity

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_participant.entity.dart`

`@freezed` with `fromServer()`, fields: `userId` (String), `displayName` (String), `avatarUrl` (Url?), `isOnline` (bool).

- [ ] **Step 1: Create entity**

Create the `ChatParticipantEntity` freezed class.

- [ ] **Step 2: Run codegen** — `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add ChatParticipantEntity"`

---

## Task 14: Flutter — Chat UI Widgets

**Files:**
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/chat_message_tile.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/chat_input_bar.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/chat_room_header.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/participant_side_panel.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/empty_chat_page.dart`

**ChatMessageTile:** Shows avatar (BaktazAvatar with imageUrl/initials), senderName, content, timestamp. System messages: gray background. Own messages: primaryContainer, right-aligned. `isOwn = message.senderId == currentUserId`.

**ChatInputBar:** BaktazTextField + BaktazButton. Disabled while loading. Max 500 chars.

**ChatRoomHeader:** BaktazAppBar with room name + participant icon button.

**ParticipantSidePanel:** Drawer with BlocSignalBuilder, shows participants with online status indicator (green dot / outline).

**EmptyChatPage:** EmptyPage with i18n strings + BaktazButton "Explore Challenges" → ChallengeRoute.

- [ ] **Step 1: Create widgets**

Create all five widgets using `baktaz_shared` components.

- [ ] **Step 2: Analyze & format**

```bash
cd baktaz_flutter && fvm dart analyze lib/features/message/presentation/widgets/
cd baktaz_flutter && fvm dart format lib/features/message/presentation/widgets/
```

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add chat UI widgets"`

---

## Task 15: Flutter — ChatPage (Replace Stub)

**Files:**
- Replace: `baktaz_flutter/lib/features/message/presentation/views/chat_page.dart`

Uses `BlocSignalBuilder<ChatCubit, ChatState>`. Shows `EmptyChatPage` when no room, chat UI when enrolled. `_ChatBody` with `useEffect` for scroll-to-bottom.

- [ ] **Step 1: Replace stub**

Implement the full `ChatPage` with BlocSignalBuilder, conditional rendering, and scroll logic.

- [ ] **Step 2: Analyze & format**

```bash
cd baktaz_flutter && fvm dart analyze lib/features/message/presentation/views/chat_page.dart
cd baktaz_flutter && fvm dart format lib/features/message/presentation/views/
```

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): implement ChatPage"`

---

## Task 16: Flutter — EventsPage

**Files:**
- Replace: `baktaz_flutter/lib/features/message/presentation/views/events_page.dart`

Uses `BlocSignalBuilder`, shows system events chronologically. Empty state with i18n key.

- [ ] **Step 1: Create page**

Implement `EventsPage` showing system events with empty state.

- [ ] **Step 2: Analyze & format**

```bash
cd baktaz_flutter && fvm dart analyze lib/features/message/presentation/views/events_page.dart
cd baktaz_flutter && fvm dart format lib/features/message/presentation/views/
```

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add EventsPage"`

---

## Task 17: Flutter — i18n Keys + DI Registration

**Files:**
- Modify: `baktaz_flutter/lib/l10n/` (add chat keys to ARB files)
- Check: `baktaz_flutter/lib/app/helpers/injection/service_locator.dart`

i18n keys:
- `chat.inputPlaceholder` — "Type a message..."
- `chat.send` — "Send"
- `chat.participants` — "Participants"
- `chat.participantsComingSoon` — "Participant list coming soon"
- `chat.eventsTitle` — "Events"
- `chat.noEvents` — "No events yet"
- `chat.emptyTitle` — "Find your chats here!"
- `chat.emptySubtitle` — "Discover what's new on the app"
- `chat.exploreChallenges` — "Explore Challenges"

- [ ] **Step 1: Add i18n keys**

Add all chat-related keys to the ARB files.

- [ ] **Step 2: Run slang** — `cd baktaz_flutter && fvm dart run slang`

- [ ] **Step 3: Verify DI** — check service_locator for `@injectable` / `@lazySingleton` on ChatCubit and ChatRepository. Ensure `ChatCubit` is registered as `@injectable` and `ChatRepository` as `@LazySingleton(as: IChatRepository)`.

- [ ] **Step 4: Commit** — `git commit -m "feat(flutter): add chat i18n keys and verify DI"`

---

## Task 17.5: Flutter — Golden Tests for Chat Widgets

**Files:**
- Create: `baktaz_flutter/test/widget/message/chat_widgets_test.dart`

Golden tests for: `ChatMessageTile` (user message, system event), `ChatRoomHeader`, `EmptyChatPage`. Use Alchemist `goldenTest` + `MockMaterialApp`.

- [ ] **Step 1: Create golden test file**

Write Alchemist golden tests for all chat widgets.

- [ ] **Step 2: Generate baselines** — `cd baktaz_flutter && fvm flutter test test/widget/message/chat_widgets_test.dart --update-goldens`

- [ ] **Step 3: Run verification** — `cd baktaz_flutter && fvm flutter test test/widget/message/chat_widgets_test.dart`

- [ ] **Step 4: Commit** — `git commit -m "feat(flutter): add chat widget golden tests"`

---

## Task 18: Flutter — Routing Integration

**Files:**
- Modify: `baktaz_flutter/lib/app/router/router.dart` (or equivalent)
- Verify: `ChatPage` and `EventsPage` routes registered

- [ ] **Step 1: Ensure routes exist**

Add `@TypedGoRoute` for `ChatPage` and `EventsPage`. Verify `/chat` and `/chat/events` routes are registered.

- [ ] **Step 2: Analyze** — `cd baktaz_flutter && fvm dart analyze lib/app/router/`

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): register chat routes"`

---

## Task 18.5: Flutter — ChatCubit Provider Registration

**Files:**
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart`

Add after existing `HomeCubit` provider:
```dart
BlocSignalProvider<ChatCubit>(lazy: false, create: (BuildContext context) => getIt<ChatCubit>()),
```

- [ ] **Step 1: Add import + provider**

Import `ChatCubit` and add the provider registration.

- [ ] **Step 2: Analyze** — `cd baktaz_flutter && fvm dart analyze lib/core/presentation/views/screens/main_screen.dart`

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): register ChatCubit in MainScreen"`

---

## Task 19: Flutter — Generated Mocks Update

**Files:**
- Verify: `baktaz_flutter/test/utils/generated_mocks.dart` includes `MockSpec<IChatRepository>()`

- [ ] **Step 1: Verify mock exists** — `grep -n "IChatRepository" baktaz_flutter/test/utils/generated_mocks.dart`

- [ ] **Step 2: If missing, add and regenerate**

Add `MockSpec<IChatRepository>()` to the `@GenerateMocks` list and re-run build_runner.

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add IChatRepository mock"`

---

## Task 20: Full Verification & Integration

- [ ] **Step 1: Analyze all packages**
  ```bash
  cd baktaz_server && fvm dart analyze
  cd baktaz_flutter && fvm dart analyze
  cd baktaz_shared && fvm dart analyze
  ```

- [ ] **Step 2: Format all changed packages**
  ```bash
  cd baktaz_server && fvm dart format lib test
  cd baktaz_flutter && fvm dart format lib test
  ```

- [ ] **Step 3: Run all tests**
  ```bash
  cd baktaz_server && fvm dart test --concurrency=1
  cd baktaz_flutter && fvm dart test
  ```

- [ ] **Step 4: Serverpod hot_restart (MCP)**

Use serverpod MCP `hot_restart` tool.

- [ ] **Step 5: Manual smoke test** — user starts `serverpod start`:
  1. Navigate to `/chat` → should show loading then chat UI (or empty state if no room)
  2. Send a message → should appear in list
  3. Navigate to `/chat/events` → should show system events
  4. Toggle panel → should open/close drawer

- [ ] **Step 6: Final commit for any fixes**

---

## Self-Review

| Criterion | Status |
|-----------|--------|
| All server models (.spy.yaml) created with correct indexes | ☐ |
| MessageEndpoint has all 7 required methods | ☐ |
| Session extension broadcasts to correct channel keys | ☐ |
| AppConfig has chat constants (no literals) | ☐ |
| Flutter entities use @freezed with fromServer + validate | ☐ |
| IChatRepository returns TaskResult<T>, never throws | ☐ |
| ChatRepository uses Serverpod client + retry + validate | ☐ |
| ChatCubit uses CubitSignal with initialState: | ☐ |
| ChatCubit subscribes to streams, cancels on close | ☐ |
| All 5 widgets created with baktaz_shared components | ☐ |
| ChatPage replaces stub, uses BlocSignalBuilder | ☐ |
| EventsPage created, shows system events | ☐ |
| i18n keys added, slang generated | ☐ |
| Golden tests added for chat widgets | ☐ |
| ChatCubit registered in MainScreen providers | ☐ |
| Mocks updated in generated_mocks.dart | ☐ |
| All tests pass (unit + integration) | ☐ |
| dart analyze clean on all packages | ☐ |
| Migrations created and applied via MCP | ☐ |

---

## Handoff Notes

- **Serverpod endpoint auto-registration**: Serverpod 2.x auto-registers endpoints found in `lib/src/features/*/endpoint/`. No manual registration needed.
- **Stream lifecycle**: `ChatCubit._messagesSubscription` and `._eventsSubscription` must be cancelled in `close()` to prevent memory leaks.
- **Challenge integration**: `getChatRoom()` currently returns `null` — integrate with challenge domain when available to resolve the active challenge's room.
- **System messages**: Currently only user-sent messages are broadcast. System messages (challenge start/end) should be sent via `broadcastSystemEvent` from the challenge endpoint when ready.
- **UserInfo firstName/lastName**: Existing users with null values will fall back to `userProfile.fullName` for display name formatting.
- **Pagination**: `getChatHistory` uses `before` cursor for infinite scroll — implement load-more trigger in UI when user scrolls to top.

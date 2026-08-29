# Chat Module — Server Sub-Plan

> **Parent plan:** `docs/superpowers/plans/chat/2026-08-24-chat-module.md`
> **Spec:** `docs/superpowers/specs/Chat/2026-08-24-00-overview.md`
> **Package:** `baktaz_server`

**Goal:** Implement the Serverpod backend for the chat module — models (`ChatMessage`, `ChatAttachment`, `EventMessage`, `EventTemplate`, `ChatRoom`, `ChatParticipant`, `ChatUnreadStatus`), presigned S3 upload, event template seeder, `IEventRepository` / `EventRepository` for system event dispatching, unread tracking methods (`getUnreadCounts`, `markMessagesRead`, `markEventsRead`), session extensions, and endpoints (`MessageEndpoint`, `EventAdminEndpoint`).

---

## Task 1: Server — Models (.spy.yaml)

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_room.spy.yaml`
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_message.spy.yaml`
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_attachment.spy.yaml`
- Create: `baktaz_server/lib/src/features/message/domain/model/event_message.spy.yaml`
- Create: `baktaz_server/lib/src/features/message/domain/model/event_template.spy.yaml`
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_participant.spy.yaml` (with `lastReadMessageAt`, `lastReadEventAt`)
- Create: `baktaz_server/lib/src/features/message/domain/model/chat_unread_status.spy.yaml`

- [ ] **Step 1: Create model files**

Create each `.spy.yaml` model per spec `2026-08-24-01-server-models.md`.

- [ ] **Step 2: Run build_runner & create_migration**

Run: `cd baktaz_server && fvm dart run build_runner build --delete-conflicting-outputs`
Run: `serverpod create-migration` and `serverpod apply-migrations`

- [ ] **Step 3: Commit** — `git commit -m "feat(server): add chat and event models with lastRead timestamps and migrations"`

---

## Task 2: Server — Event Template Seeder

**Files:**
- Create: `baktaz_server/lib/src/features/message/data/service/event_template_seeder.dart`

Seeds the 25 default system event templates into `event_templates` table at server startup.

- [ ] **Step 1: Create EventTemplateSeeder**

Implement `EventTemplateSeeder` with default templates for all 25 event keys per spec `2026-08-24-02-server-endpoint.md`.

- [ ] **Step 2: Call from server startup**

Call `seeder.seedTemplates(session)` in `bin/main.dart`.

- [ ] **Step 3: Commit** — `git commit -m "feat(server): add EventTemplateSeeder with 25 default templates"`

---

## Task 3: Server — Extend AppConfig with Chat Constants

**Files:**
- Modify: `baktaz_server/lib/src/app/config/app_config.dart`

Add:
```dart
  // Chat Configuration
  static const int maxChatMessageLength = 500;
  static const int maxChatAttachments = 5;
  static const int maxImageUploadSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int chatHistoryLimit = 50;
  static const int minStepsForSyncEvent = 1000;
  static const Duration syncEventRateLimit = Duration(hours: 2);
  static const Duration presenceHeartbeatInterval = Duration(seconds: 30);
  static const Duration presenceTtl = Duration(seconds: 60);
```

- [ ] **Step 1: Update AppConfig**
- [ ] **Step 2: Commit** — `git commit -m "feat(server): add chat constants to AppConfig"`

---

## Task 4: Server — Session Extension for Broadcasting

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/extensions/session_extensions.dart`

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

- [ ] **Step 1: Create extension**
- [ ] **Step 2: Commit** — `git commit -m "feat(server): add session broadcast extension"`

---

## Task 5: Server — IEventRepository + EventRepository

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/interface/i_event_repository.dart`
- Create: `baktaz_server/lib/src/features/message/data/repository/event_repository.dart`

Implement `IEventRepository`:
- `dispatchEvent(session, challengeId, eventKey, payload)` — fetches `EventTemplate`, checks `isEnabled`, interpolates `{placeholder}` strings, inserts `EventMessage`, calls `session.broadcastSystemEvent()`
- `getEventHistory(session, challengeId, limit, before)` — fetches history for Events tab

- [ ] **Step 1: Create interface & repository**
- [ ] **Step 2: Commit** — `git commit -m "feat(server): implement IEventRepository and EventRepository"`

---

## Task 5.5: Server — IMessageRepository + MessageRepository (with Unread Methods)

**Files:**
- Create: `baktaz_server/lib/src/features/message/domain/interface/i_message_repository.dart`
- Create: `baktaz_server/lib/src/features/message/data/repository/message_repository.dart`

Implement methods:
- `getChatRoom(session, challengeId)`
- `getUnreadCounts(session, challengeId)` — computes unread message & event counts relative to `lastReadMessageAt` & `lastReadEventAt`
- `markMessagesRead(session, chatRoomId)` — updates `lastReadMessageAt = DateTime.now()`
- `markEventsRead(session, challengeId)` — updates `lastReadEventAt = DateTime.now()`
- `getUploadUrl(session, chatRoomId, mimeType, sizeBytes)` — generates presigned S3 upload URL
- `sendMessage(session, chatRoomId, content, attachments)` — validates attachments <= 5, inserts ChatMessage + ChatAttachments, broadcasts
- `getChatMessages(session, chatRoomId, limit, before)`
- `pingPresence(session)`

- [ ] **Step 1: Create interface & repository**
- [ ] **Step 2: Commit** — `git commit -m "feat(server): implement IMessageRepository and MessageRepository with unread status methods"`

---

## Task 6: Server — MessageEndpoint & EventAdminEndpoint

**Files:**
- Create: `baktaz_server/lib/src/features/message/endpoint/message_endpoint.dart`
- Create: `baktaz_server/lib/src/features/message/endpoint/event_admin_endpoint.dart`

- [ ] **Step 1: Create MessageEndpoint** (chat, upload URL, unread counts, mark-read, history, streams, presence)
- [ ] **Step 2: Create EventAdminEndpoint** (list, update, reset event templates for admin)
- [ ] **Step 3: Analyze & format**
- [ ] **Step 4: Commit** — `git commit -m "feat(server): add MessageEndpoint with unread status methods and EventAdminEndpoint"`

---

## Verification

- [ ] `cd baktaz_server && fvm dart analyze`
- [ ] `cd baktaz_server && fvm dart test`

# Chat Module — Flutter Sub-Plan

> **Parent plan:** `docs/superpowers/plans/chat/2026-08-24-chat-module.md`
> **Spec:** `docs/superpowers/specs/Chat/2026-08-24-00-overview.md`
> **Package:** `baktaz_flutter`

**Goal:** Implement the Flutter client for the chat module — entities (`MessageEntity`, `AttachmentEntity`, `EventMessageEntity`, `RoomEntity`, `ParticipantEntity`), S3 presigned photo upload flow with local compression (`flutter_image_compress`), repository, cubit, unread state management (`unreadChatCount`, `unreadEventsCount`, instant read reset), UI widgets (MessageTile, AttachmentPickerPreview, sub-tab badges), BaktazNavBar red dot, pages, i18n, and golden tests.

---

## Task 7: Flutter — Entities (Freezed)

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_message.dart`
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_attachment.dart`
- Create: `baktaz_flutter/lib/features/message/domain/entity/event_message.dart`
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_room.dart`
- Create: `baktaz_flutter/lib/features/message/domain/entity/chat_participant.dart`

- [ ] **Step 1: Create entity files**

Create `@freezed` classes for `MessageEntity`, `AttachmentEntity`, `EventMessageEntity`, `RoomEntity`, and `ParticipantEntity` with `fromServer()` factories and `get validate` getters.

- [ ] **Step 2: Run build_runner**

Run: `cd baktaz_flutter && fvm dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): add chat entities (message, attachment, eventMessage, room, participant)"`

---

## Task 8: Flutter — IMessageRepository Interface & Repository Implementation

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/interface/i_message_repository.dart`
- Create: `baktaz_flutter/lib/features/message/data/repository/message_repository.dart`
- Create: `baktaz_flutter/lib/features/message/data/service/image_upload_service.dart`

**ImageUploadService:**
1. Compresses image locally via `flutter_image_compress` (1080p, 80% JPEG quality, max 2MB).
2. Requests presigned upload URL from `_client.message.getUploadUrl()`.
3. Uploads binary directly to S3 via HTTP PUT.
4. Returns `AttachmentEntity`.

- [ ] **Step 1: Create ImageUploadService**
- [ ] **Step 2: Create IMessageRepository & MessageRepository**
- [ ] **Step 3: Commit** — `git commit -m "feat(flutter): implement IMessageRepository and ImageUploadService for presigned S3 upload"`

---

## Task 9: Flutter — MessageState & MessageCubit (with Unread Badges)

**Files:**
- Create: `baktaz_flutter/lib/features/message/domain/cubit/message_state.dart`
- Create: `baktaz_flutter/lib/features/message/domain/cubit/message_cubit.dart`
- Create: `baktaz_flutter/test/unit/message_cubit_test.dart`

**MessageCubit Methods & Unread Logic:**
- `initialize(challengeId)` — loads room, subscribes to streams, starts heartbeat, loads saved `lastSeen` timestamps from `SharedPreferences`
- `pickImages()` — opens image picker (max 5), adds to state pending attachments
- `removePendingAttachment(index)` — removes preview
- `sendMessage(content)` — compresses + uploads pending attachments to S3 via `ImageUploadService`, sends message, clears input
- `selectSubTab(index)` — switches active sub-tab (0 = Chat, 1 = Events), resets corresponding `unreadChatCount` or `unreadEventsCount` to 0, saves timestamp to `SharedPreferences`
- `_onChatMessageReceived(msg)` — if not on active Chat tab, increments `unreadChatCount`
- `_onEventMessageReceived(event)` — if not on active Events tab, increments `unreadEventsCount`
- `loadMessagesHistory()` / `loadEventsHistory()` — cursor pagination
- `close()` — cancels timer & WebSocket subscriptions (`_messagesSubscription`, `_eventsSubscription`)

- [ ] **Step 1: Create MessageState & MessageCubit**
- [ ] **Step 2: Write unit tests for unread count increments & resets**
- [ ] **Step 3: Run unit tests** — `cd baktaz_flutter && fvm dart test test/unit/message_cubit_test.dart`
- [ ] **Step 4: Commit** — `git commit -m "feat(flutter): add MessageCubit with unread badge counters & SharedPreferences persistence"`

---

## Task 10: Flutter — UI Widgets, Badges & Pages

**Files:**
- Modify: `baktaz_flutter/lib/core/presentation/widgets/baktaz_nav_bar.dart` (add red dot on Messages tab when `state.hasUnread`)
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/message_tile.dart` (renders text + 1–5 photo grid with Shimmer)
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/attachment_picker_preview.dart` (thumbnail preview bar with (X) remove buttons)
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/message_input_bar.dart` (input + image picker button + send button)
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/room_header.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/participant_side_panel.dart`
- Create: `baktaz_flutter/lib/features/message/presentation/widgets/empty_chat_page.dart`
- Replace: `baktaz_flutter/lib/features/message/presentation/views/message_page.dart` (main tab view with `[ 💬 Chat 🔴 3 ]` & `[ ⚡ Events 🔴 1 ]` headers)
- Replace: `baktaz_flutter/lib/features/message/presentation/views/events_page.dart` (timeline feed of EventMessage)

- [ ] **Step 1: Update BaktazNavBar with red dot badge**
- [ ] **Step 2: Create widgets & pages with sub-tab badges**
- [ ] **Step 3: Add i18n keys & run slang**
- [ ] **Step 4: Analyze & format**
- [ ] **Step 5: Commit** — `git commit -m "feat(flutter): implement BaktazNavBar red dot, sub-tab unread badges, and Chat UI"`

---

## Task 11: Flutter — Golden Tests

**Files:**
- Create: `baktaz_flutter/test/widget/message/chat_widgets_test.dart`

Golden tests for `MessageTile` (text only, text + photo grid), `AttachmentPickerPreview`, `RoomHeader`, `EmptyChatPage`, and sub-tab badge headers.

- [ ] **Step 1: Write golden tests**
- [ ] **Step 2: Generate goldens** — `cd baktaz_flutter && fvm flutter test test/widget/message/chat_widgets_test.dart --update-goldens`
- [ ] **Step 3: Commit** — `git commit -m "test(flutter): add golden tests for chat widgets & unread badges"`

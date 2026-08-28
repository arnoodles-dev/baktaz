# Chat Module — Integration Sub-Plan

> **Parent plan:** `docs/superpowers/plans/chat/2026-08-24-chat-module.md`
> **Spec:** `docs/superpowers/specs/chat/2026-08-24-00-overview.md`
> **Packages:** `baktaz_flutter` (routing + DI), `baktaz_server` + `baktaz_flutter` (verification)

**Goal:** Wire up routing, DI providers, mocks, and run full verification for the chat module.

---

## Task 12: Flutter — Routing Integration

**Files:**
- Modify: `baktaz_flutter/lib/app/router/router.dart`

Add `@TypedGoRoute` for `MessagePage` (`/chat`) and `EventsPage` (`/chat/events`).

- [ ] **Step 1: Register routes**
- [ ] **Step 2: Commit** — `git commit -m "feat(flutter): register chat routes"`

---

## Task 13: Flutter — MessageCubit Provider Registration

**Files:**
- Modify: `baktaz_flutter/lib/core/presentation/views/screens/main_screen.dart`

Add after existing `HomeCubit` provider:
```dart
BlocSignalProvider<MessageCubit>(lazy: false, create: (BuildContext context) => getIt<MessageCubit>()),
```

- [ ] **Step 1: Register provider in MainScreen**
- [ ] **Step 2: Commit** — `git commit -m "feat(flutter): register MessageCubit in MainScreen"`

---

## Task 14: Flutter — Generated Mocks Update

**Files:**
- Modify: `baktaz_flutter/test/utils/generated_mocks.dart`

Add `MockSpec<IMessageRepository>()` and re-run build_runner.

- [ ] **Step 1: Add mock spec & run build_runner**
- [ ] **Step 2: Commit** — `git commit -m "feat(flutter): add IMessageRepository mock"`

---

## Task 15: Full Verification & Integration

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
  cd baktaz_flutter && fvm flutter test
  ```

- [ ] **Step 4: Serverpod hot_restart (MCP)**

- [ ] **Step 5: Manual smoke test** — user starts `serverpod start`:
  1. Open Chat tab → displays group chat or empty state.
  2. Pick 1–3 photos via AttachmentPickerPreview → send.
  3. Image displays in MessageTile grid.
  4. Switch to Events tab → displays system events (anti-cheat, milestones, payouts).
  5. Check `baktaz_admin` → manage event templates via `EventAdminEndpoint`.

- [ ] **Step 6: Commit any final fixes**

---

## Verification Matrix

| Check | Expected |
|-------|----------|
| Models (.spy.yaml) | Created & migrated (ChatMessage, ChatAttachment, EventMessage, EventTemplate) |
| Presigned Upload | Client-side compression (1080p, 80% JPEG) + S3 PUT upload |
| Max Attachments | 1–5 images per message (`AppConfig.maxChatAttachments = 5`) |
| Admin Templates | `EventTemplate` dynamic string interpolation via `EventAdminEndpoint` |
| 25 Event Types | Full catalog mapped to challenge lifecycle |
| MessageCubit | Subscribes to 2 WebSocket streams, cancels on close |
| Flutter UI | MessageTile, AttachmentPickerPreview, RoomHeader, EmptyChatPage, EventsPage |
| Golden Tests | Alchemist tests for all chat widgets |
| dart analyze | Zero errors / warnings across all packages |

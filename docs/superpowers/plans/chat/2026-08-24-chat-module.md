# Chat Module Implementation Plan

> **Parent Canonical Roadmap:** Governed by and aligned with the Master Integration Plan in [`/Users/Arnold/Projects/baktaz/docs/superpowers/plans/2026-08-30-master-integration-plan.md`](../2026-08-30-master-integration-plan.md).
> All models, paths, and invariants (presigned S3 image upload capped at max 2MB & max 5 attachments, explicit stream subscription cancellation in `ChatCubit.close()`, Serverpod 2.x session streaming channels, `session.auth.authenticatedUserId` identity derivation, Pattern B error handling, `TaskResult<T>` repository returns, and implementation-first testing workflows) strictly conform to the master roadmap.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Real-time in-app group messaging between challenge participants (with text and 1–5 photo attachments via presigned S3 upload), read-only system events feed rendered from admin-editable templates (`EventTemplate`), participant presence, and complete Flutter UI.

**Architecture:** 
- Serverpod backend: `ChatMessage`, `ChatAttachment`, `EventMessage`, `EventTemplate`, `ChatRoom`, `ChatParticipant` models.
- Endpoints: `MessageEndpoint` (chat, S3 presigned upload, streams, history), `EventAdminEndpoint` (admin template management).
- Session extensions broadcast over `chat_room_messages_{id}` and `challenge_events_{id}` channels.
- Flutter client: `@freezed` entities (`MessageEntity`, `AttachmentEntity`, `EventMessageEntity`, `RoomEntity`, `ParticipantEntity`), `IMessageRepository` / `MessageRepository` with retry + validation, `MessageCubit` (CubitSignal with stream lifecycle + client-side compression), and UI components built from `baktaz_shared`.

**Tech Stack:** Serverpod 2.x, `serverpod/serverpod.dart`, Flutter 3.47+, `bloc_signals`, `freezed`, `injectable`, `go_router`, `fpdart`, `chopper`, `flutter_image_compress`, `image_picker`, `mockito`, `alchemist`.

**Spec:** `docs/superpowers/specs/Chat/2026-08-24-00-overview.md`

## Sub-Plans

This plan is split into three sub-plans:

| Sub-Plan | File | Scope |
|----------|------|-------|
| Server | [chat/2026-08-28-chat-module-server.md](chat/2026-08-28-chat-module-server.md) | `baktaz_server` models, S3 upload, templates, endpoints |
| Flutter | [chat/2026-08-28-chat-module-flutter.md](chat/2026-08-28-chat-module-flutter.md) | `baktaz_flutter` entities, image picker, upload flow, cubit, UI |
| Integration | [chat/2026-08-28-chat-module-integration.md](chat/2026-08-28-chat-module-integration.md) | Routing, DI, mocks, verification |

---

## Global Constraints

- Dart SDK: `>=3.13.0 <4.0.0`
- Target packages: `baktaz_server`, `baktaz_flutter`, `baktaz_admin`
- Maximum file length: 400 lines
- No hardcoded user-facing strings (localization via slang).
- TDD: failing test → run → implement → pass → commit. Run `dart analyze` after every change.
- Attachment limits: Max 5 photos per message (`AppConfig.maxChatAttachments = 5`), max 2MB compressed per photo (`AppConfig.maxImageUploadSizeBytes`).
- Presigned Upload: Client compresses image locally → requests presigned URL from `MessageEndpoint.getUploadUrl()` → uploads directly to S3 via HTTP PUT → calls `sendChatMessage()`.

---

## Handoff Notes

- **Serverpod endpoint auto-registration**: Serverpod 4.x auto-registers endpoints found in `lib/src/features/*/endpoint/`.
- **Stream lifecycle**: `MessageCubit._messagesSubscription` and `._eventsSubscription` must be cancelled in `close()`.
- **Admin template management**: Admins customize system event templates via `EventAdminEndpoint` in `baktaz_admin`.

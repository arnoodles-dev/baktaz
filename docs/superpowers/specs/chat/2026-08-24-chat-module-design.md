# Chat Module — Design Spec

**Date**: 2026-08-24
**Updated**: 2026-08-28 (Photo attachments, S3 upload flow, EventMessage/EventTemplate separation, Challenge alignment)
**Status**: Approved for implementation planning
**Scope**: `baktaz_server`, `baktaz_flutter`, `baktaz_admin`

---

## Specification Sub-Files

| File | Description |
|------|-------------|
| [2026-08-24-00-overview.md](./2026-08-24-00-overview.md) | Overview, goals, key features, architecture principles |
| [2026-08-24-01-server-models.md](./2026-08-24-01-server-models.md) | Server models: ChatRoom, ChatMessage, ChatAttachment, EventMessage, EventTemplate, ChatParticipant |
| [2026-08-24-02-server-endpoint.md](./2026-08-24-02-server-endpoint.md) | MessageEndpoint, EventAdminEndpoint, repository, real-time streams, 25 system events catalog |
| [2026-08-24-03-flutter-design.md](./2026-08-24-03-flutter-design.md) | Flutter entities, repository, cubit, S3 presigned photo upload flow |
| [2026-08-24-04-flutter-ui.md](./2026-08-24-04-flutter-ui.md) | UI components, MessageTile with image grid, AttachmentPickerPreview, EventsPage, golden tests |

Read the sub-specs for detailed design specifications.

# Chat Module — Server Models

- **Date**: 2026-08-24
- **Updated**: 2026-08-28 (Added lastReadMessageAt / lastReadEventAt to ChatParticipant, ChatUnreadStatus model)
- **Parent spec**: `2026-08-24-00-overview.md`
- **Package**: `baktaz_server`

## 3. Server Design

### 3.1 Directory Structure

```
baktaz_server/lib/src/features/message/
├── endpoint/
│   ├── message_endpoint.dart
│   ├── event_admin_endpoint.dart
│   └── webhook_endpoint.dart
├── domain/
│   ├── model/
│   │   ├── chat_room.spy.yaml
│   │   ├── chat_message.spy.yaml
│   │   ├── chat_attachment.spy.yaml
│   │   ├── event_message.spy.yaml
│   │   ├── event_template.spy.yaml
│   │   ├── chat_participant.spy.yaml
│   │   └── chat_unread_status.spy.yaml
│   ├── interface/
│   │   ├── i_message_repository.dart
│   │   └── i_event_repository.dart
│   └── extensions/
│       └── session_extensions.dart
└── data/
    └── repository/
        ├── message_repository.dart
        └── event_repository.dart
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
  content: String?                  # Optional if message contains only photo attachments
  attachments: List<ChatAttachment>?, relation(optional)
  createdAt: DateTime, default=now
indexes:
  room_created_index:
    fields: [chatRoomId, createdAt]
```

**`chat_attachment.spy.yaml`**
```yaml
class: ChatAttachment
table: chat_attachment
fields:
  id: UuidValue?, defaultPersist=random
  chatMessageId: UuidValue
  chatMessage: ChatMessage?, relation(field=chatMessageId, onDelete=Cascade)
  url: Uri
  thumbnailUrl: Uri?
  mediaType: String                 # "image/jpeg", "image/png"
  sizeBytes: int
  width: int?
  height: int?
  createdAt: DateTime, default=now
indexes:
  message_attachment_index:
    fields: chatMessageId
```

**`event_message.spy.yaml`**
```yaml
class: EventMessage
table: event_message
fields:
  id: UuidValue?
  challengeId: UuidValue
  eventKey: String                  # e.g., "anti_cheat_flagged", "rank_one_taken"
  title: String
  body: String
  icon: String?                     # e.g., "warning_amber", "trophy", "bolt"
  payload: Json?                    # Raw JSON metadata (actorUserId, targetUserId, steps, etc.)
  createdAt: DateTime, default=now
indexes:
  challenge_created_index:
    fields: [challengeId, createdAt]
  event_key_index:
    fields: eventKey
```

**`event_template.spy.yaml`**
```yaml
class: EventTemplate
table: event_templates
fields:
  id: UuidValue?, defaultPersist=random
  eventKey: String                  # Unique identifier
  titleTemplate: String             # e.g., "⚠️ Anti-Cheat Review: {userName}"
  bodyTemplate: String              # e.g., "{userName} logged {dailySteps} steps (limit: {dailyStepCeiling})."
  icon: String                      # e.g., "warning_amber", "trophy"
  isEnabled: bool, default=true
  createdAt: DateTime, default=now
  updatedAt: DateTime?, scope=serverOnly
indexes:
  event_key_index:
    fields: eventKey
    unique: true
```

**`chat_participant.spy.yaml`**
```yaml
class: ChatParticipant
table: chat_participant
fields:
  id: UuidValue?, defaultPersist=random
  chatRoomId: UuidValue
  chatRoom: ChatRoom?, relation(field=chatRoomId, onDelete=Cascade)
  userId: UuidValue
  joinedAt: DateTime, default=now
  lastSeenAt: DateTime?, scope=serverOnly
  lastReadMessageAt: DateTime?          # Updated when user views Chat sub-tab
  lastReadEventAt: DateTime?            # Updated when user views Events sub-tab
indexes:
  chat_user_index:
    fields: [chatRoomId, userId]
    unique: true
  user_index:
    fields: userId
```

**`chat_unread_status.spy.yaml`**
```yaml
class: ChatUnreadStatus
fields:
  unreadChatCount: int
  unreadEventsCount: int
```

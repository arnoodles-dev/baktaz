---
title: Health Data Integration - Backend Schema
status: Proposed
version: 1.0
related: health_data_integration_spec.md
---

# 30. Backend Data Model

```sql
-- Users table (existing)
users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  ...
)

-- User settings
user_settings (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  daily_step_target INTEGER NOT NULL DEFAULT 10000,
  ...
)

-- Devices
user_devices (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  platform TEXT NOT NULL,
  device_model TEXT,
  os_version TEXT,
  app_version TEXT,
  last_seen_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

-- Health integrations
health_integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  device_id UUID NOT NULL REFERENCES user_devices(id),
  health_provider TEXT NOT NULL,
  status TEXT NOT NULL,
  data_available BOOLEAN NOT NULL DEFAULT FALSE,
  last_synced_at TIMESTAMPTZ,
  last_diagnostic TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

-- Step syncs
step_syncs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  date DATE NOT NULL,
  steps INTEGER NOT NULL,
  device_id UUID NOT NULL REFERENCES user_devices(id),
  health_provider TEXT NOT NULL,
  synced_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, date, synced_at)
)

-- Daily steps (canonical, updated by the most recent sync)
daily_steps (
  user_id UUID REFERENCES users(id),
  date DATE,
  steps INTEGER,
  last_synced_at TIMESTAMPTZ,
  device_id UUID REFERENCES user_devices(id),
  health_provider TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, date)
)
```

---

# 31. Backend Health Integration Metadata

The backend should store integration metadata, not just a single boolean.

### Stored fields

- Platform (`healthkit` or `health_connect`)
- Status (`connected`, `disconnected`, `error`)
- Data availability
- Last sync time
- Last diagnostic result

This allows:

- Debugging integration issues per device.
- Showing the right UI on app resume.
- Detecting when a device stops syncing.

---

# 32. Recommended API Flow

```
Flutter App               Serverpod
     │                         │
     │  1. GET /api/health/    │
     │     diagnostic          │
     │────────────────────────▶│
     │                         │
     │◀────────────────────────│
     │  2. Return current      │
     │     integration status  │
     │                         │
     │  3. Request permissions │
     │     (client-side)       │
     │                         │
     │  4. GET /api/health/    │
     │     verify-access       │
     │────────────────────────▶│
     │                         │
     │◀────────────────────────│
     │  5. Return verified     │
     │     diagnostic state    │
     │                         │
     │  6. GET /api/health/    │
     │     today-steps         │
     │────────────────────────▶│
     │                         │
     │◀────────────────────────│
     │  7. Return today's      │
     │     step total          │
     │                         │
     │  8. POST /api/health/   │
     │     sync-steps          │
     │  {steps, synced_at,     │
     │   device_id}            │
     │────────────────────────▶│
     │                         │
     │◀────────────────────────│
     │  9. Return sync status  │
```

---

# 33. Recommended Sync Strategy

### Cumulative snapshots, not deltas

The app sends the **total steps for today**. The backend stores the total for the day.

```json
{
  "date": "2024-01-15",
  "steps": 7842,
  "synced_at": "2024-01-15T14:30:00Z",
  "device_id": "device-abc-123",
  "health_provider": "healthkit"
}
```

### Backend handling

- If the same day is synced again, compare `synced_at` timestamps.
- Replace the stored total with the latest sync.
- Never add the new total to the existing total.

---

# 34. App Resume Validation

When the app resumes from the background:

1. Re-run the health diagnostic.
2. If the diagnostic is `connected`, fetch today's steps.
3. If today's steps have not been synced since the last sync, send a sync.
4. If the diagnostic is NOT `connected`, do not attempt to read or sync steps.

### Why re-validate

The health permission state can change:

- Between app launches
- Between foreground and background states
- Without the app's knowledge

---

# 35. "Last Synced" vs "Connected"

These are two different concepts.

| Field | Source | Meaning |
|---|---|---|
| `connected` | Device diagnostic | The device can currently access health data |
| `last_synced_at` | Backend record | The last time the backend received valid step data |

The app should:

- Use `connected` to drive UI decisions on the current device.
- Use `last_synced_at` to determine whether a sync is needed.
- Never assume `connected` on device A means device B is also connected.

---

# 36. Health Integration Status Matrix

The backend should track status per device, not per account.

```
User A
├── Device 1 (iOS, HealthKit)
│   ├── Status: connected
│   ├── Last sync: 2024-01-15T14:30:00Z
│   └── Data available: true
│
└── Device 2 (Android, Health Connect)
    ├── Status: disconnected
    ├── Last sync: 2024-01-10T09:00:00Z
    └── Data available: false
```

The canonical daily total for the user comes from Device 1, because it is the most recently active source.

---

# 37. Canonical Step Calculation

The backend determines the **canonical step total** for a user on a given day by:

1. Finding all `step_sync` records for that user and date.
2. Selecting the one with the latest `synced_at` timestamp.
3. Returning that record's `steps` value.

If no syncs exist for a day, the canonical total is null.

### Why not sum or average

- Summing double-counts steps.
- Averaging smooths over real data.
- The latest sync is the most recent cumulative total.

---

# 38. Example End-to-End Day

```
09:00 – App opens
  - Diagnose → connected
  - Read steps → 2,500
  - Sync → store 2,500 for 2024-01-15

12:00 – App resumes
  - Diagnose → connected
  - Read steps → 5,200
  - Sync → update 2,500 → 5,200 (same day, newer sync)

15:00 – Stale sync arrives from background task
  - Steps → 4,000
  - synced_at is earlier than existing record
  - Ignored

18:00 – User switches to Android device
  - Diagnose → connected
  - Read steps → 6,800
  - Sync → update 5,200 → 6,800 (newest source)

20:00 – Second sync from iOS device
  - Steps → 7,100
  - synced_at is earlier than Android sync
  - Ignored
```

Final canonical total for 2024-01-15: **6,800 steps** (from the Android device).

---

# 39. Security and Anti-Cheat

### Requirements

- Step data should never be trusted blindly from the client.
- The backend should validate:
  - That the step count is within a reasonable range.
  - That the step count does not decrease significantly between syncs.
  - That sync requests come from registered devices.

### Recommended checks

| Check | Description |
|---|---|
| Min/Max bounds | Reject steps < 0 or > 100,000 |
| Non-decreasing within day | Steps should not drop by > 10% between syncs |
| Device trust | Reject syncs from unregistered devices |
| Timestamp ordering | Reject older synced_at timestamps |
| Source consistency | Reject iOS steps from Android devices |

### Important

- Anti-cheat should be defensive, not punitive.
- Log suspicious syncs for review.
- Do not penalize the user without investigation.

### Why anti-cheat matters

This spec explicitly supports:

- Challenges
- Rewards
- Prizes
- Competitions

In those contexts, step data affects outcomes. The architecture should make it possible to audit:

```text
User
 ↓
Device
 ↓
Health Provider
 ↓
Step Snapshot
 ↓
Canonical Daily Total
 ↓
Challenge Evaluation
 ↓
Reward
```

---

# 40. Recommended UX

### First-time connection

```text
Track your daily steps

Connect Apple Health / Health Connect
to automatically track your activity.

We only read your step count.

[ Connect Health Data ]

Skip for now
```

### Successful connection

```text
✓ Health Data Connected

Today's steps are now available.

7,842 / 10,000

[ Continue ]
```

### Missing data

```text
Almost there

Health Connect is available and permission
is granted, but no step data was found.

If you use Samsung Health, make sure it is
sharing step data with Health Connect.

[ Open Health Connect ]
[ Check Again ]
```

### Revoked permission

```text
Health Data Needs Attention

Your health data is no longer accessible.

Please reconnect your health provider.

[ Reconnect ]
```

---

# 41. Recommended Product Decisions

The following decisions are recommended for Version 1:

| Decision | Recommendation |
|---|---|
| iOS integration | HealthKit |
| Android integration | Health Connect |
| Flutter abstraction | `health` package |
| Daily target source | Application/backend |
| Step source | HealthKit / Health Connect |
| Multiple devices | Supported |
| iOS + Android account | Supported |
| Multiple HealthKit sources | Let HealthKit aggregate |
| Multiple Health Connect sources | Let Health Connect aggregate |
| Cross-platform step totals | Do not add |
| Primary provider | One per user |
| Secondary device | Allowed but not canonical |
| Backend integration status | Store metadata |
| Current permission truth | Device |
| Daily step storage | Backend |
| Sync model | Cumulative snapshots |
| Sync calculation | Replace/update, never add |
| Sync audit | Recommended |
| Background sync | Optional/platform-dependent |
| Challenge evaluation | Backend |
| Client reward calculation | Not trusted |

---

# 42. Final Architecture

```text
                              USER ACCOUNT
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
               USER DEVICES                  USER SETTINGS
                    │                             │
          ┌─────────┴─────────┐             daily_step_target
          │                   │
       iOS Device        Android Device
          │                   │
      HealthKit         Health Connect
          │                   │
          ▼                   ▼
    Aggregated Steps    Aggregated Steps
          │                   │
          └─────────┬─────────┘
                    │
                    ▼
              Flutter App
                    │
            HealthRepository
                    │
                    ▼
          Integration Diagnostic
                    │
        ┌───────────┴────────────┐
        │                        │
      Valid                    Invalid
        │                        │
        ▼                        ▼
   Read Steps              Show Resolution
        │
        ▼
 Active Health Provider
        │
        ▼
  Cumulative Daily Total
        │
        ▼
      Serverpod
        │
        ├── health_integrations
        │
        ├── user_devices
        │
        ├── step_syncs
        │
        └── daily_steps
                │
                ▼
       Challenge / Rewards /
       Leaderboards / Analytics
```

---

# 43. Key Rules Summary

1. **Use HealthKit on iOS and Health Connect on Android.**
2. **Use a Flutter abstraction so application code is platform independent.**
3. **Treat HealthKit/Health Connect as the health-data aggregation layer.**
4. **Never manually add step counts from multiple devices within the same health ecosystem.**
5. **Never add HealthKit and Health Connect totals together.**
6. **Support multiple devices and both iOS and Android under one account.**
7. **Use one active/authoritative health provider per user for canonical step totals.**
8. **Keep device-level integration state separate from account state.**
9. **Do not treat a successful permission dialog as proof that health data is accessible.**
10. **Validate actual step-data access.**
11. **Handle missing Health Connect/HealthKit separately from permission problems.**
12. **Handle "no step data" separately from "service unavailable."**
13. **Explicitly guide Samsung Health users when Health Connect contains no data.**
14. **Read cumulative daily totals rather than incremental deltas.**
15. **When syncing multiple times per day, update the daily total instead of adding snapshots.**
16. **Protect against out-of-order/stale sync requests.**
17. **Store last successful sync time.**
18. **Revalidate health access when the app resumes.**
19. **Keep canonical step data on the backend for challenges/rewards.**
20. **Maintain an audit trail if health data affects rewards, prizes, or competitions.**

---

## See also

- [Overview](overview.md)
- [Flutter Architecture](flutter-architecture.md)
- [UI/UX](ui-ux.md)
- [Backend Sync & Model](backend-sync-model.md)
- [Multi-Device Rules](multi-device-rules.md)

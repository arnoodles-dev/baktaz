---
title: Health Data Integration - UI/UX
status: Proposed
version: 1.0
related: health_data_integration_spec.md
---

# 14. Health Integration UI

## 14.1 First-Time Integration

Shown when the user has never connected health data.

```text
Track your daily steps

Connect Apple Health / Health Connect
to automatically track your activity.

We only read your step count.

[ Connect Health Data ]

Skip for now
```

- The user should be able to skip and connect later.
- "Skip for now" should not hide the option forever; it should appear in settings.
- The screen must show which platform provider will be used.
- On Android, mention Health Connect.
- On iOS, mention Apple Health.

## 14.2 Permission Denied

```text
Health Data Permission Needed

To track your daily steps, allow access to
your health data in your device settings.

[ Open Settings ]
[ Not Now ]
```

The "Open Settings" button should open the app's permission page in the system settings.

## 14.3 Connected State

```text
Health Data Connected

Your step count is syncing automatically.

Last synced: 5 minutes ago
Today's steps: 7,842 / 10,000

[ Disconnect ]
```

- Show last sync time.
- Show current step count.
- Show the daily target.
- "Disconnect" should pause syncing but preserve history.

## 14.4 No Data Found

```text
Almost there

Health Connect is available and permission
is granted, but no step data was found.

If you use Samsung Health, make sure it is
sharing step data with Health Connect.

[ Open Health Connect ]
[ Check Again ]
```

- Always show this message when `noDataFound` is returned.
- Provide a "Check Again" action that re-runs the diagnostic.
- Provide an "Open Health Connect" action that opens the Health Connect app.

## 14.5 Permission Revoked

```text
Health Data Needs Attention

Your health data is no longer accessible.

This can happen if:
- You revoked permission in settings
- You uninstalled Health Connect
- Your health provider is unavailable

[ Reconnect ]
[ Open Settings ]
```

- The app should detect this state on resume.
- "Reconnect" should re-run the permission flow.
- "Open Settings" should open the system settings.

## 14.6 Service Unavailable

```text
Health Data Temporarily Unavailable

Your health provider is currently unavailable.
We'll keep trying.

[ Try Again ]
```

- The app should retry automatically when the service becomes available.
- "Try Again" should re-run the diagnostic.

---

# 15. Health Integration Checklist UI

The integration screen should show a checklist to help the user verify each step.

```text
Health Data Setup

✅ HealthKit / Health Connect is available
✅ Permission granted
⚠️ No data found
[ Open Health Connect ]
```

### Checklist items

| Item | Description |
|---|---|
| Health service available | HealthKit or Health Connect is installed |
| Permission granted | The user has granted step-read permission |
| Data source available | At least one source is providing step data |
| Data is accessible | The app can read today's step count |

The checklist is built from the `HealthConnectionDiagnostic` and additional data validation.

---

# 16. Daily Step Target

### Source

The daily step target is **application-defined** and stored in the user settings.

The target is **not** automatically calculated from the device or health provider.

### Storage

The target should be stored in the user settings table on the backend.

```sql
user_settings (
  user_id UUID PRIMARY KEY,
  daily_step_target INTEGER NOT NULL DEFAULT 10000,
  ...
)
```

### Update strategy

- The user can update the target in settings.
- The default is 10,000.
- Changes apply to the current day forward.
- Historical daily totals are not recomputed when the target changes.

### Validation

- The target must be a positive integer.
- The maximum is configurable; recommend 100,000.

---

# 17. Daily Step Retrieval

### Cumulative Daily Total

The app must read the **cumulative daily total** from the health provider, not incremental deltas.

```text
How many steps has the user accumulated today?
```

Not:

```text
How many steps did the user take since the last sync?
```

### Why cumulative

- Multiple syncs per day will not double-count.
- Stale or out-of-order syncs will not cause incorrect totals.
- The total is the source of truth for the day.

### Implementation

- Use the health package's `getHealthDataFromTypes` with a date range covering today.
- Sum all step samples within today's range.
- Or use the health package's daily total API.

### Edge cases

- If the day has just rolled over (00:00:00 - 00:01:00), the total may be very small or zero.
- The app should handle this gracefully by showing "0 steps so far" or a similar message.

---

## See also

- [Overview](overview.md)
- [Flutter Architecture](flutter-architecture.md)
- [Backend Sync & Model](backend-sync-model.md)
- [Multi-Device Rules](multi-device-rules.md)
- [Backend Schema](backend-schema.md)

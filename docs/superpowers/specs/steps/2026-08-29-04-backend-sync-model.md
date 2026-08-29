
# 18. Multiple Syncs Per Day
> **Parent Spec:** `docs/superpowers/specs/Steps/2026-08-29-01-overview.md`

The app will sync step data to the backend multiple times per day.

This happens when:

- The app is in the foreground and reads fresh data
- The app resumes from the background
- A background sync task fires
- The user manually pulls to refresh

Design requirement:

**The app must send a cumulative daily total, and the backend must update rather than add.**

---

# 19. Backend Sync Model

### Sync payload

```json
{
  "date": "2024-01-15",
  "steps": 7842,
  "device_id": "device-abc-123",
  "source": "healthkit",
  "synced_at": "2024-01-15T14:30:00Z"
}
```

### Backend behavior

When a sync request arrives:

1. Find any existing `step_sync` or `daily_step` record for this user + date.
2. **If an existing record exists:**
   - **If `incoming_synced_at > existing_synced_at`:** update the record with the new step count and timestamp.
   - **If `incoming_synced_at < existing_synced_at`:** treat it as stale and ignore it.
3. **If no existing record exists:** create a new record.

This ensures the **latest** sync always wins, regardless of order.

### Why not add deltas

```text
❌ Wrong:
Sync 1: steps += 3,000
Sync 2: steps += 4,842
Result: 7,842 ✓ (coincidentally correct)

But what if:
Sync 2 arrives first: steps += 4,842
Sync 1 arrives second: steps += 3,000
Result: 4,842 (wrong — should be 7,842)
```

```text
✅ Correct:
Sync 1: daily_total = 3,000 (at time T1)
Sync 2: daily_total = 7,842 (at time T2 > T1)

Backend stores 7,842 because T2 > T1.

If reversed:
Sync 2 first: daily_total = 7,842 (at time T2)
Sync 1 second: 7,842 at T1 < T2, so ignored.

Backend still stores 7,842.
```

---

# 20. Out-of-Order Sync Protection

Sync requests may arrive out of order due to:

- Network delays
- Offline periods
- Background sync tasks
- Multiple device sync

### Protection mechanism

Each sync request carries a `synced_at` timestamp from the device.

The backend compares this against the existing record's `synced_at`:

```sql
UPDATE step_syncs
SET steps = incoming_steps, synced_at = incoming_synced_at
WHERE user_id = X
  AND date = 'today'
  AND existing_synced_at < incoming_synced_at;
```

If the `synced_at` is older than the stored record, the sync is ignored.

### Client timestamp authority

The device timestamp is treated as authoritative for ordering within a single device.

Cross-device ordering is handled by section 27.

---

# 21. Sync History / Audit Trail

If health data affects rewards, prizes, or competitions, maintain an audit trail.

### Recommended audit table

```sql
CREATE TABLE step_syncs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    date DATE NOT NULL,
    steps INTEGER NOT NULL,
    device_id UUID NOT NULL REFERENCES user_devices(id),
    health_provider TEXT NOT NULL, -- 'healthkit', 'health_connect'
    synced_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, date, synced_at)
);
```

### What to log

- Every sync attempt (success or failure)
- The device ID that sent the sync
- The health provider used
- The cumulative total at sync time
- The timestamp of the sync

### When to use the audit trail

- **Rewards/competitions:** Use the audit trail to detect suspicious patterns.
- **Debugging:** Use it to trace sync issues per device.
- **Analytics:** Use it to study user engagement with health integration.

---

# 22. Daily Reset

The daily step count resets at midnight **in the health provider's local timezone**.

This means:

- HealthKit resets at 00:00 local time.
- Health Connect resets at 00:00 local time.

The app and backend should not assume a fixed UTC reset.

### Recommended approach

- The app reads steps for the current calendar day (local).
- The backend stores steps by date (local).
- When the date changes, start a new daily total.

### Handling timezone travel

If the user travels across timezones:

- The "current day" is based on the device's current local timezone.
- The health provider handles timezone transitions internally.
- The backend should store steps by date in the user's local timezone (or UTC+offset at sync time).

### Implementation note

HealthKit's `NSCalendar` handles timezone correctly.
Health Connect's `Instant` / `LocalDate` APIs handle this as well.
The `health` package normalizes this for the caller.

---

## See also

- [Overview](2026-08-29-01-overview.md)
- [Flutter Architecture](2026-08-29-02-flutter-architecture.md)
- [UI/UX](2026-08-29-06-ui-ux.md)
- [Multi-Device Rules](2026-08-29-05-multi-device-rules.md)
- [Backend Schema](2026-08-29-03-backend-schema.md)

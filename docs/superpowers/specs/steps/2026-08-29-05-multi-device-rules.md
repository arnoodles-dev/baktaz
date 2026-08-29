
# 23. Multiple Devices
> **Parent Spec:** `docs/superpowers/specs/Steps/2026-08-29-01-overview.md`

A single user account may register multiple devices over time.

Each device:

- Has its own health integration status.
- Has its own sync history.
- Is independent for step retrieval.

### Rules

- Do not merge step totals from multiple devices.
- Do not average step totals across devices.
- Do not combine HealthKit and Health Connect totals.
- Choose one **active/authoritative provider** per user for canonical totals.

---

# 24. Multiple iOS Devices

A user may connect multiple iOS devices:

- iPhone
- Apple Watch

### Behavior

- HealthKit **already aggregates** data from all Apple ecosystem sources.
- The iPhone reports the cumulative step total.
- The Apple Watch step data is included in the iPhone's HealthKit total.

### Rule

- Register both devices in the system.
- Use the **iPhone** as the canonical step source.
- Ignore the Apple Watch as a separate step source.
- The user is not double-counted.

---

# 25. Multiple Android Sources

A user may connect multiple Android sources:

- Phone
- Wear OS device
- Health Connect data from other apps

### Behavior

- Health Connect **already aggregates** data from all sources on the device.
- The phone reports the cumulative step total.

### Rule

- Register the phone as the step source.
- Do not count Wear OS steps separately from Health Connect.
- Do not count step data from other apps separately.

---

# 26. iOS + Android Same User

A user may sync from both:

- An iPhone (HealthKit)
- An Android phone (Health Connect)

### Rule

- Both devices are valid and supported.
- The **most recent sync** becomes the canonical total.
- Do not combine HealthKit and Health Connect totals.

---

# 27. Cross-Platform Double Counting

### Rule

Never add HealthKit steps and Health Connect steps together.

```text
❌ Wrong:
Total = iOS steps + Android steps

✅ Correct:
Use the most recent daily sync across all platforms.
```

If a user switches from iOS to Android, the Android daily total replaces the iOS total for that day.

---

# 27.1 Mid-Day Platform Switch

### Scenario

The user starts syncing from iOS in the morning, then switches to Android in the afternoon.

### Rule

- The **most recent sync per day** wins.
- The user's daily total is whatever was synced last.
- Do not merge the two.

---

# 28. Switching Platforms

If the user changes devices or health providers:

1. Disable the old integration on the backend.
2. Register the new device.
3. Re-validate health access.
4. Start new syncs from the new provider.

The backend treats the new provider as the authoritative source going forward.

---

# 29. Multiple Devices at Same Time

### Scenario

Two devices try to sync for the same user at the same time.

### Rule

- The **most recent `synced_at` timestamp** wins.
- The backend processes both syncs.
- The backend keeps only the latest one.

### Implementation

Each sync request includes:

```json
{
  "steps": 7842,
  "synced_at": "2024-01-15T14:30:00Z",
  "device_id": "device-abc-123",
  "health_provider": "healthkit"
}
```

The backend compares `synced_at` values and keeps the latest.

---

## See also

- [Overview](2026-08-29-01-overview.md)
- [Flutter Architecture](2026-08-29-02-flutter-architecture.md)
- [UI/UX](2026-08-29-06-ui-ux.md)
- [Backend Sync & Model](2026-08-29-04-backend-sync-model.md)
- [Backend Schema](2026-08-29-03-backend-schema.md)

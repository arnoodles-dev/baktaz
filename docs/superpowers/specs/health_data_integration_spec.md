# Health Data Integration & Step Synchronization Specification

**Status:** Proposed  
**Version:** 1.0  
**Platforms:** Flutter (iOS + Android), Serverpod backend  
**Health Providers:** Apple HealthKit, Android Health Connect

---

## 1. Overview

This specification defines how the application integrates with:

- **Apple HealthKit** on iOS
- **Android Health Connect** on Android

The primary use case is retrieving the user's **daily step count**, comparing it against an application-defined **daily target**, and synchronizing the resulting daily totals to the backend.

The design must handle:

- First-time health integration
- Missing HealthKit / Health Connect
- Permission denial or revocation
- Health Connect with no upstream source data
- Samsung Health → Health Connect scenarios
- Multiple watches/devices
- Multiple syncs per day
- Multiple phones
- Users who use both iOS and Android
- Device changes
- Stale/out-of-order sync requests
- Future fitness challenges, rewards, leaderboards, and prize-based features

---

# 2. Core Principles

## 2.1 Integrate with the Health Data Aggregator

The application should **not directly integrate with every wearable or health application**.

Instead:

```text
iOS:
Apple Watch / iPhone / supported apps
                ↓
            HealthKit
                ↓
           Flutter App

Android:
Galaxy Watch / Android Phone / Samsung Health / supported apps
                ↓
          Health Connect
                ↓
           Flutter App
```

HealthKit and Health Connect act as the platform-level aggregation layer.

---

## 2.2 Do Not Manually Add Device Step Counts

The application must request the platform's **aggregated/cumulative step total**.

It must not manually calculate:

```text
Apple Watch steps
+
iPhone steps
+
Samsung Health steps
=
Total steps
```

This can double-count the same physical activity.

Instead:

```text
HealthKit / Health Connect
        ↓
"How many steps has the user accumulated today?"
        ↓
Aggregated daily total
        ↓
Flutter
```

---

## 2.3 User Account Is Platform Independent

A user account must not be restricted to iOS or Android.

A user may have:

```text
User Account
├── iPhone
│   └── HealthKit
│
└── Android Phone
    └── Health Connect
```

The account remains the same.

The backend must therefore model **devices and health integrations separately from the user account**.

---

## 2.4 Device Integration Status Is Not the Same as Backend Status

The mobile device is the authority for:

> "Can this device currently access health data?"

The backend is the authority for:

> "Has this user configured health synchronization, and what health data has successfully been synchronized?"

The backend must not assume that:

```text
health_status = active
```

means the current device still has permission.

The Flutter app must periodically revalidate the integration.

---

# 3. Scope

## 3.1 Initial Scope

The first implementation supports:

- Reading step counts
- Daily step targets
- HealthKit integration
- Health Connect integration
- Integration status UI
- Permission handling
- Health service availability checks
- Step data availability checks
- Syncing daily step totals to Serverpod
- Multiple devices per account
- One authoritative health provider per user
- Sync history/audit trail

## 3.2 Out of Scope for Initial Version

- Writing data back into HealthKit/Health Connect
- Calories
- Distance
- Heart rate
- Sleep
- Workout records
- Full wearable-specific APIs
- Direct Samsung Health integration
- Direct Fitbit integration
- Direct Garmin integration

These may be added later through the same repository abstraction.

---

# 4. High-Level Architecture

```text
                         User Account
                              │
                    ┌─────────┴─────────┐
                    │                   │
                 iOS Device         Android Device
                    │                   │
                 HealthKit        Health Connect
                    │                   │
             ┌──────┴──────┐     ┌──────┴───────────┐
             │             │     │                  │
           iPhone       Watch  Phone          External Sources
                                             Samsung Health
                                             Fitbit/etc.
             │             │     │                  │
             └──────┬──────┘     └────────┬─────────┘
                    │                     │
                    ▼                     ▼
              Aggregated Steps      Aggregated Steps
                    │                     │
                    └──────────┬──────────┘
                               ▼
                          Flutter App
                               │
                         StepRepository
                               │
                               ▼
                            Serverpod
                               │
                               ▼
                    Canonical Daily Steps
```

---

# 5. Flutter Architecture

The health integration must be hidden behind a repository abstraction.

Recommended structure:

```text
lib/
├── features/
│   └── health/
│       ├── data/
│       │   ├── health_repository_impl.dart
│       │   └── health_service.dart
│       │
│       ├── domain/
│       │   ├── health_repository.dart
│       │   ├── health_integration.dart
│       │   ├── health_connection_diagnostic.dart
│       │   └── daily_steps.dart
│       │
│       └── presentation/
│           ├── health_integration_screen.dart
│           ├── health_integration_controller.dart
│           └── health_integration_state.dart
```

---

# 6. Health Repository

Recommended interface:

```dart
abstract interface class HealthRepository {
  Future<HealthConnectionDiagnostic> diagnose();

  Future<HealthConnectionDiagnostic> connect();

  Future<int> getTodaySteps();

  Future<List<DailySteps>> getStepsHistory({
    required DateTime start,
    required DateTime end,
  });

  Future<void> openHealthSettings();
}
```

The domain layer must not depend directly on HealthKit or Health Connect APIs.

---

# 7. Flutter Health Package

Use the Flutter `health` package as the initial platform abstraction.

Conceptually:

```text
Flutter
   │
   ▼
health package
   │
   ├── iOS → HealthKit
   │
   └── Android → Health Connect
```

The application should request only the permissions required for the initial feature:

```text
READ STEPS
```

Write permissions should not be requested unless a future feature explicitly requires writing health data.

---

# 8. Health Integration States

The application should not use a single boolean such as:

```dart
bool healthConnected;
```

Recommended state model:

```dart
enum HealthIntegrationStatus {
  checking,
  unsupported,
  serviceNotInstalled,
  serviceUnavailable,
  permissionRequired,
  permissionDenied,
  connectedNoData,
  connectedStaleData,
  connected,
  error,
}
```

The UI-facing status can be simplified while retaining more detailed diagnostic information internally.

---

# 9. Health Connection Diagnostic

The application should expose a diagnostic result:

```dart
class HealthConnectionDiagnostic {
  final HealthProvider provider;

  final bool serviceAvailable;
  final bool appPermissionGranted;
  final bool stepDataAccessible;
  final bool recentDataAvailable;

  final int? latestSteps;
  final DateTime? latestDataTime;

  const HealthConnectionDiagnostic({
    required this.provider,
    required this.serviceAvailable,
    required this.appPermissionGranted,
    required this.stepDataAccessible,
    required this.recentDataAvailable,
    this.latestSteps,
    this.latestDataTime,
  });
}
```

Possible provider values:

```dart
enum HealthProvider {
  healthKit,
  healthConnect,
}
```

---

# 10. Integration Validation

The application must validate the complete integration rather than relying only on the native permission result.

## Validation sequence

```text
User taps "Connect"
        ↓
Check health service availability
        ↓
Request required permission
        ↓
Validate access
        ↓
Read today's steps
        ↓
Validate returned data/query
        ↓
Mark integration state
```

The definition of **Connected** should be:

> The application can successfully access the user's step data through the platform health API.

Permission granted alone must not be treated as proof that the integration is working.

---

# 11. iOS HealthKit

## 11.1 Required Capability

Enable:

```text
HealthKit
```

in the iOS Runner target.

Add the appropriate HealthKit usage descriptions to `Info.plist`.

## 11.2 Step Data

The application reads:

```text
Step Count
```

from HealthKit.

## 11.3 Permission Validation

HealthKit's privacy model means that the application cannot reliably determine whether a user denied read access to a particular data type merely from the authorization result.

Therefore:

```text
request authorization
        ↓
attempt to read step data
```

must be part of the validation process.

A successful authorization call must not automatically mean:

```text
CONNECTED
```

## 11.4 Zero Steps

A result of zero must not automatically mean:

```text
permission denied
```

Zero may legitimately mean that there is no step data yet.

The application should use the broader diagnostic state rather than assuming zero means failure.

---

# 12. Android Health Connect

## 12.1 Availability

The application must determine whether Health Connect is available/configured on the device.

Possible state:

```text
Health Connect unavailable
```

must be handled separately from:

```text
Permission denied
```

and:

```text
No step data
```

## 12.2 Permission

The application requires read access to step data.

Conceptually:

```text
READ_STEPS
```

## 12.3 Data Availability

The application should verify that it can actually query step data after permission is granted.

---

# 13. Samsung Health / Health Connect Edge Case

A common Android scenario is:

```text
Galaxy Watch
      ↓
Samsung Health
      ↓
Health Connect
      ↓
Your App
```

Samsung Health may be recording steps while not sharing the required data with Health Connect.

The resulting application state may be:

```text
Health Connect available       ✓
App permission granted         ✓
Step data accessible           ✕
```

The application must **not** claim:

> "Samsung Health is disconnected."

because it cannot necessarily identify which upstream source is missing.

Instead display:

> "No step data found."

Then explain possible causes:

- The user has not generated step data.
- Samsung Health is not sharing data with Health Connect.
- Another source is not writing step data to Health Connect.
- The health data store has no recent data.

Provide:

```text
[ Open Health Connect ]
[ Check Again ]
```

---

# 14. Health Integration UI

The application should have a dedicated health integration screen.

## 14.1 Not Connected

```text
Health Data

Connect your health data
to automatically track your steps.

[ Connect ]
```

## 14.2 Service Missing

```text
Health Connect

Health Connect isn't available.

Install or enable Health Connect
to access your step data.

[ Set Up Health Connect ]
```

## 14.3 Permission Required

```text
Health Connect

Step access is required.

Allow the app to read your step count.

[ Allow Step Access ]
```

## 14.4 No Data

```text
Health Connect

No step data found.

Health Connect is working, but no
step data is currently available.

If you use Samsung Health, make sure
it is sharing steps with Health Connect.

[ Open Health Connect ]
[ Check Again ]
```

## 14.5 Connected

```text
Health Connect

✓ Connected

Your step data is being accessed successfully.

Today's Steps

7,842 / 10,000

███████████████░░░░░

Last synced
Just now

[ Manage Connection ]
```

## 14.6 Stale

```text
Health Connect

⚠ Connected, but data is stale.

We haven't received updated step data recently.

[ Check Again ]
```

---

# 15. Health Integration Checklist UI

A diagnostic checklist is recommended:

```text
Health Connect

✓ Health Connect available
✓ App permission granted
✓ Step data accessible
✓ Recent data available

Everything is ready.
```

Or:

```text
Health Connect

✓ Health Connect available
✓ App permission granted
✕ Step data accessible

No step data was found.

If you use Samsung Health, make sure
Samsung Health is sharing step data
with Health Connect.

[ Open Health Connect ]
[ Check Again ]
```

This provides substantially better troubleshooting than a single Connected/Disconnected status.

---

# 16. Daily Step Target

The daily target is an **application-level setting**.

It must not depend on HealthKit or Health Connect.

Example:

```text
User Settings
----------------
daily_step_target = 10000
```

The UI can calculate:

```dart
progress = actualSteps / targetSteps;
```

and:

```dart
remainingSteps = max(targetSteps - actualSteps, 0);
```

Example:

```text
7,842 / 10,000
78.4%
2,158 remaining
```

---

# 17. Daily Step Retrieval

The app should query the cumulative step count from the beginning of the local calendar day until the current time.

Conceptually:

```dart
Future<int> getTodaySteps() async {
  final now = DateTime.now();

  final startOfDay = DateTime(
    now.year,
    now.month,
    now.day,
  );

  return await health.getTotalStepsInInterval(
        startOfDay,
        now,
      ) ??
      0;
}
```

The exact API implementation may vary with the selected package version.

---

# 18. Multiple Syncs Per Day

This is a critical design rule.

Suppose:

```text
10:00 AM → 1,000 steps
2:00 PM  → 4,000 steps
6:00 PM  → 6,000 steps
```

These values are **cumulative snapshots**, not incremental values.

The backend must NOT calculate:

```text
1,000 + 4,000 + 6,000 = 11,000
```

Instead:

```text
10:00 → daily total = 1,000
2:00  → daily total = 4,000
6:00  → daily total = 6,000
```

The final canonical value is:

```text
6,000
```

---

# 19. Backend Sync Model

Recommended flow:

```text
HealthKit / Health Connect
        ↓
Today's cumulative steps
        ↓
Flutter
        ↓
Serverpod
        ↓
Update canonical daily record
```

Example:

### 10:00

```text
daily_steps
date = 2026-08-27
steps = 1000
```

### 14:00

```text
daily_steps
date = 2026-08-27
steps = 4000
```

### 18:00

```text
daily_steps
date = 2026-08-27
steps = 6000
```

The same daily record is updated.

---

# 20. Out-of-Order Sync Protection

Network requests can arrive out of order.

Example:

```text
14:00 → 4,000 steps
10:00 → 1,000 steps
```

If the 10:00 request arrives after the 14:00 request, the backend must not overwrite:

```text
4,000
```

with:

```text
1,000
```

At minimum, the backend should ensure that a new cumulative value does not move the canonical daily count backwards.

Possible rule:

```text
if incoming_steps >= current_steps:
    update
else:
    ignore stale snapshot
```

A more robust implementation should also track:

- sync timestamp
- source timestamp where available
- device
- request ID/idempotency key

---

# 21. Sync History / Audit Trail

Because step data may eventually affect challenges, rewards, leaderboards, or prize pools, storing sync snapshots is recommended.

Example:

```text
step_syncs

user_id | date       | steps | synced_at
------------------------------------------
123     | 2026-08-27 | 1000  | 10:00
123     | 2026-08-27 | 4000  | 14:00
123     | 2026-08-27 | 6000  | 18:00
```

Then maintain the canonical daily record:

```text
daily_steps

user_id | date       | steps
-----------------------------
123     | 2026-08-27 | 6000
```

This provides an audit trail without double-counting.

---

# 22. Daily Reset

Daily totals are based on the user's local calendar day.

Example:

```text
Aug 27
23:50 → 9,800

Aug 28
00:05 → 50
```

These are two separate daily records.

The application should query:

```text
start = local midnight
end   = now
```

for the current day.

The backend must store the date associated with the user's activity record.

Timezone handling must be explicitly defined to avoid incorrect day boundaries.

---

# 23. Multiple Devices

A user may have multiple devices:

```text
User
├── iPhone
│   └── HealthKit
│
├── Apple Watch
│   └── HealthKit source
│
└── Android
    └── Health Connect
```

HealthKit/Health Connect should handle aggregation of sources within their respective ecosystems.

The application must not manually sum source totals.

---

# 24. Multiple iOS Devices

Within the Apple ecosystem, HealthKit can aggregate data from supported Apple devices and sources.

The application should simply request the aggregated daily step count.

Do not implement:

```text
getIPhoneSteps()
getAppleWatchSteps()
```

and add them together.

Use the HealthKit aggregated result.

---

# 25. Multiple Android Sources

Health Connect can aggregate step data from multiple sources.

Examples:

```text
Samsung Health
Android phone
Galaxy Watch
Other supported health apps
```

Use the appropriate aggregate step query rather than summing individual source records.

This is important for avoiding duplicate activity.

---

# 26. iOS + Android for the Same User

The account must support:

```text
User
├── iOS device
│   └── HealthKit
│
└── Android device
    └── Health Connect
```

However:

**HealthKit does not automatically synchronize its data with Health Connect.**

The backend becomes the bridge between platform ecosystems.

---

# 27. Cross-Platform Double Counting

Suppose:

```text
HealthKit       = 8,000
Health Connect  = 7,500
```

The application must NOT calculate:

```text
15,500
```

These values may represent the same physical activity.

The recommended first-version rule is:

> **One authoritative health provider per user for canonical step totals.**

For example:

```text
active_health_provider = healthkit
```

or:

```text
active_health_provider = health_connect
```

---

# 28. Switching Platforms

If a user switches from iPhone to Android:

```text
Existing:
HealthKit = primary

New:
Health Connect = available
```

The app should ask:

```text
You're already syncing steps from Apple Health.

Would you like to switch your step source
to Health Connect?

[ Switch ]
[ Cancel ]
```

If the user switches:

```text
HealthKit
  → inactive for canonical syncing

Health Connect
  → primary
```

The user's account remains unchanged.

---

# 29. Multiple Devices at the Same Time

A user may have:

```text
iPhone
HealthKit
PRIMARY

Android
Health Connect
CONNECTED / SECONDARY
```

The secondary device can remain connected but must not automatically submit a competing canonical total.

Recommended UI:

```text
Health Data

✓ Apple Health
  Primary

✓ Health Connect
  Connected
  Not primary

Your steps are currently synced
from Apple Health.

[ Change Primary Source ]
```

---

# 30. Backend Data Model

Recommended initial schema:

## users

```text
id
...
active_health_provider
```

Possible values:

```text
healthkit
health_connect
null
```

## user_devices

```text
id
user_id
device_identifier
platform
app_version
last_seen_at
created_at
updated_at
```

## health_integrations

```text
id
user_device_id
provider
status
last_successful_sync_at
last_checked_at
created_at
updated_at
```

Possible status:

```text
not_connected
active
needs_attention
disabled
```

## daily_steps

```text
id
user_id
date
steps
source
source_device_id
last_synced_at
created_at
updated_at
```

## step_syncs

```text
id
user_id
date
steps
source
source_device_id
synced_at
request_id
created_at
```

`step_syncs` is the audit/history table.

---

# 31. Backend Health Integration Metadata

The backend should know that the user has configured health synchronization.

However:

```text
backend status = active
```

must not be treated as proof that the current device can still access health data.

The backend is responsible for:

- Tracking configuration
- Tracking the active provider
- Tracking devices
- Tracking last successful sync
- Storing canonical step data
- Detecting stale data
- Supporting challenges/rewards/leaderboards
- Maintaining an audit trail

The mobile application is responsible for:

- Checking platform availability
- Requesting permissions
- Reading health data
- Detecting revoked permissions
- Detecting missing data
- Revalidating the integration

---

# 32. Recommended API Flow

## Connect Health

```text
POST /health/integrations/connect
```

Example:

```json
{
  "provider": "health_connect",
  "deviceId": "device-123"
}
```

This should only be called after the mobile app has successfully validated the integration.

---

## Sync Daily Steps

```text
POST /health/steps/sync
```

Example:

```json
{
  "date": "2026-08-27",
  "steps": 4000,
  "provider": "health_connect",
  "deviceId": "device-123",
  "syncedAt": "2026-08-27T14:00:00+08:00",
  "requestId": "unique-request-id"
}
```

The backend:

1. Authenticates the user.
2. Validates that the device belongs to the user.
3. Validates that the provider is allowed.
4. Checks the active health provider.
5. Applies idempotency.
6. Rejects stale/backwards snapshots.
7. Updates the canonical daily total.
8. Stores the sync snapshot if audit history is enabled.

---

# 33. Recommended Sync Strategy

The app should sync when:

- User completes health integration
- App launches/resumes
- User opens the dashboard
- User manually taps "Sync"
- A relevant challenge screen is opened
- Optional periodic/background sync where platform capabilities permit

The application should not assume continuous background execution is always available.

---

# 34. App Resume Validation

Every time the application returns to the foreground:

```text
App resumed
    ↓
Validate health integration
    ↓
Can access health data?
    ├── YES → read today's steps → sync
    │
    └── NO  → update local status
                 ↓
             needsAttention
```

This handles cases where the user revoked permissions outside the application.

---

# 35. "Last Synced" vs "Connected"

The UI should display both concepts separately.

Example:

```text
✓ Health Connect
Connected

Today's steps
7,842 / 10,000

Last synced
Just now
```

A user can be:

```text
Connected
but
Last synced = 2 days ago
```

That should trigger a stale-data warning.

---

# 36. Health Integration Status Matrix

| Service | Permission | Data | Status |
|---|---|---|---|
| Missing | N/A | N/A | Service Missing |
| Available | No | N/A | Permission Required |
| Available | Denied | N/A | Permission Denied / Needs Attention |
| Available | Yes | None | Connected, No Data |
| Available | Yes | Old | Connected, Stale Data |
| Available | Yes | Recent | Connected |
| Error | Unknown | Unknown | Error |

For iOS, permission-denied detection must respect HealthKit's privacy model. The app should avoid falsely claiming that the user explicitly denied read access when the platform does not expose that distinction.

---

# 37. Canonical Step Calculation

For the initial version:

```text
Canonical Daily Steps
=
latest valid cumulative total
from the user's active health provider
```

Not:

```text
sum(all sync requests)
```

Not:

```text
sum(all devices)
```

Not:

```text
sum(HealthKit + Health Connect)
```

---

# 38. Example End-to-End Day

User has a 10,000-step goal.

### 10:00 AM

HealthKit:

```text
1,000
```

Backend:

```text
daily_steps = 1,000
```

### 2:00 PM

HealthKit:

```text
4,000
```

Backend:

```text
daily_steps = 4,000
```

### 6:00 PM

HealthKit:

```text
6,500
```

Backend:

```text
daily_steps = 6,500
```

### 9:00 PM

HealthKit:

```text
10,200
```

Backend:

```text
daily_steps = 10,200
```

Challenge:

```text
10,200 / 10,000

Completed ✓
```

The backend never calculates:

```text
1,000 + 4,000 + 6,500 + 10,200
```

---

# 39. Security and Anti-Cheat Considerations

If step data eventually influences money, rewards, prizes, or competition results, health data must be treated as user-provided external data and not blindly trusted.

Recommended safeguards:

- Authenticate every sync request.
- Associate syncs with a registered device.
- Associate the device with the authenticated user.
- Track the provider.
- Track sync timestamps.
- Use idempotency keys.
- Reject stale/backwards snapshots.
- Keep an audit history.
- Use server-side challenge evaluation.
- Never trust a client-provided "challenge completed" flag.
- Keep canonical totals on the backend.
- Avoid client-side reward decisions.

The architecture should make it possible to audit:

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

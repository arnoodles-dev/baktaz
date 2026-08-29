---
title: Health Data Integration - Overview
status: Proposed
version: 1.0
related: health_data_integration_spec.md
---

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

## See also

- [Flutter Architecture](flutter-architecture.md)
- [UI/UX](ui-ux.md)
- [Backend Sync & Model](backend-sync-model.md)
- [Multi-Device Rules](multi-device-rules.md)
- [Backend Schema](backend-schema.md)

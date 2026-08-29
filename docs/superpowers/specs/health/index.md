---
title: Health Data Integration - Master Index
status: Proposed
version: 1.0
related: health_data_integration_spec.md
---

# Health Data Integration — Master Index

This is the central index for the health data integration specification, which has been split into focused sub-specs for clarity and maintainability.

---

## Sub-Specs

### [1. Overview](overview.md)
Sections 1–4: Overview, Core Principles (2.1–2.4), Scope (3.1–3.2), High-Level Architecture (Section 4)

### [2. Flutter Architecture](flutter-architecture.md)
Sections 5–13: Flutter Architecture (5), Health Repository (6), Flutter Health Package (7), Health Integration States (8), Health Connection Diagnostic (9), Integration Validation (10), iOS HealthKit (11), Android Health Connect (12), Samsung Health edge case (13)

### [3. UI/UX](ui-ux.md)
Sections 14–17: Health Integration UI (14, all subsections 14.1–14.6), Health Integration Checklist UI (15), Daily Step Target (16), Daily Step Retrieval (17)

### [4. Backend Sync & Model](backend-sync-model.md)
Sections 18–22: Multiple Syncs Per Day (18), Backend Sync Model (19), Out-of-Order Sync Protection (20), Sync History/Audit Trail (21), Daily Reset (22)

### [5. Multi-Device Rules](multi-device-rules.md)
Sections 23–29: Multiple Devices (23), Multiple iOS Devices (24), Multiple Android Sources (25), iOS + Android same user (26), Cross-Platform Double Counting (27), Mid-day platform switch (27.1), Switching Platforms (28), Multiple Devices at Same Time (29)

### [6. Backend Schema](backend-schema.md)
Sections 30–43: Backend Data Model (30), Backend Health Integration Metadata (31), Recommended API Flow (32), Recommended Sync Strategy (33), App Resume Validation (34), "Last Synced" vs "Connected" (35), Health Integration Status Matrix (36), Canonical Step Calculation (37), Example End-to-End Day (38), Security and Anti-Cheat (39), Recommended UX (40), Recommended Product Decisions (41), Final Architecture (42), Key Rules Summary (43)

---

## Quick Reference

| Concern | Sub-Spec |
|---|---|
| What and why | [Overview](overview.md) |
| Flutter implementation | [Flutter Architecture](flutter-architecture.md) |
| User-facing screens | [UI/UX](ui-ux.md) |
| Sync behavior and semantics | [Backend Sync & Model](backend-sync-model.md) |
| Multi-device and cross-platform rules | [Multi-Device Rules](multi-device-rules.md) |
| Database schema and API | [Backend Schema](backend-schema.md) |

---

## Original Spec

The monolithic spec has been split from `docs/superpowers/specs/health_data_integration_spec.md`. See the individual sub-specs above for all content.

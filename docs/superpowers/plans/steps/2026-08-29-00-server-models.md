# Steps Server Models Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create Serverpod `.spy.yaml` model definitions for the Steps feature (`UserDevice`, `StepIntegration`, `StepSync`, `StepConnectionStatus`) in `baktaz_server/lib/src/features/steps/domain/model/`. Run `serverpod generate` to generate Dart DTOs in `baktaz_server` and `baktaz_client`, then create database schema migrations. DB design: Single `step_syncs` table as source of truth + write-through `daily_steps` cache.

**Architecture:** Define domain models using Serverpod's YAML model specification format under `baktaz_server/lib/src/features/steps/domain/model/`. Models follow the spec's entity definitions for device management, steps integration tracking, and step synchronization state.

**Tech Stack:** Dart 3.x, Serverpod 2.x ORM, PostgreSQL schema migration toolchain.

**Spec:** `docs/superpowers/specs/Steps/Index.md`

---

## Global Constraints

- Backend models use Serverpod `.spy.yaml` definitions under `lib/src/features/steps/domain/model/`.
- Database primary keys use `UuidValue` for `UserDevice` and `StepIntegration` (per serverpod-architecture.md).
- Immutability and type safety strictly enforced across all models.
- No editing generated files in `baktaz_client` or `lib/src/generated/`.

---

### Task 1: Serverpod Data Models & Codegen Migration

**Files:**
- Create: `baktaz_server/lib/src/features/steps/domain/model/user_device.spy.yaml`
- Create: `baktaz_server/lib/src/features/steps/domain/model/step_integration.spy.yaml`
- Create: `baktaz_server/lib/src/features/steps/domain/model/step_sync.spy.yaml`
- Create: `baktaz_server/lib/src/features/steps/domain/model/step_connection_status.spy.yaml`
- Modify: `baktaz_server/lib/src/features/home/domain/model/daily_steps.spy.yaml`

**Interfaces:**
- Consumes: Serverpod core framework YAML parser.
- Produces: Serverpod Dart model classes in `baktaz_server` and `baktaz_client`.

- [ ] **Step 1: Write the model YAML files**

Create `baktaz_server/lib/src/features/steps/domain/model/user_device.spy.yaml`:
```yaml
class: UserDevice
table: user_device
fields:
  userId: UuidValue
  deviceId: String
  deviceName: String
  platform: String  # 'ios' | 'android'
  osVersion: String?
  appVersion: String?
  isActive: bool
  lastSeenAt: DateTime
  createdAt: DateTime
  updatedAt: DateTime
```

Create `baktaz_server/lib/src/features/steps/domain/model/step_integration.spy.yaml`:
```yaml
class: StepIntegration
table: step_integration
fields:
  userId: UuidValue
  deviceId: String
  provider: String  # 'healthkit' | 'healthconnect'
  status: String  # 'pending' | 'connected' | 'disconnected' | 'error'
  lastSyncAt: DateTime?
  lastError: String?
  permissionsGranted: bool
  isAuthoritative: bool
  createdAt: DateTime
  updatedAt: DateTime
```

Create `baktaz_server/lib/src/features/steps/domain/model/step_sync.spy.yaml`:
```yaml
class: StepSync
table: step_sync
fields:
  userId: UuidValue
  deviceId: String
  integrationId: int
  syncedAt: DateTime
  stepCount: int
  syncSource: String  # 'healthkit' | 'healthconnect'
  isValid: bool
  validationNotes: String?
```

Create `baktaz_server/lib/src/features/steps/domain/model/step_connection_status.spy.yaml`:
```yaml
class: StepConnectionStatus
fields:
  hasActiveIntegration: bool
  provider: String?  # 'healthkit' | 'healthconnect'
  isAuthoritative: bool
  lastSyncAt: DateTime?
  syncStatus: String?  # 'synced' | 'pending' | 'error' | 'no_data'
  connectedDevices:
    - UserDevice
  errorMessage: String?
```

Modify `baktaz_server/lib/src/features/home/domain/model/daily_steps.spy.yaml` to add `sourceDeviceId`:
```yaml
# Add to existing fields:
sourceDeviceId: String?
```

- [ ] **Step 2: Run Serverpod codegen to verify syntax and model generation**

Run: `cd baktaz_server && fvm dart run serverpod_cli:serverpod generate`
Expected: Successfully generated protocol files in `baktaz_server` and `baktaz_client` without compilation errors.

- [ ] **Step 3: Create Serverpod database migration**

Run: `cd baktaz_server && fvm dart run serverpod_cli:serverpod create-migration --tag steps_feature_models`
Expected: Migration SQL files generated inside `baktaz_server/migrations/`.

- [ ] **Step 4: Verify generated Dart client models compile cleanly**

Run: `cd baktaz_client && fvm dart analyze`
Expected: `No issues found!`

---

## Verification Checkpoint

After completing this sub-plan:
- [ ] All `.spy.yaml` files created in `baktaz_server/lib/src/features/steps/domain/model/`
- [ ] `StepSync` model configured as source of truth and `daily_steps` updated with `sourceDeviceId`
- [ ] `serverpod generate` completed without errors
- [ ] Migration files created in `baktaz_server/migrations/`
- [ ] `baktaz_client` models compile cleanly
- [ ] No linter warnings in generated models

# RemoteConfig Architecture & System Specification — Merged

## 1. Executive Summary

This document merges the existing RemoteConfig specification with the security and unauthenticated-access design decisions from our discussion.

The RemoteConfig service enables dynamic feature toggling, parameter overrides, SemVer-based rollout constraints, and deterministic canary/A/B testing without requiring client application updates or redeployments.

The key security decision is:

> **RemoteConfig may be publicly readable because the Flutter application must be able to fetch it before authentication. It must therefore contain only data that is safe to expose publicly. Security for the endpoint should focus on abuse protection, not on trying to hide public configuration.**

General API rate limiting should preferably be implemented at the infrastructure/edge layer (for example, Cloudflare, a load balancer, or equivalent), rather than building a custom global rate limiter inside Serverpod. Serverpod remains responsible for authentication, authorization, and business-specific limits on sensitive operations.

---

## 2. Core Architecture: Entity Splitting & Transient Design

A single database table named `RemoteConfig` should not contain every configuration parameter as a column.

### Why `RemoteConfig` is Transient

1. **Schema Mutability:** New configuration keys should not require `ALTER TABLE` operations.
2. **Targeting Rule Complexity:** Individual keys can have independent override stacks.
3. **Optimized Client Delivery:** The client receives a compact dictionary with rules already evaluated server-side.
4. **Security Boundary:** The public response should be represented by an explicit DTO rather than exposing database entities directly.

### Architectural Solution: Entity Splitting

```text
┌─────────────────────────────────────────────────────────────┐
│                    PERSISTENT STORAGE                       │
│                     (PostgreSQL DB)                         │
│                                                             │
│   ┌────────────────────┐         ┌──────────────────────┐   │
│   │     ConfigKey      │1       *│  TargetingOverride   │   │
│   │ (Base Definitions) │─────────│ (Priority & SemVer)  │   │
│   └────────────────────┘         └──────────────────────┘   │
│              │                                              │
│              │ (Audit Versioning)                           │
│              ▼                                              │
│   ┌───────────────────────┐                                 │
│   │ ConfigSnapshotVersion │                                 │
│   └───────────────────────┘                                 │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ Evaluated at Runtime
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    PUBLIC RESPONSE                          │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ PublicRemoteConfig                                  │   │
│   │  ├── version                                        │   │
│   │  └── config: Map<String, RemoteConfigValue>         │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Security Model

### 3.1 Public Read, Protected Management

The read/evaluate endpoint must be callable by an unauthenticated Flutter client.

The management operations must require authentication and appropriate administrative authorization.

```text
PUBLIC
────────────────────────────────────
getRemoteConfig()
        │
        └── Safe public configuration only


ADMIN / AUTHENTICATED
────────────────────────────────────
createRemoteConfig()
updateRemoteConfig()
deleteRemoteConfig()
manage targeting overrides
publish / rollback configuration
```

The public endpoint must never expose secrets such as:

- payment provider secret keys
- database credentials
- JWT/signing secrets
- encryption keys
- webhook secrets
- internal administrative API keys

Anything returned to the Flutter application should be treated as public information.

### 3.2 Explicit Public DTO

Do not return a database model directly from the public endpoint.

Use:

```text
Persistent Model
    ↓
Server-side evaluation
    ↓
PublicRemoteConfig DTO
    ↓
Flutter
```

This creates a deliberate boundary between internal configuration metadata and client-visible configuration.

---

## 4. Infrastructure-Level Rate Limiting

### 4.1 Recommendation

General rate limiting should be implemented **before requests reach Serverpod**, using the deployment infrastructure.

Recommended architecture:

```text
                         INTERNET
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Cloudflare / LB      │
                 │                     │
                 │ • DDoS protection   │
                 │ • WAF               │
                 │ • IP rate limiting  │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      Serverpod      │
                 │                     │
                 │ Authentication      │
                 │ Authorization       │
                 │ Business limits     │
                 └──────────┬──────────┘
                            │
                            ▼
                    RemoteConfig
```

This follows the recommendation discussed in Serverpod Discussion #1860: infrastructure-level limiting is preferable for general request protection because abusive traffic can be rejected before it consumes application resources and because the mechanism naturally works across multiple Serverpod instances.

### 4.2 Initial Rate Limit

For the public RemoteConfig endpoint, a generous initial limit such as:

```text
100 requests / minute / IP
```

is sufficient as an initial protection measure.

This value is configurable and should be adjusted based on observed traffic.

The Flutter application should normally fetch RemoteConfig at application startup and cache it locally rather than requesting it repeatedly.

### 4.3 Why Not Use a Custom Redis Rate Limiter Initially?

A custom Redis-based limiter is unnecessary for this use case because:

- RemoteConfig is low-frequency traffic.
- Infrastructure can reject abusive traffic before Serverpod.
- Infrastructure-level limits work consistently across multiple Serverpod instances.
- It avoids maintaining custom distributed rate-limit state.

Redis remains useful for **caching RemoteConfig**, but should not be introduced solely to solve this rate-limiting problem.

### 4.4 Application-Level Limits

Serverpod should still enforce business-specific limits where the application needs contextual knowledge.

Examples:

```text
OTP:
    Maximum attempts per user/time window

Payout:
    Maximum payout requests per user/time window

Cash-in:
    Business-specific transaction limits

Challenge submission:
    Maximum valid submissions per challenge/user
```

These are different from general infrastructure rate limiting because the application understands the authenticated user and business operation.

---

## 5. Data Models & Schemas

The existing persistent models remain applicable.

### 5.1 `ConfigKey`

```yaml
class: ConfigKey
table: config_key
fields:
  key: String
  valueType: String       # STRING | BOOLEAN | INTEGER | DOUBLE | JSON
  defaultValue: String
  description: String?
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  config_key_key_unique_idx:
    fields: [key]
    unique: true
```

### 5.2 `TargetingOverride`

```yaml
class: TargetingOverride
table: targeting_override
fields:
  configKeyId: int
  configKey: ConfigKey?, relation
  priority: int
  appVersionConstraint: String?
  userTiers: List<String>?
  customSegmentValues: List<String>?
  rolloutPercentage: int?
  servedValue: String
  isActive: bool
indexes:
  targeting_override_priority_idx:
    fields: [configKeyId, priority]
```

### 5.3 `ConfigSnapshotVersion`

```yaml
class: ConfigSnapshotVersion
table: config_snapshot_version
fields:
  versionNumber: String
  updateTime: DateTime
  updateUserEmail: String
  updateOrigin: String
  updateType: String
indexes:
  config_version_number_idx:
    fields: [versionNumber]
    unique: true
```

---

## 6. Transient / Serializable Models

### `RemoteConfig`

```yaml
class: RemoteConfig
fields:
  config: Map<String, RemoteConfigValue>
  version: ConfigSnapshotVersion
```

### `RemoteConfigValue`

```yaml
class: RemoteConfigValue
fields:
  defaultValue: RemoteConfigDefaultValue
  valueType: String
  value: String
```

### `RemoteConfigDefaultValue`

```yaml
class: RemoteConfigDefaultValue
fields:
  value: String
```

### Security Note

For the public API, consider replacing or wrapping `ConfigSnapshotVersion` with a public-safe version DTO if audit metadata such as `updateUserEmail` must remain private.

In particular, an operator email address should generally not be sent to every unauthenticated client.

A public version object could instead contain only:

```yaml
class: PublicConfigVersion
fields:
  versionNumber: String
  updateTime: DateTime
```

---

## 7. API Endpoints

### 7.1 Public Read / Evaluate

```text
getRemoteConfig(
  Session session,
  {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment
  }
) -> Future<RemoteConfig>
```

The endpoint is unauthenticated because it must support first-launch and logged-out users.

The `userId`, `userTier`, and `customSegment` parameters should only be used when available. The server must not trust client-supplied authorization claims for protected functionality.

### 7.2 Management APIs

The following require authentication and administrative authorization:

```text
createRemoteConfig(...)
updateRemoteConfig(...)
deleteRemoteConfig(...)
create/update/delete TargetingOverride(...)
publish/rollback(...)
```

Management endpoints must never be exposed as unauthenticated calls.

---

## 8. RemoteConfig Request Flow

```text
Flutter App
    │
    │ getRemoteConfig()
    │
    ▼
Infrastructure
    │
    │ IP/WAF/rate-limit checks
    │
    ├── rejected → 429 / blocked
    │
    ▼
Serverpod
    │
    ├── Load compiled template from L1 cache
    │
    ├── L1 miss → L2 distributed cache
    │
    ├── L2 miss → PostgreSQL
    │
    ▼
Evaluate targeting rules
    │
    ▼
Build PublicRemoteConfig
    │
    ▼
Flutter
```

---

## 9. Targeting & Evaluation Engine

Each `ConfigKey` is evaluated against its ordered `TargetingOverride` rules.

```text
Evaluate ConfigKey
        │
        ▼
For each Override by Priority
        │
        ├── SemVer Match
        ├── User Tier Match
        ├── Segment Match
        └── Deterministic Canary Match
        │
        ▼
All Constraints Match?
    ├── YES → Serve servedValue and STOP
    └── NO  → Continue
        │
        ▼
No Override Matched
        │
        ▼
Serve defaultValue
```

### 9.1 SemVer

Examples:

```text
>= 2.0.0
< 2.0.0
= 2.4.0
```

### 9.2 Deterministic Canary

```text
UserScore =
  (Hash(userId + ":" + keyName) mod 100) + 1
```

If:

```text
UserScore <= rolloutPercentage
```

the user receives the rollout variant.

The assignment is deterministic and does not require storing per-user assignments.

### 9.3 Anonymous Users

For anonymous clients, a stable authenticated `userId` is unavailable.

Therefore, deterministic user-based canary assignment should not silently use a value that changes on every request.

If anonymous A/B testing is required, introduce a separate stable client installation identifier or anonymous subject identifier, while treating it only as a rollout/experimentation identifier and **not as an authentication credential**.

---

## 10. Multi-Layer Caching

The existing L1/L2 design remains appropriate:

```text
                 Serverpod Node
                       │
                 ┌─────▼─────┐
                 │ L1 Memory │
                 └─────┬─────┘
                       │ miss
                 ┌─────▼─────┐
                 │ L2 Redis  │
                 └─────┬─────┘
                       │ miss
                 ┌─────▼─────┐
                 │ PostgreSQL│
                 └───────────┘
```

### L1

Serverpod process-local memory:

```text
session.caches.local
```

### L2

Distributed cache:

```text
session.caches.global
```

Redis is appropriate for the shared cache when multiple Serverpod instances are deployed.

### Cache Invalidation

When configuration changes:

```text
Mutation
   ↓
Database transaction
   ↓
Create ConfigSnapshotVersion
   ↓
Invalidate L1/L2
   ↓
Publish config_updates event
   ↓
All nodes invalidate local cache
```

The cache key can remain:

```text
rc:compiled:template
```

with an appropriate TTL as a fallback against stale cache state.

---

## 11. Flutter Client Caching

The Flutter client should also cache the last successful RemoteConfig locally.

Recommended flow:

```text
App Launch
    │
    ├── Load local config immediately
    │
    ├── Start network refresh
    │
    ├── Network success → replace local config
    │
    └── Network failure → continue with cached config
```

The application should also maintain a safe hardcoded fallback for critical settings such as:

```text
minimum supported app version
maintenance behavior
feature defaults
```

RemoteConfig must never be the only source of truth for security-critical decisions.

---

## 12. Security Boundaries

RemoteConfig should control **client behavior**, not enforce security.

For example:

```text
RemoteConfig:
    showPayoutFeature = false
```

must not mean:

```text
Server:
    payout endpoint is disabled because the client says so
```

Instead:

```text
Flutter:
    hides payout UI

Serverpod:
    independently validates:
      - authentication
      - authorization
      - account state
      - transaction limits
      - business rules
```

A malicious client can modify its locally cached RemoteConfig, so server-side security must never depend on it.

---

## 13. Recommended Deployment Architecture

```text
                         INTERNET
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Cloudflare / LB      │
                 │                     │
                 │ WAF                 │
                 │ DDoS protection     │
                 │ IP rate limiting    │
                 └──────────┬──────────┘
                            │
             ┌──────────────┼──────────────┐
             ▼              ▼              ▼
       ┌──────────┐   ┌──────────┐   ┌──────────┐
       │Serverpod │   │Serverpod │   │Serverpod │
       │    #1    │   │    #2    │   │    #3    │
       └────┬─────┘   └────┬─────┘   └────┬─────┘
            │              │              │
            └──────────────┼──────────────┘
                           ▼
                    ┌─────────────┐
                    │    Redis    │
                    │ L2 Cache    │
                    │ Pub/Sub     │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ PostgreSQL  │
                    └─────────────┘
```

For a single-instance MVP, Redis can be omitted if the deployment does not need distributed caching. However, the architecture should leave room for adding it later.

---

## 14. Important Design Decisions

| Concern | Decision |
|---|---|
| Public RemoteConfig fetch | Allowed without authentication |
| Public config security | Treat returned configuration as public |
| Secrets | Never include in RemoteConfig |
| General rate limiting | Infrastructure/edge layer |
| Serverpod rate limiting | Use only for application/business-specific limits |
| Redis | Primarily for distributed RemoteConfig caching/invalidation |
| Database | PostgreSQL |
| Public response | Explicit DTO |
| Admin mutations | Authenticated + authorized |
| Targeting | SemVer + tier + segment + deterministic rollout |
| Anonymous rollout | Requires stable anonymous subject if deterministic behavior is desired |
| Client cache | Recommended |
| Server cache | L1 + optional L2 |
| Security enforcement | Always server-side |

---

## 15. Implementation Checklist

### Core RemoteConfig

- [x] Entity splitting: `ConfigKey`, `TargetingOverride`
- [x] `ConfigSnapshotVersion` audit model
- [x] Transient `RemoteConfig` response
- [x] SemVer evaluation
- [x] User-tier targeting
- [x] Custom-segment targeting
- [x] Deterministic canary rollout
- [x] L1/L2 server caching
- [x] Cache invalidation mechanism

### Security

- [x] Public unauthenticated read endpoint
- [x] Protected management endpoints
- [x] Explicit public DTO boundary
- [x] No secrets in RemoteConfig
- [x] Server-side authorization independent of RemoteConfig
- [x] Infrastructure-level rate limiting
- [x] Business-specific server-side limits for sensitive operations

### Client

- [x] Local RemoteConfig caching
- [x] Graceful offline fallback
- [x] Hardcoded safe defaults
- [ ] Define refresh strategy/TTL
- [ ] Define minimum supported app version behavior
- [ ] Define anonymous rollout identifier if anonymous A/B testing is required

### Deployment

- [ ] Configure Cloudflare/load-balancer rate limiting
- [ ] Configure WAF/DDoS protection where available
- [ ] Configure Redis for multi-instance deployments
- [ ] Configure PostgreSQL
- [ ] Configure production cache invalidation
- [ ] Monitor RemoteConfig request volume and 429 responses

---

## 16. Final Recommendation

The recommended design is:

```text
Flutter
   │
   │ Unauthenticated RemoteConfig request
   ▼
Edge / Infrastructure
   │
   │ DDoS + WAF + rate limiting
   ▼
Serverpod
   │
   │ PublicRemoteConfig evaluation
   ▼
L1 Cache
   │
   ▼
L2 Redis Cache
   │
   ▼
PostgreSQL
```

The most important architectural principle is:

> **Do not try to make RemoteConfig secret. Make the data safe to expose publicly, and protect the endpoint from abuse at the infrastructure layer.**

This keeps the RemoteConfig endpoint simple, supports unauthenticated Flutter startup, scales cleanly to multiple Serverpod instances, and avoids introducing a custom distributed rate-limiting system solely for a low-frequency configuration endpoint.

## Source Basis

The original RemoteConfig specification supplied for this merge defines the entity-splitting architecture, data models, targeting engine, CRUD operations, and L1/L2 caching strategy. fileciteturn0file0L9-L17 fileciteturn0file0L53-L57 fileciteturn0file0L360-L405 fileciteturn0file0L410-L418

The security and rate-limiting sections in this merged document incorporate the architectural decisions reached in our discussion, including the Serverpod Discussion #1860 recommendation to prefer infrastructure-level general rate limiting.

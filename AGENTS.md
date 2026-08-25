# Monorepo Agent Contract — Baktaz

This repository is a Flutter and Serverpod monorepo consisting of backend services, admin web/desktop management tools, client applications, and shared UI design systems.

---

## DOX Framework

AGENTS.md files are binding work contracts for their subtrees. Walk the DOX chain before editing: read root, then every child AGENTS.md along your path. Closer docs control local details, but no child may weaken parent rules.

After editing, update closest owning AGENTS.md — and any affected parents/children — when a change affects purpose, scope, contracts, workflows, or index contents. Remove stale text; trim obvious statements.

---

## Package Summaries

### 1. baktaz_server (Serverpod Backend)

Dart backend with Serverpod 2.x — API endpoints, database ORM, authentication, and admin infrastructure.

### 2. baktaz_admin (Flutter Admin Web/Desktop)

Flutter admin dashboard for users, analytics, content, localization, and remote configuration.

### 3. baktaz_flutter (Main Flutter Client)

User-facing mobile app (iOS, Android, Web) connecting to baktaz_server via baktaz_client.

### 4. baktaz_shared (Design System & Components)

Central UI library with reusable Flutter widgets, design tokens (DESIGN.md), and shared utilities.

### 5. baktaz_client (Generated Serverpod SDK)

Auto-generated client library produced by `serverpod generate` for strongly-typed Serverpod RPC.

---

## Tool Routing

Route tasks based on tool capability:

| Task Type                               | Use Tool                                    |
| --------------------------------------- | ------------------------------------------- |
| Symbol / Call graph / Impact analysis   | `codebase-memory-mcp_*` tools               |
| Session context / Past decisions / Bugs | `agentmemory_*` tools                       |
| Non-code docs / PDFs / Media            | Graphify commands                           |
| Domain architecture / Onboarding        | `codebase-memory-mcp` + Graphify (fallback) |

Guardrails:

- Prefer specialized tools over generic grep/read
- Check codebase-memory-mcp index status before querying
- Fall back to codebase-memory-mcp or Graphify if external tools unavailable

---

## Design Philosophy

Architecture decisions follow three principles:

### Depth

Avoid shallow modules. Interfaces must be smaller than implementation complexity they hide. High leverage = small interface → substantial behavior.

### Locality

Related logic, caching, and state transitions concentrate inside the module. Do not bleed behavior across the interface boundary.

### Seams

Put seams only where variations happen. One adapter = indirection; two adapters (prod + test) justify a seam.

Mandates:

1. **Entity State Resolution** — Expose single deep query seam for unified state. Hide eager-loading, cache, DTO mapping inside.
2. **State Locality in Presentation** — Coordinate coordinating UI states into single deep controller. No split into shallow controllers.
3. **Shared Platform Adapters** — Consolidate shared workflows into single deep controller in shared package.

---

## Detailed Rules

Detailed domain rules live in `.agents/rules/`:

| File                               | Scope                                                                             |
| ---------------------------------- | --------------------------------------------------------------------------------- |
| `operations.md`                    | Git workflow, Make targets, Serverpod execution, MCP tools, codegen, verification |
| `testing.md`                       | Unit/widget/golden/integration testing, mocking, coverage, DTD automation         |
| `flutter-architecture.md`          | Flutter structure, layers, Cubit/Repo, routing                                    |
| `serverpod-architecture.md`        | Serverpod structure, sessions, DB, API design                                     |
| `state-management-architecture.md` | Signals/Cubit/Bloc decision matrix                                                |
| `error-handling-architecture.md`   | Failure taxonomy, handler routing, side-effects                                   |
| `design-system.md`                 | UI wrappers, typography, colors, spacing                                          |
| `optimization.md`                  | Flutter + server performance                                                      |
| `code-quality.md`                  | Style, linting, formatting, exclusions                                            |
| `naming-convention.md`             | File/class/function naming                                                        |

Verbose code examples, checklists, and migration guides live in `.agents/reference/`.

---

## Child DOX Index

| Package | AGENTS.md | Purpose |
|---|---|---|
| `baktaz_server` | [server/AGENTS.md](baktaz_server/AGENTS.md) | Serverpod backend, API endpoints, DB |
| `baktaz_flutter` | [flutter/AGENTS.md](baktaz_flutter/AGENTS.md) | Main Flutter client app |
| `baktaz_admin` | [admin/AGENTS.md](baktaz_admin/AGENTS.md) | Admin dashboard (Flutter) |
| `baktaz_shared` | [shared/AGENTS.md](baktaz_shared/AGENTS.md) | Shared UI components, Failure, utilities |
| `baktaz_client` | — | Auto-generated, no AGENTS.md needed |

Each child AGENTS.md owns domain-specific instructions and references this root contract.

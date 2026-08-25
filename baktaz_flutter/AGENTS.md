# baktaz_flutter — DOX Contract

## Purpose

User-facing Flutter mobile app (iOS, Android, Web) connecting to baktaz_server via baktaz_client.

## Ownership

- **Owner**: Frontend team (mobile)
- **Dependencies**: baktaz_shared (UI components, Failure), baktaz_client (API client)
- **Dependents**: N/A (leaf package)

## Local Contracts

### Architecture Layers
- `features/<name>/` with data/, domain/, presentation/ subdirectories
- Cubits extend `CubitSignal<S>` (see `.agents/rules/state-management-architecture.md`)
- Repos return `TaskResult<T>`, never throw (see `.agents/rules/flutter-architecture.md`)

### Routing
- `go_router` + `go_router_builder` typed routes
- `RouteGuard` for authenticated routes
- See `.agents/reference/flutter-feature-structure.md` for directory tree

### Dependencies
- State: `bloc_signals`, `bloc_signals_flutter`, `signals_hooks`
- HTTP: `chopper`
- Utilities: `fpdart`, `trust_but_verify`, `envied`
- Forbidden: `serverpod_auth_*` legacy packages

## Work Guidance

### Creating a New Feature
1. Scaffold: `make create_feature --app=app`
2. Follow workflow in `.agents/reference/flutter-feature-workflow.md`
3. Presentation → Route → Cubit → Domain → Repo → DTOs → i18n → Codegen

### State Management
- Use `CubitSignal<S>` for state-driven UI (see `.agents/rules/state-management-architecture.md`)
- Wrap async calls in `safeRun()` (see `.agents/reference/error-handling-patterns.md`)
- Never store `Failure` objects in state — use generic error flags (Pattern B)

### Testing
- Widget tests = golden tests (Alchemist, 15% tolerance)
- Coverage: ≥80% overall, 100% for Cubit/Repo
- See `.agents/rules/testing.md` and `.agents/reference/testing-dtd-workflow.md`

## Verification

See `.agents/rules/operations.md` for verification commands.

## Child DOX Index

- `.agents/rules/flutter-architecture.md` — structure, layers, routing
- `.agents/rules/state-management-architecture.md` — Signals/Cubit/Bloc decisions
- `.agents/rules/error-handling-architecture.md` — Failure taxonomy, Pattern B
- `.agents/rules/design-system.md` — UI wrappers, typography, colors
- `.agents/rules/optimization.md` — Flutter performance rules
- `.agents/reference/flutter-feature-structure.md` — directory tree
- `.agents/reference/flutter-feature-workflow.md` — step-by-step feature creation

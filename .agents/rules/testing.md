---
trigger: glob
description: Unit, widget, golden, integration testing, mocking, coverage, and DTD automation (see package-specific rules in flutter-architecture.md, serverpod-architecture.md)
globs: **/test/**
---

# Testing

## Test Structure

### Flutter Test Structure

```
baktaz_flutter/test/
├── fixtures/              # Test data fixtures
├── unit/                  # Unit tests (flat, organized by feature)
│   ├── <feature>_cubit_test.dart
│   ├── <feature>_repository_test.dart
│   └── ...
├── widget/                # Widget tests (organized by feature)
│   ├── <feature>/
│   │   ├── <widget_name>_test.dart      # Widget tests
│   │   └── goldens/                     # Golden tests
│   │       ├── <widget_name>_macos/
│   │       ├── <widget_name>_ci/
│   │       └── ...
│   └── ...
└── utils/                 # Test utilities, mocks
    ├── generated_mocks.dart
    └── ...
```

**Rules:**
- Unit tests: Flat structure in `test/unit/`, named `<feature>_<type>_test.dart`
- Widget tests: Organized by feature in `test/widget/<feature>/`
- Golden tests: In `test/widget/<feature>/goldens/` with platform subfolders (macos, ci)
- No screen tests — only test widgets, not screens
- No interface tests — interfaces are contracts, not implementation
- No nested `domain/`, `data/`, `presentation/` folders in test paths

**Examples:**
```
test/unit/payment_cubit_test.dart
test/unit/payment_repository_test.dart
test/widget/payment/payment_method_tile_test.dart
test/widget/payment/goldens/payment_method_tile_macos/
test/widget/challenge/challenge_entry_ticket_test.dart
```

### Server Test Structure

```
baktaz_server/test/
├── fixtures/              # Test data fixtures
├── unit/                  # Unit tests (organized by feature)
│   ├── <feature>/
│   │   ├── <repository>_test.dart      # Repository unit tests
│   │   └── ...
│   └── ...
├── integration/           # Integration tests (organized by feature)
│   ├── <feature>/
│   │   ├── <endpoint>_test.dart        # Endpoint integration tests
│   │   └── <feature>_flow_test.dart    # End-to-end flow tests
│   └── ...
├── utils/                 # Test utilities, mocks
│   ├── generated_mocks.dart
│   └── ...
└── ...
```

**Rules:**
- Repository unit tests: In `test/unit/features/<feature>/`, test repository methods
- Endpoint integration tests: In `test/integration/features/<feature>/`, test full endpoint flows
- Named `<repository>_test.dart` or `<endpoint>_test.dart`
- No interface tests — interfaces are contracts, not implementation

**Examples:**
```
test/unit/features/payment/payment_repository_test.dart
test/unit/features/payout/payout_repository_test.dart
test/integration/features/payment/payment_endpoint_test.dart
test/integration/features/payment/webhook_payment_test.dart
test/integration/features/payout/payout_flow_test.dart
test/integration/features/ledger/double_entry_test.dart
```

## Implementation-First Workflow

### CRITICAL: Implementation Before Testing Rule

**CRITICAL:** Tests must NOT be written or executed until ALL implementation work is COMPLETE:
- Complete code implementation across ALL packages involved
- All codegen (localization, build_runner, serverpod generate) finished
- All code compiles cleanly
- All packages at the latest schema (migrations applied)
- All cross-package dependencies resolved

Testing is strictly prohibited until after these milestones. THIS IS A HARD REQUIREMENT — developers must wait until all implementation is complete before creating any tests.

### Original Implementation-First Workflow

1. Implement code, entities, repositories, UI components
2. Run codegen — see operations.md for full codegen order
3. Write tests after codegen complete
4. Verify coverage ≥ 80%

## Test Structure (Conventions)

- **AAA pattern**: Arrange-Act-Assert
- **Naming**: Descriptive names — `returns null when user does not exist`, `throws NotFoundException when id is empty`
- **Async & Cubits**: `bloc_test` for Cubits, `fake_async` for async

## Implementation Before Testing — Detailed Guidance

### Why This Sequence Exists

- **Complete coverage accuracy** — Test coverage is meaningless if code doesn't exist
- **Dependency assurance** — Tests depend on code being in stable state
- **Schema completeness** — Tests rely on database schema and generated client SDK
- **Cross-package integration** — Server + client + shared package dependencies must be fully resolved
- **Code generation safety** — Tests fail if codegen doesn't finish first

### What Counts as "Implementation Complete"

Implementation complete means:
✅ ALL non-test code written across **ALL packages**
✅ ALL codegen steps completed (slang → serverpod generate → build_runner)
✅ ALL code compiles without errors
✅ ALL database migrations applied
✅ ALL cross-package dependencies resolved and building
✅ Implementation reviewed and approved by architect if needed

### What Triggers Testing

Testing may only begin **after**:
1. Implementation complete and stable
2. Codegen finished for ALL packages
3. All components building successfully
4. All packages in sync (no partial/incomplete state)

### Implementation Timeline

- **Days 1-3:** Implementation phase (ALL packages)
- **Days 4-5:** Codegen phase
- **Days 6-7:** Compilation, migration, dependency resolution
- **Day 8:** Testing begins only after manual verification of complete implementation

## Mocking

- **Library**: `mockito` only. Never `mocktail` unless specified.
- **Generated mocks**: `@GenerateMocks` or `@GenerateNiceMocks` in `test/utils/generated_mocks.dart`. Reuse across tests.
- **Stubs**: `when`, `thenReturn`, `thenAnswer`
- **Type errors**: `provideDummy<T>(dummyValue)` in `flutter_test_config.dart`
- **Mockito codegen fallback**: When using `@GenerateNiceMocks` / `@GenerateMocks` in `test/utils/generated_mocks.dart`, all non-primitive return types and parameter types in the mocked interfaces must have `provideDummy<T>()` calls registered **inside that same `main()` function** before mock generation runs. Without these, Mockito falls back to `dynamic` types in generated mocks, causing invalid override errors (e.g. `Future<dynamic>` vs `Future<ConcreteType>`). Example:
  ```dart
  void main() {
    provideDummy<OtpVerificationResult>(
      const OtpVerificationResult(success: false),
    );
    provideDummy<RegistrationForm>(
      const RegistrationForm(email: '', password: ''),
    );
  }
  ```
  Re-run `build_runner` after adding dummies.

## Coverage Targets

| Type | Target |
|---|---|
| Overall | ≥80% |
| Unit (Repository, Bloc/Cubit) | 100% | (see state-management-architecture.md)
| Widget | ≥80% | (see flutter-architecture.md)
| `*_site` | Exempt from Flutter goldens |

## Coverage Exclusions

Each package has a `.coverage_exclude` file that defines files excluded from coverage reports. These exclusions apply when running coverage tools.

### baktaz_flutter
```
lib/app/*
Lib/main.dart
*.g.dart
*.freezed.dart
*.dto.dart
*.config.dart
*.chopper.dart
*_screen.dart
*_webview.dart
**/wrappers/*.dart
*_state.dart
**/pages/*
**/service/*
**/entity/*
**/dto/*
**/views/*
```

### baktaz_admin
```
lib/app/*
Lib/main.dart
*.g.dart
*.freezed.dart
*.dto.dart
*.config.dart
*.chopper.dart
*_screen.dart
*_webview.dart
**/wrappers/*.dart
*_state.dart
**/pages/*
**/service/*
**/entity/*
**/dto/*
```

### baktaz_server
```
**/app/*
**/generated/*
**/domain/**
**/*.chopper.dart
```

### baktaz_shared
```
*.g.dart
*.freezed.dart
*.dto.dart
*.config.dart
*.chopper.dart
*_state.dart
**/theme/*.dart
**/entity/*.dart
**/dto/*.dart
**/converters/*.dart
**/extensions/*.dart
*/formatters/*.dart
*/utils/*.dart
*/widgets/wrappers/*.dart
*/domain/*.dart
*/mixin/*.dart
*/observer/*.dart
```

## Widget & Golden Testing

- Widget tests = golden tests (Alchemist, 15% tolerance) — see flutter-architecture.md
- Goldens versioned by date
- Update with `--update-goldens`
- `*_site` exempt — use Jaspr testing patterns

## Integration & Server Testing

- **Repository unit tests**: Test repository methods directly with mocked dependencies
- **Endpoint integration tests**: Test full endpoint flows with real DB (via `withServerpod`)
- Server tests in `test/unit/` (repositories) and `test/integration/` (endpoints)
- Excluded from CI — require Docker/Postgres
- Run: `fvm dart test --concurrency=1` in `*_server` or `make test_server`

## Forbidden

- Full-screen widget tests
- UI component unit tests
- `mocktail` (unless specified)
- Interface tests
- Screen tests (only widgets)
- State class unit tests (`*_state_test.dart` or state data object tests)
- Nested `domain/`, `data/`, `presentation/` folders in test paths

## Automated App Testing via DTD

See `.agents/reference/testing-dtd-workflow.md` for step-by-step DTD automation procedure.

## Advanced Patterns

See `.agents/reference/testing-advanced.md` for:
- Advanced mocking strategies
- Stream testing
- BlocSignal testing
- Serverpod session testing
- Golden test maintenance

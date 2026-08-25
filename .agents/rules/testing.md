---
trigger: glob
description: Unit, widget, golden, integration testing, mocking, coverage, and DTD automation (see package-specific rules in flutter-architecture.md, serverpod-architecture.md)
globs: **/test/**
---

# Testing

## Implementation-First Workflow

1. Implement code, entities, repositories, UI components
2. Run codegen — see operations.md for full codegen order
3. Write tests after codegen complete
4. Verify coverage ≥ 80%

## Test Structure

- **AAA pattern**: Arrange-Act-Assert
- **Naming**: Descriptive names — `returns null when user does not exist`, `throws NotFoundException when id is empty`
- **Async & Cubits**: `bloc_test` for Cubits, `fake_async` for async

## Mocking

- **Library**: `mockito` only. Never `mocktail` unless specified.
- **Generated mocks**: `@GenerateMocks` or `@GenerateNiceMocks` in `test/utils/generated_mocks.dart`. Reuse across tests.
- **Stubs**: `when`, `thenReturn`, `thenAnswer`
- **Type errors**: `provideDummy<T>(dummyValue)` in `flutter_test_config.dart`

## Coverage Targets

| Type | Target |
|---|---|
| Overall | ≥80% |
| Unit (Repository, Bloc/Cubit) | 100% | (see state-management-architecture.md)
| Widget | ≥80% | (see flutter-architecture.md)
| `*_site` | Exempt from Flutter goldens |

Exclusions in `.coverage_exclude`.

## Widget & Golden Testing

- Widget tests = golden tests (Alchemist, 15% tolerance) — see flutter-architecture.md
- Goldens versioned by date
- Update with `--update-goldens`
- `*_site` exempt — use Jaspr testing patterns

## Integration & Server Testing

- Server integration tests in `test/integration/` — see serverpod-architecture.md
- Excluded from CI — require Docker/Postgres
- Run: `fvm dart test --concurrency=1` in `*_server` or `make test_server`

## Forbidden

- Full-screen widget tests
- UI component unit tests
- `mocktail` (unless specified)

## Automated App Testing via DTD

See `.agents/reference/testing-dtd-workflow.md` for step-by-step DTD automation procedure.

## Advanced Patterns

See `.agents/reference/testing-advanced.md` for:
- Advanced mocking strategies
- Stream testing
- BlocSignal testing
- Serverpod session testing
- Golden test maintenance
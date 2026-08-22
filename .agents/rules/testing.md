---
trigger: glob
description: Unit, widget, and integration testing, golden tests, mocking, and coverage rules
globs: **/test/**
---

# Testing

### Implementation-First Testing Workflow

- Implement code, entities, repositories, and UI components first.
- Execute batch codegen (`slang`, `build_runner`, `serverpod generate`) after code implementation is complete.
- Write unit tests (Repository, Bloc/Cubit) and Alchemist golden component tests after codegen.
- Run full test suite and verify coverage ≥ 80%.

### Test Structure & Organization

- **AAA pattern**: Arrange-Act-Assert.
- **Test Naming**: Use descriptive names: e.g., `returns null when user does not exist`, `throws NotFoundException when id is empty string`, `disables submit button while form is invalid`.
- **Async & Cubits**: `bloc_test` for Cubits, `fake_async` for async.
- **Modifying Implementation Code**: Do not change implementation files when adding tests; request review if truly needed.

### Mocking

- **Library**: `mockito` only. Never `mocktail` unless specified.
- **Mocks > Fakes**: Prioritize generated mocks over manual fakes.
- **Reusability**: Generate mocks in `test/utils/generated_mocks.dart` with `@GenerateMocks` or `@GenerateNiceMocks`; reuse across tests, do not regenerate per file.
- **Stubs**: Use `mockito` stub methods (`when`, `thenReturn`, `thenAnswer`).
- **Mockito Type Errors**: Register dummy with `provideDummy<T>(dummyValue)` in `flutter_test_config.dart` or test's `setUpAll` instead of custom wrappers.

### Integration & Server Testing

- Server integration tests in `test/integration/`; excluded from CI.
- Run in `*_server` directory: `fvm dart test --concurrency=1` or from root: `make test_server`.
- Forbidden: full-screen widget tests, UI component unit tests.

### Widget & Golden Testing

- **Widget tests**: Must mainly be golden tests (Alchemist, 15% tolerance).
- **Goldens**: Versioned by date. Update with `--update-goldens`.

### Coverage & Commands

- **Coverage Targets**:
  - Overall: ≥80%
  - Unit Tests (Repository, Bloc): 100%
  - Widget Tests: ≥80%
  - Exclusions per `.coverage_exclude`.
  - ***_site**: Exempt from Flutter goldens, use Jaspr patterns.

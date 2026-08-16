---
trigger: always_on
description: Code analysis, linting, formatting, coding style, and audit exclusions
---

# Code Quality

### Coding Defaults & Style

- Deletions over additions, boring over clever.
- `very_good_analysis` + `dart_code_metrics` with `--fatal-infos`.
- Width 120 chars.
- No hardcoded user-facing strings (use localization). **Exception: `*_server`**
- Prioritize using components found in `*_shared` package.

### Conditional Expressions

- Use ternary or switch expressions for simple if-else.

### Immutability & Data Classes

- Implement data classes (models, state, entities) using `freezed` as much as possible.
- Prefer `final` locally, `const` for compile-time values.
- Const constructors when all fields are final.
- Return unmodifiable collections.
- Use `copyWith()` in Freezed state classes.
- Never mutate collections directly. Use spread operator (`[...]`, `{...}`) to create new collections instead of `.add()`, `.remove()`, `.clear()`.

### Null Safety

- Avoid `!`; use `?.`, `??`, null checks, or pattern matching.
- Avoid `late` unless guaranteed initialization.
- Mark required params with `required`.

### Sealed Types & Patterns

- Use sealed classes for closed hierarchies.
- Exhaustive switch without default (`_`).

### Class Modifiers

- `interface class` – implementable only.
- `base class` – extendable only.
- `final class` – no external extension/implementation.
- `sealed class` – closed hierarchies.
- **Mockito Exception**: Mocked classes must NOT be final.

### Primary Constructors

- **SDK Requirement**: Dart `>=3.13.0` required across packages.
- **Primary Constructors Usage**:
  - Use Primary Constructors (`class Name(final Type field)`) for plain non-annotated classes, Value Objects (`value_object.dart`), plain DTOs, non-annotated service wrappers, and Serverpod endpoints.
- **Exceptions (Use Standard Generative/Factory Constructors)**:
  - **`@injectable` / `@lazySingleton` annotated classes** (Cubits, Blocs, Repositories): Keep standard generative constructors due to `injectable_generator` AST parser limitations.
  - **`@freezed` sealed union states & models**: Keep redirecting factory constructors (`factory Class.variant(...) = _Variant;`) for union variant generation and `freezed` AST parser compatibility.
  - **Flutter `StatelessWidget` / `@immutable` UI Widgets**: Keep standard `const` generative constructors (`const Name({super.key, ...});`) because primary constructors cannot be declared `const`.
- **Refactoring & Execution Workflow**:
  - Apply code changes first -> run codegen (`build_runner` / `serverpod generate`) after all code changes are complete -> run tests and analysis.

### Async / Futures

- Always `await` or use `unawaited()`.
- Never mark a function async without awaiting.
- Check `context.mounted` after async gaps.

### Imports

- Package imports only; order: `dart:` → `external package:` → `internal package:`.

### Formatting

- Run `fvm dart format lib test` inside each package; global `melos run format` only on CI.
- Trailing commas: automate on multi-line lists.

### Clean Code Constraints

- Functions < 50 lines.
- Files 200-400 lines typical, ≤ 800 max.
- Early returns, destructuring, lookup maps.
- Nesting ≤ 4 levels.
- Ban over-encapsulation: do not wrap single primitives in wrapper classes (e.g., `class UserEmail { final String value; }`). Use `typedef` or plain types. Apply this to Domain Models and DTOs.

### Extensions & Enums

- Prefer Dart extensions (`.let()`, custom `DateTime` extensions) over utility functions.
- Use enhanced enums for categorized values and related methods.

### Lint Fix Policy

- Fix ALL warnings when editing file.

### Exclusions

- Never audit/edit: `*_client`, `generated/`, `.dart_tool/`, `build/`, `**.g.dart`,`**.gen.dart`, `**.freezed.dart`, `**.config.dart`, `**.chopper.dart`, `**.mocks.dart`, `lib/app/generated/`, `lib/**/generated_plugin_registrant.dart`, `lib/src/generated/`, `test/integration/test_tools/**`.

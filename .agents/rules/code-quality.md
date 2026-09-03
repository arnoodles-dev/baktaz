---
trigger: always_on
description: Code analysis, linting, formatting, coding style, and audit exclusions
---

# Code Quality

## Style

- Deletions over additions, boring over clever
- `very_good_analysis` + `dart_code_metrics` with `--fatal-infos`
- Width 120 chars
- No hardcoded user-facing strings (use localization). **Exception: `*_server`**
- Prioritize `*_shared` components

## Expressions

- Ternary or switch for simple if-else
- Early returns, destructuring, lookup maps
- Prefer rewriting simple `if` statements into conditional (ternary) expressions
- Avoid `.substring()` — it operates on UTF-16 code units, not grapheme clusters. Use `string.characters.getRange(start, end).toString()` instead (handles emojis, composed characters correctly)

## Immutability

- `final` locally, `const` compile-time
- `copyWith()` in Freezed state classes
- Spread operator for collections: `[...]`, `{...}`
- Sealed classes for closed hierarchies

## Null Safety

- Avoid `!`; use `?.`, `??`, null checks, pattern matching
- Avoid `late` unless guaranteed initialization
- Mark `required` params

## Class Modifiers

- `interface class` — implementable only
- `base class` — extendable only
- `final class` — no external extension
- **Mockito Exception**: Mocked classes NOT final

## Constructors

- Primary constructors (`class Name(final Type field)`) for plain classes, Value Objects, DTOs, Serverpod endpoints
- Standard constructors for `@injectable`/`@lazySingleton` annotated classes, `@freezed` states, Flutter StatelessWidget (see flutter-architecture.md)

## Widgets

- Prefer `const BorderRadius.all(Radius.circular(x))` over `BorderRadius.circular(x)` and other non-const `BorderRadius` constructors — enables compile-time const propagation

## Constraints

- Functions < 50 lines
- Files 200-400 lines typical, ≤ 800 max
- Nesting ≤ 4 levels
- Ban over-encapsulation: no single-primitive wrappers (use `typedef` or plain types)

## Lint Fix

- Fix ALL warnings when editing file

## Exclusions

Never audit/edit:
```
*_client, generated/, .dart_tool/, build/, **/*.g.dart, **/*.gen.dart, **/*.freezed.dart,
**/*.config.dart, **/*.chopper.dart, **/*.mocks.dart, lib/app/generated/,
lib/**/generated_plugin_registrant.dart, lib/src/generated/, test/integration/test_tools/**
```
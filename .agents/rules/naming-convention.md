---
trigger: always_on
description: Naming rules for files, classes, variables, and DTOs
---

# Naming Conventions

## File Names (snake_case.dart)

Suffixes: `_screen`, `_page`, `_cubit`, `_state`, `_repository`, `_service`, `_endpoint`, `_widget`, `_dialog`, `.dto`, `i_*_repository`, `.spy.yaml`

Generated (no edit): `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.chopper.dart`, `*.mocks.dart`

## Class Names (PascalCase)

`{Feature}Cubit`, `{Feature}State`, `{Feature}Endpoint`, `{Feature}Repository`
- Flutter: `Cubit`, `State`, `Repository` (see flutter-architecture.md)
- Serverpod: `Endpoint`, `Repository` (see serverpod-architecture.md)

Interface: prefix `I` (e.g., `IFeatureRepository`)

DTO: suffix `DTO` (e.g., `UserDTO`)

Enum: PascalCase name, camelCase values, no suffix, location `domain/entity/enum/`

## Variables (camelCase)

- Vars, fields, params, static consts, named constructors, getters
- Private: leading `_`
- Length 3-30 chars; `id` exempt
- Follow `non_constant_identifier_names`

## Functions (verb-noun)

`fetchMarketData`, `calculateSimilarity`, `isValidEmail`

No noun-only names (`market`, `similarity`, `email`).
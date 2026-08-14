---
trigger: always_on
description: Naming rules for files, classes, variables, and DTOs
---

### File Names (`snake_case.dart`)
- Suffixes: `_screen`, `_page`, `_cubit`, `_state`, `_repository`, `_service`, `_endpoint`, `_widget`, `_dialog`, `.dto` (e.g., `user.dto.dart`), `i_*_repository`, `.spy.yaml`.
- Generated (no edit): `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.chopper.dart`, `*.mocks.dart`.

### Class Names (PascalCase)
- `{Feature}Cubit`, `{Feature}State`, `{Feature}Endpoint`, `{Feature}Repository`.
- Interface: prefix `I` (e.g., `IFeatureRepository`).
- DTO: suffix `DTO` (e.g., `UserDTO` matches `user.dto.dart`).
- Enum: PascalCase name, camelCase values, no suffix, location `domain/entity/enum/`.

### Variables & Identifiers
- `camelCase` for vars, fields, params, static consts, named constructors, getters.
- Private: leading `_`.
- Length 3‑30 chars; `id` exempt.
- Follow `non_constant_identifier_names`.

### Function Names (verb-noun pattern)
- Functions: verb-noun (`fetchMarketData`, `calculateSimilarity`, `isValidEmail`). No noun-only names (`market`, `similarity`, `email`).

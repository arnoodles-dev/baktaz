---
trigger: always_on
description: General codebase architecture standards for module depth, seams, and state locality
---

# Deepening Standards

### Principles
- **Depth**: Avoid shallow modules. An interface must be significantly smaller than the implementation complexity it hides. High leverage means a caller learns a small interface to trigger substantial behavior.
- **Locality**: Related logic, caching, and state transitions must concentrate inside the module, not bleed across the interface to callers.
- **Seams**: Put seams only where variations actually happen. One adapter is indirection; two adapters (e.g. production and test/fake) justify a seam.

### Mandates

1. **Entity State Resolution**
   When query interfaces resolve a logical domain entity with multiple facets (e.g., core records, summaries, default relations):
   - Expose a single deep query seam resolving a unified state object.
   - Do not split this into multiple shallow methods (e.g. separate getters for fields or individual child relations).
   - Hide database eager-loading, cache lookup, and DTO mappings within the implementation.

2. **State Locality in Presentation**
   When UI states coordinate multiple interactions (e.g. sorting, filtering, page sizes, and expansion/hierarchy toggles) over the same dataset:
   - Coalesce all coordinating states into a single deep controller/cubit.
   - Do not split view-model transformations, layout assembly, or expansion states into separate shallow controllers. Keep presentation logic local to one module.

3. **Shared Platform Adapters**
   When different packages or build targets share the same workflow (e.g., config parsing, parsing remote overrides, local fallback resolution):
   - Consolidate the workflow into a single deep controller in a shared package.
   - Use adapters to feed platform-specific parameters into the shared seam. Do not duplicate loading or validation logic across separate packages.

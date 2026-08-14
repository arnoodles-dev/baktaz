# Context Routing Rules

Enforce context-layer delegation matrix. Route tasks based on shape.

## Delegation Matrix

- **Symbol / Call graph / Impact analysis** -> Use `codebase-memory-mcp` (or `codegraph`) tools:
  - `codebase-memory-mcp_search_graph` / `codebase-memory-mcp_get_code_snippet`: find symbol definitions/locations.
  - `codebase-memory-mcp_trace_path`: trace callers, callees, data flow, and cross-service HTTP routes.
  - `codebase-memory-mcp_detect_changes`: run impact analysis on code changes.
- **Session context / Historical rationale / Past decisions / Past bugs** -> Use `agentmemory` tools:
  - `agentmemory_memory_smart_search` / `agentmemory_memory_recall`: retrieve decisions, bug history, and preferences.
  - `agentmemory_memory_timeline`: retrieve past events chronologically.
  - `agentmemory_memory_save`: persist new decisions, preferences, and post-mortems.
- **Docs / Spec PDFs / Non-code media** -> Run `Graphify` commands (Active/Available):
  - `/graphify .`: build cross-artifact graph mapping code, docs, PDFs, and assets.
  - `graphify export callflow-html`: generate call-flow diagrams.
- **Domain architecture / High-level onboarding** -> Run `Understand Anything` commands (External / Not Implemented):
  - `/understand`, `/understand-onboard`, `/understand-domain`: requires manual installation.
  - **Fallback**: Use `codebase-memory-mcp` to analyze packages/dependencies, and `Graphify` to view cross-artifact structure.

## Guardrails
- Do not use generic grep/read if specialized tool exists.
- Check codebase-memory-mcp index status before querying structure.
- Fall back to codebase-memory-mcp or Graphify if Understand Anything is requested but not present.

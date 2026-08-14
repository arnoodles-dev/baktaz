---
name: pre-session-check
description: >
  Pre-session validation workflow that verifies agentmemory, codebase-memory-mcp, graphify,
  context-routing, and ollama (LLM fallback) compliance are operational before starting development.
  **MANDATORY**: Enforces agentic tool priority over native tools, and
  confirms the model can detect and follow the project's governance files (`.agents/rules/**`, `AGENTS.md`,
  `DESIGN.md`). Run at session start or when tools misbehave.
  Use when user says "pre-flight", "check tools", "validate session", "are tools up", or "/pre-session-check".
user-invocable: true
---

**🚨 MANDATORY AGENTIC TOOL PRIORITY ENFORCEMENT 🚨**

Before proceeding with any task, you MUST:
1. Verify agentic/MCP tools exist for the required operation
2. Use agentic tools FIRST - never default to native/shell tools
3. Only fall back to native tools when NO agentic equivalent exists
4. Document tool choice rationale in your session

Run lightweight validation on all core tools before session work begins. Entire sequence: ~60 seconds.

## Quick start

```text
/pre-session-check
```

Runs all tool checks in sequence, reports pass/fail per tool, outputs gate decision.

## Why

Starting work with a dead tool wastes context. Agentmemory silently loses observations. Codebase Memory returns stale AST. Catch early, fix fast.

## Agentic Tool Priority (MANDATORY)

**FAILURE TO FOLLOW THESE RULES WILL RESULT IN IMMEDIATE CORRECTION AND POTENTIAL SESSION TERMINATION**

Before using any native/shell tool, you MUST follow this priority decision tree:

### Priority Rules

| Native Tool | Agentic Replacement | Mandatory Usage Condition |
|-------------|--------------------|-----------------------------|
| `grep` / `rg` | `codebase-memory-mcp search_graph`, `search_code`, `trace_path` | Codebase navigation, finding definitions/callers |
| `glob` | `codebase-memory-mcp search_graph` with `file_pattern` | Finding files by pattern |
| `read` | `codebase-memory-mcp get_code_snippet` | Reading specific functions/classes |
| `bash_run` | MCP tools first | Shell commands only when no MCP equivalent |
| `list` | `codebase-memory-mcp list_projects`, `list_mcp_resources` | Listing resources |

### Tool Verification Checklist

At session start, run:

1. **AgentMemory**: `agentmemory_memory_smart_search` test query
2. **Codebase Memory**: `codebase-memory-mcp search_graph` test query
3. **Graphify**: Verify `graphify-out/` exists, run `graphify query "<question>"`
4. **Context Routing**: Confirm `.agents/rules/*.md` files readable
5. **Design System**: Confirm `DESIGN.md` exists and readable

### Failure Handling

| Tool | Symptom | Recovery |
|------|---------|----------|
| AgentMemory | Query returns empty/error | Run `agentmemory_memory_diagnose`, `agentmemory_memory_heal` |
| Codebase Memory | Project not found | Run `codebase-memory-mcp_index_repository` |
| Graphify | `graphify-out/` missing | Run `graphify update .` |
| Context Routing | Rules unreadable | Verify `.agents/rules/*.md` files exist |

## Workflow

1. **Pre-Session Check**: Validate tools (this skill).
2. **Rule Order**: Global Rules → Project AGENTS.md → `.agents/rules/` → Prompt.
3. **DOX Pass**: Required before task close.
4. **Testing**: See `.agents/rules/ci-commands.md`.

## Rule Enforcement

All users MUST:
- Read root `AGENTS.md` before editing
- Read child `AGENTS.md` for package-specific rules
- Load `.agents/rules/code-quality.md` for style rules
- Follow priority order: Global → Project → Package → Prompt

## References

- `./AGENTS.md` — Main agent contract
- `./.agents/rules/*.md` — Rule definitions
- `./.agents/skills/*.md` — Skill definitions
- `./DESIGN.md` — Design system truth

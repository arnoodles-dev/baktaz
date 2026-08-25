---
trigger: always_on
description: Decision framework for Signals, CubitSignal, BlocSignal, and Flutter Hooks
globs: *_flutter/lib/**, *_admin/lib/**, *_shared/lib/**, lib/**
---

# State Management

## Decision Matrix

| Primitive | Use When | Example |
|---|---|---|
| `signal()` | Ephemeral local UI state | tab index, toggle |
| `computed()` | Derive from signals, no side effects | filtered list |
| `CubitSignal<State>` | State-driven UI with external inputs | `AccountCubit` |
| `BlocSignalPresentationMixin<SideEffect, State>` | One-shot side effects without state change (rare — use only when needed) | `HomeCubit` |
| `BlocSignal<Event, State>` | Complex event routing, concurrency | `HomeCubit` (mixin variant) |

> **Signals vs Cubits:** Local toggle → `signal()`. Cross-screen state → `CubitSignal`.

## Hooks (HookWidget)

| Hook | Use When |
|---|---|
| `useSignalValue(signal)` | Consume signal without widget wrapper |
| `useSignalEffect()` | One-shot side effects from signal changes |
| `useComputed(fn)` | Fine-grained derived selectors |
| `useMemoized(factory)` | Memoized values |
| `useState(initial)` | Local UI state |

## Providers (flutter_hooks)

| Provider | Use For |
|---|---|
| `BlocSignalProvider.value(value:)` | `@lazySingleton` Cubits |
| `BlocSignalProvider(create:)` | `@injectable` factory Cubits |
| `BlocSignalBuilder<C, S>` | State-driven rebuilds |
| `BlocSignalListener<C, S>` | Side effect listeners |
| `BlocSignalConsumer<C, S>` | Combined builder + listener |
| `context.select<C, R>(fn)` | Narrow selectors |

## State Access Patterns

- **`stateValue`**: Use for synchronous reads in non-reactive contexts (init, dialogs, one-time reads)
- **`state`**: Use for reactive subscriptions and stream-based listeners

Example:
```dart
// ✅ Sync read in dialog
final state = cubit.stateValue;

// ✅ Reactive subscription
final sub = cubit.state.listen((s) => ...);

// ❌ Don't use stateValue in build() — causes unnecessary rebuilds
```

## Error Handling Contract

Per error-handling-architecture.md:
- Wrap async repo calls in `safeRun(onException:)`
- Pattern B: side-effect only, state stores generic flags
- State NEVER stores `Failure` objects

## API Reference

| Need | API | Package |
|---|---|---|
| Local UI state | `useState<T>(initial)` | `flutter_hooks` |
| Reactive primitive | `signal<T>(initial)` | `signals_flutter` |
| Derived value | `computed(fn)` | `signals_flutter` |
| Side effect | `useSignalEffect(fn)` | `signals_hooks` |
| Global state (simple) | `CubitSignal<State>` | `bloc_signals` |
| Global state (events) | `BlocSignal<Event, State>` | `bloc_signals` |
| Side effects (rare) | `BlocSignalPresentationMixin<SideEffect, State>` | `bloc_signals_flutter` |
| DI singleton | `BlocSignalProvider.value(value:)` | `bloc_signals_flutter` |
| DI factory | `BlocSignalProvider(create:)` | `bloc_signals_flutter` |
| Result folding | `taskResult.fold(onLeft, onRight)` | `fpdart` |

## Common Mistakes

See `.agents/reference/state-management-mistakes.md` for code examples of common mistakes (signals in build(), calling Cubit after dispose, setState during build).

## Reference Docs

See `.agents/reference/`:
- `state-management-code-examples.md` — full code samples
- `state-management-decision-trees.md` — extended decision trees

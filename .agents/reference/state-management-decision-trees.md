# State Management — Decision Trees

This file contains extracted decision guidance from the original `state-management-architecture.md`.

---

## Local State Decision Tree

```
Is the state local to a single widget (ephemeral)?
├── YES: Is it a simple value?
│   ├── YES: Use `useState<T>(initial)`
│   └── NO: Use `signal<T>(initial)`
└── NO: Is the state shared across widgets?
    ├── YES: Use CubitSignal or BlocSignal (see Global State Tree)
    └── NO: Consider if state should be local
```

### When to use `signal()` vs `useState()`

| Scenario | Use |
|---|---|
| Simple toggle, counter, form field | `useState<T>(initial)` |
| Needs reactive computation | `signal()` + `computed()` |
| Complex state with multiple related values | `signal()` + `computed()` |
| State needs to persist across widget rebuilds | `signal()` (initialized outside build) |

---

## Global State Decision Tree

```
Does the state need external inputs (repo calls, user actions)?
├── NO: Is it a simple shared value?
│   ├── YES: Consider `signal()` + provider
│   └── NO: Consider if global state is needed
└── YES: Does the state need complex event routing?
    ├── NO: Use `CubitSignal<State>`
    └── YES: Use `BlocSignal<Event, State>`
```

### When to use CubitSignal vs BlocSignal

| Scenario | Use | Reason |
|---|---|---|
| Auth state, user profile | `CubitSignal<State>` | Simple state transitions |
| Search with debounce, droppable events | `BlocSignal<Event, State>` | Event ordering matters |
| Form wizard | `BlocSignal<Event, State>` | Sequential steps |
| Settings | `CubitSignal<State>` | Independent toggles |
| Navigation state | `CubitSignal<State>` | Simple location tracking |

---

## Side Effects Decision Tree

```
Does the state change need to trigger a side effect?
├── NO: No action needed
└── YES: What type of side effect?
    ├── Navigation: Use `useSignalEffect()` or `BlocSignalListener`
    ├── Toast/SnackBar: Use `FailureHandler` (see error-handling-architecture.md)
    ├── Analytics: Use `useSignalEffect()` with analytics service
    └── External action (e.g., API call): Consider if this belongs in state management
```

### Side Effect Implementation by Widget Type

| Widget Type | Side Effect API |
|---|---|
| `HookWidget` | `useSignalEffect()` |
| `StatelessWidget` | `BlocSignalListener` / `BlocSignalConsumer` |
| `StatefulWidget` | `BlocSignalListener` in `initState` + `addListener` |
| Inside `build()` | Use `BlocSignalListener` (not `addListener` in build) |

---

## Computed/Derived State Decision Tree

```
Does the widget need a value derived from state?
├── NO: Use raw state value
└── YES: Is it derived from signals?
    ├── YES: Use `computed()` (owned) or `useComputed()` (HookWidget)
    └── NO: Is it derived from Cubit/Bloc state?
        ├── YES: Use `BlocSignalBuilder` with `listenWhen`
        └── NO: Use `context.select()`
```

### Computed Placement

```dart
// ❌ WRONG — computed inside build (creates new computed every build)
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useSignalValue(cubit.state);
    final doubled = computed(() => count.value * 2); // WRONG: recreated every build
    return Text('${doubled.value}');
  }
}

// ✅ CORRECT — computed owned by widget, outside build
class MyWidget extends HookWidget {
  late final _doubled = computed(() => counterCubit.state.value * 2);

  @override
  Widget build(BuildContext context) {
    return Text('${_doubled.value}');
  }
}

// ✅ CORRECT — useComputed in HookWidget
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useSignalValue(counterCubit.state);
    final doubled = useComputed(() => count.value * 2);
    return Text('${doubled.value}');
  }
}
```

---

## Error Handling Integration

Per `error-handling-architecture.md`:

```
Does the async operation need error handling?
├── NO: Direct await
└── YES: Does it need UI feedback?
    ├── NO: Use `safeRun` with `onException` omitted (background work)
    └── YES: Use `safeRun` with `onException: _failureHandler.handleException`
```

### Error State Pattern (Pattern B)

```dart
// ✅ CORRECT — side-effect only, state stores generic flag
await safeRun(
  action: () async => emit(await _repo.login()),
  onException: _failureHandler.handleException,
);
// Side effect fires via handleException → handleFailure
emit(const AuthState.failed()); // generic flag only

// ❌ WRONG — Failure in state
result.fold(
  (failure) => emit(AuthState.failed(failure)), // FORBIDDEN
  (_) => emit(const AuthState.loggedIn()),
);
```

---

## Migration Checklist

When converting existing code:

- [ ] Identify local state → migrate to `useState` or `signal()`
- [ ] Identify shared state → migrate to `CubitSignal`
- [ ] Identify event-driven state → migrate to `BlocSignal`
- [ ] Remove `_emitError` helpers → Pattern B side-effect handling
- [ ] Remove `Failure` fields from state classes → generic flags
- [ ] Move computed values outside `build()` if using `computed()`
- [ ] Add `context.mounted` checks before calling cubits from callbacks
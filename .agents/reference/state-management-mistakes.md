# State Management — Common Mistakes

[Extracted from state-management-architecture.md — mistake code blocks]

## Creating signals in build()

```dart
// ❌ WRONG — creates new signal every build
final count = signal(0);
final derived = computed(() => count.value * 2);

// ✅ CORRECT — initialize outside build
late final _count = signal(0);
late final _derived = computed(() => _count.value * 2);
```

## Calling Cubit after dispose

```dart
// ❌ WRONG — may run after dispose
context.read<SomeCubit>().doSomething();

// ✅ CORRECT — check mounted
if (mounted) context.read<SomeCubit>().doSomething();
```

## setState during build

```dart
// ❌ WRONG — triggers setState during build
controller.text = displayValue;

// ✅ CORRECT — postFrameCallback
WidgetsBinding.instance.addPostFrameCallback((_) {
  controller.text = displayValue;
});
```

## Key Principles

- Signals must be initialized once, not recreated per build
- Always check `mounted` before calling Cubit methods
- Never call `setState()` or controller mutations during build

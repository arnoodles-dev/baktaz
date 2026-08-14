---
trigger: glob
description: Flutter performance optimization, widget tree, rendering, async, and memory rules
globs: *_flutter/**, *_admin/**, lib/**
---
# Flutter Optimization Rules

### Widget Tree & Rebuilds
- Prioritize widget types: `StatelessWidget` > `HookWidget` (from `flutter_hooks`) > `StatefulWidget`.
- Enforce `const` on immutable widgets.
- Extract large `build()` methods to sub-`StatelessWidget` classes. No helper methods returning `Widget`.
- Scope state rebuilds low using `ValueListenableBuilder` or selectors.
- Never override `operator ==` on Widget. Avoids O(N²) layout tree check degradation.
- Pass static subtrees to `child` parameter of `AnimatedBuilder` to skip rebuilding on every tick.

### Paint & Layout Costs
- Isolate paint regions with `RepaintBoundary` around fast-updating subtrees (animations, custom painters).
- Avoid `Opacity` widget. Use alpha on `Color` or `AnimatedOpacity`.
- Avoid heavy clipping (`ClipRRect`, `ClipOval`). Use `BorderRadius` on `BoxDecoration`.
- Do not call `saveLayer()`. Prevents expensive offscreen rendering.
- Enforce `.builder` lazy constructors for lists and grids.

### Async & Memory
- Run CPU-bound logic (JSON parsing, cryptography) in isolates via `Isolate.run()`.
- Initialize `Future`/`Stream` variables outside `build()` (e.g., in `initState` or `useEffect`) to prevent re-execution on rebuild.
- Call `dispose()` on all controllers, listeners, and subscriptions (or use `useAnimationController`, `useTextEditingController`, etc., via hooks to handle lifecycle automatically).
- Use `Future.wait([])` for parallel independent futures. Do not `await` sequentially when calls are independent.

### Assets & Caching
- Specify `cacheWidth`/`cacheHeight` on local images to reduce RAM decodes.
- Cache network images using `CachedNetworkImage`.
- Prioritize vector graphics (SVGs) over raster formats.

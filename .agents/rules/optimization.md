---
trigger: glob
description: Flutter and Serverpod performance optimization rules
globs: *_flutter/**, *_admin/**, *_server/**, lib/**
---

# Performance Optimization

## Flutter Widgets & Rebuilds

- Prioritize: `StatelessWidget` > `HookWidget` > `StatefulWidget`
- Enforce `const` on immutable widgets
- Extract large `build()` methods to sub-StatelessWidget classes
- Scope rebuilds low: `ValueListenableBuilder`, selectors, `context.select`
- Never override `operator ==` on Widget
- Pass static subtrees to `child` param of `AnimatedBuilder`

## Flutter Paint & Layout

- `RepaintBoundary` around fast-updating subtrees
- Avoid `Opacity` widget — use alpha on `Color` or `AnimatedOpacity`
- Avoid heavy clipping — use `BorderRadius` on `BoxDecoration`
- Do not call `saveLayer()`
- Use `.builder` constructors for lazy lists/grids

## Flutter Async & Memory

- CPU-bound logic in isolates via `Isolate.run()`
- Initialize `Future`/`Stream` outside `build()`
- `dispose()` all controllers, listeners, subscriptions
- `Future.wait([])` for parallel independent futures

## Flutter Assets & Caching

- `cacheWidth`/`cacheHeight` on local images
- `CachedNetworkImage` for network images
- Prefer vector (SVG) over raster

## Server Performance

- DB indexing for query optimization
  - See serverpod-architecture.md for DB transactions and multi-write operations
- Set timeouts on DB queries and API calls
- Use `session.caches.local` for in-memory caching
- See serverpod-architecture.md for session/cache rules
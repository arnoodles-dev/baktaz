# 2026-08-22-02 Discovery Plan

> **PREREQUISITE:** This plan depends on `2026-08-22-00-foundation-plan.md` being complete. Do not start until `IChallengeDiscoveryRepository`, `ChallengeCubit`, and typed routes exist.

**Goal:** Implement the Discovery page (`/challenge/explore`) with public challenge search, card listing with filters, empty state, debounced search, and challenge card layout.

**Spec:** `docs/superpowers/specs/challenge/2026-08-22-02-discovery.md`

## Tasks

- [ ] **Task 1: ChallengeExploreCubit** (`challenge_explore_cubit.dart`)
  - Connect to `ChallengeDiscoveryRepository`
  - State: `ExploreState` (loading, loaded, empty, error)
  - Methods: `init()`, `refresh()`, `applyFilter()`, `search()`, `loadMore()`, `navigateToDetails()`
   - Cubit mixes in `BlocSignalPresentationMixin` and uses `safeRun(onException: _failureHandler.handleException)`. The `ChallengeExploreScreen` listens to its own presentation stream for error toasts (Q2 — per-cubit side-effect architecture, aligned with foundation plan).

- [ ] **Task 2: ExploreFilter VO**
  - Create `ExploreFilter` freezed VO: `{rewardModes, durations, feeRange, sort, descending}`
  - `activeCount` computed getter for badge
  - Apply/Clear both refetch page 1

- [ ] **Task 3: ChallengeExploreScreen**
  - Search bar with 300ms debounce
  - Filter chips bar
  - Vertical list of challenge cards
  - Pull-to-refresh

- [ ] **Task 4: Challenge Card Widget**
  - "The Ledger" layout (Variation 1): header, description (1 line ellipsis), host row, details row, footer with slot progress + prize pool
  - Entire card tappable → `navigateToDetails(summary)`

- [ ] **Task 5: Filter Bottom Sheet**
  - Modal bottom sheet with radiusXLarge top corners
  - Sections: Prize Pool (sliders), Duration (chips), Mode (chips), Sort By (dropdown), Order By (toggle)
  - Sticky footer: Reset + Apply buttons

- [ ] **Task 6: Empty State**
  - Illustration + "No public challenges match your filters"
  - "Clear Filters" CTA → resets ExploreFilter, refetches page 1

- [ ] **Task 7: Description Display Rule**
  - Explore cards: truncated to 1 line with ellipsis
  - Details screen: full description

## Route Checkpoint
- [ ] `fvm dart format lib test` clean
- [ ] `dart analyze` zero errors (--fatal-infos)
- [ ] Codegen compiles

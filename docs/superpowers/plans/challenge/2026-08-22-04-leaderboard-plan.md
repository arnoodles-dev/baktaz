# 2026-08-22-04 Leaderboard Plan

**Goal:** Implement the Full Leaderboard Page (`/challenge/leaderboard/:id`) — "The Arena Dashboard" with sticky header, participant search, column sorting, infinite scroll, responsive layout, medals, daily pulse icons, and Gap Meter.

**Spec:** `docs/superpowers/specs/challenge/2026-08-22-04-leaderboard.md`

## Tasks

- [ ] **Task 1: LeaderboardCubit**
  - Connect to `ChallengeLeaderboardRepository`
  - State: `loading`, `loaded`, `error` (via FailureHandler)
  - Methods: `init()`, `refresh()`, `changeSort()`, `changeSearch()`, `loadMore()`

- [ ] **Task 2: ChallengeLeaderboardPage**
  - Header: challenge title, ID, stats chips (players, prize pool, days left)
  - Sync status indicator
  - Responsive two-column layout (Focus Panel + Rank Movement)
  - Stacks vertically at 760px breakpoint

- [ ] **Task 3: Focus Panel**
  - Current user rank summary
  - Steps total + daily average
  - Gap Meter against rival
  - Daily goal progress label

- [ ] **Task 4: Rank Movement (Q76)**
  - O(1) snapshot diff: `rankDelta = oldRank - newRank`
  - Colored arrows: Up (green), Down (red), Stable (grey)
  - Rival movement when user not rank 1

- [ ] **Task 5: Leaderboard Table**
  - Medals inline for top 3 (gold/silver/bronze)
  - Sorting by columns
  - Participant search filters rows
  - Sticky header
  - Current user highlight (10% opacity + "Me" chip)
  - Daily Pulse fire icon
  - Linear gauge below Steps column

- [ ] **Task 6: Infinite Scroll (Q143)**
  - Load next page when within 3 items of bottom (distance-based)
  - Loading skeleton while fetching

- [ ] **Task 7: Pull-to-Refresh**
  - Triggers `cubit.refresh()`

- [ ] **Task 8: Loading Skeleton**
  - Zero layout shift shimmer placeholders

- [ ] **Task 9: Gap Meter**
  - Reuse `gap_meter_widget.dart` from root page plan

- [ ] **Task 10: Medals Inline**
  - Show medals in RANK column for top 3

## Route Checkpoint
- [ ] `fvm dart format lib test` clean
- [ ] `dart analyze` zero errors (--fatal-infos)
- [ ] Codegen compiles

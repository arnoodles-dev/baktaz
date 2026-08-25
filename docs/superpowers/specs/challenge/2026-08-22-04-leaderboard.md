# Challenge Page Specification — Full Leaderboard

- **Date**: 2026-08-22
- **Parent Reference**: Part of the Challenge Page specification suite — see 00-overview.md

## Route

- `/challenge/leaderboard/:id` — Full participant leaderboard page

## 5.6 Full Leaderboard Page (`ChallengeLeaderboardPage`, `/challenge/leaderboard/:id`) — "The Arena Dashboard"

Final layout for full participant leaderboard:

- **Header**: Challenge title, Challenge ID (`mono`), and contextual route title for full leaderboard.
- **Stats Chips**: Compact chips near header:
  - Players
  - PrizePool
  - DaysLeft
- **Sync Status**: Shown at the top so users understand leaderboard freshness. Shows last sync time, in-progress state, or failed sync state when applicable.
- **Responsive Dashboard Layout**:
  - Two-column layout above tablet breakpoint.
  - Left column: **Focus Panel**.
  - Right column: **Rank Movement**.
  - Columns stack vertically at `760px`.
- **Focus Panel**:
  - Current user rank summary.
  - Steps total.
  - Daily average (`mono`).
  - Gap Meter against rival directly above.
  - Daily goal progress label inside the progress bar.
- **Rank Movement** (Q76 Option A):
  - Shows movement since last sync via O(1) snapshot diff: `rankDelta = oldRank - newRank` (positive = gained positions, negative = lost)
  - Uses colored rank-movement arrows:
    - Up: Green `#0F6E56` (▲)
    - Down: Red `#A32D2D` (▼)
    - Stable: Grey `#5F6D7E` (—)
  - Rival movement = check if entry at `userRankPosition - 1` changed between snapshots; only shows when rival exists (user not rank 1)
- **Leaderboard Table**:
  - Medals shown inline in the table **RANK** column for top 3:
    - 🥇 Gold (1st Place): `#FFD700`
    - 🥈 Silver (2nd Place): `#C0C0C0`
    - 🥉 Bronze (3rd Place): `#CD7F32`
  - Columns support sorting.
- **Participant Avatar**: Each row shows `BaktazAvatar` (shared widget from `*_shared`) — displays user avatar image if `avatarUrl` present, falls back to initials. Matches `home_leaderboard_row.dart` pattern.
  - Participant search filters table rows.
  - Sticky header remains visible while scrolling.
  - Daily goal label appears inside progress bar for each row where daily progress is rendered.
  - Current user row uses subtle `primary` (10% opacity) background tint + small "Me" chip.
  - Daily Pulse fire icon marks users who hit daily step goal today.
  - Linear gauge (`BaktazProgressBar`) below "Steps" column visually compares progress relative to the leader.
- **Infinite Scroll (Q143 Option B)**:
  - Load next page when user scrolls within 3 items of bottom (distance-based, not time-based).
  - Show loading skeleton while next participant page loads.
- **Loading Skeleton**:
  - Zero layout shift shimmer skeletons mirror final card/table dimensions and flex layouts.
- **Empty State**:
  - No empty state required because host always participates.
- **Refresh**:
  - Supports pull-to-refresh to trigger leaderboard sync.

## Gap Meter Definition

**The Gap Meter** is a visual progress bar (`BaktazProgressBar`) showing steps gap to the rival directly above the user on the leaderboard.

- If user is rank #1, Gap Meter can show lead over rank #2 or a completed/leader state.
- If user is below rank #1, Gap Meter shows remaining steps required to overtake the participant directly above.
- Gap Meter appears in:
  - Root registered view `UserRankBanner`.
  - Full leaderboard Focus Panel.

# Design Specification: Baktaz Home Screen UI

> **Document Version:** 2.0  
> **Date:** 2026-08-22  
> **Topic:** Baktaz Flutter App Home Screen (`/home`) Architectural & Full-Stack Redesign  
> **Status:** Approved  

---

## 🧭 Navigation & Layout Structure
The Baktaz Home Screen is built on a **Modular Sliver Dashboard** (`CustomScrollView` layout) that integrates sticky/collapsible actions with structured widget sections constrained to a maximum responsive width of `Constant.tabletBreakpoint` (800px).

```
HomePage (NestedScrollView + RefreshIndicator)
 ├── SliverAppBar.large (BaktazAppBar)
 └── CustomScrollView (slivers)
      ├── HomeDailyStepHeroCard
      ├── HomeWeeklyStepsChart
      ├── HomeActiveChallengeTicker
      └── HomeLeaderboardPreview (conditional)
```

---

## 🏗️ Detailed Component Breakdown

### 1. AppBar Header (`BaktazAppBar`)
- **Left Alignment**: Brand logo `Baktaz` typography.
- **Right Alignment**:
  - Notification icon button with dynamic unread badge (`/notifications`).
  - User avatar thumbnail (`/account/profile`) rendered via `BaktazAvatar(size: BaktazAvatar.sizeSM)`.

### 2. Daily Step Count Hero Card (`HomeDailyStepHeroCard`)
A linear progress card showcasing primary daily step data.
- **Subcomponents**: `HomeDailyStepHeader`, `HomeDailyStepLinearGauge`, `HomeDailyStepSyncFooter`.
- **Top Header**: "TODAY'S STEPS" label (`BaktazText`).
- **Primary Text**: Large step metric (e.g. `8,450`) formatted via `StepFormatter`.
- **Secondary Badge**: Percentage goal progress (e.g. `84.5% of 10,000 Goal`). Uncapped when goal is exceeded (e.g. `125.0% of 10,000 Goal`).
- **Progress Indicator**: Horizontal linear progress bar showing current progress towards daily target.
  - When steps ≤ goal: Bar is filled proportionally in `colorScheme.primary`.
  - When steps > goal: Bar is clamped to 1.0 with color transition to `colorScheme.tertiary` (success theme color) to visually reward target completion.
- **Footer**:
  - Sync status details (e.g. `Synced via Health Connect • 5m ago`).
  - Refresh icon button on right to manually re-sync steps via debounced `HomeCubit.syncDailySteps()`.

### 3. Weekly Steps Analytics Chart (`HomeWeeklyStepsChart`)
An interactive 7-day visualization of the user's step counts.
- **Subcomponents**: `HomeWeeklyChartHeader`, `HomeWeeklyBarItem`, `HomeWeeklyTotalFooter`.
- **Header**: "Weekly Activity" with 7-day average steps (e.g. `Avg: 9,120 steps/day`).
- **7-Day Bar Chart**:
  - Interactive bar heights representing daily total steps (bounded safely with `List.filled(7, 0)` fallback).
  - Horizontal dotted target goal line at 10,000 steps.
  - Days meeting goal are highlighted in primary brand color; days below goal are shown in a subtle muted tint.
  - Tapping a bar displays a floating tooltip with exact steps for that date.
- **Footer**: Single summary pill showing 7-day total step count (e.g., `Total: 63,840 steps` formatted via `StepFormatter`). Distance and calories are removed.

### 4. Active Challenge Ticker Card / Discovery Banner (`HomeActiveChallengeTicker`)
Dynamically switches presentation depending on the user's active challenge enrollment status.

#### State A: Enrolled in a Challenge
- **Header**: Challenge title (e.g. `🏆 30-Day Step Showdown`) + Current User Rank Badge (`BaktazRankBadge`).
- **Sub-Header**: Prize Pool information (e.g. `Prize Pool: ₱25,000 • Top 3 Tiered` formatted via `MoneyFormatter`).
- **Rank Badge & Gap Info**:
  - Top 3: Gold (#1), Silver (#2), or Bronze (#3) badge.
  - Outside Top 3: Standard Rank badge (`BaktazRankBadge`).
  - Step gap display to next rank (e.g. `1,250 steps behind 2nd (@Sarah)` or `3,400 steps behind 6th (@Marcus)`).
- **Leaders List**: Top leaders displayed inline (`BaktazLeadersStrip`: `Leaders: 🥇 @Alex  🥈 @Sarah`).
- **Duration / Timeline Bar**:
  - `BaktazStageProgressBar` representing elapsed days (e.g. `Day 16 of 30 (53%)`).
  - Active time remaining label (e.g. `14 Days Remaining`).
- **Navigation Action**: `BaktazButton` (`Go to Challenge Page ➔`) triggering `StatefulNavigationShell.of(context).goBranch(1)`.

#### State B: Unenrolled
- **Icon / Header**: `🏆 Take on a Challenge` banner.
- **Description**: "Put your daily steps to work. Join a public pool or enter a private invite code to compete for prizes!"
- **Action**: `BaktazButton` (`Explore Challenges ➔`) triggering `goBranch(1)`.

### 5. Challenge Leaderboard Preview (`HomeLeaderboardPreview`)
*Visible only if user has an active challenge.*
- **Subcomponents**: `HomeLeaderboardRow`.
- **Header**: "Challenge Leaderboard" with a secondary `View Full Leaderboard ➔` link.
- **List Header**: Columns structured as `RANK`, `PARTICIPANT`, `PROGRESS / STEPS`, and `AVG/DAY`.
- **Top 5 Rows**:
  - `BaktazRankTrend` shift indicators displaying movement since yesterday (`▲2`, `▼1`, `──`).
  - Relative progress bars scaled relative to the #1 leader's total steps (zero-guarded).
  - Profile avatar thumbnail (`BaktazAvatar`) and username string.
  - Cumulative step total (`StepFormatter`) and average daily steps.
- **Current Position Pinned Card**:
  - If the user is outside the top 5 (e.g. Rank #7), a pinned bottom row displays the user's position (`📍 #7 @You (Current)`) with matching relative progress bar, trend, and steps.

---

## 🛠️ Generic Core Reusable Widgets (`lib/core/presentation/widgets/`)
1. **`BaktazRankBadge`**: Rank number (`#1`, `#2`, `#3`, `#7`) with Gold/Silver/Bronze/Neutral styling.
2. **`BaktazRankTrend`**: Movement arrow badge (`▲2`, `▼1`, `──`) with green/red/neutral color tinting.
3. **`BaktazStageProgressBar`**: Progress bar displaying stage progress (`Day 16 of 30 (53%)`) and remaining days.
4. **`BaktazLeadersStrip`**: Inline podium participant chips (`🥇 @Alex  🥈 @Sarah  🥉 @David`).

---

## ⚡ State Management & Hybrid Error Strategy
- **Cubit Architecture**: `HomeCubit` (`@injectable`) extending `CubitSignal<HomeState>` with `BlocSignalPresentationMixin`.
- **Single-Action Methods**: `fetchDailyStepTelemetry()`, `fetchWeeklyAnalytics()`, `fetchActiveChallengeDashboard()`, `fetchLeaderboardPreview()`, and debounced `syncDailySteps()`.
- **Hybrid Error Handling Strategy**:
  - Initial Launch Complete Failure ➔ Render `BaktazErrorScreen` with retry button.
  - Partial Section Fetch Failure ➔ Render section inline error banner with retry button (`HomeCubit.fetchLeaderboardPreview()`).
  - One-shot Failure Toast ➔ Handled via `FailureHandler` and `ErrorActions` mixin logging to Talker.

---

## 💾 Caching & Full-Stack Serverpod Architecture

### Caching Policy Matrix
- **Daily Step Telemetry**: Persisted in `LocalStorageRepository`; loads instantly offline.
- **Weekly Analytics (7-Day)**: Cached locally with 24-hour TTL.
- **Active Challenge Summary**: Live RPC fetch with local cache fallback when offline.
- **Leaderboard Preview (Top 5)**: Always live RPC fetch for real-time rankings.

### Backend Contract (`baktaz_server`)
- `.spy.yaml` models under `baktaz_server/lib/src/features/home/domain/model/`:
  - `DailyStepTelemetry`
  - `WeeklyStepAnalytics`
  - `ActiveChallengeSummary`
  - `HomeLeaderboardEntry` (using native Serverpod `Uri?` for `avatarUrl`).
- `IHomeServerRepository` (`@LazySingleton`) using `session.caches.local` for in-memory query caching.
- `HomeEndpoint` extending `Endpoint` returning typed domain models.

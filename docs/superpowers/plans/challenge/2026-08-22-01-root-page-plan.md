# 2026-08-22-01 Root Page Plan

> **PREREQUISITE:** This plan depends on `2026-08-22-00-foundation-plan.md` being complete. Do not start until `ChallengeCubit`, `ChallengeState`, `IChallengeLifecycleRepository`, `IChallengeDiscoveryRepository`, `IChallengeLeaderboardRepository`, and typed routes exist.

**Goal:** Implement the root Challenge Page (`/challenge`) with dynamic `initial` (Trophy Case layout) and `registered` (Pro Challenge Hub) views, host management card, prize pool card, user rank banner, leaderboard preview list, gap meter, and leave dialog.

**Spec:** `docs/superpowers/specs/Challenge/2026-08-22-01-challenge-root.md`

## Tasks

- [ ] **Task 1: ChallengeCubit Integration**
  - Connect root page to `ChallengeCubit` from foundation plan
  - Read state via `cubit.state` signal
  - Map states to views: `loading` → skeleton, `initial` → Trophy Case, `registered` → Dashboard, `done` → ChallengeDonePage

- [ ] **Task 2: ChallengeInitialView (Trophy Case)**
  - Header: Icon + "Challenge Hub" title + subtitle
  - Invite code card: 6-digit `BaktazTextField` + "Join Private Challenge" button
  - Inline error feedback for invalid/expired codes
  - "Explore Public Challenges" secondary button → `/challenge/explore`
  - "Create Challenge" CTA (premium only) → `/challenge/create`
  - Archive button (when `hasArchived == true`)

- [ ] **Task 3: ChallengeRegisteredView (Pro Challenge Hub)**
  - Challenge metadata header (host, reward mode, entry fee, duration, slots, dates)
  - Host Management Card (if `isHost == true`): Share Invite, Start Challenge Now, View Full Leaderboard
  - Prize Pool Card with countdown + fee breakdown
  - User Rank Banner: rank badge + Gap Meter + trend arrows
  - Leaderboard preview (top 5 + current user row)
  - Leave Challenge button (disabled for hosts, pre-launch shows disclaimer)

- [ ] **Task 4: ChallengeDonePage**
  - Winner: Payout Seal + Claim Payout button + receipt
  - Non-Winner (Q140): Subdued seal + "Thanks for Participating" + archive
  - Read-only from archive (Q132): all actions hidden
  - Navigation: back → archive list or `.initial` reset

- [ ] **Task 5: ChallengeArchiveScreen**
  - Full-screen vertical list of completed challenge cards
  - Card: name, date, rank badge, payout amount
  - Tap → ChallengeDonePage (read-only)
  - No empty state (gated by `hasArchived`)

- [ ] **Task 6: AppBar & Navigation**
  - Root AppBar with history icon → archive
  - Full-screen routes via `$parentNavigatorKey` + `SlideTransitionPage`
  - Deep link guards: auth check → login; enrollment check → `/challenge`

- [ ] **Task 7: Side Effect Listener (Q2 — per-cubit pattern)**
  - Root `ChallengePage` listens to `cubit.presentationStream` for enrollment-level errors only (e.g., challenge-not-found on init)
  - Sub-route Cubits (`ChallengeExploreCubit`, `ChallengeDetailsCubit`, `ChallengeLeaderboardCubit`, `ChallengeCreateCubit`) each emit their own presentation streams. Their respective screens handle side effects independently via `BlocSignalPresentationMixin`.
  - This matches the per-cubit pattern from foundation plan (Q2 RESOLVED).

- [ ] **Task 8: Gap Meter Widget**
  - Create `gap_meter_widget.dart`
  - Visual progress bar showing steps gap to rival directly above
  - Uses `BaktazProgressBar`

- [ ] **Task 9: Skeletons for Loading States**
  - Create `challenge_initial_skeleton.dart` and `challenge_registered_skeleton.dart`
  - Zero layout shift shimmer placeholders mirroring card dimensions

- [ ] **Task 10: Leave Challenge Dialog**
  - Create `leave_challenge_dialog.dart` under `presentation/widgets/dialogs/`
  - Triggered from secondary "Leave Challenge" button
  - Disabled for Hosts
  - Confirmation before unenrolling
  - Follows shared Dialog Anatomy in spec 06

## Route Checkpoint
- [ ] `fvm dart format lib test` clean
- [ ] `dart analyze` zero errors (--fatal-infos)
- [ ] Codegen (`slang` + `build_runner`) compiles

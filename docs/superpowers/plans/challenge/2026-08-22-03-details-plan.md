# 2026-08-22-03 Details Plan

**Goal:** Implement the Challenge Details Screen (`/challenge/detail/:id`) — "The Race Contract" with countdown hero, identity block, TERMS ledger, sticky CTA, non-refundable disclaimer, and wallet insufficient handling.

**Spec:** `docs/superpowers/specs/challenge/2026-08-22-03-details.md`

## Tasks

- [ ] **Task 1: DetailsCubit**
  - Connect to `ChallengeLifecycleRepository` + `ChallengeDiscoveryRepository`
  - State: `loading`, `seed`, `loaded`, `failure` (handled via FailureHandler)
  - Methods: `init(seed)`, `joinChallenge()`, `refresh()`

- [ ] **Task 2: ChallengeDetailsScreen**
  - Countdown hero (gradient container, mono digits)
  - Identity block (title, ID, host, mode badge, full description)
  - TERMS section (ledger rows: entry fee, duration, slots, prize pool, tie-breaker, rules link)
  - Sticky footer CTA ("Join Challenge")

- [ ] **Task 3: NonRefundableDisclaimerDialog**
  - ConfirmationDialog pattern
  - Title: "Confirm Entry"
  - Mono data rows: Entry Fee / Your Balance
  - Actions: [Cancel] [Pay & Join]

- [ ] **Task 4: Wallet Insufficient Flow**
  - Insufficient balance → ConfirmationDialog with cash-in CTA → `/account`

- [ ] **Task 5: Host View Behavior**
  - For hosts: CTA hidden, Host Management Card shown instead

- [ ] **Task 6: Seed-Aware State (Q66)**
  - `seed({optimistic})` → render immediately from ChallengeSummary
  - Mutable fields shimmer until authoritative ChallengeDetail arrives
  - Fetch fails but seed exists → keep seed + presentation toast

- [ ] **Task 7: Deep Link Guard (Q67)**
  - Navigation-layer guard before pushing DetailsRoute
  - Auth check → login redirect
  - Enrollment check → `/challenge` registered view

## Route Checkpoint
- [ ] `fvm dart format lib test` clean
- [ ] `dart analyze` zero errors (--fatal-infos)
- [ ] Codegen compiles

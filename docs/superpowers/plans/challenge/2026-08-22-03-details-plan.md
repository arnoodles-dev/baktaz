# 2026-08-22-03 Details Plan

> **PREREQUISITE:** This plan depends on `2026-08-22-00-foundation-plan.md` being complete. Do not start until `IChallengeLifecycleRepository`, `IChallengeDiscoveryRepository`, `ChallengeCubit`, and typed routes exist.

**Goal:** Implement the Challenge Details Screen (`/challenge/detail/:id`) — "The Race Contract" with countdown hero, identity block, TERMS ledger, sticky CTA, non-refundable disclaimer, and payment flow integration.

**Spec:** `docs/superpowers/specs/challenge/2026-08-22-03-details.md`

## Tasks

- [ ] **Task 1: ChallengeDetailsCubit** (`challenge_details_cubit.dart`)
  - Connect to `ChallengeLifecycleRepository` + `ChallengeDiscoveryRepository`
  - State: `loading`, `seed`, `loaded`, `failure` (handled via FailureHandler)
  - Methods: `init(seed)`, `joinChallenge()`, `refresh()`
  - **TODO(payment)**: `createPaymentIntent()` → calls `PaymentEndpoint.createPaymentIntent()` → returns `PaymentIntent` with checkout URL
  - **TODO(payment)**: `pollPaymentStatus()` → polls `PaymentEndpoint.getPaymentStatus()` until PAID
   - Cubit mixes in `BlocSignalPresentationMixin` and uses `safeRun(onException: _failureHandler.handleException)`. The `ChallengeDetailsScreen` listens to its own presentation stream for error toasts (Q2 — per-cubit side-effect architecture, aligned with foundation plan).

- [ ] **Task 2: ChallengeDetailsScreen**
  - Countdown hero (gradient container, mono digits)
  - Identity block (title, ID, host, mode badge, full description)
  - TERMS section (ledger rows: entry fee, duration, slots, prize pool, tie-breaker, rules link)
  - Sticky footer CTA ("Join Challenge")
  - **TODO(payment)**: Payment method selector widget embedded in join flow
  - **TODO(payment)**: Payment intent WebView integration
  - **TODO(payment)**: Payment success/cancel deep link handling

- [ ] **Task 3: Payment Intent Flow**
  - **TODO(payment)**: Create `PaymentIntentWebView` widget (opens HitPay checkout)
  - **TODO(payment)**: Handle deep links: `/payment/success`, `/payment/cancel`
  - **TODO(payment)**: Show `ChallengePaymentSuccessScreen` after payment confirmation

- [ ] **Task 4: NonRefundableDisclaimerDialog**
  - Title "Confirm Entry". Body states entry fees strictly non-refundable once paid + acceptance of rules and dispute policy. Mono data rows: Entry Fee. Actions: [Cancel] [Continue to Payment].

- [ ] **Task 5: Host View Behavior**
  - For hosts: CTA hidden, Host Management Card shown instead

- [ ] **Task 6: Seed-Aware State (Q66)**
  - `seed({optimistic})` → render immediately from ChallengeSummary
  - Mutable fields shimmer until authoritative ChallengeDetail arrives

- [ ] **Task 7: Deep Link Guard (Q67)**
  - Navigation-layer guard before pushing DetailsRoute
  - Auth check → login redirect
  - Enrollment check → `/challenge` registered view

## Route Checkpoint
- [ ] `fvm dart format lib test` clean
- [ ] Codegen compiles

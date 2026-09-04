# Challenge Page Specification — Shared Models and Cross-Cutting Concerns

- **Date**: 2026-08-22
- **Updated**: 2026-08-28 (Payment integration & Anti-cheat daily step ceiling)
- **Parent Reference**: Part of the Challenge Page specification suite — see 00-overview.md

## 5.3 Presentation Layer Design & Theme Tokens

- **Typography Tokens**: Standardized text styles across components using `Theme.of(context).textTheme.*` for common styles and `BaktazType.*` strictly for display styles (`displayHero`, `metricHero`, `headlineTitle`, `subheadingUppercase`, `labelRanking`):
  - Header / Section Titles: `Theme.of(context).textTheme.headlineLarge`
  - Big Counters / Metric Displays: `BaktazType.metricHero(scheme.onSurface)`
  - Invite Codes / Step Counts / Rank Numbers: `BaktazType.labelRanking(scheme.onSurface)`
  - General Body Text & Labels: `Theme.of(context).textTheme.bodyMedium`
- **Spacing Tokens**: Consistent layouts using `BaktazSpacing.*` (xs2=4, xs=8, sm=12, md=16, lg=20, xl=24, xl2=32, xl3=40) and `BaktazRadius.*` (card, row, chip, pill):
  - Horizontal Screen Margin: `BaktazSpacing.xl`
  - Standard Item Gaps: `BaktazSpacing.md` between cards/elements, `BaktazSpacing.lg` between major sections
- **Border Radius Tokens**: `BaktazRadius.*`
  - Cards & Containers: `BaktazRadius.card` (12dp for cards)
  - Dialogs & Bottom Sheets: `BaktazRadius.chip` (24dp for dialogs/bottom sheets)
  - Badges & Action Buttons: `BaktazRadius.pill` (999dp for badges/buttons)
- **Color Palette & Theme Extensions**:
  - Surface Containers: `scheme.surfaceContainer`
  - Custom Brand / Accent Colors: `BaktazCustomColors.*` (ThemeExtension)
  - **Dynamic Brand Primary Gradient Headers**: Prize Pool Card and main Dashboard cards feature dynamic brand primary gradient headers (`LinearGradient` using `scheme.primary` `#10B981`/`#34D399` and `scheme.primaryContainer`) for strong visual hierarchy.
  - **Metallic Podium Rank Badges**: Top-3 leaderboard entries feature metallic podium rank badges via `BaktazCustomColors.*`:
    - 🥇 **Gold (1st Place)**: `BaktazCustomColors.gold`
    - 🥈 **Silver (2nd Place)**: `BaktazCustomColors.silver`
    - 🥉 **Bronze (3rd Place)**: `BaktazCustomColors.bronze`
  - **Zero Layout Shift Shimmer Skeletons**: During the `loading` state, custom `Shimmer` skeleton placeholders (imported from `*_shared`) mirror the exact card dimensions and flex layouts of `ChallengeRegisteredView` and `ChallengeDefaultView` to eliminate layout shift upon data resolve.

## Challenge Entity Fields (Server & Client)
- `id`, `name`, `description`, `entryFee`, `currency`
- `prizePercentage` (default 90.0), `platformFeePercentage` (default 10.0), `hostCutPercentage` (default 0.5)
- `dailyStepCeiling: int` — Anti-cheat threshold set by host at creation (range 10,000–50,000, default 30,000). Participants logging steps above this daily threshold are auto-flagged for anti-cheat community review.
- `dailyStepGoal: int?`, `totalStepGoal: int?`
- `status` (ChallengeStatus), `startsAt`, `endsAt`

## 4.2 Host Controls, Creation & Forfeiture Lifecycle

- If `activeChallenge.isHost == true`:
  - Renders **Host Management Card** on `ChallengeRegisteredView` with `Invite Friends / Share Code` button.
- **Private Challenges**:
  - Host pays entry fee to launch via HitPay (payment intent flow).
  - Can archive/cancel challenge before launch if minimum participants are not met.
  - Automatic cancellation occurs after a 30-day pending window if minimum participants are not reached.
  - Host can tap `Start Challenge Now` CTA once minimum participants join.
- **Public Challenges**:
  - Host pays entry fee upfront during creation via HitPay.
  - If public challenge fails to meet minimum participants by start date, host entry fee is forfeited, while participant entry fees are 100% refunded via HitPay API.
  - Displays "Initial Phase" countdown timer (`Starts in X days/hours`).

### Private Challenge Start/End Recalculation Rule

- Manual start updates End Date = start time + duration.
- Manual start is gated behind `start_challenge_confirmation_dialog.dart`.
- Confirmation dialog shows new Ends date (`start time + duration`) before host confirms.

## 4.3 Leaderboard Sync Policy

Leaderboard updates on:

1. App login.
2. Manual pull-to-refresh action.
3. Automatically whenever health step sync pushes updates to server.

## Challenge Participant Entity
`ChallengeParticipant` freezed entity:
- `id`, `challengeId`, `authUserId`, `isHost`, `status` (ChallengeStatus), `steps`, `rank?`, `entryFeePaid`, `payoutAmount?`, `claimedAt?`, `joinedAt`
- `payoutAmount`: computed by FutureCall #2, null until challenge completed, set when payout distributed
- `claimedAt`: set automatically by FutureCall #2 when payout distributed (not user-triggered)
- Used by root cubit for enrollment check
- Server returns full participant record (not summary)

## 4.4 Challenge Completion & Payout Lifecycle

Upon challenge end countdown reaching 0:

1. **Validation & Dispute Window**: Challenge enters a 24-hour "Validation & Dispute Window" for step verification and participant dispute submission.
2. **Dispute Resolution (Community Vote Re-run)**: When a participant files a dispute during the window:
   - All active participants vote on the disputed result (same simple-majority mechanism as anti-cheat voting).
   - **Upheld**: payout blocked; affected results are recalculated.
   - **Rejected**: dispute dismissed; payout proceeds.
   - Multiple disputes may coexist; payout FutureCall waits until ALL disputes are resolved.

**Q113 — FutureCall #2 Purpose**: Computes winner(s), calculates payoutAmount (gross prize - tax - fee), sets status=completed. Does NOT distribute funds. Distribution happens via user claim or FutureCall #3 (auto-disbursement after 30 days).
   - All active participants vote on the disputed result (same simple-majority mechanism as anti-cheat voting).
   - **Upheld**: payout blocked; affected results are recalculated.
   - **Rejected**: dispute dismissed; payout proceeds.
   - Multiple disputes may coexist; payout FutureCall waits until ALL disputes are resolved.
3. **Automatic Ledger Payout**: If NO participant files a dispute within the 24-hour window (or all disputes resolved as rejected), prize pool payouts automatically distribute to winners via HitPay (GCash/Maya).
3. **Post-Distribution Standings (Q139)**:
     - **Winners**:
       - See **"Claim Payout"** CTA button → **TODO(payment)**: calls `claimPayout` endpoint → creates HitPay payout to winner's saved payout account → cubit resets to `.initial(isPremium:)` (Q139) — user returns to Trophy Case to join another challenge
       - Auto-disbursed after 30d: FutureCall #3 creates HitPay payout → same `.initial` reset
     - **Non-Winning Participants (Q140)**:
       - See **"Thanks for Participating"** banner + final podium standings and archive button → cubit resets to `.initial(isPremium:)` (Q140) — user free to join another challenge
       - Archive button opens archive view from Trophy Case

## 4.5 Configurable Tie-Breaker Rules

Host selects tie-breaker rule during challenge creation:

- **`Equal Split`**: Combines payouts of tied positions and splits them evenly among tied participants.
- **`Sudden Death`**: Triggers a 24-hour competition extension for tied leaders.
  - Runs INSIDE the 24-hour Validation & Dispute Window (not a separate phase).
  - Only TIED participants' steps count during the extension; all other participants are frozen.
  - Winner = higher step count recorded during the extension window.
  - *Note: The `Sudden Death` extension runs concurrently with the 24-hour Validation & Dispute Window (not a separate phase). When challenge timer reaches 0 and tie is detected, the 24-hour sudden death extension begins immediately. During this window, only TIED participants' steps count. After extension ends, if ties persist, fall back to `equalSplit` of combined positions.*
  - Still tied after extension → falls back to Equal Split of the combined positions.
- **`Consistency Metric`**: Resolves ties based on the highest number of days meeting the daily step goal.

### Challenge Step Goals
Two optional goal fields on `Challenge`:
- **`dailyStepGoal: int?`** — per-day step target. Powers:
  - 🔥 Daily Pulse streak icons on leaderboards (participant hit goal today)
  - `consistencyMetric` tie-breaker (most days hitting the goal wins)
  - Required when host selects `tieBreaker = consistencyMetric`; optional otherwise
- **`totalStepGoal: int?`** — whole-challenge cumulative target (e.g. 300,000 steps in 30 days). Powers:
  - `goalThresholdEqualProfitShare` mode qualification threshold
  - Required when `rewardMode = goalThresholdEqualProfitShare`; rejected otherwise at creation

### Tie Resolution Order (payout calculator)
1. Apply selected tie-breaker (`suddenDeath` or `consistencyMetric`) if configured.
2. If tie persists (or no tie-breaker configured), fall back to `equalSplit`.

## 4.6 Anti-Cheat Flagging & Community Majority Voting

1. **Auto-Detect (Q126 Option A)**: Server detects step anomalies — specifically when a participant's single-day step total exceeds the challenge's configured **`dailyStepCeiling`** (set by host, 10,000–50,000, default 30,000), duplicate timestamps, or zero-step pattern > 3 days → auto-places suspect on `On Hold` status. No manual flagging needed.
2. **Notification & Explanation**: Alert and explanation request are delivered to the `Events` tab.
3. **Community Voting (Q127 Option A)**: Same vote mechanism for both auto-detect and manual dispute. Participants vote via simple majority (50% + 1 threshold):
   - **Pass (Innocent)**: `On Hold` status is revoked, and normal ranking resumes.
   - **Fail (Cheater)**: Moved to bottom of leaderboard, entry fee forfeited, and barred from joining new challenges until the current challenge finishes.

## 4.7 Push Notifications & Event Reminders

The challenge engine dispatches real-time push notifications and in-app event reminders to participants across key lifecycle milestones:

1. **24h Pre-Launch Countdown Reminder**: Sent 24 hours before challenge start timestamp to remind enrolled participants to sync their devices and prepare.
2. **Rank Overtake Alert**: Dispatched immediately when another participant passes the user's rank on the leaderboard (e.g., *"⚡ @Alex just overtook your #2 spot!"*).
3. **Anti-Cheat Voting Poll Alert**: Dispatched to active participants when a suspect user is flagged for step anomalies and community voting begins (e.g., *"⚠️ Voting open: verify step log for @John"*).
4. **Final 24h Countdown Reminder**: Sent 24 hours prior to challenge end timestamp to spur final step activity.
5. **Challenge Completion & Dispute Window Open**: Dispatched when challenge timer reaches 0, notifying users that challenge results are locked and the 24-hour Validation & Dispute Window is active.
6. **Payout Ready Notification**: Dispatched once payout distribution is finalized or ready to claim (e.g., *"🎉 Your ₱11,820 prize is ready to claim!"*).

> **Delivery mechanism**: Deferred to the **Message feature** implementation. The challenge server emits lifecycle event payloads only; transport (polling/streaming), persistence, and the Chat `Events` tab belong to the messaging feature scope.

## 6. Security & Access Rules

- Premium user check (`Scope.premium`) gates the "Create Challenge" button/route.
- Entering 6-digit code validates format inline; **TODO(payment)**: non-refundable entry fee disclaimer (`ConfirmationDialog`) occurs on `ChallengeDetailsScreen` prior to payment flow initiation. Entry Fees are strictly non-refundable once paid.
- Challenge end countdown reaching 0: `endAt` reached → status transitions `active` → `validationWindow` (24h dispute window). Steps FROZEN at endAt — no last-second inflation during dispute window.
- **Q102 Payout Distribution**: **TODO(payment)**: Prize pool = sum(entryFees). App fee = entryFee × `appFeePercentage` (host-configurable, capped by AppConfig.maxAppFeePercentage, default 10%). Host cut = entryFee × `hostCutPercentage` (host-configurable, capped by AppConfig.maxHostCutPercentage, default 0.5%). Percentages SET BY HOST at challenge creation, stored on Challenge entity (immutable after joins begin). Net to winner(s) = pool - appFee - hostCut - tax - payout fee. Distribution per reward mode (WTA=100% to 1st, Tiered=host-configured split, Goal=equal among qualifiers, Hybrid=tiered+bonus). Ties resolved per tie-breaker. Each winner gets HitPay payout. If no dispute filed → auto payout via FutureCall #3. If dispute filed → community vote determines outcome.

## 7. Testing Strategy

- **Unit Tests**: Test `ChallengeCubit` state transitions (`loading` → `initial`/`registered`/`done`, post-challenge reset to `.initial` (Q139/Q140), background init check, invite code validation, **TODO(payment)**: payment intent flow, non-refundable entry fee disclaimer, refresh flow, FailureHandler error mapping). No offline caching — serverpod client always fresh.
- **Golden Tests**: Alchemist golden tests for `ChallengeDefaultView`, `ChallengeRegisteredView` (including host card, 24-hour dispute window banner & completion banners), `RulesBottomSheet`, `AntiCheatVoteBottomSheet`.


### Dialog Anatomy (shared standard)
All four challenge dialogs share one anatomy: title (headlineSmall), body (bodyMedium), risk/data rows in mono where numeric, actions right-aligned. Destructive actions use `BaktazButton.destructive`.
1. **NonRefundableDisclaimerDialog** (`non_refundable_disclaimer_dialog.dart`): Title "Confirm Entry". Body states entry fees strictly non-refundable once paid + acceptance of rules and dispute policy. Mono data rows: Entry Fee. Actions: [Cancel] [Continue to Payment].
2. **AntiCheatVoteBottomSheet** (`anti_cheat_vote_bottom_sheet.dart`): Modal bottom sheet (Q138). Step-log timeline + accused card (name, anomaly summary) + Innocent/Cheater buttons (Q130 B) + live result bar (majority so far). Dismissable. Button disabled after voted or window closed.
3. **LeaveChallengeDialog** (`leave_challenge_dialog.dart`): Title "Leave Challenge?" Body warns entry fee forfeited, irreversible. Actions: [Stay] [Leave] (destructive).
4. **StartChallengeConfirmationDialog** (`start_challenge_confirmation_dialog.dart`): Title "Start Challenge Now?" Body explains step counting begins immediately and end date updates to match duration. Mono rows: Starts = Now / Ends = computed (start time + duration). Actions: [Cancel] [Start].

### Rules Bottom Sheet — "The Rulebook" (`rules_bottom_sheet.dart`)
Bottom sheet (radiusXLarge top corners). Header: "Rules & Guidelines" title + close icon. Sections separated by BaktazDivider, each with eyebrow header (labelLarge letterspaced):
1. HOW WINNERS ARE DECIDED — ranking by total verified steps start to end
2. STEP VALIDATION — health source sync; daily step ceiling configured by host (e.g. 30,000 steps/day); suspicious spikes above ceiling go to participant vote
3. DISPUTES — 24-hour window after timer zero; no dispute = auto payout
4. ENTRY FEES — non-refundable once paid; public challenge underfill refunds participants 100% via HitPay, host fee forfeited

Content adapts per challenge reward mode where relevant.

## Step Sync Model (Q137)

- **Model**: `UserStepsInfo` (.spy.yaml), one-to-one with account (`authUserId` unique). Fields: `lastStepSyncAt`. Created lazily on first sync; absent row = never synced.

# Challenge Page Specification — Root Tab Page

- **Date**: 2026-08-22
- **Parent Reference**: Part of the Challenge Page specification suite — see 00-overview.md

## Route

- Root Tab Route: `/challenge`

## 5.1 Default View (`ChallengeInitialView`) — Trophy Case Flat Layout

- **Header**: Icon, Title ("Challenge Hub"), Subtitle ("Join a private challenge or explore public competitions").
- **Invite Code Card**: 6-digit `BaktazTextField` input + `Join Private Challenge` action button. Shows inline feedback for invalid/expired codes.
- **Explore Button**: `BaktazButton.secondary` ("Explore Public Challenges") -> Redirects to `/challenge/explore`.
- **Create Challenge Action** (Visible if user has `Scope.premium`): Prominent Host CTA card/button -> Redirects to `/challenge/create` (includes tie-breaker selection).

## 4.1 Invite Code & Entry Fee Flow

1. User enters valid 6-digit invite code in `ChallengeInitialView`.
2. Code errors (invalid code format, expired challenge) show inline feedback on input card.
3. Valid code redirects to `ChallengeDetailsScreen` (`/challenge/detail/:id`).
4. Payment / entry fee confirmation & wallet check occur on `ChallengeDetailsScreen` before final enrollment:
   - Entry Fees are strictly non-refundable once paid.
   - Before user confirms entry fee payment on `ChallengeDetailsScreen`, display explicit `ConfirmationDialog` with legal disclaimer confirming non-refundable terms.
   - Insufficient wallet balance triggers `ConfirmationDialog` with cash-in CTA redirecting to `/account`.
   - Sufficient balance processes entry fee and completes enrollment.

## 5.2 Registered View (`ChallengeRegisteredView`) — "Pro Challenge Hub"

- **Spacing**: Major sections separated by vertical spacing of `Gap.large()` (20dp).
- **Header Grouping**: Explicit challenge metadata block listing Host, Reward Mode, Entry Fee, Duration, Slots, and Start/End dates.
- **Initial Phase Behavior (Q86 Option A)**: Same dashboard view for all phases. Public challenges auto-start at `startAt` (no host action needed). Private challenges in initial phase show `Start Challenge Now` button on Host Management Card (calls `startPrivateChallenge` endpoint). No special "waiting" view — just conditional action button.
- **Host Management Card** (Visible if `activeChallenge.isHost == true`, Q85 Option A): Three actions only (MVP scope):
  - **Share Invite Code**: Copy to clipboard + Share sheet (private challenges only; public challenges hide this action)
  - **Start Challenge Now**: For private challenges in initial phase (calls `startPrivateChallenge` endpoint); hidden/disabled post-launch
  - **View Full Leaderboard**: Pushes `LeaderboardRoute(id)` full-screen
  - Edit/Pause/Delete challenged deferred to future (complex participant-impact semantics)
  - Leave Challenge: Already handled by global "Leave Challenge" button (disabled for hosts per single-enrollment gate)
- **Prize Pool Card**: Clean block with `displayMedium` currency amount and `BaktazProgressBar` for duration countdown (includes 24-Hour Validation & Dispute Window status). Fee breakdown pill (App fee, Host cut, Net pool) and Reward Mode badge.
- **User Rank Banner** (Q72):
  - Current rank badge (metallic podium badge for top 3).
  - **"The Gap Meter"**: Visual progress bar (`BaktazProgressBar`) showing steps gap to the rival directly above the user on the leaderboard. Rival data included in `ChallengeDashboard` aggregate (server eager-loads rival row alongside top-5 + user; client derives `rivalAbove = leaderboardPreview[userRankPosition - 1]`; null if user is rank 1 — no extra query).
  - **Leaderboard Table (MVP)**:
    - **Read-Only Rows**: Rows have no touch targets; visual balance only (no interactive hit areas required).
    - **Row Sizing**: Each row wrapped in `IntrinsicHeight` + `Padding` for flexible, content-driven row sizing (no fixed row height).
    - **"Daily Pulse"**: Small 🔥 fire icon next to names for users who hit the daily step goal today (streak indicator).
    - **Columns**: Rank (Badges), Name, Steps (`mono`), Daily Average (`mono`).
    - **Trend Indicators**: Colored rank-movement arrows next to rank showing movement since last sync:
      - Up: Green `#0F6E56` (▲)
      - Down: Red `#A32D2D` (▼)
      - Stable: Grey `#5F6D7E` (—)
    - **Current User Highlight**: Subtle `primary` (10% opacity) background tint + small "Me" chip on the row.
    - **Linear Gauge**: `BaktazProgressBar` below "Steps" column for each row to visually compare progress relative to the leader.
    - Top 5 ranked participants list + Current user's row if outside Top 5.
    - Supports pull-to-refresh to trigger leaderboard sync.
    - "See All" button -> Redirects to `/challenge/leaderboard/:id`.
    - **Action Footer** (Q81): Secondary "Leave Challenge" button (`BaktazButton.secondary`). Disabled for Hosts. For participants, tapping opens `LeaveChallengeDialog` for confirmation before unenrolling.
  - **Pre-launch** (`challenge.status == initialPhase`): `leaveChallenge()` refunds wallet (undoes entry fee debit via `WalletTransactions` credit), removes participant row, emits `.initial(isPremium:)` → user can re-join any challenge
  - **Post-launch** (`challenge.status != initialPhase`): Leave button hidden/disabled — competition integrity. User stays enrolled until challenge ends.
    - **Sudden Death Banner & Leaderboard (Q87 + Q136 Option A)**:
  - During active sudden death extension: red accent banner "⚡ SUDDEN DEATH" at top of dashboard
  - Shows countdown to sudden death end (`suddenDeathEndsAt`)
  - **Leaderboard filters to tied participants ONLY** — others greyed out with "eliminated from tie-break" note
  - Tied participants' steps update live — creates tension
  - Normal dashboard otherwise (no separate view)
- **Completion / Payout Banners** (Q103):
      - **active**: Normal dashboard (leaderboard + Gap Meter + Leave)
      - **validationWindow**: "Validation & Dispute Window" banner (24h countdown), Leave disabled, File Dispute CTA
      - **disputePending**: "Dispute Pending" banner + explanation, no actions until resolved
      - **disputeUpheld**: "Dispute Upheld - Recalculating" banner, new winner computation triggered
      - **disputeRejected**: "Dispute Rejected" banner + Claim Payout activates
      - **completed + Winner**: **"Claim Payout"** button → REAL ACTION: calls `claimPayout` endpoint, debits escrow → credits wallet, shows confirmation
      - **completed + Non-Winner (Q140)**: **"Thanks for Participating"** button → read-only final rank + archive → cubit resets to `.initial(isPremium:)` (Q140)
      - **post-claim (Q139)**: After winning user claims payout → cubit resets to `.initial(isPremium:)` — user returns to Trophy Case, free to join/explore another challenge. No active enrollment.
      - **auto-disbursed**: If winner doesn't claim within 30 days → FutureCall #3 auto-credits wallet → same `.initial` reset as claim
      - **Note**: If winner does NOT claim within 30 days of button appearing, funds auto-disbursed (FutureCall #3).
      - **disputed**: "Dispute Pending" banner, no actions until resolved


### Archive & History (Q119 Option A)
- **Archive button on ChallengeInitialPage** (not ChallengeDonePage): When user is NOT enrolled in any active challenge, ChallengeInitialPage shows an **Archive** tab/section listing all previously completed challenges
- **Archive entry**: Challenge card with final rank, payout amount, date, and "View Details" → re-opens ChallengeDonePage (read-only)
- **ChallengeDonePage**: No archive button — it's the final screen. User navigates back to ChallengeInitialPage to see archive.
- **Unarchive**: Not supported — archived = permanent history record
- **History icon on AppBar**: Navigates to ChallengeInitialPage archive section

### ChallengeDonePage — Final Outcome Screen (Q115 Option A)
When challenge completes (FutureCall #2 sets status=completed), root cubit emits `.done({result})` → renders `ChallengeDonePage` (replaces registered dashboard).
- **Winner**: Payout Seal (breaks open, reveals amount) + "Claim Payout" button (REAL ACTION) + receipt breakdown + Archive
- **Non-Winner (Q140)**: Subdued seal + "Thanks for Participating" button (outlined) + final rank + Archive → cubit resets to `.initial(isPremium:)`
- **Payout Claimed**: Green checkmark seal + "Payout Claimed" confirmation + transaction record link
- **Payout Auto-Disbursed**: Seal with ⏰ icon + "Payout Auto-Disbursed" + transaction record link
- **Archived**: Hidden from active view, viewable in history

### Cancelled Challenges (Q133 Option A)
**Challenge can ONLY be cancelled during initial phase (before launch):**
- **Auto-cancel**: If minimum participants not met by end of initial phase → status `cancelled`
- **Manual cancel**: Host can cancel during initial phase → status `cancelled`
- **Post-launch**: Challenge CANNOT be cancelled. Users can leave (non-refundable).
- **Refund**: All participants get entry fee refunded to wallet
- **Archive**: Cancelled challenges show in archive with "Cancelled" badge
- **No active view**: Cancelled challenges hidden from dashboard

### Single-Enrollment Gate
Users can hold only ONE active challenge at a time. Once enrolled (or hosting):
- Root tab renders `.registered` dashboard exclusively.
- Explore/details/create routes remain technically reachable via deep link but are **navigation-layer guarded** (Q67 Option B): auth-check → login redirect if unauthenticated; enrollment-check → redirect to `/challenge` registered view if already-joined. Details screen never receives unauthenticated attempt.
- `isAlreadyJoined` checks on details screen are therefore unnecessary — navigation gating handles it upstream.

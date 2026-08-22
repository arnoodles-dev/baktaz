# Screens & User Flow Specification

> **Document Version:** 1.0  
> **Target Audience:** UX/UI Designers, Mobile Engineers (Flutter)

---

## 🧭 Navigation Architecture

Baktaz uses a standard 4-tab bottom navigation bar for high-level app navigation, complemented by deep sub-screen flows.

```
Bottom Navigation Bar
├── 🏠 1. Home
├── 🏆 2. Challenge Hub
├── 💬 3. Chat
└── 👤 4. Account & Wallet
```

---

## 📱 1. Home Screen (`/home`)

The Home Screen serves as the daily operational dashboard for personal progress and challenge quick-glance data.

### 1.1 UI Layout Breakdown

- **AppBar Header**:
  - App Brand Logo (`Baktaz`)
  - User Avatar (taps redirect to `/account/profile`)
  - Notification Bell Icon (with unread badge counter)
- **Daily Step Count Hero Card**:
  - Current day's total steps in prominent typography (e.g., `8,450 / 10,000 steps`).
  - Circular progress indicator showing percentage of daily target met.
  - Health Source Sync Badge (e.g. `Synced via Health Connect • 5m ago`) with a manual refresh button.
- **Weekly Steps Analytics Chart**:
  - 7-day bar graph showing daily totals vs daily goal line.
  - Quick stats: 7-day average steps, total distance (km), estimated calories.
- **Active Challenge Ticker Card** _(Visible if user has an active challenge)_:
  - Challenge Title, User's current rank (e.g., `Rank #3 of 25`), Time remaining countdown.
  - Direct button: `Go to Challenge Page ->`.
- **Daily Mission Widget**:
  - Current daily step milestone objective (e.g., "Walk 10,000 steps today to earn your Daily Streak Badge").
- **Leaderboard Preview Component** _(Visible if user has an active challenge)_:
  - Mini top-5 ranked participants list (Rank #1–#5) with avatars and step counts.
  - `View Full Leaderboard` link redirecting to `/challenge/joined`.

---

## 🏆 2. Challenge Hub (`/challenge`)

The Challenge tab dynamically shifts between **Discovery/Invite Mode** (when no challenge is active) and **Active Challenge Dashboard** (when enrolled).

```
                      ┌───────────────────────────┐
                      │ User Enters Challenge Tab │
                      └─────────────┬─────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
       [No Active Challenge]              [Active Challenge]
       ├── Join via Invite Code           ├── Challenge Header & Rules
       └── Explore Public List            ├── Prize Pool & Financial Breakdown
           ├── Area / Filter              ├── Countdown / Stage Progress
           └── Challenge Details          └── Ranked Participant Leaderboard
```

### 2.1 State A: Initial / Unenrolled State

- **Invite Code Banner**:
  - Quick input field for 6-digit private invite codes with a `Join Private Challenge` button.
- **Explore Public Challenges**:
  - Search bar + Filter Drawer button (Filter by: Geographic Area, Min/Max Buy-in Fee, Duration, Reward Mode).
  - Challenge Card List displaying:
    - Host badge & Name
    - Buy-in fee (e.g. `₱500`)
    - Duration tag (e.g. `30 Days`)
    - Participant counter (e.g. `18 / 25 Slots Filled`)
    - Estimated Total Prize Pool (e.g. `₱12,500`)
    - CTA button: `View Challenge Details`.

### 2.2 State B: Enrolled / Active Challenge Dashboard

- **Header Actions**:
  - `Rules & Guidelines` icon button -> opens modal with rules, dispute terms, and step validation policy.
- **Challenge Overview Card**:
  - Total Gross Prize Pool display (e.g. `₱25,000`).
  - Breakdown breakdown pill: `R_app% App Service Fee • R_host% Host Cut • Net Prize Pool` (e.g. `1.0% App Service Fee • 0.5% Host Cut • 98.5% Net Prize Pool`).
  - Challenge Lifecycle Indicator:
    - _Public Challenge_: Initial Phase countdown timer to launch date.
    - _Private Challenge_: Host `Start Challenge Now` CTA button (active once required minimum participants join).
  - Duration bar: Start Date ── Current Progress ── End Date (1–3 months).
  - Buy-in fee & max participant cap indicator.
  - Selected Reward Mode badge (e.g., `Top 3 Tiered Split`).
- **User Rank Banner**:
  - Displays user's current position, current total steps, and step gap to overtake the participant directly above them.
- **Full Participant Leaderboard**:
  - Sortable list by total cumulative steps.
  - Displays: Rank badge (#1 Gold, #2 Silver, #3 Bronze, #4+ Standard), Avatar, Username, Step Count, Daily Average, and Last Synced timestamp.

---

## 💬 3. Chat Module (`/chat`)

The Chat screen facilitates social engagement and rivalry among participants.

### 3.1 Initial State (Unenrolled)

- Empty state screen with an energetic illustration.
- Message: _"Join a challenge to unlock your automated challenge group chat!"_
- Button: `Explore Challenges`.

### 3.2 Active Challenge State

- **Automated Group Chat Room**: Group chat room automatically created upon challenge initialization.
- **Features**:
  - Real-time text messaging, emoji reactions, photo sharing (e.g., workout pictures).
  - **Automated Milestone Bot**: System messages triggered on key events:
    - _"⚡ @Sarah just took over 1st place with 12,400 steps today!"_
    - _"🔥 Halfway mark reached! 15 days remaining in the challenge."_
  - **Participant Drawer**: Side slide-out panel listing all active chat members and their current rankings.

---

## 👤 4. Account & Wallet Screen (`/account`)

The central hub for user profile, monetization, wallet management, and app configurations.

### 4.1 UI Component Breakdown

- **Profile Header**:
  - Avatar, Username, Bio, Member since date.
  - Lifetime Stats grid: Total Lifetime Steps, Total Challenges Joined, Challenges Won.
- **Host Subscription Management**:
  - Banner indicating `Standard Walker` or `Verified Host (Subscribed)`.
  - CTA button: `Upgrade to Host ($S_{host}$/month, e.g. ₱99/month)` -> unlocks custom challenge creation and $R_{host}$ host fee cut.
- **Achievements & Badges Showcase**:
  - Badge Grid: Visual collection of unlocked milestone badges (e.g. _30-Day Streak_, _100k Steps_, _Podium Finisher_).
  - XP Bar & Current Level badge with progress to next level perk.
- **Referral & Affiliate Hub**:
  - Personal Invite Link generator & QR code (`baktaz.app/invite/USER123`).
  - Referral Earnings Ledger: Total friends invited, referral bonus balance earned ($R_{ref}$).
  - Affiliate share button for Host challenge promoters.
- **In-App Wallet Card**:
  - **Balance Overview**: Available Balance vs Escrowed Funds (locked in active challenges).
  - **Actions**: `Cash In` (Deposit via GCash/Maya/Card) and `Withdraw Payout` (Transfer winnings to personal bank/GCash).
  - **Transaction Ledger**: Scrollable history of buy-ins paid, prize winnings received, host fee payouts, and cash-in/cash-out records.
- **Health Sync Configuration**:
  - Primary source toggle: `Health Connect (Android)` / `Apple HealthKit` / `Strava`.
  - Manual sync trigger & sync diagnostics log.
- **Preferences & System Settings**:
  - **Notifications**: Push toggles for Chat messages, Lead rank changes, Sync warnings, and Daily mission reminders.
  - **Theme**: Light Mode / Dark Mode switcher.
  - **Language**: English (default) with future Visayan/Tagalog options.
- **Legal & Help**:
  - `Privacy Policy` Webview.
  - `Terms & Conditions` Webview (Financial escrow rules, dispute resolution).
  - `Help Center` Webview.
  - Share Feedback
  - About Us

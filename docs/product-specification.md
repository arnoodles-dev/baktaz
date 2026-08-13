# Product Specification: Baktas

> **Document Version:** 1.0  
> **Status:** Active Concept Specification  
> **Target Audience:** Product Teams, Mobile Engineers (Flutter), UX Designers  

---

## 1. Product Vision & Mission

**Baktas** is a gamified, social step-tracking and fitness challenge ecosystem. Its primary mission is to solve the common drop-off in personal exercise consistency by attaching **social accountability**, **gamified leaderboards**, and **stake-backed financial incentives** to daily walking routines.

---

## 2. User Personas & Roles

| Role | Permissions & Capabilities | Value Proposition |
| :--- | :--- | :--- |
| **Standard Walker (Participant)** | • Sync health metrics (Health Connect, Apple Health, Strava)<br>• Join public challenges via Explore<br>• Join private challenges via Invite Code<br>• Participate in Challenge Group Chats<br>• Earn rewards from prize pools upon goal completion | Free access to daily step tracking, missions, and community motivation with optional stake challenges. |
| **Challenge Host (Organizer)** | • All Participant capabilities<br>• Ability to create public or private custom challenges<br>• Set buy-in fees, minimum step targets, duration (1–3 months), participant caps, and reward modes<br>• Earn host fee cut ($R_{host}$, configurable % cut of prize pool) | Monetize community organizing skills while staying fit and building an active group. |
| **Platform Administrator** | • Monitor financial transactions and wallet ledger<br>• Review reported suspicious step-count logs (Anti-Cheat tribunal)<br>• Manage platform fee structures and public challenge spotlights | System security, fraud prevention, and overall platform maintenance. |

---

## 3. Core Feature Matrix

### 3.1 Personal Habit & Fitness Tracking
- **Automated Step Integration**: Background sync with Health Connect (Android), HealthKit (iOS), and Strava API.
- **Daily Mission System**: Dynamic step targets based on historical rolling averages to keep motivation achievable.
- **Weekly Analytics**: Visual bar and line charts showing step consistency, distance covered, and estimated calories burned.

### 3.2 Stake-Backed Challenge Engine
- **Flexible Entry Fees**: Configurable buy-in fee per challenge (e.g., ₱500 – ₱1,000+).
- **Duration Enforcements**: Min 1 month to max 1 quarter (3 months) to promote sustained habit formation.
- **Access Modes**:
  - **Public Challenges**: Discoverable via Explore with filters for area/region, duration, buy-in amount, and reward mode.
  - **Private Challenges**: Accessible exclusively via 6-character alphanumeric Invite Codes or direct deep links.
- **Participant Limits**: Hosts can specify max participants (e.g., 10, 25, 50, 100, or unlimited).

### 3.3 Social & Community Engagement
- **Auto-Generated Challenge Group Chat**: Joining a challenge automatically enrolls the user into a dedicated, ephemeral group chat room.
- **Milestone Announcements**: Bot-driven chat alerts for lead changes, daily top walker, and goal completion milestones.
- **Live Leaderboards**: Real-time rank calculation updated per sync cycle.

### 3.4 In-App Wallet & Escrow Ledger
- **Buy-in Escrow**: User buy-in fees are held securely in escrow during the challenge period.
- **Prize Pool Distribution**: Automated post-challenge settlement and balance transfer directly into winner wallets.
- **Seamless Cash-in / Cash-out**: Support for local wallet payouts (e.g., GCash, Maya, Bank Transfer).

---

## 4. Monetization & Economic Model

### 4.1 System Variables & Configurable Parameters
- **$R_{app}$ (App Service Fee %)**: Configurable variable percentage automatically deducted from the prize pool after **every completed challenge** (default: `1.0%`).
- **$R_{host}$ (Host Fee %)**: Configurable host reward percentage cut from the gross pool (default: `0.5%`).
- **$S_{host}$ (Host Subscription Fee)**: Configurable recurring monthly subscription rate for host privileges (default: `₱99/month`).

```
                    ┌─────────────────────────┐
                    │  Total Challenge Pool   │
                    └────────────┬────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ App Service Fee │     │ Host Fee Cut    │     │ Net Prize Pool  │
│ (R_app %)       │     │ (R_host %)      │     │ (100% - R_total)│
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
                                                ┌─────────────────┐
                                                │ Participant     │
                                                │ Reward Winners  │
                                                └─────────────────┘
```

1. **App Service Fee ($R_{app}$)**: **After every completed challenge**, Baktas automatically deducts a configurable variable service fee ($R_{app}$) from the gross prize pool prior to reward payouts to cover platform infrastructure, anti-cheat monitoring, and transaction processing.
2. **Host Earnings ($R_{host}$)**: Subscribed Hosts earn a configurable percentage cut of the gross prize pool as compensation for organizing and maintaining community engagement.
3. **Host Creator Subscription ($S_{host}$)**:
   - Configurable recurring subscription fee granting the user the ability to host unlimited public and private challenges.
   - Access to custom challenge banner creation and participant export metrics.
   - Earns $R_{host}$ cut from created challenge pools.

---

## 5. Future Feature Roadmap & Recommendations

### 5.1 Affiliate & Referral System ($R_{ref}$)
- **User Referral Program**:
  - Users receive a unique referral link / code.
  - When a referred user signs up and completes their first challenge, the referrer earns a configurable referral commission ($R_{ref}$, e.g., ₱50 bonus credit or 5% of first buy-in).
- **Host Affiliate / Promoter Engine**:
  - Hosts & fitness influencers can generate affiliate tracking links for specific public challenges.
  - Hosts can optionally share a portion of their host fee ($R_{host}$) with affiliate promoters who recruit participants.

### 5.2 Achievements, Badges & XP Gamification
- **Tiered Achievement System**:
  - **Milestone Badges**: *First Step (1st Challenge)*, *Iron Walker (30-day 10k streak)*, *Century Club (100,000 total steps)*, *Podium Finisher (Top 3 finish)*, *Community Pillar (Hosted 5+ challenges)*.
- **Level & XP Progression**:
  - Every 1,000 steps synced yields 10 XP. Completing daily missions yields +50 XP.
  - Higher levels unlock cosmetic perks (animated avatar borders, custom chat title tags, exclusive app themes) and host subscription discounts.

### 5.3 Sponsored Challenges (B2B Brand Partnerships)
- Brands (e.g., shoe companies, energy drinks, fitness gear) sponsor public challenge prize pools by contributing gear, product vouchers, or bonus cash pools.
- App displays sponsored challenge banners and custom branded leaderboards.

### 5.4 Charity & Social Impact Walking ("Walk for a Cause")
- Participants can choose to donate a percentage of their challenge winnings (or forfeited pools in goal-threshold challenges) to vetted non-profit partners (e.g., reforestation, medical aid).

### 5.5 Team Squad Battles (Guilds & Clubs)
- Multi-user teams compete against each other in seasonal leagues based on team average step counts.

# Baktaz 🚶‍♂️🏆

> **Gamified Social Walking & Step-Count Challenge Platform**  
> *Turn your daily steps into real rewards, commitment, and community competition.*

---

## 🌟 Overview

**Baktaz** (Visayan term for walking/trekking) is a mobile-first fitness app designed to motivate people to stay active through stake-backed step challenges. Users put up a buy-in fee to join public or private walking challenges, compete on live leaderboards, interact in challenge-bound group chats, and win from the prize pool.

Whether aiming for personal fitness goals or competing against friends and local walkers, Baktaz turns daily physical activity into an engaging, accountable, and rewarding experience.

---

## ✨ Key Features

- 👟 **Automated Step Tracking Integration**: Seamlessly sync steps via Health Connect, Apple Health, and Strava.
- 🎯 **Daily Missions & Weekly Analytics**: Personal goals and visual charts to maintain daily activity habits.
- 💰 **Stake-Backed Challenges**: Buy-in fees (e.g., ₱500 – ₱1,000+) to foster real commitment and accountability.
- 🏆 **Flexible Reward Models**: Multiple distribution options including Winner-Takes-All, Top 3 Tiered Split, and Goal-Threshold Profit Shares.
- 💬 **Auto-Generated Group Chats**: Dynamic group chats created automatically for participants upon joining a challenge.
- 👑 **Host Subscriptions**: Hosts pay a monthly subscription (configurable variable $S_{host}$, e.g. ₱99/month) to create custom challenges and earn a configurable host fee cut ($R_{host}$, e.g. 0.5%) from the prize pool.
- 🏦 **App Service Fee**: After every completed challenge, the platform automatically deducts a configurable variable service fee ($R_{app}$, e.g. 1.0%) from the gross prize pool to maintain platform security, hosting, and operations.
- 🛡️ **Built-in Anti-Cheat Protection**: Multi-layered detection system to guard against step spoofing and ensure fair competition.

---

## 📂 Documentation Directory

To view detailed specifications and feature breakdowns, explore the `docs/` folder:

| Document | Description |
| :--- | :--- |
| 📑 [**Product Specification**](file:///Users/arnold/Projects/Project%20Baktaz/docs/product-specification.md) | High-level PRD, user roles, core value propositions, and monetization model. |
| 📱 [**Screens & User Flow**](file:///Users/arnold/Projects/Project%20Baktaz/docs/screens-and-user-flow.md) | Detailed UI layout specs for Home, Challenge Hub, Group Chat, and Wallet/Account. |
| ⚖️ [**Challenge Mechanics & Math**](file:///Users/arnold/Projects/Project%20Baktaz/docs/challenge-mechanics-and-math.md) | Prize pool calculations, tax rates, duration rules, and reward mode recommendations. |
| 🛡️ [**Anti-Cheat & Integrations**](file:///Users/arnold/Projects/Project%20Baktaz/docs/anti-cheat-and-integrations.md) | Recommendations for anti-spoofing step verification, health sync, and wallet escrow. |

---

## 🛠️ Main App Structure

```
Baktaz App
├── 🏠 Home (Daily Steps, Weekly Charts, Active Challenge Ticker, Daily Missions, Leaderboard Preview)
├── 🏆 Challenge Hub (Explore Public/Private, Invite Codes, Rules/Guidelines, Live Leaderboard)
├── 💬 Chat (Challenge-Specific Automated Group Chats & Announcements)
└── 👤 Account & Wallet (Profile, Host Subscription, Wallet Balance, Payouts, Health Sync Setup)
```

---

## 🚀 Future Features & Roadmap Recommendations

- 🤝 **Affiliate & Referral Engine**:
  - **User Referral Program**: Invite friends via personalized codes to earn bonus wallet credits or a percentage share of their initial challenge buy-in.
  - **Host / Creator Affiliates**: Fitness influencers and community leaders get custom referral links to promote public challenges, earning a commission on referred buy-in pools.
- 🎖️ **Achievements & Gamification System**:
  - **Unlockable Badges & XP**: Earn digital badges for milestones (e.g., *30-Day Streak*, *100k Steps Club*, *Podium Finisher*, *Master Host*).
  - **Leveling & Perks**: XP unlocks custom avatar frames, chat titles, and host subscription discounts.
- 🏢 **Brand & Corporate Sponsorships**:
  - Corporate partners and fitness brands sponsor public challenge prize pools (providing merchandise, gear vouchers, or bonus cash pools).
- 🌳 **Charity & Impact Walking ("Walk for a Cause")**:
  - Special challenge modes where forfeited pools or step targets generate donations to local health and environmental non-profits.
- ⚔️ **Team vs Team (Walking Squads & Clubs)**:
  - Group squad battles where team step averages compete head-to-head on club leaderboards.
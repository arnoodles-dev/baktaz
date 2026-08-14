# Challenge Mechanics & Reward Distribution Math

> **Document Version:** 1.0  
> **Target Audience:** Product Managers, Financial Ledger Engineers, Game Designers  

---

## 1. Challenge Parameters & Boundary Rules

To foster habit formation and ensure financial commitment, challenges on Baktaz operate under explicit boundary conditions:

| Parameter | Boundary / Limit | Rationale |
| :--- | :--- | :--- |
| **Buy-in Fee ($B$)** | Min: ₱500 \| Max: ₱10,000 | Minimum stake ensures meaningful "skin in the game" to prevent early abandonment. |
| **Duration ($D$)** | Min: 30 Days (1 Month) \| Max: 90 Days (1 Quarter) | Habit research proves physical habit formation requires sustained multi-week commitment. |
| **Participant Cap ($N$)** | Min: 2 participants \| Max: Configurable (10, 25, 50, 100, Unlimited) | Allows tight friend groups or large public walking marathons. |
| **Public Launch Phase** | 7-day initial signup phase before step counting officially begins | Gives time for public challenges to accumulate participants and maximize prize pools. |
| **Private Launch Phase** | Host can launch immediately once minimum participant count is met | Provides flexiblity for private friend groups. |

---

## 2. Gross Pool & Fee Calculation Math

Let:
- $N$ = Total number of verified participants in the challenge
- $B$ = Individual buy-in fee (in ₱)
- $P_{gross}$ = Total gross prize pool gathered in escrow
- $R_{app}$ = Configurable App Service Fee Rate (deducted after every challenge; default: $1.0\% = 0.01$)
- $R_{host}$ = Configurable Host Cut Rate (default: $0.5\% = 0.005$)
- $S_{host}$ = Configurable Host Monthly Subscription Fee (default: ₱99/month)

$$\text{Gross Prize Pool } (P_{gross}) = N \times B$$

### Fee Deductions

1. **App Service Fee ($T_{app}$)**: **After every completed challenge**, the app automatically deducts a configurable variable service fee percentage ($R_{app}$) from the gross prize pool prior to winner payout settlement.
   $$T_{app} = P_{gross} \times R_{app}$$

2. **Host Organizer Cut ($T_{host}$)**: Calculated via configurable host cut variable $R_{host}$ (payable to active Subscribed Hosts with monthly fee $S_{host}$). If host is unsubscribed, this fee reverts to the net prize pool.
   $$T_{host} = P_{gross} \times R_{host}$$

3. **Net Prize Pool ($P_{net}$)**: Distributed to challenge winners after App Service Fee and Host Cut deductions.
   $$P_{net} = P_{gross} - T_{app} - T_{host} = P_{gross} \times (1 - R_{app} - R_{host})$$

#### Example Calculation (Using Default Variables $R_{app} = 1.0\%$, $R_{host} = 0.5\%$):
If 20 participants join a 30-day challenge with a ₱1,000 buy-in:
- $P_{gross} = 20 \times ₱1,000 = ₱20,000$
- $T_{app} = ₱20,000 \times 0.01 = ₱200$
- $T_{host} = ₱20,000 \times 0.005 = ₱100$
- $P_{net} = ₱20,000 - ₱200 - ₱100 = ₱19,700$

---

## 3. Recommended Reward Distribution Modes

Baktaz provides 4 recommended reward modes for hosts to choose from during challenge creation:

```
                                  ┌─────────────────────────┐
                                  │   Net Prize Pool P_net  │
                                  └────────────┬────────────┘
                                               │
     ┌──────────────────┬──────────────────────┼──────────────────────┐
     ▼                  ▼                      ▼                      ▼
┌───────────┐    ┌───────────────┐     ┌───────────────┐      ┌───────────────┐
│ Mode 1:   │    │ Mode 2:       │     │ Mode 3:       │      │ Mode 4:       │
│ Winner    │    │ Top 3 Tiered  │     │ Goal Target   │      │ Milestone     │
│ Takes All │    │ (60/25/15)    │     │ Equal Split   │      │ Hybrid        │
└───────────┘    └───────────────┘     └───────────────┘      └───────────────┘
```

---

### 🟢 Mode 1: Winner-Takes-All ("All In")
* **Target Audience**: High-intensity competitive athletes & small private rivalries.
* **Mechanism**: 100% of $P_{net}$ is awarded to the #1 ranked participant with the highest cumulative step count at the end of the challenge duration.
* **Payout**:
  $$\text{Payout}_{\text{Rank 1}} = P_{net}$$
  $$\text{Payout}_{\text{Rank } 2..N} = ₱0$$

---

### 🔵 Mode 2: Top 3 Tiered Split ("Podium Model") — *Recommended Default*
* **Target Audience**: Standard public challenges & community events.
* **Mechanism**: Rewards the top 3 highest step count finishers to maintain excitement across multiple leaders.
* **Payout Schedule**:
  - **1st Place**: $60\%$ of $P_{net}$
  - **2nd Place**: $25\%$ of $P_{net}$
  - **3rd Place**: $15\%$ of $P_{net}$

#### Payout Example ($P_{net} = ₱19,700$):
- 🥇 **1st Place**: $₱19,700 \times 0.60 = ₱11,820$
- 🥈 **2nd Place**: $₱19,700 \times 0.25 = ₱4,925$
- 🥉 **3rd Place**: $₱19,700 \times 0.15 = ₱2,955$

---

### 🟡 Mode 3: Goal-Threshold Equal Profit Share ("Habit Builder") — *Recommended for Groups*
* **Target Audience**: Corporate wellness teams, beginner walking groups, habit builders.
* **Mechanism**: A fixed total step goal is defined (e.g. 300,000 steps in 30 days = 10,000 steps/day). Every participant who meets or exceeds the target gets their full buy-in returned, plus an equal share of the forfeited pool from participants who failed to reach the target!
* **Formula**:
  Let $M$ = number of participants who successfully hit the step target ($M \le N$).
  - If $M = N$ (Everyone succeeds): Everyone gets their exact net buy-in back ($\frac{P_{net}}{N}$).
  - If $M < N$:
    $$\text{Payout}_{\text{Qualifying Participant}} = \frac{P_{net}}{M}$$
    $$\text{Payout}_{\text{Non-Qualifying Participant}} = ₱0$$

#### Payout Example ($P_{gross} = ₱20,000$, $P_{net} = ₱19,700$, 20 Participants @ ₱1,000 buy-in):
- Suppose 14 participants reach 300k steps, while 6 fail.
- Each of the 14 qualifying participants receives: $\frac{₱19,700}{14} = ₱1,407.14$ (a **40.7% return on investment** for completing their walking habit!).

---

### 🟣 Mode 4: Milestone Tiered Cashback + Leader Bonus ("Hybrid Model")
* **Target Audience**: Medium-to-large public challenges.
* **Mechanism**:
  - **80% of $P_{net}$** is allocated to a Performance Pool distributed proportionally to all participants based on their percentage of completion toward the step target.
  - **20% of $P_{net}$** is reserved as a Leaderboard Bonus split among the Top 3 overall step leaders (50% / 30% / 20% of the bonus pool).
* **Benefit**: Ensures every participant receives partial financial return for whatever steps they completed, while still keeping a competitive incentive at the top.

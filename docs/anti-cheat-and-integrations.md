# Anti-Cheat Strategy & Technical Integrations Specification

> **Document Version:** 1.0  
> **Target Audience:** Backend Engineers, Mobile Developers (Flutter), Security & Data Engineers  

---

## 🛡️ 1. Comprehensive Anti-Cheat Strategy Recommendations

Because stake-backed challenges involve financial rewards ($P_{gross}$), protecting step integrity against fraud (mechanical shakers, fake syncs, manual input edits) is critical for user trust.

```
+-------------------------------------------------------------------+
|                     Multi-Layer Anti-Cheat Pipeline               |
+-------------------------------------------------------------------+
| Layer 1: Hardware Sensor Filtering (Block manual health inputs)   |
| Layer 2: Cadence & Anomaly Sanity Checks (Flag >4 steps/sec)      |
| Layer 3: GPS Distance & Velocity Cross-Verification               |
| Layer 4: Device & Account Binding (1 device = 1 active account)   |
| Layer 5: Community Flagging & Dispute Tribunal                    |
+-------------------------------------------------------------------+
```

### 1.1 Anti-Cheat Layers & Technical Rules

| Layer | Attack Vector Target | Detection & Prevention Mechanism |
| :--- | :--- | :--- |
| **Layer 1: Sensor Metadata Filtering** | Manual step entries in Google Fit / Health Connect | Filter step data streams by `DataOrigin`. Reject any data records marked with metadata tag `WAS_MANUALLY_ENTERED`. Only accept sensor inputs originating from verified OS pedometer hardware (`TYPE_STEP_COUNTER`). |
| **Layer 2: Cadence & Burst Sanity Checks** | Mechanical phone shakers / pendulums | • **Max Cadence Rule**: Human walking max cadence is ~3.5 to 4.0 steps per second. Flag step bursts exceeding 4 steps/sec sustained over 10 minutes.<br>• **Daily Ceiling Rule**: Flag any daily step log exceeding 45,000 steps (~35 km) for manual review before payout release. |
| **Layer 3: GPS & Step Ratio Cross-Validation** | Stationary phone shaking | For high-stakes challenges (buy-in $\ge$ ₱1,000), cross-reference step count with GPS displacement via Strava or location background samples. Flag logs reporting 15,000 steps with $<0.2\text{ km}$ net GPS movement. |
| **Layer 4: Device & Account Hardening** | Multiple fake accounts on 1 phone | Bind active challenge enrollment to hardware `DeviceUUID` and unique Health Account ID. Disallow switching Baktaz user accounts on a single physical device during an active challenge. |
| **Layer 5: Community Dispute Tribunal** | Undetected edge-case cheating | Include a `Report Participant` button on leaderboards. If a participant receives $\ge 3$ flags, their payout is temporarily frozen for 48 hours pending submission of raw step cadence charts or Strava activity links. |

---

## 🔌 2. Health Sync Integrations

Baktaz aggregates health data from three primary APIs:

```
                    ┌─────────────────────────┐
                    │    Baktaz Sync Hub      │
                    └────────────┬────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Health Connect  │     │ Apple HealthKit │     │   Strava API    │
│ (Android 14+)   │     │ (iOS Native)    │     │ (OAuth 2.0 Web) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 2.1 Integration Protocols
1. **Android Health Connect**:
   - Unified API for Android 14+ (and Android 9+ via Health Connect APK).
   - Reads `StepsRecord` with time-stamped interval granularities.
2. **iOS Apple HealthKit**:
   - Accesses `HKQuantityTypeIdentifierStepCount`.
   - Uses `HKStatisticsQuery` to aggregate daily cumulative step samples while excluding manually logged quantities (`HKWasUserEntered`).
3. **Strava OAuth 2.0 API**:
   - Secondary provider for verified outdoor walk/run activities.
   - Syncs distance, moving time, pace, and step estimates from Strava activity payloads.

---

## 💳 3. Wallet Escrow & Financial Integrations

### 3.1 Financial Ledger States
To maintain transparency and security, every buy-in transaction moves through explicit ledger states:

```
[Available Wallet Balance] ──(Join Challenge)──> [Escrow Locked Pool]
                                                         │
                                               (Challenge Completed)
                                                         │
[User Wallet Payout] <──(Automated Settlement)───────────┴──> [Platform & Host Fee Wallet]
```

### 3.2 Payment Gateway Integrations
- **Local Mobile Wallets**: GCash & Maya integration via local payment aggregators (e.g. PayMongo / Xendit APIs).
- **Cards & Bank Transfers**: Debit/Credit card processing via Stripe.
- **Escrow Automation**: Buy-in fees are held in platform escrow bank accounts and settled automatically by backend cron triggers upon challenge completion.

---

## 💬 4. Real-Time Chat Infrastructure

- **Protocol**: WebSockets / Realtime DB channel subscribed per `challenge_id`.
- **Automated Webhook Announcements**:
  - Triggers on backend rank changes and milestone events.
  - Broadcasts structured JSON events to chat room channels (e.g., `EVENT_LEAD_CHANGE`, `EVENT_MILESTONE_REACHED`, `EVENT_CHALLENGE_HALF_TIME`).

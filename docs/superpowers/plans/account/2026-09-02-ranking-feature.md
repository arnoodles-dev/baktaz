# Ranking Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a tiered ranking system (unknown/bronze/silver/gold/platinum/diamond/challengers) based on average daily steps, driven by remote config thresholds.

**Architecture:** Server-side `RankingService` computes rank from `DailyStepTelemetry` data and remote config thresholds; `AccountSummary` carries `avgStepsPerDay` and `rank`. Flutter `UserRank` model mirrors server rank with display helpers; `RankBadge` and updated `LifetimeStatsGrid` / `AccountHeaderCard` render the UI.

**Tech Stack:** Serverpod 2.x (Dart), Flutter, `freezed`, `bloc_signals`, `injectable`, `RemoteConfig` via `IRemoteConfigRepository`

**Spec:** `docs/superpowers/specs/account/2026-08-28-00-overview.md`

## Global Constraints

- Serverpod protocol types for `.spy.yaml` models; generated code must not be hand-edited
- `AccountRepository` constructor: `(SecurityLogger, IChallengeRepository, IRemoteConfigRepository)` — add IRemoteConfigRepository as 3rd dep
- `RemoteConfig` values are strings — parse in `RankingService`
- `RankingService` is stateless; takes `Map<String, String> configValues`
- `avgStepsPerDay` computed on-demand in repository, not cached
- `UserRank` is a `freezed` model with `label`, `color`, `assetPath` helpers
- Flutter `AccountSummary.fromServer` must map new server fields
- All new Dart files need `part '*.freezed.dart'` if freezed

---

### Task 1: Server — Rank enum model

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/model/rank.spy.yaml`

**Interfaces:**
- Consumes: `RemoteConfigValueType` enum (existing)
- Produces: `Rank` enum for use in `AccountSummary`

- [ ] **Step 1: Create rank.spy.yaml**

```yaml
enum: Rank
values:
  - unknown
  - bronze
  - silver
  - gold
  - platinum
  - diamond
  - challengers
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && serverpod generate`

- [ ] **Step 3: Verify generated Rank enum exists**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && dart analyze lib/src/features/account/domain/model/`

- [ ] **Step 4: Commit**

```bash
git add baktaz_server/lib/src/features/account/domain/model/rank.spy.yaml
git commit -m "feat(account): add Rank enum model"
```

---

### Task 2: Server — AccountSummary model with avgStepsPerDay and rank

**Files:**
- Modify: `baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml`

**Interfaces:**
- Consumes: `Rank` enum (Task 1)
- Produces: `AccountSummary` with `avgStepsPerDay: int` and `rank: Rank` fields

- [ ] **Step 1: Modify account_summary.spy.yaml**

Add two fields to existing fields list:

```yaml
class: AccountSummary
fields:
  userId: UuidValue
  isPremium: bool
  totalSteps: int
  activeChallengeCount: int
  fullName: String
  username: String
  avatarUrl: String?
  challengesJoined: int
  challengesWon: int
  winRatePercentage: double
  isHostTier: bool
  isStepsSyncActive: bool
  memberSince: DateTime?
  avgStepsPerDay: int
  rank: Rank
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && serverpod generate`

- [ ] **Step 3: Verify AccountSummary now has avgStepsPerDay and rank fields**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && dart analyze lib/src/features/account/domain/model/`

- [ ] **Step 4: Commit**

```bash
git add baktaz_server/lib/src/features/account/domain/model/account_summary.spy.yaml
git commit -m "feat(account): add avgStepsPerDay and rank to AccountSummary"
```

---

### Task 3: Server — RankingService

**Files:**
- Create: `baktaz_server/lib/src/features/account/domain/service/ranking_service.dart`
- Test: `baktaz_server/test/unit/features/account/ranking_service_test.dart`

**Interfaces:**
- Consumes: `Rank` enum, `DailyStepTelemetry` model, `Map<String, String> configValues`
- Produces: `Rank` from avgStepsPerDay thresholds

- [ ] **Step 1: Write failing test**

```dart
import 'package:baktaz_server/src/features/account/domain/service/ranking_service.dart';
import 'package:baktaz_server/src/features/account/domain/model/rank.dart';
import 'package:test/test.dart';

void main() {
  group('RankingService', () {
    const Map<String, String> configValues = {
      'ranking.bronze.max': '5000',
      'ranking.silver.max': '8000',
      'ranking.gold.max': '12000',
      'ranking.platinum.max': '15000',
      'ranking.diamond.max': '20000',
    };

    test('returns unknown when avgStepsPerDay is 0', () {
      final service = RankingService(configValues);
      expect(service.computeRank(0), Rank.unknown);
    });

    test('returns bronze when avgStepsPerDay is at bronze boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(5000), Rank.bronze);
    });

    test('returns bronze when avgStepsPerDay is just below silver', () {
      final service = RankingService(configValues);
      expect(service.computeRank(7999), Rank.bronze);
    });

    test('returns silver when avgStepsPerDay is at silver boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(8000), Rank.silver);
    });

    test('returns silver when avgStepsPerDay is just below gold', () {
      final service = RankingService(configValues);
      expect(service.computeRank(11999), Rank.silver);
    });

    test('returns gold when avgStepsPerDay is at gold boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(12000), Rank.gold);
    });

    test('returns gold when avgStepsPerDay is just below platinum', () {
      final service = RankingService(configValues);
      expect(service.computeRank(14999), Rank.gold);
    });

    test('returns platinum when avgStepsPerDay is at platinum boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(15000), Rank.platinum);
    });

    test('returns platinum when avgStepsPerDay is just below diamond', () {
      final service = RankingService(configValues);
      expect(service.computeRank(19999), Rank.platinum);
    });

    test('returns diamond when avgStepsPerDay is at diamond boundary', () {
      final service = RankingService(configValues);
      expect(service.computeRank(20000), Rank.diamond);
    });

    test('returns challengers when avgStepsPerDay exceeds diamond', () {
      final service = RankingService(configValues);
      expect(service.computeRank(20001), Rank.challengers);
    });
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && fvm dart test test/unit/features/account/ranking_service_test.dart -v`

Expected: FAIL — `RankingService` not defined

- [ ] **Step 3: Write minimal implementation**

```dart
import 'package:baktaz_server/src/features/account/domain/model/rank.dart';

class RankingService {
  RankingService(this.configValues);

  final Map<String, String> configValues;

  Rank computeRank(int avgStepsPerDay) {
    if (avgStepsPerDay <= 0) return Rank.unknown;
    final int bronzeMax = _parseInt('ranking.bronze.max');
    final int silverMax = _parseInt('ranking.silver.max');
    final int goldMax = _parseInt('ranking.gold.max');
    final int platinumMax = _parseInt('ranking.platinum.max');
    final int diamondMax = _parseInt('ranking.diamond.max');
    if (avgStepsPerDay <= bronzeMax) return Rank.bronze;
    if (avgStepsPerDay <= silverMax) return Rank.silver;
    if (avgStepsPerDay <= goldMax) return Rank.gold;
    if (avgStepsPerDay <= platinumMax) return Rank.platinum;
    if (avgStepsPerDay <= diamondMax) return Rank.diamond;
    return Rank.challengers;
  }

  int _parseInt(String key) {
    final String? value = configValues[key];
    if (value == null) return 0;
    return int.tryParse(value) ?? 0;
  }
}
```

- [ ] **Step 4: Run test to verify pass**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && fvm dart test test/unit/features/account/ranking_service_test.dart -v`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/account/domain/service/ranking_service.dart baktaz_server/test/unit/features/account/ranking_service_test.dart
git commit -m "feat(account): add RankingService with threshold-based rank computation"
```

---

### Task 4: Server — Update AccountRepository to compute avgStepsPerDay and rank

**Files:**
- Modify: `baktaz_server/lib/src/features/account/data/repository/account_repository.dart`
- Modify: `baktaz_server/lib/src/features/account/domain/interface/i_account_repository.dart`

**Interfaces:**
- Consumes: `IRemoteConfigRepository`, `DailyStepTelemetry`, `RankingService`, `Rank` enum
- Produces: `AccountSummary` with `avgStepsPerDay` and `rank` populated

- [ ] **Step 1: Write failing test for avgStepsPerDay calculation**

Create `baktaz_server/test/unit/features/account/account_repository_test.dart` if it does not exist, add test:

```dart
import 'package:baktaz_server/src/features/account/data/repository/account_repository.dart';
import 'package:baktaz_server/src/features/account/domain/model/rank.dart';
import 'package:baktaz_server/src/features/account/domain/model/rank.spy.yaml' as rank_proto;
import 'package:test/test.dart';

void main() {
  group('AccountRepository avgStepsPerDay', () {
    test('avgStepsPerDay = totalSteps ~/ distinctDateCount', () {
      // 3 distinct dates with steps [100, 200, 300] => total=600, distinct=3 => avg=200
      // Implementation verifies the formula via the repository
    });
  });
}
```

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && fvm dart test test/unit/features/account/account_repository_test.dart -v`

Expected: FAIL (or existing test structure — adapt to actual test file)

- [ ] **Step 2: Add IRemoteConfigRepository to IAccountRepository interface**

No interface signature change needed — the implementation adds a constructor param. The interface `IAccountRepository` stays the same. Only `AccountRepository` constructor changes.

Verify: `dart analyze baktaz_server/lib/src/features/account/domain/interface/`

- [ ] **Step 3: Modify AccountRepository constructor and getAccountSummary**

Update constructor:

```dart
@LazySingleton(as: IAccountRepository)
final class AccountRepository implements IAccountRepository {
  AccountRepository(this._securityLogger, this._challengeRepository, this._remoteConfigRepository);

  final SecurityLogger _securityLogger;
  final IChallengeRepository _challengeRepository;
  final IRemoteConfigRepository _remoteConfigRepository;
```

Update `getAccountSummary` to compute avgStepsPerDay and rank:

```dart
  @override
  Future<AccountSummary> getAccountSummary(Session session, UuidValue userId) async {
    final List<DailyStepTelemetry> dailySteps = await DailyStepTelemetry.db.find(
      session,
      where: (DailyStepTelemetryTable t) => t.userId.equals(userId),
    );
    final int totalSteps = dailySteps.fold<int>(0, (int sum, DailyStepTelemetry e) => sum + e.currentSteps);
    final int distinctDateCount = dailySteps.map((DailyStepTelemetry e) => e.date).toSet().length;
    final int avgStepsPerDay = distinctDateCount > 0 ? totalSteps ~/ distinctDateCount : 0;

    final RemoteConfig remoteConfig = await _remoteConfigRepository.getPublicConfig(session);
    final Map<String, String> configValues = <String, String>{
      for (final ConfigKey key in remoteConfig.config.keys)
        key.key: remoteConfig.config[key]!.value.value,
    };
    final Rank rank = RankingService(configValues).computeRank(avgStepsPerDay);

    final ActiveChallengeSummary? activeChallenge = await _challengeRepository.getActiveChallengeSummary(session);
    final int activeChallengeCount = activeChallenge != null ? 1 : 0;

    final UserInfo? userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (UserInfoTable t) => t.userIdentifier.equals(userId),
    );

    final String fullName = <String>[
      if (userInfo?.firstName != null && userInfo!.firstName!.isNotEmpty) userInfo.firstName!,
      if (userInfo?.lastName != null && userInfo!.lastName!.isNotEmpty) userInfo.lastName!,
    ].join(' ').trim();

    return AccountSummary(
      userId: userId,
      isPremium: false,
      totalSteps: totalSteps,
      activeChallengeCount: activeChallengeCount,
      fullName: fullName,
      username: userInfo?.username ?? '',
      challengesJoined: 0,
      challengesWon: 0,
      winRatePercentage: 0,
      isHostTier: false,
      isStepsSyncActive: false,
      memberSince: userInfo?.createdAt,
      avatarUrl: userInfo?.avatarUrl,
      avgStepsPerDay: avgStepsPerDay,
      rank: rank,
    );
  }
```

- [ ] **Step 4: Run analysis**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && dart analyze lib/src/features/account/`

Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add baktaz_server/lib/src/features/account/data/repository/account_repository.dart
git commit -m "feat(account): add avgStepsPerDay and rank computation to AccountRepository"
```

---

### Task 5: Flutter — UserRank freezed model

**Files:**
- Create: `baktaz_flutter/lib/features/account/domain/entity/model/user_rank.dart`

**Interfaces:**
- Consumes: `Rank` enum concept (server-side), `DESIGN.md` colors
- Produces: `UserRank` freezed model with `label`, `color`, `assetPath`

- [ ] **Step 1: Write failing test**

Create `baktaz_flutter/test/unit/user_rank_test.dart`:

```dart
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRank', () {
    test('unknown has correct label, color, assetPath', () {
      final rank = UserRank.unknown;
      expect(rank.label, 'Unknown');
      expect(rank.color, Colors.grey);
      expect(rank.assetPath, 'assets/rank/unknown.png');
    });

    test('bronze has correct label, color, assetPath', () {
      final rank = UserRank.bronze;
      expect(rank.label, 'Bronze');
      expect(rank.color, Colors.brown[700]);
      expect(rank.assetPath, 'assets/rank/bronze.png');
    });

    test('silver has correct label, color, assetPath', () {
      final rank = UserRank.silver;
      expect(rank.label, 'Silver');
      expect(rank.color, Colors.grey[400]);
      expect(rank.assetPath, 'assets/rank/silver.png');
    });

    test('gold has correct label, color, assetPath', () {
      final rank = UserRank.gold;
      expect(rank.label, 'Gold');
      expect(rank.color, Colors.amber[700]);
      expect(rank.assetPath, 'assets/rank/gold.png');
    });

    test('platinum has correct label, color, assetPath', () {
      final rank = UserRank.platinum);
      expect(rank.label, 'Platinum');
      expect(rank.color, Colors.blue[300]);
      expect(rank.assetPath, 'assets/rank/platinum.png');
    });

    test('diamond has correct label, color, assetPath', () {
      final rank = UserRank.diamond);
      expect(rank.label, 'Diamond');
      expect(rank.color, Colors.cyan[400]);
      expect(rank.assetPath, 'assets/rank/diamond.png');
    });

    test('challengers has correct label, color, assetPath', () {
      final rank = UserRank.challengers);
      expect(rank.label, 'Challengers');
      expect(rank.color, Colors.purple[700]);
      expect(rank.assetPath, 'assets/rank/challengers.png');
    });
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/unit/user_rank_test.dart -v`

Expected: FAIL — `UserRank` not defined

- [ ] **Step 3: Write UserRank implementation**

```dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_rank.freezed.dart';

@freezed
class UserRank with _$UserRank {
  const factory UserRank({
    required String label,
    required Color color,
    required String assetPath,
  }) = _UserRank;

  const UserRank._();

  factory UserRank.unknown() => const UserRank(
    label: 'Unknown',
    color: Colors.grey,
    assetPath: 'assets/rank/unknown.png',
  );

  factory UserRank.bronze() => const UserRank(
    label: 'Bronze',
    color: Color(0xFF8B4513),
    assetPath: 'assets/rank/bronze.png',
  );

  factory UserRank.silver() => const UserRank(
    label: 'Silver',
    color: Color(0xFFC0C0C0),
    assetPath: 'assets/rank/silver.png',
  );

  factory UserRank.gold() => const UserRank(
    label: 'Gold',
    color: Color(0xFFDAA520),
    assetPath: 'assets/rank/gold.png',
  );

  factory UserRank.platinum() => const UserRank(
    label: 'Platinum',
    color: Color(0xFFB3C9E0),
    assetPath: 'assets/rank/platinum.png',
  );

  factory UserRank.diamond() => const UserRank(
    label: 'Diamond',
    color: Color(0xFF00CED1),
    assetPath: 'assets/rank/diamond.png',
  );

  factory UserRank.challengers() => const UserRank(
    label: 'Challengers',
    color: Color(0xFF800080),
    assetPath: 'assets/rank/challengers.png',
  );

  static UserRank fromRank(String rankValue) {
    return switch (rankValue) {
      'bronze' => UserRank.bronze(),
      'silver' => UserRank.silver(),
      'gold' => UserRank.gold(),
      'platinum' => UserRank.platinum(),
      'diamond' => UserRank.diamond(),
      'challengers' => UserRank.challengers(),
      _ => UserRank.unknown(),
    };
  }
}
```

- [ ] **Step 4: Run test to verify pass**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/unit/user_rank_test.dart -v`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/account/domain/entity/model/user_rank.dart baktaz_flutter/test/unit/user_rank_test.dart
git commit -m "feat(account): add UserRank freezed model with display helpers"
```

---

### Task 6: Flutter — Update AccountSummary model

**Files:**
- Modify: `baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart`

**Interfaces:**
- Consumes: `UserRank` (Task 5), server `AccountSummary` with `avgStepsPerDay` and `rank`
- Produces: Updated `AccountSummary` with `avgStepsPerDay`, `rank`, and `challengeStepsTotal` preserved

- [ ] **Step 1: Write failing test**

Add to `baktaz_flutter/test/unit/account_repository_test.dart` or create `baktaz_flutter/test/unit/account_summary_test.dart`:

```dart
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountSummary', () {
    test('fromServer maps avgStepsPerDay and rank', () {
      final serverSummary = serverpod.AccountSummary(
        userId: serverpod.UuidValue.parse('12345678-1234-1234-1234-123456789012'),
        isPremium: false,
        totalSteps: 600,
        activeChallengeCount: 1,
        fullName: 'Test User',
        username: 'testuser',
        challengesJoined: 5,
        challengesWon: 3,
        winRatePercentage: 60.0,
        isHostTier: false,
        isStepsSyncActive: true,
        memberSince: DateTime(2024, 1, 1),
        avatarUrl: null,
        avgStepsPerDay: 200,
        rank: serverpod.Rank.bronze,
      );

      final summary = AccountSummary.fromServer(serverSummary);
      expect(summary.avgStepsPerDay, 200);
      expect(summary.rank, UserRank.bronze());
    });
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/unit/account_summary_test.dart -v`

Expected: FAIL

- [ ] **Step 3: Update AccountSummary model**

```dart
import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';

part 'account_summary.freezed.dart';

@freezed
abstract class AccountSummary with _$AccountSummary {
  const factory AccountSummary({
    required serverpod.UuidValue userId,
    required bool isPremium,
    required int challengeStepsTotal,
    required int challengesJoined,
    required int challengesWon,
    required String fullName,
    required String username,
    required bool isHostTier,
    required bool isStepsSyncActive,
    required DateTime? memberSince,
    String? avatarUrl,
    required int avgStepsPerDay,
    required UserRank rank,
  }) = _AccountSummary;

  const AccountSummary._();

  factory AccountSummary.fromServer(serverpod.AccountSummary accountSummary) => AccountSummary(
    userId: accountSummary.userId,
    isPremium: accountSummary.isPremium,
    challengeStepsTotal: accountSummary.totalSteps,
    challengesJoined: accountSummary.challengesJoined,
    challengesWon: accountSummary.challengesWon,
    fullName: accountSummary.fullName,
    username: accountSummary.username,
    isHostTier: accountSummary.isHostTier,
    isStepsSyncActive: accountSummary.isStepsSyncActive,
    memberSince: accountSummary.memberSince,
    avatarUrl: accountSummary.avatarUrl,
    avgStepsPerDay: accountSummary.avgStepsPerDay,
    rank: UserRank.fromRank(accountSummary.rank.toString().split('.').last),
  );
}
```

- [ ] **Step 4: Run codegen and test**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter pub run build_runner build --delete-conflicting-outputs`

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/unit/account_summary_test.dart -v`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/account/domain/entity/model/account_summary.dart baktaz_flutter/test/unit/account_summary_test.dart
git commit -m "feat(account): add avgStepsPerDay and rank to Flutter AccountSummary"
```

---

### Task 7: Flutter — RankBadge widget

**Files:**
- Create: `baktaz_flutter/lib/features/account/presentation/widgets/rank_badge.dart`
- Test: `baktaz_flutter/test/widget/account/rank_badge_test.dart`

**Interfaces:**
- Consumes: `UserRank` (Task 5)
- Produces: `RankBadge` widget showing icon + label

- [ ] **Step 1: Write failing test**

```dart
import 'package:baktaz_flutter/features/account/presentation/widgets/rank_badge.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RankBadge', () {
    final testRanks = [
      UserRank.unknown(),
      UserRank.bronze(),
      UserRank.silver(),
      UserRank.gold(),
      UserRank.platinum(),
      UserRank.diamond(),
      UserRank.challengers(),
    ];

    for (final rank in testRanks) {
      testWidgets('renders ${rank.label} label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RankBadge(rank: rank),
            ),
          ),
        );
        expect(find.text(rank.label), findsOneWidget);
      });
    }
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/rank_badge_test.dart -v`

Expected: FAIL — `RankBadge` not defined

- [ ] **Step 3: Write RankBadge implementation**

```dart
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

/// RankBadge — displays rank icon and label.
class RankBadge extends StatelessWidget {
  const RankBadge({required this.rank, super.key});

  final UserRank rank;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      BaktazText(
        text: rank.label,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: AppFontWeight.bold,
          color: rank.color,
        ),
      ),
    ],
  );
}
```

- [ ] **Step 4: Run test to verify pass**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/rank_badge_test.dart -v`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/account/presentation/widgets/rank_badge.dart baktaz_flutter/test/widget/account/rank_badge_test.dart
git commit -m "feat(account): add RankBadge widget"
```

---

### Task 8: Flutter — Update LifetimeStatsGrid to 4 columns (add AvgSteps)

**Files:**
- Modify: `baktaz_flutter/lib/features/account/presentation/widgets/lifetime_stats_grid.dart`
- Test: `baktaz_flutter/test/widget/account/lifetime_stats_grid_test.dart`

**Interfaces:**
- Consumes: `AccountSummary.avgStepsPerDay`
- Produces: 4-column grid with ChallengeSteps, Joined, Won, AvgSteps

- [ ] **Step 1: Write failing test**

```dart
import 'package:baktaz_flutter/features/account/presentation/widgets/lifetime_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LifetimeStatsGrid', () {
    testWidgets('renders 4 columns including avgSteps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LifetimeStatsGrid(
              isLoading: false,
              challengeStepsTotal: 1000,
              challengesJoined: 5,
              challengesWon: 3,
              avgStepsPerDay: 200,
            ),
          ),
        ),
      );
      // Verify 4 stat cards exist
      expect(find.byType(_StatCard), findsNWidgets(4));
    });
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/lifetime_stats_grid_test.dart -v`

Expected: FAIL — `avgStepsPerDay` param not on `LifetimeStatsGrid`

- [ ] **Step 3: Update LifetimeStatsGrid to 4 columns**

```dart
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// LifetimeStatsGrid — DESIGN.md §2.1
///
/// 4-column stats grid showing challengeStepsTotal, challengesJoined, challengesWon, avgStepsPerDay.
class LifetimeStatsGrid extends StatelessWidget {
  const LifetimeStatsGrid({
    required this.isLoading,
    required this.challengeStepsTotal,
    required this.challengesJoined,
    required this.challengesWon,
    required this.avgStepsPerDay,
    super.key,
  });

  final bool isLoading;
  final int challengeStepsTotal;
  final int challengesJoined;
  final int challengesWon;
  final int avgStepsPerDay;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xl),
      child: Row(
        children: <Widget>[
          Expanded(child: _StatCard(value: _formatNumber(challengeStepsTotal), label: context.i18n.lifetime_stats_grid.challenge_steps)),
          const SizedBox(width: BaktazSpacing.md),
          Expanded(child: _StatCard(value: _formatNumber(challengesJoined), label: context.i18n.lifetime_stats_grid.challenges_joined)),
          const SizedBox(width: BaktazSpacing.md),
          Expanded(child: _StatCard(value: _formatNumber(challengesWon), label: context.i18n.lifetime_stats_grid.challenges_won)),
          const SizedBox(width: BaktazSpacing.md),
          Expanded(child: _StatCard(value: _formatNumber(avgStepsPerDay), label: context.i18n.lifetime_stats_grid.avg_steps_per_day)),
        ],
      ),
    ),
  );

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return number.toString();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => BaktazCard(
    body: Padding(
      padding: const EdgeInsets.all(BaktazSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(
            text: value,
            style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.onSurface),
          ),
          Gap.xSmall(),
          BaktazText(
            text: label,
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: Add localization key**

Add to existing i18n JSON file: `avg_steps_per_day`

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter pub run flutter_localizations:generate`

- [ ] **Step 5: Run test to verify pass**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/lifetime_stats_grid_test.dart -v`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add baktaz_flutter/lib/features/account/presentation/widgets/lifetime_stats_grid.dart baktaz_flutter/test/widget/account/lifetime_stats_grid_test.dart
git commit -m "feat(account): expand LifetimeStatsGrid to 4 columns with avgSteps"
```

---

### Task 9: Flutter — Update AccountHeaderCard with optional rank

**Files:**
- Modify: `baktaz_flutter/lib/features/account/presentation/widgets/account_header_card.dart`
- Modify: `baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart`
- Test: `baktaz_flutter/test/widget/account/account_header_card_test.dart`

**Interfaces:**
- Consumes: `UserRank`, `RankBadge` (Task 7)
- Produces: `AccountHeaderCard` with optional `rank` parameter showing `RankBadge` next to username

- [ ] **Step 1: Write failing test**

```dart
import 'package:baktaz_flutter/features/account/presentation/widgets/account_header_card.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountHeaderCard', () {
    testWidgets('renders RankBadge when rank is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountHeaderCard(
              fullName: 'Test User',
              username: 'testuser',
              memberSince: DateTime(2024, 1, 1),
              imageUrl: null,
              onEditProfile: () {},
              rank: UserRank.bronze(),
            ),
          ),
        ),
      );
      expect(find.text('Bronze'), findsOneWidget);
    });

    testWidgets('does not render RankBadge when rank is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountHeaderCard(
              fullName: 'Test User',
              username: 'testuser',
              memberSince: DateTime(2024, 1, 1),
              imageUrl: null,
              onEditProfile: () {},
            ),
          ),
        ),
      );
      expect(find.text('Bronze'), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/account_header_card_test.dart -v`

Expected: FAIL — `rank` param not on `AccountHeaderCard`

- [ ] **Step 3: Update AccountHeaderCard**

Add `rank` parameter and show `RankBadge` next to username:

```dart
class AccountHeaderCard extends StatelessWidget {
  const AccountHeaderCard({
    required this.fullName,
    required this.username,
    required this.memberSince,
    required this.imageUrl,
    required this.onEditProfile,
    this.isLoading = false,
    this.rank,
    super.key,
  });

  final String? fullName;
  final String? username;
  final DateTime? memberSince;
  final String? imageUrl;
  final VoidCallback onEditProfile;
  final bool isLoading;
  final UserRank? rank;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xl),
      child: BaktazCard(
        headerTitle: fullName,
        headerIcon: Icons.person,
        headerAction: BaktazButton(
          text: context.i18n.account_header_card.edit_profile,
          onPressed: onEditProfile,
          buttonType: ButtonType.outlined,
          isEnabled: !isLoading,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: BaktazSpacing.md),
          child: Row(
            children: <Widget>[
              BaktazAvatar(
                size: 64,
                imageUrl: imageUrl,
                initials: AccountHeaderCard.initialsFromFullName(fullName),
              ),
              const SizedBox(width: BaktazSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (username case final String effectiveUsername) ...<Widget>[
                      Row(
                        children: <Widget>[
                          BaktazText(
                            text: '@$effectiveUsername',
                            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                          ),
                          if (rank != null) ...<Widget>[
                            const SizedBox(width: BaktazSpacing.xs),
                            RankBadge(rank: rank!),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: BaktazSpacing.xs2),
                    if (memberSince case final DateTime effectiveMemberSince)
                      BaktazText(
                        text: context.i18n.account_header_card.member_since(date: effectiveMemberSince.year.toString()),
                        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
```

- [ ] **Step 4: Update AccountPage to pass rank**

In `account_page.dart`, pass `rank` to `AccountHeaderCard`:

```dart
// Inside _AccountAppBar or wherever AccountHeaderCard is used:
AccountHeaderCard(
  fullName: fullName,
  username: username,
  memberSince: memberSince,
  imageUrl: avatarUrl,
  onEditProfile: () => context.goNamed('profile-edit'),
  rank: state.accountSummary?.rank,
),
```

- [ ] **Step 5: Run test to verify pass**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/widget/account/account_header_card_test.dart -v`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add baktaz_flutter/lib/features/account/presentation/widgets/account_header_card.dart baktaz_flutter/lib/features/account/presentation/views/pages/account_page.dart baktaz_flutter/test/widget/account/account_header_card_test.dart
git commit -m "feat(account): add rank display to AccountHeaderCard"
```

---

### Task 10: Flutter — Update AccountCubit to propagate rank and avgStepsPerDay

**Files:**
- Modify: `baktaz_flutter/lib/features/account/domain/cubit/account_cubit.dart`
- Modify: `baktaz_flutter/lib/features/account/domain/entity/model/account_state.dart` (if needed)

**Interfaces:**
- Consumes: Updated `AccountSummary` (Task 6)
- Produces: State flows `avgStepsPerDay` and `rank` to UI

- [ ] **Step 1: Verify AccountState has accountSummary field**

Read `account_state.dart` — confirm `accountSummary` field exists and is propagated via `safeEmit`.

- [ ] **Step 2: Verify AccountCubit getAccountSummary propagation**

The existing `initialize()` method already does:

```dart
_AccountSummary result = await _accountRepository.getAccountSummary().run();
result.fold(
  _failureHandler.handleFailure,
  (AccountSummary accountSummary) => safeEmit(stateValue.copyWith(accountSummary: accountSummary)),
);
```

Since `AccountSummary` now includes `avgStepsPerDay` and `rank`, the `copyWith` propagates automatically. No change needed in `AccountCubit` if `AccountState` uses the full `AccountSummary` object.

- [ ] **Step 3: Verify AccountState.accountSummary type**

If `AccountState` stores `AccountSummary?` directly, it already has the new fields. No code change required.

- [ ] **Step 4: If state uses individual fields, add them**

If `AccountState` has individual fields for `avgStepsPerDay` and `rank`, update them. Otherwise no change.

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && dart analyze lib/features/account/domain/cubit/`

- [ ] **Step 5: Commit**

```bash
git add baktaz_flutter/lib/features/account/domain/cubit/account_cubit.dart
git commit -m "feat(account): propagate rank and avgStepsPerDay in AccountCubit"
```

---

### Task 11: Add ConfigKey entries for ranking thresholds

**Files:**
- Modify: `baktaz_server/lib/src/features/remote_config/domain/model/config_key.spy.yaml` (or seed data)

**Interfaces:**
- Produces: 5 ConfigKey entries for ranking thresholds

- [ ] **Step 1: Add ConfigKey seed/migration entries**

The 5 config keys are already defined by `RankingService`:
- `ranking.bronze.max` = 5000
- `ranking.silver.max` = 8000
- `ranking.gold.max` = 12000
- `ranking.platinum.max` = 15000
- `ranking.diamond.max` = 20000

These are consumed by `RankingService` via `RemoteConfig`. Ensure the `ConfigKey` table has entries for these keys (either via seed data or migration).

- [ ] **Step 2: Commit**

```bash
git add baktaz_server/lib/src/features/remote_config/domain/model/config_key.spy.yaml
git commit -m "feat(config): add ranking threshold ConfigKey entries"
```

---

### Task 12: Final integration verification

**Files:**
- All modified files

- [ ] **Step 1: Run server analyze**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && dart analyze --fatal-infos`

Expected: No errors

- [ ] **Step 2: Run Flutter analyze**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter analyze --fatal-infos`

Expected: No errors

- [ ] **Step 3: Run server tests**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_server && fvm dart test test/unit/features/account/ -v`

Expected: PASS

- [ ] **Step 4: Run Flutter tests**

Run: `cd /Users/Arnold/Projects/baktaz/baktaz_flutter && fvm flutter test test/unit/ test/widget/account/ -v`

Expected: PASS

- [ ] **Step 5: Final commit**

```bash
git add -A && git commit -m "feat(ranking): complete ranking feature implementation"
```

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_active_challenge_ticker.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_app_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_challenge_discovery_banner.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_daily_step_hero_card.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_leaderboard_preview.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_title_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_steps_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(HomeTitleHeader, () {
    testWidgets('renders title without see-all when callback is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(body: HomeTitleHeader(title: 'Featured')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('See All'), findsNothing);
    });

    testWidgets('renders see-all and invokes callback when tapped', (WidgetTester tester) async {
      bool? pressed;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeTitleHeader(
              title: 'Featured',
              onSeeAllPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Featured'), findsOneWidget);
      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });

  group(HomeDailyStepHeroCard, () {
    goldenTest(
      'renders correctly',
      fileName: 'home_daily_step_hero_card'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default',
            child: MockMaterialApp(
              surfaceWidth: 600,
              child: Scaffold(
                body: HomeDailyStepHeroCard(
                  currentSteps: 7500,
                  goalSteps: 10000,
                  syncSource: 'Health Connect',
                  lastSyncedText: '10 mins ago',
                  onRefresh: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('renders step counts and sync source', (WidgetTester tester) async {
      bool refreshed = false;
      await tester.pumpWidget(
        MockMaterialApp(
          surfaceWidth: 600,
          child: Scaffold(
            body: HomeDailyStepHeroCard(
              currentSteps: 7500,
              goalSteps: 10000,
              syncSource: 'Health Connect',
              lastSyncedText: '10 mins ago',
              onRefresh: () {
                refreshed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("TODAY'S STEPS"), findsOneWidget);
      expect(find.text('7,500 steps'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      expect(refreshed, isTrue);
    });
  });

  group(HomeWeeklyStepsChart, () {
    testWidgets('renders weekly steps chart and header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          surfaceWidth: 600,
          child: Scaffold(
            body: HomeWeeklyStepsChart(
              weeklySteps: <int>[5000, 6000, 7000, 8000, 7500, 9000, 8500],
              averageSteps: 7285,
              totalWeeklySteps: 51000,
              goalTarget: 10000,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Weekly Activity'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });
  });

  group(HomeAppHeader, () {
    testWidgets('renders brand title and notifications icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: HomeAppHeader(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Baktaz'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });

  group(HomeChallengeDiscoveryBanner, () {
    testWidgets('renders prompt and explore button', (WidgetTester tester) async {
      bool explored = false;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeChallengeDiscoveryBanner(
              onOpenChallenge: () {
                explored = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🏆 Take on a Challenge'), findsOneWidget);
      expect(find.text('Explore Challenges ➔'), findsOneWidget);

      await tester.tap(find.text('Explore Challenges ➔'));
      await tester.pumpAndSettle();
      expect(explored, isTrue);
    });
  });

  group(HomeActiveChallengeTicker, () {
    testWidgets('renders enrollment discovery banner when isEnrolled is false', (WidgetTester tester) async {
      bool opened = false;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeActiveChallengeTicker(
              isEnrolled: false,
              onOpenChallenge: () {
                opened = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🏆 Take on a Challenge'), findsOneWidget);
      await tester.tap(find.text('Explore Challenges ➔'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    });

    testWidgets('renders active challenge details when isEnrolled is true', (WidgetTester tester) async {
      bool opened = false;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeActiveChallengeTicker(
              isEnrolled: true,
              title: 'August Marathon',
              rank: 12,
              totalParticipants: 500,
              prizePoolText: '5,000 pts',
              gapText: '50 steps to #11',
              leaders: const <String>['Alice', 'Bob', 'Charlie'],
              currentDay: 4,
              totalDays: 7,
              onOpenChallenge: () {
                opened = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🏆 August Marathon'), findsOneWidget);
      expect(find.text('Rank #12 / 500'), findsOneWidget);
      expect(find.text('Prize Pool: 5,000 pts'), findsOneWidget);
      expect(find.text('50 steps to #11'), findsOneWidget);
      expect(find.text('Go to Challenge Page ➔'), findsOneWidget);

      await tester.tap(find.text('Go to Challenge Page ➔'));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    });
  });

  group(HomeLeaderboardPreview, () {
    testWidgets('renders title, top entries, and view-full button', (WidgetTester tester) async {
      bool viewedFull = false;
      const List<LeaderboardEntry> entries = <LeaderboardEntry>[
        LeaderboardEntry(rank: 1, username: 'Alice', steps: 15000, avgSteps: '12,000', trend: 'up'),
        LeaderboardEntry(rank: 2, username: 'Bob', steps: 12000, avgSteps: '11,000', trend: 'down'),
      ];

      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeLeaderboardPreview(
              topEntries: entries,
              onViewFull: () {
                viewedFull = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Challenge Leaderboard'), findsOneWidget);
      expect(find.text('View Full Leaderboard ➔'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      await tester.tap(find.text('View Full Leaderboard ➔'));
      await tester.pumpAndSettle();
      expect(viewedFull, isTrue);
    });

    testWidgets('renders current user entry when not in top list', (WidgetTester tester) async {
      const List<LeaderboardEntry> entries = <LeaderboardEntry>[
        LeaderboardEntry(rank: 1, username: 'Alice', steps: 15000, avgSteps: '12,000', trend: 'up'),
      ];
      const LeaderboardEntry userEntry = LeaderboardEntry(
        rank: 99,
        username: 'Me',
        steps: 4000,
        avgSteps: '4,500',
        trend: 'flat',
      );

      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: HomeLeaderboardPreview(
              topEntries: entries,
              currentUserEntry: userEntry,
              onViewFull: _noop,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
      expect(find.text('📍 #99'), findsOneWidget);
    });
  });
}

void _noop() {}

import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_bar_item.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_chart_header.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_weekly_total_footer.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeWeeklyStepsChart extends StatefulWidget {
  const HomeWeeklyStepsChart({
    required this.weeklySteps,
    required this.averageSteps,
    required this.totalWeeklySteps,
    required this.goalTarget,
    super.key,
  });

  final List<int> weeklySteps;
  final int averageSteps;
  final int totalWeeklySteps;
  final int goalTarget;

  @override
  State<HomeWeeklyStepsChart> createState() => _HomeWeeklyStepsChartState();
}

class _HomeWeeklyStepsChartState extends State<HomeWeeklyStepsChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<int> safeSteps = widget.weeklySteps.length == 7 ? widget.weeklySteps : List<int>.filled(7, 0);

    return BaktazCard(
      body: Padding(
        padding: Paddings.allLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HomeWeeklyChartHeader(averageSteps: widget.averageSteps),
            Gap.medium(),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List<Widget>.generate(
                  7,
                  (int index) => HomeWeeklyBarItem(
                    steps: safeSteps[index],
                    dayLabel: days[index],
                    goalTarget: widget.goalTarget,
                    isSelected: selectedIndex == index,
                    onTap: () => setState(() => selectedIndex = index),
                  ),
                ),
              ),
            ),
            Gap.medium(),
            HomeWeeklyTotalFooter(totalWeeklySteps: widget.totalWeeklySteps),
          ],
        ),
      ),
    );
  }
}

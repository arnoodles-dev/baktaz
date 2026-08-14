import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const int todaySteps = 8450;
    const int targetSteps = 10000;
    const double cashBalance = 1500;

    return Scaffold(
      appBar: AppBar(
        title: Text('Baktaz Dashboard', style: AppTextStyle.titleLarge),
        actions: <Widget>[IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Daily Steps Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.large),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Today's Activity", style: AppTextStyle.headlineSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.colorPrimarySubtle,
                            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
                          ),
                          child: Text(
                            StepFormatter.formatProgressPercent(todaySteps, targetSteps),
                            style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSizes.large),
                    const Icon(Icons.directions_run_rounded, size: 48, color: AppColors.colorPrimary),
                    const Gap(AppSizes.medium),
                    Text(
                      StepFormatter.formatSteps(todaySteps),
                      style: AppTextStyle.displayLarge.copyWith(color: AppColors.colorPrimary),
                    ),
                    Text(
                      'Goal: ${StepFormatter.formatSteps(targetSteps)} (${StepFormatter.formatDistanceKm(todaySteps * 0.00075)})',
                      style: AppTextStyle.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const Gap(AppSizes.medium),
                    const LinearProgressIndicator(
                      value: todaySteps / targetSteps,
                      backgroundColor: AppColors.colorPrimarySubtle,
                      color: AppColors.colorPrimary,
                      minHeight: 8,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(AppSizes.medium),
            // Wallet Balance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.large),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Wallet Balance', style: AppTextStyle.labelMedium),
                        const Gap(4),
                        Text(
                          MoneyFormatter.format(cashBalance),
                          style: AppTextStyle.displayMedium.copyWith(color: AppColors.colorSuccess),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Top Up'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

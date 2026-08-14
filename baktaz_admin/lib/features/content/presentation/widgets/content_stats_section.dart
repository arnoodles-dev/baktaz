import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ContentStatsSection extends StatelessWidget {
  const ContentStatsSection({
    required this.activeCount,
    required this.scheduledCount,
    required this.draftCount,
    super.key,
  });

  final int activeCount;
  final int scheduledCount;
  final int draftCount;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: _StatCard(label: context.i18n.content.stats.active, value: '$activeCount', icon: Icons.check_circle),
      ),
      const Gap(AppSizes.small),
      Expanded(
        child: _StatCard(label: context.i18n.content.stats.scheduled, value: '$scheduledCount', icon: Icons.schedule),
      ),
      const Gap(AppSizes.small),
      Expanded(
        child: _StatCard(label: context.i18n.content.stats.drafts, value: '$draftCount', icon: Icons.edit),
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BaktazCard(
      body: Row(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary, size: AppSizes.iconMedium),
          const Gap(AppSizes.small),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BaktazText(
                text: value,
                style: AppTextStyle.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              BaktazText(
                text: label,
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

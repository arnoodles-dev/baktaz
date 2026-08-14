import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.growth,
    this.isStatus = false,
    super.key,
  });

  final String title;
  final String value;
  final String? growth;
  final IconData icon;
  final Color color;
  final bool isStatus;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.textTheme;
    final ColorScheme colorScheme = context.colorScheme;

    return Container(
      padding: Paddings.allMedium,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: Paddings.allSmall,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: BaktazIcon(icon: right(icon), color: color),
              ),
              if (isStatus)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                )
              else
                _GrowthBadge(growth: growth, colorScheme: colorScheme, textTheme: textTheme),
            ],
          ),
          Gap.medium(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: title,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Gap.x2Small(),
              BaktazText(
                text: value,
                style: textTheme.headlineSmall?.copyWith(fontWeight: AppFontWeight.bold, color: colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge({required this.growth, required this.colorScheme, required this.textTheme});

  final String? growth;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final String? g = growth;
    if (g == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.small, vertical: AppSizes.x2Small),
      decoration: BoxDecoration(
        color: g.startsWith('+')
            ? colorScheme.secondary.withValues(alpha: 0.1)
            : colorScheme.error.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
      ),
      child: BaktazText(
        text: g,
        style: textTheme.labelSmall?.copyWith(
          color: g.startsWith('+') ? colorScheme.secondary : colorScheme.error,
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }
}

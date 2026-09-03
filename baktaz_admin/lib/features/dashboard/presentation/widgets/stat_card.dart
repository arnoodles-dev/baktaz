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
        color: context.colorScheme.surface,
        borderRadius: BaktazRadius.chip,
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: context.colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                  decoration: BoxDecoration(color: context.colorScheme.primary, shape: BoxShape.circle),
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
                style: textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
              Gap.x2Small(),
              BaktazText(
                text: value,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: context.colorScheme.onSurface),
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
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm, vertical: BaktazSpacing.xs2),
      decoration: BoxDecoration(
        color: g.startsWith('+')
            ? context.colorScheme.secondary.withValues(alpha: 0.1)
            : context.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BaktazRadius.chip,
      ),
      child: BaktazText(
        text: g,
        style: textTheme.labelSmall?.copyWith(
          color: g.startsWith('+') ? context.colorScheme.secondary : context.colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

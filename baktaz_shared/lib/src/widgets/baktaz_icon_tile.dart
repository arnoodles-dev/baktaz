import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// IconTile — DESIGN.md §3.3
///
/// Square tile for facility/amenity grids and feature highlights.
class BaktazIconTile extends StatelessWidget {
  const BaktazIconTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconSize = BaktazSpacing.iconMedium,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget tile = Container(
      constraints: const BoxConstraints(minWidth: 56),
      padding: const EdgeInsets.all(BaktazSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: iconSize, color: theme.colorScheme.primary),
          const SizedBox(height: BaktazSpacing.xs2),
          BaktazText(
            text: label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
          onTap: onTap,
          child: tile,
        ),
      );
    }

    return tile;
  }
}

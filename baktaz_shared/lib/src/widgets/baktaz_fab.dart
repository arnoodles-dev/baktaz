import 'package:baktaz_shared/src/theme/baktaz_elevation.dart';
import 'package:flutter/material.dart';

/// BaktazFAB — DESIGN.md §1.6
///
/// Custom 54dp circular action button (not standard 56dp FloatingActionButton).
class BaktazFAB extends StatelessWidget {
  const BaktazFAB({
    required this.onPressed,
    this.icon = Icons.add,
    super.key,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: scheme.primary,
        shape: BoxShape.circle,
        boxShadow: BaktazElevation.fab(theme.brightness),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, color: scheme.onPrimary, size: 24),
          ),
        ),
      ),
    );
  }
}

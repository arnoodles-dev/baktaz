import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:flutter/material.dart';

/// NotificationIconButton — DESIGN.md §2.1
///
/// 40dp circular icon button with optional unread indicator dot.
class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({
    required this.onPressed,
    this.hasUnread = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: scheme.onSurfaceVariant, size: 20),
              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: BaktazSpacing.xs2,
              right: BaktazSpacing.xs2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

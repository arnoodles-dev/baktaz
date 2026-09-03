import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_avatar.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

class BaktazListRow extends StatelessWidget {
  const BaktazListRow({
    required this.title,
    this.subtitle,
    this.leadingAvatar,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.isThreeLine,
    this.avatarSize = BaktazAvatar.sizeSM,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? leadingAvatar;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? isThreeLine;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool? threeLine = isThreeLine;
    final String? effectiveSubtitle = subtitle;
    final String? avatarInitials = leadingAvatar;
    final IconData? leadingIconData = leadingIcon;
    final Widget? trailingWidget = trailing;

    Widget? leadingWidget;
    if (avatarInitials != null) {
      leadingWidget = BaktazAvatar(size: avatarSize, initials: avatarInitials);
    } else if (leadingIconData != null) {
      leadingWidget = Container(
        width: BaktazAvatar.sizeSM,
        height: BaktazAvatar.sizeSM,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(leadingIconData, size: BaktazSpacing.iconSmall, color: theme.colorScheme.primary),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BaktazRadius.row,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(BaktazSpacing.md),
            child: Row(
              children: <Widget>[
                if (leadingWidget != null) ...<Widget>[
                  leadingWidget,
                  const SizedBox(width: BaktazSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BaktazText(
                        text: title,
                        style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
                        maxLines: threeLine == true ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (effectiveSubtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: BaktazSpacing.xs2),
                          child: BaktazText(
                            text: effectiveSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            maxLines: threeLine == true ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailingWidget != null) ...<Widget>[
                  const SizedBox(width: BaktazSpacing.sm),
                  trailingWidget,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

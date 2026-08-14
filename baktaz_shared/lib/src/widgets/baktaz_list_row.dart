import 'package:baktaz_shared/src/theme/app_colors.dart';
import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// ListRow — DESIGN.md §12.10
///
/// Settings / Navigation list row with leading icon/avatar, label, and trailing variants.
class BaktazListRow extends StatelessWidget {
  const BaktazListRow({
    required this.label,
    this.leading,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailing,
    this.trailingIcon,
    this.subtitle,
    this.isDestructive = false,
    this.onTap,
    super.key,
  });

  final Widget? leading;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final IconData? trailingIcon;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final String? subtitle = this.subtitle;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: Paddings.horizontalMedium,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5), width: 0.5)),
          ),
          child: Row(
            children: <Widget>[
              if (leading case final Widget effectiveLeading)
                Padding(padding: Paddings.rightMedium, child: effectiveLeading)
              else if (leadingIcon case final IconData effectiveLeadingIcon)
                Padding(
                  padding: Paddings.rightMedium,
                  child: Icon(
                    effectiveLeadingIcon,
                    size: AppSizes.iconMedium,
                    color: leadingIconColor ?? effectiveColor,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BaktazText(
                      text: label,
                      style: theme.textTheme.titleMedium?.copyWith(color: effectiveColor),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: Paddings.topX2Small,
                        child: BaktazText(
                          text: subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing case final Widget effectiveTrailing)
                Padding(padding: Paddings.leftSmall, child: effectiveTrailing)
              else if (trailingIcon != null && !isDestructive)
                Padding(
                  padding: Paddings.leftSmall,
                  child: Icon(trailingIcon, size: AppSizes.iconSmall, color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

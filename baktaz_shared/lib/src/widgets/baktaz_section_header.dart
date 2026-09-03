import 'package:baktaz_shared/src/theme/app_sizes.dart';
import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// SectionHeader — DESIGN.md §12.20
///
/// Row with space-between layout, title, and optional "See All" link.
class BaktazSectionHeader extends StatelessWidget {
  const BaktazSectionHeader({required this.title, this.linkLabel, this.onLinkPressed, super.key});

  final String title;
  final String? linkLabel;
  final VoidCallback? onLinkPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? linkLabel = this.linkLabel;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.large,
        bottom: AppSizes.small,
        left: AppSizes.medium,
        right: AppSizes.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: BaktazText(
              text: title,
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (linkLabel != null && onLinkPressed != null)
            GestureDetector(
              onTap: onLinkPressed,
              child: Padding(
                padding: Paddings.leftXSmall,
                child: BaktazText(
                  text: linkLabel,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

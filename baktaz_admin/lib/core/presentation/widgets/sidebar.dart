import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/core/presentation/widgets/baktaz_nav_item_data.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.navItems,
    required this.extended,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BaktazNavItemData> navItems;
  final bool extended;

  static const double compactWidth = 72;
  static const double extendedWidth = 264;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: extended ? extendedWidth : compactWidth,
      color: context.colorScheme.surface,
      child: Column(
        children: <Widget>[
          const SizedBox(height: BaktazSpacing.lg),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: extended ? BaktazSpacing.sm : 0, vertical: BaktazSpacing.xs),
              children: <Widget>[
                for (int index = 0; index < navItems.length; index++)
                  _NavItemTile(
                    icon: navItems[index].icon,
                    label: navItems[index].label,
                    selected: index == selectedIndex,
                    extended: extended,
                    onTap: () => onDestinationSelected(index),
                  ),
              ],
            ),
          ),
          if (extended) const _UserTile(),
        ],
      ),
    );
}

class _UserTile extends StatelessWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.3))),
      ),
      padding: const EdgeInsets.fromLTRB(BaktazSpacing.md, BaktazSpacing.sm, BaktazSpacing.sm, BaktazSpacing.md),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 16,
            backgroundColor: context.colorScheme.primaryContainer,
            child: BaktazText(
              text: 'AR',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: context.colorScheme.primary),
            ),
          ),
          const SizedBox(width: BaktazSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BaktazText(
                  text: context.i18n.remote_config.sidebar.user_name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurface),
                ),
                BaktazText(
                  text: context.i18n.remote_config.sidebar.user_role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: BaktazIcon(
              icon: right(Icons.logout),
              size: BaktazSpacing.iconSmall,
              color: context.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {},
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedBg = context.colorScheme.primary.withValues(alpha: 0.12);
    final Color selectedFg = context.colorScheme.primary;
    final Color inactiveFg = context.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? selectedBg : Colors.transparent,
        borderRadius: BaktazRadius.pill,
        child: InkWell(
          borderRadius: BaktazRadius.pill,
          onTap: onTap,
          child: Container(
            height: extended ? 44 : 48,
            alignment: Alignment.center,
            child: extended
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm),
                    child: Row(
                      children: <Widget>[
                        BaktazIcon(
                          icon: right(icon),
                          size: BaktazSpacing.iconMedium,
                          color: selected ? selectedFg : inactiveFg,
                        ),
                        const SizedBox(width: BaktazSpacing.sm),
                        Expanded(
                          child: BaktazText(
                            text: label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? selectedFg : inactiveFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : BaktazIcon(
                    icon: right(icon),
                    size: BaktazSpacing.iconMedium,
                    color: selected ? selectedFg : inactiveFg,
                  ),
          ),
        ),
      ),
    );
  }
}

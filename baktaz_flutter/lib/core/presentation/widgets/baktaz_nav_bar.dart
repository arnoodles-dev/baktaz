import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/presentation/widgets/wrappers/hidable.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaktazNavBar extends StatelessWidget implements PreferredSizeWidget {
  const BaktazNavBar({required this.navigationShell, required this.selectedIndex, this.size, super.key});

  final StatefulNavigationShell navigationShell;
  final ValueNotifier<int> selectedIndex;
  final Size? size;

  List<_BaktazNavBarItem> _getNavItemList(BuildContext context) => <_BaktazNavBarItem>[
    _BaktazNavBarItem(
      defaultIcon: Icons.home_outlined,
      activeIcon: Icons.home,
      title: context.i18n.common.home.capitalize(),
    ),
    _BaktazNavBarItem(
      defaultIcon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
      title: context.i18n.common.challenge.capitalize(),
    ),
    _BaktazNavBarItem(
      defaultIcon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      title: context.i18n.common.messages.capitalize(),
    ),
    _BaktazNavBarItem(
      defaultIcon: Icons.person_outline,
      activeIcon: Icons.person,
      title: context.i18n.common.account.capitalize(),
    ),
  ];

  @override
  Size get preferredSize => size ?? const Size.fromHeight(AppTheme.defaultNavBarHeight);

  @override
  Widget build(BuildContext context) {
    final List<_BaktazNavBarItem> navItems = _getNavItemList(context);
    return Hidable(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: NavigationBar(
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (int index) => _onItemTapped(context, index, selectedIndex),
          destinations: navItems
              .map(
                (_BaktazNavBarItem item) => NavigationDestination(
                  icon: Icon(item.defaultIcon),
                  selectedIcon: Icon(item.activeIcon),
                  label: item.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index, ValueNotifier<int> selectedIndex) {
    selectedIndex.value = index;
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }
}

class _BaktazNavBarItem {
  const _BaktazNavBarItem({required this.defaultIcon, required this.activeIcon, required this.title});

  final IconData defaultIcon;
  final IconData activeIcon;
  final String title;
}

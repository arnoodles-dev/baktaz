import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/presentation/widgets/wrappers/hidable.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
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
      defaultIcon: Icons.history_outlined,
      activeIcon: Icons.history,
      title: context.i18n.common.activity.capitalize(),
    ),
    _BaktazNavBarItem(
      defaultIcon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      title: context.i18n.common.messages.capitalize(),
    ),
    _BaktazNavBarItem(
      defaultIcon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
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
        child: AnimatedBottomNavigationBar.builder(
          backgroundColor: context.colorScheme.surfaceContainer,
          scaleFactor: 0,
          itemCount: navItems.length,
          tabBuilder: (int index, bool isActive) => RepaintBoundary(
            child: _NavBarItem(index: index, isActive: isActive, navBarItems: navItems),
          ),
          height: AppTheme.defaultNavBarHeight,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.smoothEdge,
          activeIndex: selectedIndex.value,
          shadow: AppTheme.shadowLevel1(context.colorScheme).first,
          onTap: (int index) => _onItemTapped(context, index, selectedIndex),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index, ValueNotifier<int> selectedIndex) {
    selectedIndex.value = index;
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({required this.index, required this.isActive, required this.navBarItems});

  final int index;
  final bool isActive;
  final List<_BaktazNavBarItem> navBarItems;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? context.colorScheme.primary : context.colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        BaktazIcon(
          icon: right(isActive ? navBarItems[index].activeIcon : navBarItems[index].defaultIcon),
          size: AppSizes.size26,
          color: color,
        ),
        Gap.x2Small(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall),
          child: BaktazText(
            text: navBarItems[index].title,
            maxLines: 1,
            style: context.textTheme.labelMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _BaktazNavBarItem {
  const _BaktazNavBarItem({required this.defaultIcon, required this.activeIcon, required this.title});

  final IconData defaultIcon;
  final IconData activeIcon;
  final String title;
}

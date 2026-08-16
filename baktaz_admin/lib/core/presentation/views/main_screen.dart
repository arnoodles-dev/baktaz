import 'package:baktaz_admin/core/presentation/widgets/baktaz_header_bar.dart';
import 'package:baktaz_admin/core/presentation/widgets/baktaz_nav_item_data.dart';
import 'package:baktaz_admin/core/presentation/widgets/navigation_transition.dart';
import 'package:baktaz_admin/core/presentation/widgets/sidebar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({required this.child, super.key});

  final Widget child;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  static const double _mediumWidthBreakpoint = 520;
  static const double _largeWidthBreakpoint = 1200;

  late final AnimationController _controller;
  late final CurvedAnimation _railAnimation;
  bool _initialized = false;
  bool _showLargeSizeLayout = false;
  bool _sidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _railAnimation = CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = _controller.status;

    if (width > _mediumWidthBreakpoint) {
      _showLargeSizeLayout = width > _largeWidthBreakpoint;
      if (status != AnimationStatus.forward && status != AnimationStatus.completed) {
        _controller.forward();
      }
    } else {
      _showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse && status != AnimationStatus.dismissed) {
        _controller.reverse();
      }
    }

    if (!_initialized) {
      _initialized = true;
      _controller.value = width > _mediumWidthBreakpoint ? 1 : 0;
    }
  }

  int _selectedIndex() {
    final String currentRoute = GoRouterState.of(context).matchedLocation;
    final int index = _navItems.indexWhere((BaktazNavItemData item) => currentRoute.startsWith(item.route));
    return index >= 0 ? index : 0;
  }

  static const List<BaktazNavItemData> _navItems = <BaktazNavItemData>[
    BaktazNavItemData(icon: Icons.home, label: 'Overview', route: '/dashboard'),
    BaktazNavItemData(icon: Icons.trending_up, label: 'Activities', route: '/activities'),
    BaktazNavItemData(icon: Icons.sell, label: 'Sales', route: '/sales'),
    BaktazNavItemData(icon: Icons.settings_suggest, label: 'Config', route: '/config'),
    BaktazNavItemData(icon: Icons.language, label: 'Localization', route: '/localization'),
    BaktazNavItemData(icon: Icons.group, label: 'Users', route: '/users'),
    BaktazNavItemData(icon: Icons.description, label: 'Content', route: '/content'),
    BaktazNavItemData(icon: Icons.analytics, label: 'Analytics', route: '/analytics'),
    BaktazNavItemData(icon: Icons.assignment, label: 'Reports', route: '/reports'),
    BaktazNavItemData(icon: Icons.settings, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width <= _mediumWidthBreakpoint;
    final int selectedIndex = _selectedIndex();

    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => NavigationTransition(
            railAnimation: _railAnimation,
            appBar: BaktazHeaderBar(onMenuTap: isMobile ? () => setState(() => _sidebarOpen = true) : null),
            body: widget.child,
            navigationRail: isMobile
                ? const SizedBox.shrink()
                : RepaintBoundary(
                    child: Sidebar(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) {
                        context.go(_navItems[index].route);
                        if (isMobile) setState(() => _sidebarOpen = false);
                      },
                      navItems: _navItems,
                      extended: _showLargeSizeLayout,
                    ),
                  ),
          ),
        ),
        // Backdrop (behind sidebar)
        if (_sidebarOpen && isMobile)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(color: AppColors.black.withValues(alpha: 0.26)),
            ),
          ),
        // Mobile sidebar drawer (on top of backdrop)
        if (isMobile)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _sidebarOpen ? 0 : -Sidebar.extendedWidth,
            top: 0,
            bottom: 0,
            width: Sidebar.extendedWidth,
            child: Material(
              elevation: 16,
              child: RepaintBoundary(
                child: Sidebar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    context.go(_navItems[index].route);
                    if (isMobile) setState(() => _sidebarOpen = false);
                  },
                  navItems: _navItems,
                  extended: true,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

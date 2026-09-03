import 'dart:async';

import 'package:baktaz_admin/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';

class BaktazHeaderBar extends HookWidget implements PreferredSizeWidget {
  const BaktazHeaderBar({this.onMenuTap, super.key});

  /// DESIGN.md §10.2 App Bar height.
  static const double _headerHeight = 56;

  /// DESIGN.md §12.3 SearchBar height.
  static const double _searchHeight = 52;

  static const double _notificationDotSize = 8;

  final VoidCallback? onMenuTap;

  @override
  Size get preferredSize => const Size.fromHeight(_headerHeight);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = useTextEditingController();

    return Container(
      height: _headerHeight,
      color: context.colorScheme.surface,
      child: Row(
        children: <Widget>[
          if (onMenuTap != null)
            Semantics(
              label: 'Open menu',
              child: IconButton(
                icon: const BaktazIcon(icon: Right<String, IconData>(Icons.menu)),
                onPressed: onMenuTap,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: BaktazSpacing.md),
            child: Semantics(
              label: 'PAXA',
              child: BaktazText(
                text: 'PAXA',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: context.colorScheme.primary),
              ),
            ),
          ),
          Gap.medium(),
          Flexible(
            child: SizedBox(
              height: _searchHeight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: Paddings.verticalXSmall,
                child: BaktazTextField(
                  controller: searchController,
                  hintText: 'Search...',
                  prefix: const BaktazIcon(icon: Right<String, IconData>(Icons.search)),
                  fillColor: context.colorScheme.surfaceContainer,
                  borderRadius: BaktazRadius.pill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md, vertical: 14),
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          Semantics(
            label: 'Toggle dark mode',
            child: BlocSignalBuilder<ThemeCubit, ThemeMode>(
              builder: (BuildContext context, _) {
                final bool isDark = Theme.of(context).brightness == Brightness.dark;
                return IconButton(
                  icon: BaktazIcon(
                    icon: Right<String, IconData>(isDark ? Icons.light_mode : Icons.dark_mode),
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    final Brightness current = Theme.of(context).brightness;
                    unawaited(context.read<ThemeCubit>().switchTheme(current));
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: BaktazSpacing.md),
            child: Semantics(
              label: 'Notifications',
              child: Stack(
                children: <Widget>[
                  IconButton(
                    icon: BaktazIcon(
                      icon: const Right<String, IconData>(Icons.notifications_outlined),
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: BaktazSpacing.xs,
                    right: BaktazSpacing.xs,
                    child: Container(
                      width: _notificationDotSize,
                      height: _notificationDotSize,
                      decoration: BoxDecoration(color: context.colorScheme.error, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

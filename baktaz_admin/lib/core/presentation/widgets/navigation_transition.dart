import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/core/presentation/widgets/rail_transition.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class NavigationTransition extends StatelessWidget {
  const NavigationTransition({
    required this.railAnimation,
    required this.appBar,
    required this.body,
    required this.navigationRail,
    super.key,
  });

  final Animation<double> railAnimation;
  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget navigationRail;

  @override
  Widget build(BuildContext context) => ConnectivityChecker.scaffold(
    offlineMessage: context.i18n.common.error.no_internet_connection,
    appBar: appBar,

    body: Row(
      children: <Widget>[
        RailTransition(animation: railAnimation, backgroundColor: context.colorScheme.surface, child: navigationRail),
        Expanded(
          child: ColoredBox(
            color: context.colorScheme.surfaceContainerLow,
            child: Padding(padding: Paddings.allLarge, child: body),
          ),
        ),
      ],
    ),
  );
}

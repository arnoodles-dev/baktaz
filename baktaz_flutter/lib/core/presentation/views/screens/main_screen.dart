import 'dart:async';

import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_nav_bar.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends HookWidget {
  const MainScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onPopInvoked(BuildContext context, bool didPop, ValueNotifier<int> selectedIndex) {
    if (!didPop) {
      if (navigationShell.currentIndex != 0) {
        navigationShell.goBranch(0);
        selectedIndex.value = 0;
      } else {
        unawaited(DialogUtils.showExitDialog(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedIndex = useState<int>(0);

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AccountCubit>(lazy: false, create: (BuildContext context) => getIt<AccountCubit>()),
        BlocProvider<HomeCubit>(lazy: false, create: (BuildContext context) => getIt<HomeCubit>()),
      ],
      child: Builder(
        builder: (BuildContext context) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) => _onPopInvoked(context, didPop, selectedIndex),
          child: ConnectivityChecker.scaffold(
            offlineMessage: context.i18n.common.error.no_internet_connection,
            extendBody: true,
            body: SafeArea(maintainBottomViewPadding: true, child: navigationShell),
            bottomNavigationBar: BaktazNavBar(navigationShell: navigationShell, selectedIndex: selectedIndex),
          ),
        ),
      ),
    );
  }
}

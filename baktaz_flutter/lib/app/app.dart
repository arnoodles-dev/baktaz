import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_router.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_life_cycle/app_life_cycle_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  App({super.key});

  final List<BlocSignalProvider<BlocSignalBase<dynamic>>> _globalProviders =
      <BlocSignalProvider<BlocSignalBase<dynamic>>>[
        BlocSignalProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocSignalProvider<AppLifeCycleCubit>.value(value: getIt<AppLifeCycleCubit>()),
        BlocSignalProvider<HidableCubit>.value(value: getIt<HidableCubit>()),
        // Needs Initialization
        BlocSignalProvider<RemoteConfigCubit>.value(value: getIt<RemoteConfigCubit>()),
        BlocSignalProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocSignalProvider<AppCoreCubit>.value(value: getIt<AppCoreCubit>()),
        BlocSignalProvider<AppLocalizationCubit>.value(value: getIt<AppLocalizationCubit>()),
      ];

  final List<Breakpoint> _breakpoints = <Breakpoint>[
    const Breakpoint(start: 0, end: Constant.mobileBreakpoint, name: MOBILE),
    const Breakpoint(start: Constant.mobileBreakpoint + 1, end: Constant.tabletBreakpoint, name: TABLET),
    const Breakpoint(start: Constant.tabletBreakpoint + 1, end: double.infinity, name: DESKTOP),
  ];

  List<Condition<double>> _getResponsiveWidth(BuildContext context) => <Condition<double>>[
    const Condition<double>.equals(name: MOBILE, value: Constant.mobileBreakpoint),
    const Condition<double>.equals(name: TABLET, value: Constant.tabletBreakpoint),
    Condition<double>.equals(name: DESKTOP, value: context.screenWidth),
  ];

  @override
  Widget build(BuildContext context) {
    /// This will tell you which image is oversized by throwing an exception.
    debugInvertOversizedImages = kDebugMode;

    return MultiBlocSignalProvider(
      providers: _globalProviders,
      child: Builder(
        builder: (BuildContext context) => ToastificationWrapper(
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: <PointerDeviceKind>{
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
              },
            ),
            builder: (BuildContext context, Widget? child) => ResponsiveBreakpoints.builder(
              child: Builder(
                builder: (BuildContext context) => ResponsiveScaledBox(
                  width: ResponsiveValue<double>(
                    context,
                    defaultValue: Constant.mobileBreakpoint,
                    conditionalValues: _getResponsiveWidth(context),
                  ).value,
                  child: _LoadingOverlay(child: child!),
                ),
              ),
              breakpoints: _breakpoints,
            ),
            title: Constant.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: context.select<ThemeCubit, ThemeMode>((ThemeCubit cubit) => cubit.stateValue),
            themeAnimationCurve: Curves.fastOutSlowIn,
            themeAnimationDuration: const Duration(milliseconds: 500),
            locale: context.select<AppLocalizationCubit, Locale>(
              (AppLocalizationCubit cubit) => cubit.stateValue.$meta.locale.flutterLocale,
            ),
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: Constant.localizationDelegates,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LoaderOverlay(
    overlayWidgetBuilder: (_) => Center(
      child: Container(
        padding: Paddings.allXLarge,
        decoration: BoxDecoration(color: context.colorScheme.surface, borderRadius: AppTheme.defaultBorderRadius),
        child: Transform.scale(scale: 1.25, child: CircularProgressIndicator(color: context.colorScheme.primary)),
      ),
    ),
    overlayColor: context.colorScheme.scrim.withValues(alpha: 0.5),
    child: child,
  );
}

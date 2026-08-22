import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';

class MockMaterialApp extends StatelessWidget {
  const MockMaterialApp({required this.child, this.surfaceWidth = 400, this.surfaceHeight = 800, super.key});

  final Widget child;
  final double surfaceWidth;
  final double surfaceHeight;

  @override
  Widget build(BuildContext context) => BlocSignalProvider<AppLocalizationCubit>.value(
    value: getIt<AppLocalizationCubit>(),
    child: BlocSignalProvider<AppCoreCubit>.value(
      value: getIt<AppCoreCubit>(),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(surfaceWidth, surfaceHeight)),
          child: SizedBox(width: surfaceWidth, height: surfaceHeight, child: child),
        ),
        title: Constant.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: Constant.localizationDelegates,
        supportedLocales: AppLocaleUtils.supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

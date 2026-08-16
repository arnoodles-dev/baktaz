import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/app/generated/localization.g.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/app/themes/app_theme.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';

class MockMaterialApp extends StatelessWidget {
  const MockMaterialApp({required this.child, this.surfaceWidth = 1200, this.surfaceHeight = 800, super.key});

  final Widget child;
  final double surfaceWidth;
  final double surfaceHeight;

  @override
  Widget build(BuildContext context) => BlocSignalProvider<AppLocalizationCubit>.value(
    value: getIt<AppLocalizationCubit>(),
    child: MaterialApp(
      home: SizedBox(width: surfaceWidth, height: surfaceHeight, child: child),
      title: Constant.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: Constant.localizationDelegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      debugShowCheckedModeBanner: false,
    ),
  );
}

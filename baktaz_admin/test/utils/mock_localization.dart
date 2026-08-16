import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';

class MockLocalization extends StatelessWidget {
  const MockLocalization({required this.child, required this.appLocalizationCubit, super.key});

  final Widget child;
  final AppLocalizationCubit appLocalizationCubit;

  @override
  Widget build(BuildContext context) => BlocSignalProvider<AppLocalizationCubit>.value(
    value: appLocalizationCubit,
    child: Localizations(locale: const Locale('en'), delegates: Constant.localizationDelegates, child: child),
  );
}

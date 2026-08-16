import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_admin/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  void _initialize(BuildContext context) => WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (context.mounted) {
      await _initializeBlocs(context);
    }
  });

  Future<void> _initializeBlocs(BuildContext context) async {
    await Future.wait(<Future<void>>[
      context.read<AppCoreCubit>().initialize(),
      context.read<AuthCubit>().initialize(),
      context.read<ThemeCubit>().initialize(),
      context.read<AppLocalizationCubit>().initialize(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _initialize(context);
      return null;
    }, <Object?>[]);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Flexible(
                child: Center(
                  child: BaktazText(
                    text: Constant.appName,
                    textAlign: TextAlign.center,
                    style: context.textTheme.displayLarge,
                  ),
                ),
              ),
              const Flexible(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

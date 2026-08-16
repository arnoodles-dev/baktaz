import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kDebugMode, kProfileMode;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:safe_device/safe_device.dart';

const double _splashFontSize = 84;

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  void _initialize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await _isDeviceSafe() && context.mounted
          ? await _initializeBlocs(context)
          : await _showUnsupportedDeviceDialog(context),
    );
  }

  Future<void> _initializeBlocs(BuildContext context) async {
    final AppCoreCubit appCoreCubit = context.read<AppCoreCubit>();
    final RemoteConfigCubit remoteConfigCubit = context.read<RemoteConfigCubit>();
    await Future.wait(<Future<void>>[appCoreCubit.initialize(), remoteConfigCubit.initialize()]);
    if (context.mounted && !remoteConfigCubit.isForceUpdate && !remoteConfigCubit.isMaintenance) {
      await context.read<AuthCubit>().initialize(isOnboardingDone: appCoreCubit.stateValue.isOnboardingDone);
    }
  }

  Future<void> _showUnsupportedDeviceDialog(BuildContext context) async {
    await showFlash<void>(
      context: context,
      builder: (BuildContext context, FlashController<void> controller) => FlashBar<void>(
        controller: controller,
        dismissDirections: const <FlashDismissDirection>[],
        elevation: 3, // Default elevation for FlashBar
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: context.colorScheme.surfaceTint,
        indicatorColor: context.colorScheme.error,
        shouldIconPulse: false,
        icon: BaktazIcon(icon: fpdart.right(Icons.mobile_off), color: context.colorScheme.onSurface),
        content: Padding(
          padding: Paddings.horizontalMedium,
          child: BaktazText(
            text: context.i18n.common.error.unsupported_device,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  Future<bool> _isDeviceSafe() async {
    if (kDebugMode || kProfileMode) {
      return true;
    } else {
      final bool isDevice =
          defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
      if (isDevice) {
        final List<bool> results = await Future.wait(<Future<bool>>[SafeDevice.isRealDevice, SafeDevice.isJailBroken]);

        final bool isRealDevice = results.first;
        final bool isJailBroken = results[1];

        return !isJailBroken && isRealDevice;
      } else {
        return true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _initialize(context);

      return null;
    }, <Object?>[]);

    return Builder(
      builder: (BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Center(
                    child: BaktazText(
                      text: Constant.appName.toUpperCase().split('').join(' '),
                      textAlign: TextAlign.center,
                      style: context.textTheme.displayLarge?.copyWith(
                        color: AppColors.white,
                        fontSize: _splashFontSize,
                        fontWeight: AppFontWeight.black,
                      ),
                    ),
                  ),
                ),
                const Flexible(child: CircularProgressIndicator(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  void _onPopInvoked(BuildContext context, bool didPop) {
    if (!didPop) {
      DialogUtils.showExitDialog(context);
    }
  }

  void _onStateChangedListener(BuildContext context, LoginState state) {
    state.whenOrNull(
      idle: (bool isLoading) {
        isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();
      },
      success: (AuthSuccess authInfo) {
        context.loaderOverlay.hide();
        context.read<AuthCubit>().authenticate(authInfo);
      },
      failed: (_) => context.loaderOverlay.hide(),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, _) => _onPopInvoked(context, didPop),
    child: BlocSignalProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocSignalListener<LoginCubit, LoginState>(
          listener: _onStateChangedListener,
          child: ConnectivityChecker.scaffold(
            offlineMessage: context.i18n.common.error.no_internet_connection,
            appBar: AppBar(backgroundColor: AppColors.transparent, elevation: 0),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: Paddings.horizontalXLarge,
                        child: Column(
                          children: <Widget>[
                            // Top section
                            Gap.x2Large(),
                            BaktazText(
                              text: Constant.appName.toUpperCase(),
                              style: context.textTheme.displayLarge?.copyWith(
                                fontSize: AppSizes.size80,
                                color: context.colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(), // This will fill the available space
                            // Bottom section
                            Column(
                              children: <Widget>[
                                Gap.medium(),
                                BaktazButton(
                                  buttonType: ButtonType.outlined,
                                  isExpanded: true,
                                  icon: BaktazIcon(icon: left(Assets.icons.facebook.path), size: AppSizes.size26),
                                  text: context.i18n.login.button.facebook,
                                  onPressed: () => context.read<LoginCubit>().loginWithProvider(LoginProvider.facebook),
                                ),
                                Gap.medium(),
                                BaktazButton(
                                  buttonType: ButtonType.outlined,
                                  isExpanded: true,
                                  icon: BaktazIcon(icon: left(Assets.icons.google.path), size: AppSizes.size26),
                                  text: context.i18n.login.button.google,
                                  onPressed: () => context.read<LoginCubit>().loginWithProvider(LoginProvider.google),
                                ),
                                Gap.medium(),
                                const BaktazDivider(text: 'or'),
                                Gap.medium(),

                                BaktazButton(
                                  text: context.i18n.login.button.email,
                                  isExpanded: true,
                                  onPressed: () => const LoginMobileRoute().push<void>(context),
                                ),
                              ],
                            ),
                            Gap.large(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

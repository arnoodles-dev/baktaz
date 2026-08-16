import 'dart:async';

import 'package:baktaz_admin/app/constants/constant.dart';
import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/app/utils/dialog_utils.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  Future<void> _onPopInvoked(BuildContext context, bool didPop) async {
    if (!didPop) {
      await DialogUtils.showExitDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController passwordTextController = useTextEditingController();
    final TextEditingController emailTextController = useTextEditingController();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) => _onPopInvoked(context, didPop),
      child: BlocSignalProvider<LoginCubit>(
        create: (BuildContext context) {
          final LoginCubit cubit = getIt<LoginCubit>();
          unawaited(cubit.initialize());
          return cubit;
        },
        child: BlocSignalBuilder<LoginCubit, LoginState>(
          builder: (BuildContext context, LoginState state) {
            final String currentEmail = state.email ?? '';
            if (emailTextController.text != currentEmail) {
              emailTextController.value = TextEditingValue(
                text: currentEmail,
                selection: TextSelection.fromPosition(TextPosition(offset: currentEmail.length)),
              );
            }

            return ConnectivityChecker.scaffold(
              isUnfocusable: true,
              offlineMessage: context.i18n.common.error.no_internet_connection,
              body: Center(
                child: Container(
                  padding: Paddings.allXLarge,
                  constraints: const BoxConstraints(maxWidth: Constant.mobileBreakpoint),
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
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            BaktazTextField(
                              controller: emailTextController,
                              labelText: context.i18n.login.label.email,
                              hintText: context.i18n.login.hint.email,
                              textFieldType: TextFieldType.email,
                              onChanged: (String value) => context.read<LoginCubit>().onEmailChanged(value),
                              autofocus: true,
                            ),
                            Gap.large(),
                            BaktazTextField(
                              controller: passwordTextController,
                              labelText: context.i18n.login.label.password,
                              hintText: context.i18n.login.hint.password,
                              textFieldType: TextFieldType.password,
                            ),
                            Gap.x3Large(),
                            BaktazButton(
                              text: context.i18n.login.button.login,
                              isEnabled: !state.isLoading,
                              isLoading: state.isLoading,
                              isExpanded: true,
                              onPressed: () => context.read<LoginCubit>().login(
                                emailTextController.text,
                                passwordTextController.text,
                              ),
                              contentPadding: Paddings.verticalSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

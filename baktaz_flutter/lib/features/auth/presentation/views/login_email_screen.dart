import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/utils/validation_utils.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/entity/enum/login_provider.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoginEmailScreen extends HookWidget {
  const LoginEmailScreen({super.key});

  void _onStateChangedListener(BuildContext context, LoginState state) {
    state.whenOrNull(
      idle: (bool isLoading) {
        isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();
      },
      codeSent: (String email) {
        context.loaderOverlay.hide();
        OtpRoute(email: email).push<void>(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController();
    final FocusNode focusNode = useFocusNode();
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocSignalProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocSignalListener<LoginCubit, LoginState>(
          listener: _onStateChangedListener,
          child: UnfocusableScaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: BaktazAppBar(
              title: '',
              leading: BackButton(color: context.colorScheme.onSecondaryContainer),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: Paddings.allLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BaktazText(
                        text: context.i18n.login.welcome,
                        style: context.textTheme.displayMedium?.copyWith(color: context.colorScheme.primary),
                      ),
                      Gap.medium(),
                      BaktazText(text: context.i18n.login.email_subtitle, style: context.textTheme.bodyLarge),
                      Gap.xLarge(),
                      BaktazTextField(
                        focusNode: focusNode,
                        controller: controller,
                        hintText: context.i18n.register.hint.email,
                        keyboardType: TextInputType.emailAddress,
                        textFieldType: TextFieldType.form,
                        validator: ValidationUtils.emailValidator,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomSheet: BaktazBottomSheet(
              decoration: BoxDecoration(color: context.colorScheme.surface),
              children: <Widget>[
                BaktazButton(
                  isExpanded: true,
                  text: context.i18n.common.next.capitalize(),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<LoginCubit>().loginWithProvider(LoginProvider.email, email: controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/app/utils/error_message_utils.dart';
import 'package:baktaz_flutter/app/utils/validation_utils.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_flutter/core/presentation/widgets/dialogs/country_selector_bottom_sheet.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class LoginMobileScreen extends HookWidget {
  const LoginMobileScreen({super.key});

  void _onStateChangedListener(
    BuildContext context,
    LoginState state,
    PhoneCountryData countryCode,
    String mobileNumber,
  ) {
    state.whenOrNull(
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        DialogUtils.showError(ErrorMessageUtils.generate(context, failure));
      },
      success: (AuthSuccess? authInfo) {
        context.loaderOverlay.hide();
        if (authInfo != null) {
          // TODO: Navigate to dashboard
        } else {
          // Navigate to register screen
          RegistrationRoute(mobileNumber: mobileNumber, $extra: countryCode).push<void>(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController();
    final FocusNode focusNode = useFocusNode();
    final ValueNotifier<PhoneCountryData> selectedCountryCode = useState<PhoneCountryData>(
      CountrySelectorBottomSheet.defaultCountry,
    );
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocListener<LoginCubit, LoginState>(
          listener: (BuildContext context, LoginState state) =>
              _onStateChangedListener(context, state, selectedCountryCode.value, controller.value.text),
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
                      BaktazMobileNumberField(
                        focusNode: focusNode,
                        controller: controller,
                        selectedCountryCode: selectedCountryCode,
                        onSelectCountry: DialogUtils.showCountrySelectorBottomSheet,
                        validator: ValidationUtils.mobileNumberValidator,
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
                      context.read<LoginCubit>().loginWithMobile(
                        selectedCountryCode.value.phoneCodeToString(),
                        controller.text,
                      );
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

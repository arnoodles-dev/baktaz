import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/app/utils/error_message_utils.dart';
import 'package:baktaz_flutter/app/utils/validation_utils.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/core/presentation/views/widgets/gender_selector.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart' hide Gender;
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class RegistrationScreen extends HookWidget {
  const RegistrationScreen({required this.email, required this.registrationToken, super.key});

  final String email;
  final String registrationToken;

  void _onStateChangedListener(BuildContext context, LoginState state) {
    state.whenOrNull(
      idle: (bool isLoading) {
        isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();
      },
      registrationCompleted: (AuthSuccess authInfo) {
        context.loaderOverlay.hide();
        context.read<AuthCubit>().authenticate(authInfo);
      },
      success: (AuthSuccess authInfo) {
        context.loaderOverlay.hide();
        context.read<AuthCubit>().authenticate(authInfo);
      },
      failed: (Failure failure) {
        context.loaderOverlay.hide();
        DialogUtils.showError(ErrorMessageUtils.generate(context, failure));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final TextEditingController emailController = useTextEditingController(text: email);
    final TextEditingController nameController = useTextEditingController();
    final TextEditingController birthdayController = useTextEditingController();
    final ValueNotifier<Gender?> selectedGender = useState<Gender?>(null);
    final ValueNotifier<DateTime?> selectedBirthday = useState<DateTime?>(null);

    final Map<String, dynamic> remoteConfig = context.read<RemoteConfigCubit>().stateValue;

    Future<void> selectBirthday() async {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedBirthday.value ?? DateTime(now.year - 18, now.month, now.day),
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (picked != null) {
        selectedBirthday.value = picked;
        birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }

    return BlocSignalProvider<LoginCubit>(
      create: (BuildContext context) => getIt<LoginCubit>(),
      child: Builder(
        builder: (BuildContext context) => BlocSignalListener<LoginCubit, LoginState>(
          listener: _onStateChangedListener,
          child: UnfocusableScaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: BaktazAppBar(title: context.i18n.register.title, centerTitle: true, leading: const BackButton()),
            body: Padding(
              padding: Paddings.allLarge,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BaktazText(text: context.i18n.register.label.email_address, style: context.textTheme.bodyLarge),
                      Gap.xSmall(),
                      BaktazTextField(
                        controller: emailController,
                        readOnly: true,
                        isDisabled: true,
                        textFieldType: TextFieldType.form,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Gap.large(),
                      BaktazText(text: context.i18n.register.label.name, style: context.textTheme.bodyLarge),
                      Gap.xSmall(),
                      BaktazTextField(
                        controller: nameController,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        textFieldType: TextFieldType.form,
                        hintText: context.i18n.register.hint.name,
                        hintTextStyle: context.textTheme.bodyLarge,
                        validator: ValidationUtils.nameValidator,
                      ),
                      Gap.large(),
                      BaktazText(text: context.i18n.register.label.gender, style: context.textTheme.bodyLarge),
                      Gap.xSmall(),
                      GenderSelector(
                        value: selectedGender.value,
                        onChanged: (Gender? val) => selectedGender.value = val,
                        validator: (Gender? val) => val == null ? context.i18n.register.hint.gender : null,
                      ),
                      Gap.large(),
                      BaktazText(text: context.i18n.register.label.birthday, style: context.textTheme.bodyLarge),
                      Gap.xSmall(),
                      GestureDetector(
                        onTap: selectBirthday,
                        child: AbsorbPointer(
                          child: BaktazTextField(
                            controller: birthdayController,
                            readOnly: true,
                            hintText: context.i18n.register.hint.birthday,
                            hintTextStyle: context.textTheme.bodyLarge,
                            textFieldType: TextFieldType.form,
                            suffix: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      Gap.xLarge(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: BaktazText(
                          text: context.i18n.register.label.disclaimer(
                            terms: remoteConfig['terms_condition_url'].toString(),
                            privacy: remoteConfig['privacy_policy_url'].toString(),
                          ),
                          textType: TextType.styled,
                          style: context.textTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Gap.large(),
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
                  text: context.i18n.register.submit,
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (formKey.currentState!.validate() && selectedGender.value != null) {
                      context.read<LoginCubit>().completeRegistration(
                        email: email,
                        name: nameController.text.trim(),
                        gender: selectedGender.value!.name,
                        birthday: selectedBirthday.value,
                        registrationToken: registrationToken,
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

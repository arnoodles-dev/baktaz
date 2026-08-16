import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/utils/validation_utils.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/core/domain/entity/enum/select_address_entry.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';

class RegistrationScreen extends HookWidget {
  const RegistrationScreen({required this.countryCode, required this.mobileNumber, super.key});

  final PhoneCountryData countryCode;
  final String mobileNumber;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = useMemoized(GlobalKey<FormState>.new);
    final TextEditingController nameController = useTextEditingController();
    final TextEditingController emailController = useTextEditingController();

    final Map<String, dynamic> remoteConfig = context.read<RemoteConfigCubit>().stateValue;

    return UnfocusableScaffold(
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
                BaktazText(text: context.i18n.register.label.mobile_number, style: context.textTheme.bodyLarge),
                Gap.xSmall(),
                BaktazMobileNumberField(
                  controller: useTextEditingController(text: mobileNumber),
                  focusNode: useFocusNode(),
                  selectedCountryCode: ValueNotifier<PhoneCountryData>(countryCode),
                  isDisabled: true,
                  validator: ValidationUtils.mobileNumberValidator,
                  // onSelectCountry is null because the picker is disabled anyway
                ),
                Gap.large(),
                BaktazText(text: context.i18n.register.label.email_address, style: context.textTheme.bodyLarge),
                Gap.xSmall(),
                BaktazTextField(
                  controller: emailController,
                  hintText: context.i18n.register.hint.email,
                  hintTextStyle: context.textTheme.bodyLarge,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  textFieldType: TextFieldType.form,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationUtils.emailValidator,
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
              if (formKey.currentState!.validate()) {
                const SelectAddressRoute($extra: SelectAddressEntry.registration).push<void>(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

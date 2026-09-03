import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/utils/dialog_utils.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/profile/profile_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_container.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_content.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_tile.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/dialogs/delete_account_confirmation_dialog.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/dialogs/logout_confirmation_dialog.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  bool isLoading(QueryStatus queryStatus, Either<Profile?, (String?, String?)> object) {
    final bool isObjectNull = object.fold(
      (Profile? profile) => profile == null,
      ((String?, String?) value) => value.$1 == null || value.$2 == null,
    );

    return switch (queryStatus) {
          QueryStatus.loading => true,
          _ => false,
        } &&
        isObjectNull;
  }

  void _showLogoutDialog(BuildContext context) => DialogUtils.showBottomSheet(
    context,
    child: LogoutConfirmationDialog(onLogout: () => context.read<AuthCubit>().terminateSession()),
  );

  void _showDeleteAccountDialog(BuildContext context) => DialogUtils.showBottomSheet(
    context,
    child: DeleteAccountConfirmationDialog(
      onConfirm: () async {
        Navigator.pop(context);
        await context.read<ProfileCubit>().deleteAccount();
        if (context.mounted) {
          await context.read<AuthCubit>().terminateSession();
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) => BlocSignalProvider<ProfileCubit>(
    create: (BuildContext context) => getIt<ProfileCubit>()..initialize(),
    child: Builder(
      builder: (BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: BlocSignalBuilder<ProfileCubit, ProfileState>(
            builder: (BuildContext context, ProfileState state) => Column(
              children: <Widget>[
                BaktazAppBar(
                  title: context.i18n.account.profile_title,
                  titleStyle: context.textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.medium),
                  centerTitle: true,
                  leading: const BackButton(),
                ),
                Gap.custom(AppSizes.size80),
                AccountDetailsContainer(
                  isLoading: isLoading(state.queryStatus, left(state.profile)),
                  child: Stack(
                    key: const Key('profile_stack'),
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.x3Large),
                        child: AccountDetailsContent(
                          title: context.i18n.account.personal_information,
                          onEdit: () {
                            //TODO: add onEdit function
                          },
                          children: <Widget>[
                            AccountDetailsTile(label: context.i18n.account.name, value: state.profile?.fullName.getValue()),
                            Gap.medium(),
                            AccountDetailsTile(label: context.i18n.account.gender, value: state.profile?.gender.toString().capitalize()),
                            Gap.medium(),
                            AccountDetailsTile(
                              label: context.i18n.account.date_of_birth,
                              value: state.profile?.birthday?.value.formatMonthDayYear(),
                            ),
                            Gap.medium(),
                            AccountDetailsTile(label: context.i18n.account.age, value: state.profile?.birthday?.value.age),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -AppSizes.size80,
                        child: BaktazAvatar(
                          size: AppSizes.size128,
                          imageUrl: state.profile?.imageUrl?.getValue(),
                          isLoading: isLoading(state.queryStatus, left(state.profile)),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.medium(),
                AccountDetailsContainer(
                  isLoading: isLoading(state.queryStatus, left(state.profile)),
                  child: AccountDetailsContent(
                    title: context.i18n.account.contact_information,
                    children: <Widget>[
                      AccountDetailsTile(
                        label: context.i18n.account.mobile_number,
                        value: state.profile?.mobileNumber?.getValue(),
                        onValueEmptyText: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Gap.small(),
                            GestureDetector(
                              onTap: () {
                                //TODO: add on mobile number pressed
                              },
                              child: BaktazText(
                                text: context.i18n.account.add_mobile_number,
                                style: context.textTheme.bodyLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
                              ),
                            ),
                            Gap.x2Small(),
                            BaktazText(
                              text: context.i18n.account.add_mobile_number_desc,
                              style: context.textTheme.bodySmall,
                            ),
                            Gap.small(),
                          ],
                        ),
                      ),
                      const BaktazDivider(padding: Paddings.verticalMedium),
                      AccountDetailsTile(
                        label: context.i18n.account.email_address,
                        value: state.profile?.email?.getValue(),
                        onValueEmptyText: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Gap.small(),
                            GestureDetector(
                              onTap: () {
                                //TODO: add on email pressed
                              },
                              child: BaktazText(
                                text: context.i18n.account.add_email,
                                style: context.textTheme.bodyLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
                              ),
                            ),
                            Gap.x2Small(),
                            BaktazText(
                              text: context.i18n.account.add_email_desc,
                              style: context.textTheme.bodySmall,
                            ),
                            Gap.small(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.medium(),
                AccountDetailsContainer(
                  child: AccountDetailsContent(
                    title: context.i18n.account.account_settings,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _showDeleteAccountDialog(context),
                        child: BaktazText(
                          text: context.i18n.account.request_account_deletion,
                          style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.error),
                        ),
                      ),
                      const BaktazDivider(padding: Paddings.verticalMedium),
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: BaktazText(
                          text: context.i18n.account.button.logout,
                          style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.medium(),
                Skeletonizer(
                  enabled: isLoading(state.queryStatus, right((state.appVersion, state.buildNumber))),
                  child: BaktazText(
                    text: context.i18n.account.version(version: '${state.appVersion}+${state.buildNumber}'),
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ),
                Gap.large(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

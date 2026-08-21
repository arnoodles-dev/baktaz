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
                  title: 'Profile',
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
                          title: 'Personal Information',
                          onEdit: () {
                            //TODO: add onEdit function
                          },
                          children: <Widget>[
                            AccountDetailsTile(label: 'Name', value: state.profile?.fullName.getValue()),
                            Gap.medium(),
                            AccountDetailsTile(label: 'Gender', value: state.profile?.gender.toString().capitalize()),
                            Gap.medium(),
                            AccountDetailsTile(
                              label: 'Date of Birth',
                              value: state.profile?.birthday?.value.formatMonthDayYear(),
                            ),
                            Gap.medium(),
                            AccountDetailsTile(label: 'Age', value: state.profile?.birthday?.value.age),
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
                    title: 'Contact Information',
                    children: <Widget>[
                      AccountDetailsTile(
                        label: 'Mobile Number',
                        value: state.profile?.mobileNumber?.getValue(),
                        onValueEmptyText: _AddContactInformation(
                          title: 'Add a mobile number',
                          subtitle: 'Share your mobile number to get updates straight to your inbox',
                          onPressed: () {
                            //TODO: add on mobile number pressed
                          },
                        ),
                      ),
                      const BaktazDivider(padding: Paddings.verticalMedium),
                      AccountDetailsTile(
                        label: 'Email Address',
                        value: state.profile?.email?.getValue(),
                        onValueEmptyText: _AddContactInformation(
                          title: 'Add an e-mail address',
                          subtitle: 'Share your email to get updates straight to your inbox',
                          onPressed: () {
                            //TODO: add on email pressed
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.medium(),
                AccountDetailsContainer(
                  child: AccountDetailsContent(
                    title: 'Account Settings',
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _showDeleteAccountDialog(context),
                        child: BaktazText(
                          text: 'Request for Account Deletion',
                          style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.error),
                        ),
                      ),
                      const BaktazDivider(padding: Paddings.verticalMedium),
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: BaktazText(
                          text: 'Logout',
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
                    text: 'Version ${state.appVersion}+${state.buildNumber}',
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

class _AddContactInformation extends StatelessWidget {
  const _AddContactInformation({required this.title, required this.subtitle, required this.onPressed});

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Gap.small(),
      GestureDetector(
        onTap: onPressed,
        child: BaktazText(
          text: title,
          style: context.textTheme.bodyLarge?.copyWith(fontWeight: AppFontWeight.semiBold),
        ),
      ),
      Gap.x2Small(),
      BaktazText(text: subtitle, style: context.textTheme.bodySmall),
      Gap.small(),
    ],
  );
}

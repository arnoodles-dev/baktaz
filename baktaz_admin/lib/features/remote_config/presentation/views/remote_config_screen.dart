import 'dart:async';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/remote_config/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/config_info_section.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/dialogs/add_parameter_dialog.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/dialogs/edit_parameter_dialog.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/parameter_table.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/pending_changes_banner.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class RemoteConfigScreen extends HookWidget {
  const RemoteConfigScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocSignalProvider<RemoteConfigCubit>(
    create: (_) {
      final RemoteConfigCubit cubit = getIt<RemoteConfigCubit>();
      unawaited(cubit.loadConfig());
      return cubit;
    },
    child: BlocSignalListener<RemoteConfigCubit, RemoteConfigState>(
      listenWhen: (RemoteConfigState previous, RemoteConfigState current) =>
          previous.pendingChanges.isNotEmpty && current.pendingChanges.isEmpty,
      listener: (BuildContext context, RemoteConfigState state) {
        toastification.show(
          context: context,
          title: BaktazText(text: context.i18n.remote_config.published_success),
          autoCloseDuration: const Duration(seconds: 4),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          alignment: Alignment.topCenter,
        );
      },
      child: const LoaderOverlay(child: _RemoteConfigView()),
    ),
  );
}

class _RemoteConfigView extends StatelessWidget {
  const _RemoteConfigView();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.colorBackground,
    body: BlocSignalBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (BuildContext context, RemoteConfigState state) {
        final QueryStatus status = state.status;
        if (status.isLoading || status is QueryInitial) {
          return const _RemoteConfigShimmer();
        }

        final Map<String, RemoteConfigValue> pendingChanges = state.pendingChanges;
        final ConfigSnapshotVersion? version = state.remoteConfig?.version;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSizes.medium, AppSizes.medium, AppSizes.medium, AppSizes.xLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (pendingChanges.isNotEmpty)
                PendingChangesBanner(
                  changeCount: pendingChanges.length,
                  onPublish: () => context.read<RemoteConfigCubit>().publishChanges(),
                  onDiscard: () => context.read<RemoteConfigCubit>().discardChanges(),
                ),
              _PageHeader(version: version),
              const Gap(AppSizes.xLarge),
              ParameterTable(
                onEdit: (String key, RemoteConfigValue currentValue, String resolvedDescription) {
                  unawaited(
                    showDialog<void>(
                      context: context,
                      builder: (_) => EditParameterDialog(
                        parameterKey: key,
                        currentValue: currentValue,
                        initialDescription: resolvedDescription,
                        onSave: (String pKey, RemoteConfigValue pValue) {
                          context.read<RemoteConfigCubit>().updateParameter(pKey, pValue);
                        },
                      ),
                    ),
                  );
                },
              ),
              if (version != null) ...<Widget>[const Gap(AppSizes.xLarge), ConfigInfoSection(version: version)],
            ],
          ),
        );
      },
    ),
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.version});

  final ConfigSnapshotVersion? version;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                BaktazText(
                  text: context.i18n.remote_config.title,
                  style: AppTextStyle.displayMedium.copyWith(color: AppColors.colorTextPrimary),
                ),
                if (version != null) ...<Widget>[
                  const Gap(AppSizes.small),
                  _VersionBadge(versionNumber: version?.versionNumber.getValue() ?? '0'),
                ],
              ],
            ),
            const Gap(AppSizes.xSmall),
            BaktazText(
              text: context.i18n.remote_config.description,
              style: AppTextStyle.bodyMedium.copyWith(color: AppColors.colorTextSecondary),
            ),
          ],
        ),
      ),
      const Gap(AppSizes.medium),
      BaktazButton(
        onPressed: () {
          unawaited(
            showDialog<void>(
              context: context,
              builder: (_) => AddParameterDialog(
                onSave: (String key, RemoteConfigValue value) {
                  context.read<RemoteConfigCubit>().updateParameter(key, value);
                },
              ),
            ),
          );
        },
        icon: BaktazIcon(
          icon: Either<String, IconData>.right(Icons.add),
          size: AppSizes.iconSmall,
          color: AppColors.white,
        ),
        text: context.i18n.remote_config.add_parameter,
        textStyle: AppTextStyle.labelLarge.copyWith(color: AppColors.white),
        buttonType: ButtonType.elevated,
        buttonStyle: ElevatedButton.styleFrom(
          backgroundColor: AppColors.colorPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
        ),
      ),
    ],
  );
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.versionNumber});

  final String versionNumber;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x2Small),
    decoration: const BoxDecoration(
      color: AppColors.colorPrimarySubtle,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
    ),
    child: BaktazText(
      text: 'v$versionNumber',
      style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorPrimaryDark),
    ),
  );
}

class _RemoteConfigShimmer extends StatelessWidget {
  const _RemoteConfigShimmer();

  @override
  Widget build(BuildContext context) => Shimmer(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSizes.medium, AppSizes.medium, AppSizes.medium, AppSizes.xLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BaktazText(
                      text: context.i18n.remote_config.title,
                      style: AppTextStyle.displayMedium.copyWith(fontWeight: AppFontWeight.bold),
                    ),
                    const Gap(AppSizes.xSmall),
                    BaktazText(text: context.i18n.remote_config.description, style: AppTextStyle.bodyMedium),
                  ],
                ),
              ),
              const Gap(AppSizes.medium),
              BaktazButton(
                onPressed: () {},
                text: context.i18n.remote_config.add_parameter,
                buttonType: ButtonType.elevated,
              ),
            ],
          ),
          const Gap(AppSizes.xLarge),
          // ponytail: skeleton placeholders, not user-facing - raw primitives acceptable
          Container(
            decoration: const BoxDecoration(
              color: AppColors.colorSurface,
              borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
              border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.large, AppSizes.medium, AppSizes.large, AppSizes.small),
                  child: Row(
                    children: <Widget>[
                      BaktazText(
                        text: context.i18n.remote_config.global_parameters,
                        style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.semiBold),
                      ),
                      const Spacer(),
                      BaktazIcon(icon: right(Icons.filter_list), size: 20),
                      const Gap(AppSizes.xSmall),
                      BaktazIcon(icon: right(Icons.arrow_upward), size: 20),
                      const Gap(AppSizes.xSmall),
                      BaktazIcon(icon: right(Icons.download_outlined), size: 20),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.parameter_key,
                          style: AppTextStyle.labelMedium.copyWith(fontWeight: AppFontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.value,
                          style: AppTextStyle.labelMedium.copyWith(fontWeight: AppFontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.type,
                          style: AppTextStyle.labelMedium.copyWith(fontWeight: AppFontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.last_modified,
                          style: AppTextStyle.labelMedium.copyWith(fontWeight: AppFontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: BaktazText(
                          text: 'ACTIONS',
                          textAlign: TextAlign.right,
                          style: AppTextStyle.labelSmall.copyWith(fontWeight: AppFontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...List<Widget>.generate(
                  5,
                  (int index) => Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: 14),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 150,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                  const Gap(AppSizes.x2Small),
                                  Container(
                                    width: double.infinity,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 80,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 60,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXLarge)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: 80,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: BaktazIcon(icon: right(Icons.edit_outlined), size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
                  child: Row(
                    children: <Widget>[
                      BaktazText(text: context.i18n.remote_config.pagination.showing_summary),
                      const Spacer(),
                      BaktazIcon(icon: right(Icons.chevron_left)),
                      const Gap(AppSizes.xSmall),
                      BaktazText(text: 1.toString()),
                      const Gap(AppSizes.xSmall),
                      BaktazText(text: 2.toString()),
                      const Gap(AppSizes.xSmall),
                      BaktazIcon(icon: right(Icons.chevron_right)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSizes.xLarge),
          // ponytail: skeleton cards, not user-facing
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: Paddings.allLarge,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
                    border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          BaktazIcon(icon: right(Icons.history)),
                          const Gap(AppSizes.small),
                          BaktazText(
                            text: context.i18n.remote_config.history.title,
                            style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.bold),
                          ),
                        ],
                      ),
                      const Gap(AppSizes.medium),
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.colorTextSecondary,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      const Gap(AppSizes.medium),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.colorTextSecondary,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(AppSizes.medium),
              Expanded(
                child: Container(
                  padding: Paddings.allLarge,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
                    border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          BaktazIcon(icon: right(Icons.manage_history_outlined)),
                          const Gap(AppSizes.small),
                          BaktazText(
                            text: context.i18n.remote_config.version.title,
                            style: AppTextStyle.titleMedium.copyWith(fontWeight: AppFontWeight.bold),
                          ),
                        ],
                      ),
                      const Gap(AppSizes.medium),
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.colorTextSecondary,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      const Gap(AppSizes.medium),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.colorTextSecondary,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

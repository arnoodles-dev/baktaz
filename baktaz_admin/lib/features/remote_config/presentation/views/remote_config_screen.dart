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
    backgroundColor: context.colorScheme.surface,
    body: BlocSignalBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (BuildContext context, RemoteConfigState state) {
        final QueryStatus status = state.status;
        if (status.isLoading || status is QueryInitial) {
          return const _RemoteConfigShimmer();
        }

        final Map<String, RemoteConfigValue> pendingChanges = state.pendingChanges;
        final ConfigSnapshotVersion? version = state.remoteConfig?.version;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.xl),
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
              const Gap(BaktazSpacing.xl),
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
              if (version != null) ...<Widget>[const Gap(BaktazSpacing.xl), ConfigInfoSection(version: version)],
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: context.colorScheme.onSurface),
                ),
                if (version != null) ...<Widget>[
                  const Gap(BaktazSpacing.sm),
                  _VersionBadge(versionNumber: version?.versionNumber.getValue() ?? '0'),
                ],
              ],
            ),
            const Gap(BaktazSpacing.xs),
            BaktazText(
              text: context.i18n.remote_config.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      const Gap(BaktazSpacing.md),
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
          size: BaktazSpacing.iconSmall,
          color: Colors.white,
        ),
        text: context.i18n.remote_config.add_parameter,
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
        buttonType: ButtonType.elevated,
        buttonStyle: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BaktazRadius.pill),
          padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
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
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
    decoration: BoxDecoration(
      color: context.colorScheme.primaryContainer,
      borderRadius: BaktazRadius.pill,
    ),
    child: BaktazText(
      text: 'v$versionNumber',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.colorScheme.primaryContainer),
    ),
  );
}

class _RemoteConfigShimmer extends StatelessWidget {
  const _RemoteConfigShimmer();

  // ponytail: skeleton-only dimensions — not user-facing
  static const double _shimmerTitleWidth = 150;
  static const double _shimmerChipWidth = 120;
  static const double _shimmerBarHeight = 14;

  @override
  Widget build(BuildContext context) => Shimmer(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.md, BaktazSpacing.xl),
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
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(BaktazSpacing.xs),
                    BaktazText(text: context.i18n.remote_config.description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Gap(BaktazSpacing.md),
              BaktazButton(
                onPressed: () {},
                text: context.i18n.remote_config.add_parameter,
                buttonType: ButtonType.elevated,
              ),
            ],
          ),
          const Gap(BaktazSpacing.xl),
          // ponytail: skeleton placeholders, not user-facing - raw primitives acceptable
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
              border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(BaktazSpacing.lg, BaktazSpacing.md, BaktazSpacing.lg, BaktazSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      BaktazText(
                        text: context.i18n.remote_config.global_parameters,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      BaktazIcon(icon: right(Icons.filter_list), size: 20),
                      const Gap(BaktazSpacing.xs),
                      BaktazIcon(icon: right(Icons.arrow_upward), size: 20),
                      const Gap(BaktazSpacing.xs),
                      BaktazIcon(icon: right(Icons.download_outlined), size: 20),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.parameter_key,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.value,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.type,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: BaktazText(
                          text: context.i18n.remote_config.table.last_modified,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: BaktazText(
                          text: 'ACTIONS',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
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
                        padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: 14),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: _shimmerTitleWidth,
                                    height: BaktazSpacing.md,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                    ),
                                  ),
                                  const Gap(BaktazSpacing.xs2),
                                  Container(
                                    width: double.infinity,
                                    height: BaktazSpacing.sm,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
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
                                    color: Colors.white,
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.xl)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: 80,
                                height: _shimmerBarHeight,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
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
                  padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      BaktazText(text: context.i18n.remote_config.pagination.showing_summary),
                      const Spacer(),
                      BaktazIcon(icon: right(Icons.chevron_left)),
                      const Gap(BaktazSpacing.xs),
                      BaktazText(text: 1.toString()),
                      const Gap(BaktazSpacing.xs),
                      BaktazText(text: 2.toString()),
                      const Gap(BaktazSpacing.xs),
                      BaktazIcon(icon: right(Icons.chevron_right)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(BaktazSpacing.xl),
          // ponytail: skeleton cards, not user-facing
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: Paddings.allLarge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
                    border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          BaktazIcon(icon: right(Icons.history)),
                          const Gap(BaktazSpacing.sm),
                          BaktazText(
                            text: context.i18n.remote_config.history.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Gap(BaktazSpacing.md),
                      Container(
                        width: double.infinity,
                        height: _shimmerBarHeight,
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSurfaceVariant,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      const Gap(BaktazSpacing.md),
                      Container(
                        width: _shimmerChipWidth,
                        height: _shimmerBarHeight,
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSurfaceVariant,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(BaktazSpacing.md),
              Expanded(
                child: Container(
                  padding: Paddings.allLarge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
                    border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          BaktazIcon(icon: right(Icons.manage_history_outlined)),
                          const Gap(BaktazSpacing.sm),
                          BaktazText(
                            text: context.i18n.remote_config.version.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Gap(BaktazSpacing.md),
                      Container(
                        width: double.infinity,
                        height: _shimmerBarHeight,
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSurfaceVariant,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      const Gap(BaktazSpacing.md),
                      Container(
                        width: _shimmerChipWidth,
                        height: _shimmerBarHeight,
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSurfaceVariant,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
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

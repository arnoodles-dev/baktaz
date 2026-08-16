import 'dart:async';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/dialogs/add_translation_dialog.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/dialogs/edit_translation_dialog.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_info_section.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_pending_changes_banner.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_widget.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LocalizationScreen extends StatelessWidget {
  const LocalizationScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocSignalProvider<LocalizationCubit>(
    create: (BuildContext context) => getIt<LocalizationCubit>()..initialize().ignore(),
    child: const LoaderOverlay(child: _LocalizationScreenView()),
  );
}

class _LocalizationScreenView extends StatelessWidget {
  const _LocalizationScreenView();

  @override
  Widget build(BuildContext context) => BlocSignalConsumer<LocalizationCubit, LocalizationState>(
    listenWhen: (LocalizationState previous, LocalizationState current) =>
        previous.status != current.status ||
        previous.currentPage != current.currentPage ||
        previous.sortCriteria != current.sortCriteria,
    listener: (BuildContext context, LocalizationState state) {
      if (state.status.isLoading && state.keys.isNotEmpty) {
        context.loaderOverlay.show();
      } else {
        context.loaderOverlay.hide();
      }
      context.read<LocalizationCubit>().clearExpanded();
    },
    builder: (BuildContext context, LocalizationState state) {
      final int pendingCount = state.pendingChanges.length;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.medium, AppSizes.medium, AppSizes.medium, AppSizes.xLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (pendingCount > 0) ...<Widget>[
              LocalizationPendingChangesBanner(
                changeCount: pendingCount,
                onPublish: () => context.read<LocalizationCubit>().publishChanges(),
                onDiscard: () => context.read<LocalizationCubit>().discardChanges(),
              ),
              Gap.x2Large(),
            ],
            _PageHeader(
              onAddPressed: () {
                unawaited(_showAddDialog(context));
              },
            ),
            Gap.x2Large(),
            LocalizationTableWidget(
              onEdit: (LocalizationKey key, String? currentValue) {
                unawaited(_showEditDialog(context, key, currentValue));
              },
            ),
            Gap.x2Large(),
            const LocalizationInfoSection(),
          ],
        ),
      );
    },
  );

  Future<void> _showAddDialog(BuildContext context) async {
    final LocalizationCubit cubit = context.read<LocalizationCubit>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AddTranslationDialog(
        existingKeys: cubit.stateValue.keys.map((LocalizationKey k) => '${k.namespace}.${k.key}').toSet(),
        onSave: (String key, String namespace, String valueEn) {
          cubit.addKey(key: key, namespace: namespace, defaultValueEn: valueEn);
        },
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, LocalizationKey locKey, String? currentValue) async {
    final LocalizationCubit cubit = context.read<LocalizationCubit>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => EditTranslationDialog(
        localizationKey: locKey,
        currentTranslation: currentValue,
        locale: cubit.stateValue.selectedLocale,
        onSave: (String val) {
          cubit.updateTranslation(
            LocalizationTranslation(keyId: locKey.id, locale: cubit.stateValue.selectedLocale, value: val),
          );
        },
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(
            text: context.i18n.localization.title,
            style: AppTextStyle.headlineLarge.copyWith(fontWeight: AppFontWeight.bold),
          ),
          const Gap(AppSizes.x2Small),
          BaktazText(
            text: context.i18n.localization.description,
            style: AppTextStyle.bodyLarge.copyWith(color: AppColors.colorTextSecondary),
          ),
        ],
      ),
      BaktazButton(text: context.i18n.localization.add_key, icon: const Icon(Icons.add), onPressed: onAddPressed),
    ],
  );
}

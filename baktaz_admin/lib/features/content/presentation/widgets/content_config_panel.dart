import 'dart:convert';

import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_status.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';

class ContentConfigPanel extends HookWidget {
  const ContentConfigPanel({required this.asset, required this.onSave, required this.onCancel, super.key});

  final ContentAsset? asset;
  final ValueChanged<ContentAsset> onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = useTextEditingController(
      text: asset?.title.value.fold((_) => '', identity) ?? '',
    );
    final TextEditingController routeUrlController = useTextEditingController(
      text: asset?.routeUrl?.value.fold((_) => '', identity) ?? '',
    );
    final TextEditingController imageUrlController = useTextEditingController(
      text: asset?.imageUrl?.value.fold((_) => '', identity) ?? '',
    );
    final TextEditingController metadataController = useTextEditingController(
      text: asset?.metadataJson?.value.fold((_) => '', jsonEncode) ?? '',
    );
    final TextEditingController orderIndexController = useTextEditingController(
      text: asset?.orderIndex.value.fold((_) => '0', (num v) => '$v') ?? '1',
    );
    final ValueNotifier<ContentAssetType> selectedType = useState<ContentAssetType>(
      asset?.type ?? ContentAssetType.banner,
    );
    final ValueNotifier<ContentPlacementGroup> selectedPlacement = useState<ContentPlacementGroup>(
      asset?.placementGroup ?? ContentPlacementGroup.home,
    );
    final ValueNotifier<bool> isActive = useState<bool>(asset?.status == ContentStatus.active);
    final ValueNotifier<bool> hasSchedule = useState<bool>(asset?.status == ContentStatus.scheduled);

    useEffect(() {
      titleController.text = asset?.title.value.fold((_) => '', identity) ?? '';
      routeUrlController.text = asset?.routeUrl?.value.fold((_) => '', identity) ?? '';
      imageUrlController.text = asset?.imageUrl?.value.fold((_) => '', identity) ?? '';
      metadataController.text = asset?.metadataJson?.value.fold((_) => '', jsonEncode) ?? '';
      orderIndexController.text = asset?.orderIndex.value.fold((_) => '0', (num v) => '$v') ?? '1';
      selectedType.value = asset?.type ?? ContentAssetType.banner;
      selectedPlacement.value = asset?.placementGroup ?? ContentPlacementGroup.home;
      isActive.value = asset?.status == ContentStatus.active;
      hasSchedule.value = asset?.status == ContentStatus.scheduled;
      return null;
    }, <Object?>[asset?.id.getValue()]);

    ContentAsset buildUpdatedAsset() {
      final ContentStatus status = hasSchedule.value
          ? ContentStatus.scheduled
          : isActive.value
          ? ContentStatus.active
          : ContentStatus.draft;

      dynamic parsedMetadata;
      if (metadataController.text.isNotEmpty) {
        try {
          parsedMetadata = jsonDecode(metadataController.text);
        } on Exception catch (_) {
          parsedMetadata = metadataController.text;
        }
      }

      return ContentAsset(
        id: asset?.id ?? UniqueId(),
        title: ValueString(titleController.text, fieldName: 'title'),
        type: selectedType.value,
        placementGroup: selectedPlacement.value,
        orderIndex: ValueNumeric(int.tryParse(orderIndexController.text) ?? 0, fieldName: 'orderIndex'),
        status: status,
        routeUrl: routeUrlController.text.isNotEmpty ? Url(routeUrlController.text) : null,
        imageUrl: imageUrlController.text.isNotEmpty ? Url(imageUrlController.text) : null,
        metadataJson: parsedMetadata != null ? ValueJson(parsedMetadata, fieldName: 'metadata') : null,
        lastModified: LocalDateTime(DateTime.now()),
      );
    }

    void emitChanges() {
      onSave(buildUpdatedAsset());
    }

    return BaktazCard(
      headerTitle: asset != null ? context.i18n.content.panel.edit_content : context.i18n.content.panel.add_content,
      headerIcon: asset != null ? Icons.edit : Icons.add,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazTextField(
            controller: titleController,
            labelText: context.i18n.content.panel.title_label,
            hintText: context.i18n.content.panel.title_hint,
            onChanged: (_) => emitChanges(),
          ),
          const Gap(BaktazSpacing.sm),
          _TypeAndPlacementRow(
            selectedType: selectedType.value,
            selectedPlacement: selectedPlacement.value,
            onTypeChanged: (ContentAssetType t) {
              selectedType.value = t;
              emitChanges();
            },
            onPlacementChanged: (ContentPlacementGroup g) {
              selectedPlacement.value = g;
              emitChanges();
            },
          ),
          const Gap(BaktazSpacing.sm),
          BaktazTextField(
            controller: orderIndexController,
            labelText: context.i18n.content.panel.order_index,
            keyboardType: TextInputType.number,
            onChanged: (_) => emitChanges(),
          ),
          const Gap(BaktazSpacing.sm),
          _StatusTogglesRow(
            isActive: isActive.value,
            hasSchedule: hasSchedule.value,
            onActiveChanged: (bool val) {
              isActive.value = val;
              emitChanges();
            },
            onScheduleChanged: (bool val) {
              hasSchedule.value = val;
              emitChanges();
            },
          ),
          const Gap(BaktazSpacing.sm),
          BaktazTextField(
            controller: routeUrlController,
            labelText: context.i18n.content.panel.route_url_label,
            hintText: context.i18n.content.panel.route_url_hint,
            onChanged: (_) => emitChanges(),
          ),
          const Gap(BaktazSpacing.sm),
          BaktazTextField(
            controller: imageUrlController,
            labelText: context.i18n.content.panel.image_url_label,
            hintText: context.i18n.content.panel.image_url_hint,
            onChanged: (_) => emitChanges(),
          ),
          const Gap(BaktazSpacing.sm),
          BaktazTextField(
            controller: metadataController,
            labelText: context.i18n.content.panel.metadata_label,
            hintText: context.i18n.content.panel.metadata_hint,
            maxLines: 3,
            onChanged: (_) => emitChanges(),
          ),
          const Gap(BaktazSpacing.md),
          _PanelActionButtons(isEditing: asset != null, onCancel: onCancel, onSubmit: emitChanges),
        ],
      ),
    );
  }
}

class _TypeAndPlacementRow extends StatelessWidget {
  const _TypeAndPlacementRow({
    required this.selectedType,
    required this.selectedPlacement,
    required this.onTypeChanged,
    required this.onPlacementChanged,
  });

  final ContentAssetType selectedType;
  final ContentPlacementGroup selectedPlacement;
  final ValueChanged<ContentAssetType> onTypeChanged;
  final ValueChanged<ContentPlacementGroup> onPlacementChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: _BaktazDropdown<ContentAssetType>(
          value: selectedType,
          items: ContentAssetType.values
              .map(
                (ContentAssetType t) => DropdownMenuItem<ContentAssetType>(
                  value: t,
                  child: BaktazText(text: t.displayName, style: Theme.of(context).textTheme.bodyMedium),
                ),
              )
              .toList(),
          onChanged: (ContentAssetType? val) {
            if (val != null) onTypeChanged(val);
          },
        ),
      ),
      const Gap(BaktazSpacing.sm),
      Expanded(
        child: _BaktazDropdown<ContentPlacementGroup>(
          value: selectedPlacement,
          items: ContentPlacementGroup.values
              .map(
                (ContentPlacementGroup g) => DropdownMenuItem<ContentPlacementGroup>(
                  value: g,
                  child: BaktazText(text: g.displayName, style: Theme.of(context).textTheme.bodyMedium),
                ),
              )
              .toList(),
          onChanged: (ContentPlacementGroup? val) {
            if (val != null) onPlacementChanged(val);
          },
        ),
      ),
    ],
  );
}

class _BaktazDropdown<T> extends StatelessWidget {
  const _BaktazDropdown({required this.value, required this.items, required this.onChanged});

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(value: value, isExpanded: true, isDense: true, items: items, onChanged: onChanged),
      ),
    );
}

class _StatusTogglesRow extends StatelessWidget {
  const _StatusTogglesRow({
    required this.isActive,
    required this.hasSchedule,
    required this.onActiveChanged,
    required this.onScheduleChanged,
  });

  final bool isActive;
  final bool hasSchedule;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onScheduleChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      BaktazText(text: context.i18n.content.panel.active, style: Theme.of(context).textTheme.bodyMedium),
      const Gap(BaktazSpacing.xs),
      BaktazToggle(value: isActive, onChanged: onActiveChanged),
      const Gap(BaktazSpacing.lg),
      BaktazText(text: context.i18n.content.panel.scheduled, style: Theme.of(context).textTheme.bodyMedium),
      const Gap(BaktazSpacing.xs),
      BaktazToggle(value: hasSchedule, onChanged: onScheduleChanged),
    ],
  );
}

class _PanelActionButtons extends StatelessWidget {
  const _PanelActionButtons({required this.isEditing, required this.onCancel, required this.onSubmit});

  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      BaktazButton(text: context.i18n.content.panel.cancel, buttonType: ButtonType.text, onPressed: onCancel),
      const Gap(BaktazSpacing.sm),
      BaktazButton(
        text: isEditing ? context.i18n.content.panel.update : context.i18n.content.panel.add,
        onPressed: onSubmit,
      ),
    ],
  );
}

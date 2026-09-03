import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ContentTableHeader extends StatefulWidget {
  const ContentTableHeader({
    required this.selectedType,
    required this.selectedPlacement,
    required this.searchQuery,
    required this.onTypeFilterChanged,
    required this.onPlacementFilterChanged,
    required this.onSearchChanged,
    super.key,
  });

  final ContentAssetType? selectedType;
  final ContentPlacementGroup? selectedPlacement;
  final String searchQuery;
  final ValueChanged<ContentAssetType?> onTypeFilterChanged;
  final ValueChanged<ContentPlacementGroup?> onPlacementFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  State<ContentTableHeader> createState() => _ContentTableHeaderState();
}

class _ContentTableHeaderState extends State<ContentTableHeader> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(ContentTableHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      BaktazFilterChip(
        label: context.i18n.content.table.all,
        isActive: widget.selectedType == null,
        onTap: () => widget.onTypeFilterChanged(null),
      ),
      const Gap(BaktazSpacing.xs),
      ...ContentAssetType.values.map(
        (ContentAssetType type) => Padding(
          padding: const EdgeInsets.only(right: BaktazSpacing.xs),
          child: BaktazFilterChip(
            label: type.displayName,
            isActive: widget.selectedType == type,
            onTap: () => widget.onTypeFilterChanged(type),
          ),
        ),
      ),
      const Spacer(),
      _PlacementDropdown(selected: widget.selectedPlacement, onChanged: widget.onPlacementFilterChanged),
      const Gap(BaktazSpacing.sm),
      SizedBox(
        width: BaktazSpacing.tableSearchWidth,
        child: BaktazTextField(
          controller: _searchController,
          hintText: context.i18n.content.table.search_placeholder,
          onChanged: widget.onSearchChanged,
          prefix: const Icon(Icons.search, size: BaktazSpacing.iconSmall),
        ),
      ),
    ],
  );
}

class _PlacementDropdown extends StatelessWidget {
  const _PlacementDropdown({required this.selected, required this.onChanged});

  final ContentPlacementGroup? selected;
  final ValueChanged<ContentPlacementGroup?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ContentPlacementGroup>(
          value: selected,
          hint: BaktazText(
            text: context.i18n.content.table.placement,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          isDense: true,
          items: <DropdownMenuItem<ContentPlacementGroup>>[
            DropdownMenuItem<ContentPlacementGroup>(
              child: BaktazText(
                text: context.i18n.content.table.all_placements,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ...ContentPlacementGroup.values.map(
              (ContentPlacementGroup group) => DropdownMenuItem<ContentPlacementGroup>(
                value: group,
                child: BaktazText(text: group.displayName, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
}

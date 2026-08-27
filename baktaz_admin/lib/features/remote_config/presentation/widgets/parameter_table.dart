import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/remote_config/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/sort_criteria.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;

class ParameterTable extends StatelessWidget {
  const ParameterTable({required this.onEdit, super.key});

  final void Function(String, RemoteConfigValue, String) onEdit;

  @override
  Widget build(BuildContext context) {
    final RemoteConfigCubit cubit = context.watch<RemoteConfigCubit>();
    final RemoteConfigState state = cubit.stateValue;

    final Map<String, RemoteConfigValue> parameters =
        state.remoteConfig?.parameters ?? const <String, RemoteConfigValue>{};
    final Map<String, RemoteConfigValue> pendingChanges = state.pendingChanges;

    final Set<String> allKeys = <String>{...parameters.keys, ...pendingChanges.keys};

    if (allKeys.isEmpty) {
      return Center(
        child: Padding(
          padding: Paddings.allX2Large,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BaktazText(
                text: context.i18n.remote_config.table.no_parameters_title,
                style: AppTextStyle.titleLarge.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
              const Gap(AppSizes.xSmall),
              BaktazText(
                text: context.i18n.remote_config.table.no_parameters_desc,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColors.colorTextSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final List<MapEntry<String, RemoteConfigValue>> paginatedEntries = state.paginatedParameters;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TableHeader(
            totalCount: state.totalParametersCount,
            availableTypes: state.availableTypes,
            selectedType: state.selectedType,
            onTypeSelected: cubit.selectType,
            sortCriteria: state.sortCriteria,
            onSortCriteriaSelected: cubit.selectSortCriteria,
            isAscending: state.isAscending,
            onToggleSort: cubit.toggleSortOrder,
          ),
          const Divider(height: 1, color: AppColors.colorBorder),
          const _TableColumnHeaders(),
          const Divider(height: 1, color: AppColors.colorBorder),
          ...paginatedEntries.map((MapEntry<String, RemoteConfigValue> entry) {
            final String key = entry.key;
            final RemoteConfigValue baseValue = entry.value;
            final bool isNew = pendingChanges.containsKey(key) && !parameters.containsKey(key);
            final bool isModified = pendingChanges.containsKey(key) && parameters.containsKey(key);
            final String resolvedDescription = baseValue.description?.getValue() ?? '';

            return Column(
              key: ValueKey<String>(key),
              children: <Widget>[
                _ParameterRow(
                  paramKey: key,
                  displayValue: baseValue,
                  isNew: isNew,
                  isModified: isModified,
                  onEdit: () => onEdit(key, baseValue, resolvedDescription),
                ),
                const Divider(height: 1, color: AppColors.colorBorder),
              ],
            );
          }),
          _TablePaginationFooter(
            startIndex: state.startIndex,
            endIndex: state.endIndex,
            totalItems: state.totalItems,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            onPageChanged: cubit.setPage,
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatefulWidget {
  const _TableHeader({
    required this.totalCount,
    required this.availableTypes,
    required this.selectedType,
    required this.onTypeSelected,
    required this.sortCriteria,
    required this.onSortCriteriaSelected,
    required this.isAscending,
    required this.onToggleSort,
  });

  final int totalCount;
  final Set<ConfigValueType> availableTypes;
  final ConfigValueType? selectedType;
  final void Function(ConfigValueType?) onTypeSelected;
  final SortCriteria sortCriteria;
  final void Function(SortCriteria) onSortCriteriaSelected;
  final bool isAscending;
  final VoidCallback onToggleSort;

  @override
  State<_TableHeader> createState() => _TableHeaderState();
}

class _TableHeaderState extends State<_TableHeader> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSizes.large, AppSizes.medium, AppSizes.large, AppSizes.small),
    child: Row(
      children: <Widget>[
        BaktazText(
          text: context.i18n.remote_config.table.global_parameters,
          style: AppTextStyle.titleMedium.copyWith(color: AppColors.colorTextPrimary),
        ),
        Gap.xSmall(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: context.i18n.remote_config.table.all_count(count: widget.totalCount),
                  isSelected: widget.selectedType == null,
                  onTap: () => widget.onTypeSelected(null),
                ),
                Gap.xSmall(),
                ...widget.availableTypes.map(
                  (ConfigValueType type) => Padding(
                    padding: const EdgeInsets.only(right: AppSizes.xSmall),
                    child: _FilterChip(
                      label: type.label,
                      isSelected: widget.selectedType == type,
                      onTap: () => widget.onTypeSelected(type),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        MenuAnchor(
          controller: _menuController,
          style: const MenuStyle(padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: AppSizes.xSmall))),
          menuChildren: <Widget>[
            _SortMenuItem(
              icon: Icons.sort_by_alpha,
              label: context.i18n.remote_config.table.sort_alpha,
              selected: widget.sortCriteria == SortCriteria.alphabetical,
              onTap: () {
                _menuController.close();
                widget.onSortCriteriaSelected(SortCriteria.alphabetical);
              },
            ),
            _SortMenuItem(
              icon: Icons.category_outlined,
              label: context.i18n.remote_config.table.sort_type,
              selected: widget.sortCriteria == SortCriteria.type,
              onTap: () {
                _menuController.close();
                widget.onSortCriteriaSelected(SortCriteria.type);
              },
            ),
            _SortMenuItem(
              icon: Icons.date_range_outlined,
              label: context.i18n.remote_config.table.sort_date,
              selected: widget.sortCriteria == SortCriteria.dateModified,
              onTap: () {
                _menuController.close();
                widget.onSortCriteriaSelected(SortCriteria.dateModified);
              },
            ),
          ],
          builder: (BuildContext context, MenuController controller, Widget? child) => IconButton(
            tooltip: context.i18n.remote_config.table.sort_options,
            padding: Paddings.allX2Small,
            constraints: const BoxConstraints(),
            onPressed: () => controller.open(),
            icon: BaktazIcon(
              icon: Either<String, IconData>.right(Icons.filter_list),
              size: AppSizes.iconSmall,
              color: AppColors.colorTextSecondary,
            ),
          ),
        ),
        Gap.x2Small(),
        IconButton(
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(widget.isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            size: AppSizes.iconSmall,
            color: AppColors.colorTextSecondary,
          ),
          onPressed: widget.onToggleSort,
          tooltip: widget.isAscending ? context.i18n.remote_config.table.sort_asc : context.i18n.remote_config.table.sort_desc,
          padding: Paddings.allX2Small,
          constraints: const BoxConstraints(),
        ),
        Gap.xSmall(),
        IconButton(
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.download_outlined),
            size: AppSizes.iconSmall,
            color: AppColors.colorTextSecondary,
          ),
          onPressed: () {},
          tooltip: context.i18n.remote_config.table.export,
          padding: Paddings.allX2Small,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.small, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.colorPrimarySubtle : AppColors.colorSurfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
      ),
      child: BaktazText(
        text: label,
        style: AppTextStyle.labelSmall.copyWith(
          fontWeight: isSelected ? AppFontWeight.semiBold : AppFontWeight.medium,
          color: isSelected ? AppColors.black : AppColors.colorTextSecondary,
        ),
      ),
    ),
  );
}

class _TableColumnHeaders extends StatelessWidget {
  const _TableColumnHeaders();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
    child: Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: BaktazText(
            text: context.i18n.remote_config.table.parameter_key,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextDisabled,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: BaktazText(
            text: context.i18n.remote_config.table.value,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextDisabled,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: BaktazText(
            text: context.i18n.remote_config.table.type,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextDisabled,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: BaktazText(
            text: context.i18n.remote_config.table.last_modified,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextDisabled,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
        Expanded(
          child: BaktazText(
            text: context.i18n.remote_config.table.actions,
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColors.colorTextDisabled,
              fontWeight: AppFontWeight.semiBold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({
    required this.paramKey,
    required this.displayValue,
    required this.isNew,
    required this.isModified,
    required this.onEdit,
  });

  final String paramKey;
  final RemoteConfigValue displayValue;
  final bool isNew;
  final bool isModified;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String description = displayValue.description?.getValue() ?? '';

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.medium),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BaktazText(
                    text: paramKey,
                    style: AppTextStyle.bodyMedium.copyWith(
                      fontWeight: AppFontWeight.semiBold,
                      color: AppColors.colorTextPrimary,
                    ),
                  ),
                  if (description.isNotEmpty) ...<Widget>[
                    Gap.x2Small(),
                    BaktazText(
                      text: description,
                      style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
                    ),
                  ],
                  if (isNew) ...<Widget>[
                    Gap.x2Small(),
                    // ponytail: mapped to AppColors tokens
                    const _StatusBadge(
                      label: 'PENDING',
                      bg: AppColors.colorPrimarySubtle,
                      fg: AppColors.colorPrimaryDark,
                    ),
                  ] else if (isModified) ...<Widget>[
                    Gap.x2Small(),
                    const _StatusBadge(label: 'MODIFIED', bg: AppColors.pendingSubtle, fg: AppColors.warningText),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _ValueDisplay(value: displayValue.rawValue, type: displayValue.valueType),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypeBadge(type: displayValue.valueType),
              ),
            ),
            Expanded(
              flex: 2,
              child: BaktazText(
                text: _getLastModifiedDisplay(displayValue.lastModified),
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: BaktazButton(
                  onPressed: onEdit,
                  buttonType: ButtonType.text,
                  icon: BaktazIcon(
                    icon: Either<String, IconData>.right(Icons.edit_outlined),
                    size: 14,
                    color: AppColors.colorPrimary,
                  ),
                  text: context.i18n.remote_config.table.edit,
                  textStyle: AppTextStyle.labelLarge.copyWith(color: AppColors.colorPrimary),
                  buttonStyle: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastModifiedDisplay(DateTime? lastModified) {
    final DateTime date = lastModified ?? DateTime.now();
    final Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 7) {
      return date.formatMonthShortDayYear();
    }
    return date.ago;
  }
}

class _SortMenuItem extends StatelessWidget {
  const _SortMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    leadingIcon: BaktazIcon(
      icon: Either<String, IconData>.right(icon),
      size: AppSizes.iconSmall,
      color: selected ? AppColors.colorPrimary : AppColors.colorTextSecondary,
    ),
    onPressed: onTap,
    child: BaktazText(text: label),
  );
}

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({required this.value, required this.type});

  final String value;
  final ConfigValueType type;

  @override
  Widget build(BuildContext context) {
    final Color textColor = switch (type) {
      ConfigValueType.boolean => value.toLowerCase() == 'true' ? AppColors.colorAccent : AppColors.colorTextPrimary,
      _ => AppColors.colorTextPrimary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: 5),
      decoration: const BoxDecoration(
        color: AppColors.colorSurfaceVariant,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusX2Small)),
      ),
      child: BaktazText(
        text: value,
        style: AppTextStyle.bodySmall.copyWith(
          fontFamily: type == ConfigValueType.json ? 'RobotoMono' : null,
          fontWeight: AppFontWeight.medium,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ConfigValueType type;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (type) {
      ConfigValueType.string => (AppColors.colorPrimarySubtle, AppColors.colorPrimaryDark),
      ConfigValueType.boolean => (AppColors.colorAccentSubtle, AppColors.successText),
      ConfigValueType.number => (AppColors.pendingSubtle, AppColors.warningText),
      ConfigValueType.json => (AppColors.purpleSubtle, AppColors.purpleText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x2Small),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
      child: BaktazText(
        text: type.name.toUpperCase(),
        style: AppTextStyle.labelSmall.copyWith(color: fg, letterSpacing: 0.3),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x3Small),
    decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull))),
    child: BaktazText(
      text: label,
      style: AppTextStyle.labelSmall.copyWith(color: fg, fontWeight: AppFontWeight.bold, letterSpacing: 0.4),
    ),
  );
}

class _TablePaginationFooter extends StatelessWidget {
  const _TablePaginationFooter({
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int startIndex;
  final int endIndex;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
    child: Row(
      children: <Widget>[
        BaktazText(
          text: totalItems == 0
              ? context.i18n.remote_config.table.no_parameters_summary
              : context.i18n.remote_config.table.showing_summary(
                  start: startIndex + 1,
                  end: endIndex,
                  total: totalItems,
                ),
          style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
        ),
        const Spacer(),
        if (totalPages > 1) ...<Widget>[
          IconButton(
            icon: BaktazIcon(icon: Either<String, IconData>.right(Icons.chevron_left), size: AppSizes.iconSmall),
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Gap.xSmall(),
          ...List<Widget>.generate(totalPages, (int index) {
            final int pageNumber = index + 1;
            final bool isSelected = pageNumber == currentPage;
            return GestureDetector(
              onTap: () => onPageChanged(pageNumber),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.x2Small),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.colorPrimary : AppColors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusX2Small)),
                ),
                child: BaktazText(
                  text: pageNumber.toString(),
                  style: AppTextStyle.bodySmall.copyWith(
                    fontWeight: AppFontWeight.semiBold,
                    color: isSelected ? AppColors.white : AppColors.colorTextSecondary,
                  ),
                ),
              ),
            );
          }),
          Gap.xSmall(),
          IconButton(
            icon: BaktazIcon(icon: Either<String, IconData>.right(Icons.chevron_right), size: AppSizes.iconSmall),
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    ),
  );
}

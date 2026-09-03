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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(BaktazSpacing.xs),
              BaktazText(
                text: context.i18n.remote_config.table.no_parameters_desc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final List<MapEntry<String, RemoteConfigValue>> paginatedEntries = state.paginatedParameters;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
        border: Border.fromBorderSide(BorderSide(color: context.colorScheme.outline)),
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
          Divider(height: 1, color: context.colorScheme.outline),
          const _TableColumnHeaders(),
          Divider(height: 1, color: context.colorScheme.outline),
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
                Divider(height: 1, color: context.colorScheme.outline),
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
    padding: const EdgeInsets.fromLTRB(BaktazSpacing.lg, BaktazSpacing.md, BaktazSpacing.lg, BaktazSpacing.sm),
    child: Row(
      children: <Widget>[
        BaktazText(
          text: context.i18n.remote_config.table.global_parameters,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurface),
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
                    padding: const EdgeInsets.only(right: BaktazSpacing.xs),
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
          style: const MenuStyle(
            padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(vertical: BaktazSpacing.xs)),
          ),
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
              size: BaktazSpacing.iconSmall,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Gap.x2Small(),
        IconButton(
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(widget.isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            size: BaktazSpacing.iconSmall,
            color: context.colorScheme.onSurfaceVariant,
          ),
          onPressed: widget.onToggleSort,
          tooltip: widget.isAscending
              ? context.i18n.remote_config.table.sort_asc
              : context.i18n.remote_config.table.sort_desc,
          padding: Paddings.allX2Small,
          constraints: const BoxConstraints(),
        ),
        Gap.xSmall(),
        IconButton(
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.download_outlined),
            size: BaktazSpacing.iconSmall,
            color: context.colorScheme.onSurfaceVariant,
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
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? context.colorScheme.primaryContainer : context.colorScheme.surfaceContainerHighest,
        borderRadius: BaktazRadius.pill,
      ),
      child: BaktazText(
        text: label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.black : context.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class _TableColumnHeaders extends StatelessWidget {
  const _TableColumnHeaders();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
    child: Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: BaktazText(
            text: context.i18n.remote_config.table.parameter_key,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: BaktazText(
            text: context.i18n.remote_config.table.value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: BaktazText(
            text: context.i18n.remote_config.table.type,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: BaktazText(
            text: context.i18n.remote_config.table.last_modified,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: BaktazText(
            text: context.i18n.remote_config.table.actions,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BaktazText(
                    text: paramKey,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (description.isNotEmpty) ...<Widget>[
                    Gap.x2Small(),
                    BaktazText(
                      text: description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (isNew) ...<Widget>[
                    Gap.x2Small(),
                    // ponytail: mapped to AppColors tokens
                    _StatusBadge(
                      label: 'PENDING',
                      bg: context.colorScheme.primaryContainer,
                      fg: context.colorScheme.primaryContainer,
                    ),
                  ] else if (isModified) ...<Widget>[
                    Gap.x2Small(),
                    _StatusBadge(label: 'MODIFIED', bg: context.colorScheme.surfaceContainerHigh, fg: context.baktazColors.warning),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
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
                    color: context.colorScheme.primary,
                  ),
                  text: context.i18n.remote_config.table.edit,
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.colorScheme.primary),
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
  const _SortMenuItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MenuItemButton(
    leadingIcon: BaktazIcon(
      icon: Either<String, IconData>.right(icon),
      size: BaktazSpacing.iconSmall,
      color: selected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
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
      ConfigValueType.boolean => value.toLowerCase() == 'true' ? context.colorScheme.primary : context.colorScheme.onSurface,
      _ => context.colorScheme.onSurface,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: 5),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
      ),
      child: BaktazText(
        text: value,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: type == ConfigValueType.json ? 'RobotoMono' : null,
          fontWeight: FontWeight.w500,
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
      ConfigValueType.string => (context.colorScheme.primaryContainer, context.colorScheme.primaryContainer),
      ConfigValueType.boolean => (context.colorScheme.primaryContainer, context.colorScheme.primary),
      ConfigValueType.number => (context.colorScheme.surfaceContainerHigh, context.baktazColors.warning),
      ConfigValueType.json => (context.colorScheme.tertiaryContainer, context.colorScheme.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
      decoration: BoxDecoration(color: bg, borderRadius: BaktazRadius.pill),
      child: BaktazText(
        text: type.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, letterSpacing: 0.3),
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
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
    decoration: BoxDecoration(color: bg, borderRadius: BaktazRadius.pill),
    child: BaktazText(
      text: label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.bold, letterSpacing: 0.4),
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
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        if (totalPages > 1) ...<Widget>[
          IconButton(
            icon: BaktazIcon(icon: Either<String, IconData>.right(Icons.chevron_left), size: BaktazSpacing.iconSmall),
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
                margin: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs2),
                padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? context.colorScheme.primary : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
                ),
                child: BaktazText(
                  text: pageNumber.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
          Gap.xSmall(),
          IconButton(
            icon: BaktazIcon(icon: Either<String, IconData>.right(Icons.chevron_right), size: BaktazSpacing.iconSmall),
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    ),
  );
}

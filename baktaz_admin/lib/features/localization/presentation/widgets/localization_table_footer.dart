import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;

class LocalizationTableFooter extends StatelessWidget {
  const LocalizationTableFooter({
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.isNamespacePagination,
    super.key,
  });

  final int startIndex;
  final int endIndex;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;
  final bool isNamespacePagination;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
    child: Row(
      children: <Widget>[
        BaktazText(
          text: totalItems == 0
              ? context.i18n.localization.table.no_keys_summary
              : (isNamespacePagination
                    ? context.i18n.localization.table.showing_summary_namespaces(
                        start: startIndex + 1,
                        end: endIndex,
                        total: totalItems,
                      )
                    : context.i18n.localization.table.showing_summary_keys(
                        start: startIndex + 1,
                        end: endIndex,
                        total: totalItems,
                      )),
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

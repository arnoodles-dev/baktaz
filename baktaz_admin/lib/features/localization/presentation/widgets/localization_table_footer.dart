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
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.large, vertical: AppSizes.small),
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

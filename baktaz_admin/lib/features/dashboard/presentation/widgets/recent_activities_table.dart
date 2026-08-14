import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/enum/activity_status.dart';
import 'package:baktaz_admin/features/dashboard/domain/entity/recent_activity.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class RecentActivitiesTable extends StatelessWidget {
  const RecentActivitiesTable({required this.activities, super.key});

  final List<RecentActivity> activities;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.textTheme;
    final ColorScheme colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: Paddings.allLarge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                BaktazText(
                  text: context.i18n.dashboard.recent.title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
                ),
                BaktazButton(
                  onPressed: () {},
                  text: context.i18n.dashboard.recent.see_all,
                  buttonType: ButtonType.text,
                  textStyle: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          RepaintBoundary(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                    columns: <DataColumn>[
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.no)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.activity_id)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.date)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.activity)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.customers)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.total_amount)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.status)),
                      DataColumn(label: BaktazText(text: context.i18n.dashboard.recent.columns.action)),
                    ],
                    rows: activities.take(7).toList().asMap().entries.map((MapEntry<int, RecentActivity> entry) {
                      final int index = entry.key;
                      final RecentActivity activity = entry.value;

                      return DataRow(
                        cells: <DataCell>[
                          DataCell(BaktazText(text: (index + 1).toString().padLeft(2, '0'))),
                          DataCell(
                            BaktazText(
                              text: activity.id.getValue(),
                              style: AppTextStyle.labelLarge.copyWith(
                                color: colorScheme.primary,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(BaktazText(text: DateFormat('MMM dd, yyyy').format(activity.date))),
                          DataCell(
                            BaktazText(
                              text: activity.name.getValue(),
                              style: AppTextStyle.bodyMedium.copyWith(fontWeight: AppFontWeight.semiBold),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: <Widget>[
                                for (final Url avatarUrl in activity.customerAvatars)
                                  Padding(
                                    padding: Paddings.rightX2Small,
                                    child: BaktazAvatar(size: AppSizes.avatarSM, imageUrl: avatarUrl.getValue()),
                                  ),
                                if (activity.customers.getValue() > activity.customerAvatars.length)
                                  CircleAvatar(
                                    radius: AppSizes.small,
                                    backgroundColor: colorScheme.primary,
                                    child: BaktazText(
                                      text: '+${activity.customers.getValue() - activity.customerAvatars.length}',
                                      style: AppTextStyle.labelSmall.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            BaktazText(
                              text: '\$${activity.totalAmount.getValue().toStringAsFixed(2)}',
                              style: AppTextStyle.bodyMedium.copyWith(fontWeight: AppFontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _StatusBadge(status: activity.status),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: BaktazIcon(icon: right(Icons.more_vert)),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.colorScheme;
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case ActivityStatus.completed:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        label = 'Completed';
        icon = Icons.check_circle;
      case ActivityStatus.processing:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Processing';
        icon = Icons.sync;
      case ActivityStatus.pending:
        backgroundColor = colorScheme.tertiaryContainer;
        textColor = colorScheme.onTertiaryContainer;
        label = 'Pending';
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xSmall, vertical: AppSizes.x2Small),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BaktazIcon(icon: right(icon), size: 14, color: textColor),
          Gap.x2Small(),
          BaktazText(
            text: label,
            style: AppTextStyle.labelMedium.copyWith(color: textColor, fontWeight: AppFontWeight.bold),
          ),
        ],
      ),
    );
  }
}

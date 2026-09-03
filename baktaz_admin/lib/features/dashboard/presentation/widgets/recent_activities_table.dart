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

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BaktazRadius.chip,
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
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
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                BaktazButton(
                  onPressed: () {},
                  text: context.i18n.dashboard.recent.see_all,
                  buttonType: ButtonType.text,
                  textStyle: textTheme.labelLarge?.copyWith(color: context.colorScheme.primary),
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
                      context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: context.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(BaktazText(text: DateFormat('MMM dd, yyyy').format(activity.date))),
                          DataCell(
                            BaktazText(
                              text: activity.name.getValue(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: <Widget>[
                                for (final Url avatarUrl in activity.customerAvatars)
                                  Padding(
                                    padding: Paddings.rightX2Small,
                                    child: BaktazAvatar(size: BaktazAvatar.sizeSM, imageUrl: avatarUrl.getValue()),
                                  ),
                                if (activity.customers.getValue() > activity.customerAvatars.length)
                                  CircleAvatar(
                                    radius: BaktazSpacing.sm,
                                    backgroundColor: context.colorScheme.primary,
                                    child: BaktazText(
                                      text: '+${activity.customers.getValue() - activity.customerAvatars.length}',
                                      style: Theme.of(context).textTheme.labelSmall
                                          ?.copyWith(color: context.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            BaktazText(
                              text: '\$${activity.totalAmount.getValue().toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case ActivityStatus.completed:
        backgroundColor = context.colorScheme.secondaryContainer;
        textColor = context.colorScheme.onSecondaryContainer;
        label = 'Completed';
        icon = Icons.check_circle;
      case ActivityStatus.processing:
        backgroundColor = context.colorScheme.primaryContainer;
        textColor = context.colorScheme.onPrimaryContainer;
        label = 'Processing';
        icon = Icons.sync;
      case ActivityStatus.pending:
        backgroundColor = context.colorScheme.tertiaryContainer;
        textColor = context.colorScheme.onTertiaryContainer;
        label = 'Pending';
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BaktazRadius.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BaktazIcon(icon: right(icon), size: 14, color: textColor),
          Gap.x2Small(),
          BaktazText(
            text: label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

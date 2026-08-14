import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class ConfigInfoSection extends StatelessWidget {
  const ConfigInfoSection({required this.version, super.key});

  final ConfigSnapshotVersion version;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: _RecentHistoryCard(version: version)),
        Gap.medium(),
        Expanded(child: _VersionManagementCard(version: version)),
      ],
    ),
  );
}

class _RecentHistoryCard extends StatelessWidget {
  const _RecentHistoryCard({required this.version});

  final ConfigSnapshotVersion version;

  @override
  Widget build(BuildContext context) => Container(
    padding: Paddings.allLarge,
    decoration: const BoxDecoration(
      color: AppColors.colorSurface,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
      border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: AppSizes.size36,
              height: AppSizes.size36,
              decoration: const BoxDecoration(
                color: AppColors.colorPrimarySubtle,
                borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXSmall)),
              ),
              child: BaktazIcon(
                icon: Either<String, IconData>.right(Icons.history),
                size: AppSizes.iconSmall,
                color: AppColors.colorPrimary,
              ),
            ),
            Gap.small(),
            BaktazText(
              text: context.i18n.remote_config.history.title,
              style: AppTextStyle.titleMedium.copyWith(color: AppColors.colorTextPrimary),
            ),
          ],
        ),
        Gap.medium(),
        _HistoryEntry(
          email: version.updateUser.getValue(),
          action: 'updated',
          detail: 'v${version.versionNumber.getValue()}',
          time: _formatRelativeTime(version.updateTime),
        ),
        Gap.medium(),
        TextButton.icon(
          onPressed: () {},
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.open_in_new),
            size: 14,
            color: AppColors.colorPrimary,
          ),
          label: BaktazText(
            text: context.i18n.remote_config.history.view_audit_log,
            style: AppTextStyle.labelLarge.copyWith(color: AppColors.colorPrimary),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    ),
  );

  String _formatRelativeTime(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inDays > 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} mins ago';
    }
    return 'Just now';
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.email, required this.action, required this.detail, required this.time});

  final String email;
  final String action;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    final String displayName = email.split('@').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.colorPrimarySubtle,
          child: BaktazText(
            text: displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: AppTextStyle.labelMedium.copyWith(color: AppColors.colorPrimary),
          ),
        ),
        Gap.xSmall(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: '<b>$displayName</b> $action <blueText>$detail</blueText>',
                textType: TextType.styled,
                style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextPrimary),
              ),
              Gap.x2Small(),
              BaktazText(
                text: time,
                style: AppTextStyle.labelSmall.copyWith(color: AppColors.colorTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VersionManagementCard extends StatelessWidget {
  const _VersionManagementCard({required this.version});

  final ConfigSnapshotVersion version;

  @override
  Widget build(BuildContext context) => Container(
    padding: Paddings.allLarge,
    decoration: const BoxDecoration(
      color: AppColors.colorSurface,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
      border: Border.fromBorderSide(BorderSide(color: AppColors.colorBorder)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: AppSizes.size36,
              height: AppSizes.size36,
              decoration: const BoxDecoration(
                color: AppColors.colorPrimarySubtle,
                borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXSmall)),
              ),
              child: BaktazIcon(
                icon: Either<String, IconData>.right(Icons.manage_history_outlined),
                size: AppSizes.iconSmall,
                color: AppColors.colorPrimary,
              ),
            ),
            Gap.small(),
            BaktazText(
              text: context.i18n.remote_config.version.title,
              style: AppTextStyle.titleMedium.copyWith(color: AppColors.colorTextPrimary),
            ),
          ],
        ),
        Gap.medium(),
        BaktazText(
          text:
              '<b>v${version.versionNumber.getValue()}</b> is currently live. Previous versions available for rollback.',
          textType: TextType.styled,
          style: AppTextStyle.bodySmall.copyWith(color: AppColors.colorTextSecondary),
        ),
        Gap.medium(),
        TextButton.icon(
          onPressed: () {},
          icon: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.settings_backup_restore),
            size: 14,
            color: AppColors.colorPrimary,
          ),
          label: BaktazText(
            text: context.i18n.remote_config.version.manage_versions,
            style: AppTextStyle.labelLarge.copyWith(color: AppColors.colorPrimary),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    ),
  );
}

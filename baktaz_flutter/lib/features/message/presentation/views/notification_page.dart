import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) => EmptyPage(
    title: context.i18n.messages.notifications_placeholder,
    subtitle: context.i18n.messages.notifications_subtitle,
    iconPath: Assets.images.emptyNotification.path,
  );
}

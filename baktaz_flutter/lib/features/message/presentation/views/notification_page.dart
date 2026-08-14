import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) => EmptyPage(
    title: 'Notifications will appear here',
    subtitle: 'Watch this space for offers, updates, and more.',
    iconPath: Assets.images.emptyNotification.path,
  );
}

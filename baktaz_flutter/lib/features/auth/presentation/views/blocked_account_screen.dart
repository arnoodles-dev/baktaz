import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) => BaktazErrorScreen(
    icon: Icon(Icons.block, size: BaktazAvatar.sizeLG, color: context.colorScheme.error),
    title: context.i18n.blocked.title,
    subtitle: context.i18n.blocked.subtitle,
    retryLabel: context.i18n.blocked.button,
    onRetry: () => const LoginRoute().go(context),
  );
}

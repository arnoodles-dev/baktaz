import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeDailyStepSyncFooter extends StatelessWidget {
  const HomeDailyStepSyncFooter({
    required this.syncSource,
    required this.lastSyncedText,
    required this.onRefresh,
    super.key,
  });

  final String syncSource;
  final String lastSyncedText;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: BaktazText(
          text: context.i18n.home.synced_via(source: syncSource, time: lastSyncedText),
          style: context.textTheme.bodySmall,
        ),
      ),
      IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: const Icon(Icons.refresh),
        onPressed: onRefresh,
      ),
    ],
  );
}

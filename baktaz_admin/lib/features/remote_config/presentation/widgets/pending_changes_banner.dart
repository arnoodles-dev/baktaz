import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class PendingChangesBanner extends StatelessWidget {
  const PendingChangesBanner({required this.changeCount, required this.onPublish, required this.onDiscard, super.key});

  final int changeCount;
  final VoidCallback onPublish;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) => Container(
    margin: Paddings.bottomXLarge,
    padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.md),
    decoration: BoxDecoration(
      color: context.colorScheme.primaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
      border: Border.fromBorderSide(BorderSide(color: context.colorScheme.primaryContainer)),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(BaktazSpacing.lg)),
          ),
          child: BaktazIcon(
            icon: Either<String, IconData>.right(Icons.sync),
            size: BaktazSpacing.iconSmall,
            color: Colors.white,
          ),
        ),
        Gap.medium(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BaktazText(
                text: context.i18n.remote_config.pending_changes.title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Gap.x2Small(),
              BaktazText(
                text: context.i18n.remote_config.pending_changes.description(changeCount: changeCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Gap.small(),
        BaktazButton(
          onPressed: () => _showDiscardConfirmation(context),
          text: context.i18n.remote_config.pending_changes.discard,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          buttonType: ButtonType.text,
          buttonStyle: TextButton.styleFrom(foregroundColor: context.colorScheme.primary),
        ),
        Gap.xSmall(),
        BaktazButton(
          onPressed: onPublish,
          text: context.i18n.remote_config.pending_changes.publish,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          buttonType: ButtonType.elevated,
          buttonStyle: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BaktazRadius.pill),
            padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.lg, vertical: BaktazSpacing.sm),
          ),
        ),
      ],
    ),
  );

  Future<void> _showDiscardConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.sm))),
        title: BaktazText(
          text: context.i18n.remote_config.pending_changes.discard_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: BaktazText(text: context.i18n.remote_config.pending_changes.discard_message),
        actions: <Widget>[
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            text: context.i18n.remote_config.pending_changes.cancel,
            buttonType: ButtonType.text,
          ),
          BaktazButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            text: context.i18n.remote_config.pending_changes.discard,
            buttonType: ButtonType.elevated,
            buttonStyle: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(BaktazRadius.xl)),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onDiscard();
    }
  }
}

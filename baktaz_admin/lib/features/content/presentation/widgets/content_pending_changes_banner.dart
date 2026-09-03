import 'package:baktaz_admin/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ContentPendingChangesBanner extends HookWidget {
  const ContentPendingChangesBanner({
    required this.changeCount,
    required this.onPublish,
    required this.onDiscard,
    super.key,
  });

  final int changeCount;
  final VoidCallback onPublish;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isExpanded = useState<bool>(false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.md, vertical: BaktazSpacing.sm),
      decoration: BoxDecoration(
        color: context.colorScheme.tertiaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(BaktazRadius.sm)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Row(
              children: <Widget>[
                Icon(Icons.edit_note, color: context.colorScheme.onTertiaryContainer, size: BaktazSpacing.iconMedium),
                const Gap(BaktazSpacing.sm),
                Expanded(
                  child: BaktazText(
                    text: changeCount == 1
                        ? context.i18n.content.pending_changes.changes_one
                        : context.i18n.content.pending_changes.changes_other(count: changeCount),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: context.colorScheme.onTertiaryContainer, fontWeight: FontWeight.w600),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: context.colorScheme.onTertiaryContainer,
                    size: BaktazSpacing.iconSmall,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: BaktazSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  BaktazButton(
                    text: context.i18n.content.pending_changes.publish,
                    padding: EdgeInsets.zero,
                    onPressed: onPublish,
                  ),
                  const Gap(BaktazSpacing.sm),
                  BaktazButton(
                    text: context.i18n.content.pending_changes.discard,
                    buttonType: ButtonType.outlined,
                    padding: EdgeInsets.zero,
                    onPressed: onDiscard,
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

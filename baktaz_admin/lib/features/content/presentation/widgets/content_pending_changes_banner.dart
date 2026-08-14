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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ValueNotifier<bool> isExpanded = useState<bool>(false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.medium, vertical: AppSizes.small),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusSmall)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Row(
              children: <Widget>[
                Icon(Icons.edit_note, color: colorScheme.onTertiaryContainer, size: AppSizes.iconMedium),
                const Gap(AppSizes.small),
                Expanded(
                  child: BaktazText(
                    text: changeCount == 1
                        ? context.i18n.content.pending_changes.changes_one
                        : context.i18n.content.pending_changes.changes_other(count: changeCount),
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, color: colorScheme.onTertiaryContainer, size: AppSizes.iconSmall),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSizes.small),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  BaktazButton(
                    text: context.i18n.content.pending_changes.publish,
                    padding: EdgeInsets.zero,
                    onPressed: onPublish,
                  ),
                  const Gap(AppSizes.small),
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

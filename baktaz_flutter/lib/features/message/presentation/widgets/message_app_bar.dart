import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessageAppBar({required this.selectedIndex, super.key});

  final ValueNotifier<int> selectedIndex;

  static const int chatIndex = 0;
  static const int notificationIndex = 1;

  @override
  Size get preferredSize => Size.fromHeight(AppTheme.defaultAppBarHeight) * 2;

  @override
  Widget build(BuildContext context) => BaktazAppBar(
    title: context.i18n.common.messages.capitalize(),
    backgroundColor: context.colorScheme.surface,
    size: preferredSize,
    bottom: PreferredSize(
      preferredSize: preferredSize / 2,
      child: Padding(
        padding: Paddings.horizontalLarge,
        child: Row(
          children: <Widget>[
            _MessageAppBarButton(
              selectedIndex: selectedIndex,
              buttonIndex: 0,
              label: context.i18n.common.chats.capitalize(),
            ),
            Gap.large(),
            _MessageAppBarButton(
              selectedIndex: selectedIndex,
              buttonIndex: 1,
              label: context.i18n.common.notifications.capitalize(),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MessageAppBarButton extends StatelessWidget {
  const _MessageAppBarButton({required this.selectedIndex, required this.buttonIndex, required this.label});

  final String label;
  final ValueNotifier<int> selectedIndex;
  final int buttonIndex;

  ButtonType get buttonType => selectedIndex.value == buttonIndex ? ButtonType.filled : ButtonType.tonal;

  void _onItemPressed(BuildContext context) {
    if (selectedIndex.value != buttonIndex) {
      selectedIndex.value = buttonIndex;
      switch (buttonIndex) {
        case MessageAppBar.chatIndex:
          const ChatRoute().go(context);
        case MessageAppBar.notificationIndex:
          const NotificationRoute().go(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Expanded(
    child: BaktazButton(
      buttonType: buttonType,
      contentPadding: EdgeInsets.zero,
      padding: Paddings.verticalXSmall,
      text: label,
      onPressed: () => _onItemPressed(context),
    ),
  );
}

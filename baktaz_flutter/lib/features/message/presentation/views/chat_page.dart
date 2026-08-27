import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => EmptyPage(
    title: context.i18n.messages.find_chats,
    subtitle: context.i18n.common.discover_new,
    iconPath: Assets.images.emptyChat.path,
  );
}

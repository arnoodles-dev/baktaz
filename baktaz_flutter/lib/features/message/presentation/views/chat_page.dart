import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => EmptyPage(
    title: 'Find your chats here!',
    subtitle: "Discover what's new on the app",
    iconPath: Assets.images.emptyChat.path,
  );
}

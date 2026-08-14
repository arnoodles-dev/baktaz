import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/features/message/presentation/widgets/message_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MessagePage extends HookWidget {
  const MessagePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedIndex = useState<int>(0);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: MessageAppBar(selectedIndex: selectedIndex),
      body: child,
    );
  }
}

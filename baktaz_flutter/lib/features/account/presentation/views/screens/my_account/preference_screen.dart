import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreferenceScreen extends StatelessWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: BaktazAppBar(
      titleColor: context.colorScheme.primary,
      leading: BackButton(color: context.colorScheme.primary, onPressed: () => GoRouter.of(context).pop()),
    ),
    body: ColoredBox(
      color: context.colorScheme.primary,
      child: const Center(child: BaktazText(text: 'Preference Screen')), // TODO: Localize hardcoded string
    ),
  );
}

import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: BaktazAppBar(
      title: context.i18n.common.profile.capitalize(),
      backgroundColor: context.colorScheme.surface,
      leading: BackButton(color: context.colorScheme.onSurface, onPressed: () => GoRouter.of(context).pop()),
    ),
    body: ColoredBox(
      color: context.colorScheme.primary,
      child: const Center(child: BaktazText(text: 'Address Screen')), // TODO: Localize hardcoded string
    ),
  );
}

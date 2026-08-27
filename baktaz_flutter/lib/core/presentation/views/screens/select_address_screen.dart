import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/domain/entity/enum/select_address_entry.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectAddressScreen extends StatelessWidget {
  const SelectAddressScreen({required this.entryPoint, super.key});

  final SelectAddressEntry entryPoint;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: BaktazAppBar(title: context.i18n.select_address.title, leading: const BackButton()),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BaktazText(text: context.i18n.select_address.address_selection),
          Gap.medium(),
          BaktazButton(text: context.i18n.common.confirm, onPressed: () => GoRouter.of(context).pop()),
        ],
      ),
    ),
  );
}

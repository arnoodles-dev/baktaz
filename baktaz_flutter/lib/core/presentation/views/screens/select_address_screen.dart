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
          const BaktazText(text: 'Address Selection'),
          Gap.medium(),
          BaktazButton(text: 'Confirm', onPressed: () => GoRouter.of(context).pop()),
        ],
      ),
    ),
  );
}

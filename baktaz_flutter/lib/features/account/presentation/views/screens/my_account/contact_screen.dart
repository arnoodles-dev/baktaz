import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorScheme.surface,
    appBar: BaktazAppBar(
      backgroundColor: context.colorScheme.surface,
      centerTitle: true,
      title: context.i18n.account.contacts_title,
      leading: const BackButton(),
    ),
    body: EmptyPage(title: context.i18n.account.no_contacts, iconPath: Assets.images.emptyContacts.path),
    bottomSheet: BaktazBottomSheet(
      children: <Widget>[
        BaktazButton(
          isExpanded: true,
          text: context.i18n.account.add_contact,
          onPressed: () {
            //TODO: add contact
          },
        ),
      ],
    ),
  );
}

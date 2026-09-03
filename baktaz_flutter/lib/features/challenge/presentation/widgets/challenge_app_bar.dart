import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class ChallengeAppBar extends StatelessWidget {
  const ChallengeAppBar({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Gap.large(),
      Expanded(
        child: BaktazText(text: context.i18n.common.challenge.capitalize(), style: context.textTheme.headlineLarge),
      ),
      const Spacer(),
      BaktazButton(
        text: context.i18n.common.history.capitalize(),
        textStyle: context.textTheme.titleMedium,
        contentPadding: const EdgeInsets.symmetric(vertical: BaktazSpacing.xs, horizontal: BaktazSpacing.md),
        padding: const EdgeInsets.only(right: BaktazSpacing.lg),
        buttonType: ButtonType.tonal,
        icon: BaktazIcon(icon: right(Icons.history), size: BaktazSpacing.lg),
        onPressed: () => const HistoryRoute().go(context),
      ),
    ],
  );
}

import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:baktaz_flutter/features/challenge/presentation/widgets/challenge_app_bar.dart';
import 'package:flutter/material.dart';

class ChallengePage extends StatelessWidget {
  const ChallengePage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: <Widget>[
          const ChallengeAppBar(),
          Expanded(
            child: EmptyPage(
              title: context.i18n.challenge.nothing_happening_now,
              subtitle: context.i18n.common.discover_new,
              iconPath: Assets.images.noActivity.path,
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeChallengeDiscoveryBanner extends StatelessWidget {
  const HomeChallengeDiscoveryBanner({required this.onOpenChallenge, super.key});

  final VoidCallback onOpenChallenge;

  @override
  Widget build(BuildContext context) => BaktazCard(
    body: Padding(
      padding: Paddings.allLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(text: context.i18n.home.active_challenge.take_challenge_title),
          Gap.small(),
          BaktazText(text: context.i18n.home.active_challenge.take_challenge_desc),
          Gap.medium(),
          BaktazButton(text: context.i18n.home.active_challenge.explore_btn, onPressed: onOpenChallenge),
        ],
      ),
    ),
  );
}

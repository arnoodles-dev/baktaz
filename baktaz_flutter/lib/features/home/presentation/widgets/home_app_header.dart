import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: context.colorScheme.surface,
        padding: Paddings.allLarge,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            BaktazText(text: 'Baktaz', style: context.textTheme.headlineSmall),
            Row(
              children: <Widget>[
                IconButton(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                Gap.small(),
                const BaktazAvatar(size: BaktazAvatar.sizeSM),
              ],
            ),
          ],
        ),
      );
}

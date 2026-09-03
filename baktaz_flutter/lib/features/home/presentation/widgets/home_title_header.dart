import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class HomeTitleHeader extends StatelessWidget {
  const HomeTitleHeader({required this.title, this.onSeeAllPressed, super.key});

  final String title;
  final VoidCallback? onSeeAllPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: Paddings.allLarge,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        BaktazText(
          text: title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600) ?? const TextStyle(),
        ),
        if (onSeeAllPressed != null)
          GestureDetector(
            onTap: onSeeAllPressed,
            child: BaktazText(
              text: context.i18n.common.see_all,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}

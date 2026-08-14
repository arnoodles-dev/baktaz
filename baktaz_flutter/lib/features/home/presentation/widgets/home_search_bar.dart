import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      //TODO: Redirect to search page
      //const SearchRoute().push(context);
    },
    child: Container(
      margin: Paddings.horizontalLarge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
        color: context.colorScheme.surfaceContainer,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: Paddings.allMedium,
            child: BaktazIcon(icon: right(Icons.search), color: context.colorScheme.onSurface),
          ),
          Expanded(
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: context.i18n.home.search_hints
                  .map(
                    (String hint) => TyperAnimatedText(
                      hint,
                      textStyle: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: AppFontWeight.light,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

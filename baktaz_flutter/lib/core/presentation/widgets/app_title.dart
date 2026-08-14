import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) => BaktazText(
    text: Constant.appName,
    textAlign: TextAlign.center,
    style: context.textTheme.displayLarge?.copyWith(color: context.colorScheme.primary),
  );
}

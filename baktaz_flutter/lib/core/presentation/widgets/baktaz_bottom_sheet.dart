import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazBottomSheet extends StatelessWidget {
  const BaktazBottomSheet({required this.children, super.key, this.decoration});

  final List<Widget> children;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) => Container(
    decoration:
        decoration ??
        BoxDecoration(color: context.colorScheme.surface, boxShadow: AppTheme.shadowLevel1(context.colorScheme)),
    padding: Paddings.allLarge,
    child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[...children, Gap.large()]),
  );
}

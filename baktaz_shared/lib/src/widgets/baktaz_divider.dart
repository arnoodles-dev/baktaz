import 'package:flutter/material.dart';

/// Divider — DESIGN.md §1.8
///
/// Thin rule between content sections.
class BaktazDivider extends StatelessWidget {
  const BaktazDivider({this.height = 1, this.padding, super.key});

  final double height;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: height, color: scheme.outlineVariant),
        ),
      ),
    );
  }
}

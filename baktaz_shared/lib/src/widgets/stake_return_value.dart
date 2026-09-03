import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// StakeReturnValue — DESIGN.md §2.6
///
/// Right-aligned monetary return value. Positive gains use primary emerald with a leading "+".
class StakeReturnValue extends StatelessWidget {
  const StakeReturnValue({
    required this.value,
    this.isPositive = false,
    super.key,
  });

  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String displayText = isPositive ? '+$value' : value;
    final Color textColor = isPositive ? scheme.primary : scheme.outline;

    return BaktazText(
      text: displayText,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.right,
    );
  }
}

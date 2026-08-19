import 'package:flutter/material.dart';

/// Toggle (Switch) — DESIGN.md §12.11
///
/// Wrapper around Material Switch with DESIGN.md tokens.
/// Track on: colorPrimary · Track off: colorBorder · Thumb: white
class BaktazToggle extends StatelessWidget {
  const BaktazToggle({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 51,
      height: 31,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: theme.colorScheme.outline,
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) => theme.colorScheme.onPrimary),
      ),
    );
  }
}

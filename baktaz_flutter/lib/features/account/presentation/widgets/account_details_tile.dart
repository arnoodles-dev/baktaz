import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/widgets.dart';

final class AccountDetailsTile extends StatelessWidget {
  const AccountDetailsTile({required this.label, required this.value, this.onValueEmptyText, super.key});

  final String label;
  final String? value;
  final Widget? onValueEmptyText;

  @override
  Widget build(BuildContext context) {
    final String? value = this.value;
    final Widget? onValueEmptyText = this.onValueEmptyText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        BaktazText(
          text: label,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.primary),
        ),
        Gap.x2Small(),
        if (value != null)
          BaktazText(
            text: value,
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: AppFontWeight.medium),
          ),
        if (value == null && onValueEmptyText != null) onValueEmptyText,
      ],
    );
  }
}

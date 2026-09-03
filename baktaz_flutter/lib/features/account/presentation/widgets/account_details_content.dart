import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class AccountDetailsContent extends StatelessWidget {
  const AccountDetailsContent({required this.children, required this.title, super.key, this.onEdit});

  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _AccountDetailsContentHeader(title: title, onEdit: onEdit),
      const BaktazDivider(padding: Paddings.verticalMedium),
      ...children,
    ],
  );
}

class _AccountDetailsContentHeader extends StatelessWidget {
  const _AccountDetailsContentHeader({required this.title, this.onEdit});

  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: BaktazText(
          text: title,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      if (onEdit != null)
        Padding(
          padding: Paddings.rightX2Small,
          child: BaktazIcon(icon: right(Icons.edit), color: context.colorScheme.primary),
        ),
    ],
  );
}

import 'package:flutter/material.dart';

class BaktazErrorScreen extends StatelessWidget {
  const BaktazErrorScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                icon,
                const SizedBox(height: 16),
                Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onRetry, child: Text(retryLabel ?? 'Retry')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

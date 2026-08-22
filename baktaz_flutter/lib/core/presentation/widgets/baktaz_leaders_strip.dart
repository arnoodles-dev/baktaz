import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';

class BaktazLeadersStrip extends StatelessWidget {
  const BaktazLeadersStrip({required this.leaders, super.key});

  final List<String> leaders;

  @override
  Widget build(BuildContext context) {
    if (leaders.isEmpty) return const SizedBox.shrink();

    const List<String> medals = <String>['🥇', '🥈', '🥉'];
    final String formattedText = leaders
        .asMap()
        .entries
        .map((MapEntry<int, String> e) {
          final String medal = e.key < medals.length ? medals[e.key] : '';
          return '$medal ${e.value}';
        })
        .join('   ');

    return Row(
      children: <Widget>[
        BaktazText(
          text: 'Leaders: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: BaktazText(text: formattedText, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

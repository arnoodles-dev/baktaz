import 'package:baktaz_shared/src/theme/app_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

class BaktazDivider extends StatelessWidget {
  const BaktazDivider({
    this.text,
    this.textStyle,
    this.padding,
    super.key,
  });

  final String? text;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final String? text = this.text;
    if (text != null) {
      return Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: Paddings.horizontalMedium,
            child: BaktazText(text: text, style: textStyle),
          ),
          const Expanded(child: Divider()),
        ],
      );
    }
    return Padding(padding: padding ?? EdgeInsets.zero, child: const Divider(height: 1, thickness: 1));
  }
}

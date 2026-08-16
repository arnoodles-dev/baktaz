import 'package:baktaz_shared/src/entity/enum/text_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:styled_text/styled_text.dart';

final class BaktazText extends StatelessWidget {
  const BaktazText({
    required this.text,
    this.style,
    this.textType = TextType.regular,
    this.overflow,
    this.textAlign,
    this.maxLines,
    this.textWidthBasis,
    this.styledTextIcon,
    this.onLinkPressed,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextType textType;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final IconData? styledTextIcon;
  final ValueChanged<String>? onLinkPressed;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = DefaultTextStyle.of(context).style;
    return switch (textType) {
      TextType.regular => Text(
        text,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textAlign: textAlign,
      ),
      TextType.styled => _StyledText(
        text: text,
        style: style ?? defaultTextStyle,
        overflow: overflow,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textAlign: textAlign,
        styledTextIcon: styledTextIcon,
        onLinkPressed: onLinkPressed,
      ),
      TextType.markdown => _MarkdownText(text: text, style: style ?? defaultTextStyle),
      TextType.selectable => SelectableText(
        text,
        style: style,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textAlign: textAlign,
      ),
    };
  }
}

class _StyledText extends StatelessWidget {
  const _StyledText({
    required this.text,
    required this.style,
    this.overflow,
    this.textAlign,
    this.maxLines,
    this.textWidthBasis,
    this.styledTextIcon,
    this.onLinkPressed,
  });

  final String text;
  final TextStyle style;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final IconData? styledTextIcon;
  final ValueChanged<String>? onLinkPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ValueChanged<String>? onLinkPressed = this.onLinkPressed;
    final IconData? styledTextIcon = this.styledTextIcon;
    return StyledText(
      text: text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textWidthBasis: textWidthBasis,
      tags: <String, StyledTextTagBase>{
        'b': StyledTextTag(
          style: style.copyWith(fontWeight: FontWeight.bold, color: style.color),
        ),
        'blueText': StyledTextTag(
          style: style.copyWith(fontWeight: FontWeight.w400, color: theme.colorScheme.primary),
        ),
        'link': StyledTextActionTag(
          style: style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.primary,
            color: theme.colorScheme.primary,
          ),
          (_, Map<String?, String?> attributes) {
            final String? href = attributes['href'];
            if (href != null) {
              if (onLinkPressed != null) {
                onLinkPressed.call(href);
              }
            }
          },
        ),
        if (styledTextIcon != null)
          'icon': StyledTextIconTag(
            styledTextIcon,
            size: style.fontSize ?? theme.textTheme.bodySmall?.fontSize,
            color: theme.colorScheme.primary,
          ),
      },
    );
  }
}

class _MarkdownText extends StatelessWidget {
  const _MarkdownText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Markdown(
    data: text,
    styleSheet: MarkdownStyleSheet(p: style),
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
  );
}

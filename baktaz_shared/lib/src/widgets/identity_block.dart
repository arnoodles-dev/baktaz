import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/theme/baktaz_type.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// IdentityBlock — DESIGN.md §2.8
///
/// Dual-mode block: Brand lockup (BAKTAZ + edition) or Participant identity (Name + metric).
class IdentityBlock extends StatelessWidget {
  const IdentityBlock.brand({
    this.tag = 'EMERALD GREEN EDITION',
    super.key,
  })  : name = null,
        metric = null,
        isBrand = true;

  const IdentityBlock.participant({
    required String this.name,
    required String this.metric,
    super.key,
  })  : tag = null,
        isBrand = false;

  final String? name;
  final String? metric;
  final String? tag;
  final bool isBrand;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (isBrand) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BaktazText(
            text: 'BAKTAZ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: BaktazSpacing.xs2),
          BaktazText(
            text: tag ?? 'EMERALD GREEN EDITION',
            style: BaktazType.subheadingUppercase(scheme.primary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BaktazText(
          text: name ?? '',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: BaktazSpacing.xs2),
        BaktazText(
          text: metric ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

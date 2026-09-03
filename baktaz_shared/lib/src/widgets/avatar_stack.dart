import 'package:baktaz_shared/src/theme/baktaz_radius.dart';
import 'package:baktaz_shared/src/theme/baktaz_spacing.dart';
import 'package:baktaz_shared/src/widgets/baktaz_avatar.dart';
import 'package:baktaz_shared/src/widgets/baktaz_text.dart';
import 'package:flutter/material.dart';

/// AvatarStack — DESIGN.md §2.5
///
/// Stack of overlapping micro avatars (24dp) with trailing count badge pill.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.initialsList,
    required this.countLabel,
    this.imageUrls,
    super.key,
  });

  final List<String> initialsList;
  final List<String?>? imageUrls;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int displayCount = initialsList.take(3).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: (displayCount - 1) * 16.0 + 24,
          height: 24,
          child: Stack(
            children: List<Widget>.generate(displayCount, (int i) {
              final String? url = (imageUrls != null && i < imageUrls!.length) ? imageUrls![i] : null;
              return Positioned(
                left: i * 16.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 1.5),
                  ),
                  child: BaktazAvatar(
                    size: 24,
                    initials: url == null ? initialsList[i] : null,
                    imageUrl: url,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: BaktazSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: BaktazSpacing.xs, vertical: BaktazSpacing.xs2),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BaktazRadius.pill,
          ),
          child: BaktazText(
            text: countLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

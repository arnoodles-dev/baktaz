import 'package:baktaz_flutter/features/home/presentation/widgets/home_title_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeFeaturedContent extends StatelessWidget {
  const HomeFeaturedContent({
    required this.itemBuilder,
    required this.title,
    required this.isLoading,
    required this.itemCount,
    required this.height,
    super.key,
    this.onSeeAllPressed,
  });

  final Widget Function(BuildContext, int) itemBuilder;
  final String title;
  final int itemCount;
  final VoidCallback? onSeeAllPressed;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: RepaintBoundary(
      child: Column(
        children: <Widget>[
          HomeTitleHeader(title: title, onSeeAllPressed: onSeeAllPressed),
          Expanded(
            child: Padding(
              padding: Paddings.verticalMedium,
              child: Skeletonizer(
                enabled: isLoading,
                child: RepaintBoundary(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: itemBuilder,
                    itemCount: itemCount,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

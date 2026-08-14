import 'package:baktaz_flutter/core/presentation/widgets/wrappers/controller_hook.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeCarousel extends HookWidget {
  const HomeCarousel({required this.itemsCount, required this.itemBuilder, this.height = 200, super.key});

  final int itemsCount;
  final double height;
  final Widget Function(BuildContext, int, int)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final CarouselSliderController carouselController = useController<CarouselSliderController>(
      controller: CarouselSliderController(),
    );
    final ValueNotifier<int> currentCarouselIndex = useState(0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          CarouselSlider.builder(
            carouselController: carouselController,
            itemCount: itemsCount,
            itemBuilder: itemBuilder,
            options: CarouselOptions(
              height: height,
              autoPlay: true,
              viewportFraction: 1,
              onPageChanged: (int index, _) {
                currentCarouselIndex.value = index;
              },
            ),
          ),
          Positioned(
            bottom: AppSizes.small,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: currentCarouselIndex.value,
                count: itemsCount,
                effect: ExpandingDotsEffect(
                  dotWidth: AppSizes.xSmall,
                  dotHeight: AppSizes.xSmall,
                  activeDotColor: context.colorScheme.onPrimary,
                  dotColor: context.colorScheme.onPrimary.withValues(alpha: 0.5),
                ),
                onDotClicked: (int index) {
                  carouselController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

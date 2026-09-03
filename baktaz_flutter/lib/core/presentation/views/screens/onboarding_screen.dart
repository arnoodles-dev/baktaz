import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  static const int totalPages = 3;
  static final Faker faker = Faker();

  //TODO: delete this once  onboarding title/subtitle is finalize
  static final String title1 = faker.lorem.words(3).join(' ');
  static final String title2 = faker.lorem.words(3).join(' ');
  static final String title3 = faker.lorem.words(3).join(' ');
  static final String body1 = faker.lorem.sentences(2).join(' ');
  static final String body2 = faker.lorem.sentences(2).join(' ');
  static final String body3 = faker.lorem.sentences(2).join(' ');

  String _getTitle(int index) => switch (index) {
    0 => title1,
    1 => title2,
    2 => title3,
    _ => '',
  };

  String _getBody(int index) => switch (index) {
    0 => body1,
    1 => body2,
    2 => body3,
    _ => '',
  };

  //TODO: finalize onboarding page images
  String _getImagePath(int index) => switch (index) {
    0 => Assets.images.onboardingTravel.path,
    1 => Assets.images.onboardingDeliver.path,
    2 => Assets.images.onboardingEarn.path,
    _ => '',
  };

  void _onNext(PageController pageController, int index) =>
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);

  Future<void> _onDone(BuildContext context) async {
    await context.read<AppCoreCubit>().setOnboardingDone();
    if (context.mounted) {
      const LoginRoute().go(context);
    }
  }

  void _onSkip(PageController pageController) =>
      pageController.animateToPage(totalPages - 1, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = usePageController();
    final ValueNotifier<int> index = useState<int>(0);
    const double indicatorSize = BaktazSpacing.xs;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              itemCount: totalPages,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) =>
                  _OnBoardingPage(imagePath: _getImagePath(index), title: _getTitle(index), body: _getBody(index)),
              onPageChanged: (int value) => index.value = value,
            ),
          ),
          Gap.large(),
          SmoothPageIndicator(
            controller: pageController,
            count: totalPages,
            effect: ExpandingDotsEffect(
              dotWidth: indicatorSize,
              dotHeight: indicatorSize,
              activeDotColor: context.colorScheme.primary,
            ),
          ),
          Gap.large(),
          _OnBoardingFooter(
            index: index,
            onDone: () => _onDone(context),
            onNext: () => _onNext(pageController, index.value + 1),
            onSkip: () => _onSkip(pageController),
          ),
        ],
      ),
    );
  }
}

class _OnBoardingFooter extends StatelessWidget {
  const _OnBoardingFooter({required this.index, required this.onDone, required this.onNext, required this.onSkip});

  final ValueNotifier<int> index;
  final VoidCallback onDone;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = index.value >= OnboardingScreen.totalPages - 1;

    return Padding(
      padding: Paddings.allLarge,
      child: Column(
        children: <Widget>[
          BaktazButton(
            padding: EdgeInsets.zero,
            text: isLastPage ? context.i18n.onboarding.button.get_started : context.i18n.common.next.capitalize(),
            isExpanded: true,
            onPressed: () => isLastPage ? onDone() : onNext(),
          ),
          Gap.large(),
          if (!isLastPage) ...<Widget>[
            BaktazButton(
              text: context.i18n.common.skip.capitalize(),
              isExpanded: true,
              buttonType: ButtonType.text,
              onPressed: onSkip,
              contentPadding: Paddings.allXSmall,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}

class _OnBoardingPage extends StatelessWidget {
  const _OnBoardingPage({required this.imagePath, required this.title, required this.body});

  final String imagePath;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    const double widthFactor = 0.8; // 80% of screen width

    return Padding(
      padding: Paddings.horizontalLarge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BaktazIcon(
            icon: left(imagePath),
            size: context.screenWidth * widthFactor,
            child: Column(
              children: <Widget>[
                Gap.x2Large(),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: BaktazText(
                    text: title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.displayMedium?.copyWith(color: context.colorScheme.primary),
                  ),
                ),
                Gap.large(),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: BaktazText(
                    text: body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

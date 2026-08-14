import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.directions_walk_rounded,
      title: 'Turn Steps Into Real Rewards',
      description:
          'Join stake-backed step challenges, reach your daily goals, and split prize pools with fellow walkers.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Compete & Connect',
      description:
          'Climb live step leaderboards, participate in challenge group chats, and build active habits together.',
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'Fair & Verified',
      description: 'Automated step sync via Apple Health & Health Connect with multi-layered anti-cheat verification.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.large),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Skip', style: AppTextStyle.labelLarge.copyWith(color: AppColors.colorPrimary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _OnboardingPage page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSizes.x2Large),
                          decoration: const BoxDecoration(color: AppColors.colorPrimarySubtle, shape: BoxShape.circle),
                          child: Icon(page.icon, size: 72, color: AppColors.colorPrimary),
                        ),
                        const Gap(AppSizes.x2Large),
                        Text(
                          page.title,
                          style: AppTextStyle.displayMedium.copyWith(color: theme.colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(AppSizes.medium),
                        Text(
                          page.description,
                          style: AppTextStyle.bodyLarge.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _pages.length,
                  (int index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.colorPrimary : AppColors.colorBorder,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ),
              const Gap(AppSizes.x2Large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: ThemeConstants.animationNormal,
                        curve: ThemeConstants.easeInOut,
                      );
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

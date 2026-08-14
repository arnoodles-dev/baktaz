import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/core/domain/entity/enum/select_address_entry.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_app_bar.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_carousel.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_featured_content.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_search_bar.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_services_grid.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_title_header.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  void _hidableListener(ScrollController scrollController, HidableCubit hidableCubit) {
    switch (scrollController.position.userScrollDirection) {
      case ScrollDirection.forward:
        hidableCubit.setVisibility(isVisible: true);
      case ScrollDirection.reverse:
        hidableCubit.setVisibility(isVisible: false);
      case ScrollDirection.idle:
        break;
    }
  }

  void _onSideEffect(BuildContext context, HomeStateSideEffect sideEffect) {
    switch (sideEffect) {
      case HomeStateException(:final Exception exception):
        getIt<FailureHandler>().handleException(exception, null);
      case HomeStateInitializeAddress():
        const SelectAddressRoute($extra: SelectAddressEntry.home).push<void>(context);
    }
  }

  void _changeAddress(BuildContext context) {
    const SelectAddressRoute($extra: SelectAddressEntry.home).push<void>(context);
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = useScrollController();

    useEffect(() {
      final HidableCubit hidableCubit = context.read<HidableCubit>();
      void listener() => _hidableListener(scrollController, hidableCubit);
      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, <Object?>[scrollController]);

    return BlocPresentationListener<HomeCubit, HomeStateSideEffect>(
      listener: _onSideEffect,
      child: Scaffold(
        body: RepaintBoundary(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (BuildContext context, HomeState state) => RepaintBoundary(
              child: Scaffold(
                body: NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverAppBar.large(
                        scrolledUnderElevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          background: HomeAppBar(
                            isLoading: state.queryStatus.isLoading,
                            onChangeAddress: () => _changeAddress(context),
                            name: state.profile?.fullName.getValue() ?? context.i18n.home.loading,
                            profileImage: state.profile?.imageUrl?.getValue(),
                            greeting: context.i18n.home.greeting,
                          ),
                          expandedTitleScale: 1,
                          title: const HomeSearchBar(),
                        ),
                        forceElevated: innerBoxIsScrolled,
                      ),
                    ),
                  ],
                  body: Builder(
                    builder: (BuildContext context) => CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: <Widget>[
                        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                        _HomeSectionSpecialOffers(state: state),
                        _HomeSectionCarousel(state: state),
                        _HomeSectionServices(state: state),
                        _HomeContentSections(state: state),
                        SliverToBoxAdapter(child: Gap.large()),
                        SliverToBoxAdapter(
                          child: Center(child: BaktazText(text: context.i18n.home.thats_all)),
                        ),
                        SliverToBoxAdapter(child: Gap.medium()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSectionSpecialOffers extends StatelessWidget {
  const _HomeSectionSpecialOffers({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: RepaintBoundary(
      child: Skeletonizer(
        enabled: state.queryStatus.isLoading,
        child: HomeTitleHeader(title: context.i18n.home.special_offers, onSeeAllPressed: () {}),
      ),
    ),
  );
}

class _HomeSectionCarousel extends StatelessWidget {
  const _HomeSectionCarousel({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: RepaintBoundary(
      child: Skeletonizer(
        enabled: state.queryStatus.isLoading,
        child: HomeCarousel(
          itemsCount: 5,
          itemBuilder: (BuildContext context, int index, _) => Container(
            margin: Paddings.horizontalLarge,
            decoration: BoxDecoration(
              color: <Color>[
                context.colorScheme.primary,
                context.colorScheme.secondary,
                context.colorScheme.error,
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ][index],
              borderRadius: AppTheme.cardBorderRadius,
            ),
            child: Center(
              child: BaktazText(
                text: context.i18n.home.special_offer_item(index: index),
                style: context.textTheme.headlineMedium?.copyWith(color: context.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _HomeSectionServices extends StatelessWidget {
  const _HomeSectionServices({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Column(
      children: <Widget>[
        RepaintBoundary(child: HomeTitleHeader(title: context.i18n.home.services)),
        RepaintBoundary(
          child: Skeletonizer(enabled: state.queryStatus.isLoading, child: const HomeServicesGrid()),
        ),
      ],
    ),
  );
}

class _HomeContentSections extends StatelessWidget {
  const _HomeContentSections({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.contentList == null || state.contentList!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: state.contentList!.map((String content) {
        Widget child;
        switch (content) {
          case 'featuredShops':
            child = RepaintBoundary(
              child: HomeFeaturedContent(
                height: 300,
                title: context.i18n.home.shops_you_might_like,
                isLoading: state.queryStatus.isLoading,
                itemCount: (state.homeContent?['featuredShops'] as List<dynamic>?)?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final String item = (state.homeContent?['featuredShops'] as List<dynamic>)[index] as String;
                  return BaktazCard(
                    body: Container(
                      width: 160,
                      height: 100,
                      color: context.colorScheme.primaryContainer,
                      child: Center(
                        child: BaktazText(
                          text: item,
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          case 'featuredPackages':
            child = RepaintBoundary(
              child: HomeFeaturedContent(
                height: 300,
                title: context.i18n.home.packages_for_you,
                onSeeAllPressed: () {},
                isLoading: state.queryStatus.isLoading,
                itemCount: (state.homeContent?['featuredPackages'] as List<dynamic>?)?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final String item = (state.homeContent?['featuredPackages'] as List<dynamic>)[index] as String;
                  return BaktazCard(
                    body: Container(
                      width: 160,
                      height: 100,
                      color: context.colorScheme.secondaryContainer,
                      child: Center(
                        child: BaktazText(
                          text: item,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          case 'featuredHeroes':
            child = RepaintBoundary(
              child: HomeFeaturedContent(
                height: 300,
                title: context.i18n.home.heroes_near_you,
                onSeeAllPressed: () {},
                isLoading: state.queryStatus.isLoading,
                itemCount: (state.homeContent?['featuredHeroes'] as List<dynamic>?)?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final String item = (state.homeContent?['featuredHeroes'] as List<dynamic>)[index] as String;
                  return BaktazCard(
                    body: Container(
                      width: 160,
                      height: 100,
                      color: context.colorScheme.tertiaryContainer,
                      child: Center(
                        child: BaktazText(
                          text: item,
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          case 'carouselAds':
            child = RepaintBoundary(
              child: Skeletonizer(
                enabled: state.queryStatus.isLoading,
                child: Container(
                  padding: Paddings.horizontalLarge,
                  height: 200,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) => Gap.small(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: (state.homeContent?['carouselAds'] as List<dynamic>?)?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) => Container(
                      width: context.screenWidth * 0.35,
                      decoration: BoxDecoration(
                        color: <Color>[
                          context.colorScheme.primaryContainer,
                          context.colorScheme.secondaryContainer,
                          context.colorScheme.tertiaryContainer,
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                        ][index],
                        borderRadius: AppTheme.cardBorderRadius,
                      ),
                      child: Center(
                        child: BaktazText(
                          text: context.i18n.home.ads_item(index: index),
                          style: context.textTheme.headlineMedium?.copyWith(color: context.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          case 'bannerAds':
            child = RepaintBoundary(
              child: Skeletonizer(
                enabled: state.queryStatus.isLoading,
                child: Container(
                  padding: Paddings.allLarge,
                  margin: Paddings.allLarge,
                  height: 100,
                  color: context.colorScheme.primaryContainer,
                  child: Center(child: BaktazText(text: context.i18n.home.banner_ads)),
                ),
              ),
            );
          default:
            child = const SizedBox.shrink();
        }
        return SliverToBoxAdapter(child: child);
      }).toList(),
    );
  }
}

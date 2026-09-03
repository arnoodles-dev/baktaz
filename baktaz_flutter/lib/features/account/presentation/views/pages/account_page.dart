import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/app/utils/app_utils.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/user_rank.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_widget.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_header_card.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/host_subscription_banner.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/lifetime_stats_grid.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountPage extends HookWidget {
  const AccountPage({super.key});

  bool _isLoading(AccountState state) =>
      switch (state.queryStatus) {
        QueryLoading() => true,
        _ => false,
      } ||
      state.accountSummary == null;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = useScrollController();
    final ValueNotifier<double> avatarSize = useState(BaktazAvatar.sizeXL);

    useEffect(() {
      scrollController.addListener(() {
        avatarSize.value = AppUtils.isSliverAppBarExpanded(scrollController)
            ? BaktazAvatar.sizeXL
            : BaktazAvatar.sizeLG;
      });

      return null;
    }, <Object?>[]);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<AccountCubit>().initialize(),
        child: BlocSignalBuilder<AccountCubit, AccountState>(
          builder: (BuildContext context, AccountState state) => CustomScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: context.colorScheme.surface,
                shadowColor: context.colorScheme.shadow,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                expandedHeight: AppTheme.defaultAppBarHeight * 2,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: Paddings.verticalSmall,
                  expandedTitleScale: 1,
                  title: !_isLoading(state)
                      ? _AccountAppBar(
                          isSliverAppBarExpanded: AppUtils.isSliverAppBarExpanded(scrollController),
                          avatarSize: avatarSize.value,
                          fullName: state.accountSummary?.fullName,
                          username: state.accountSummary?.username,
                          memberSince: state.accountSummary?.memberSince,
                          avatarUrl: state.accountSummary?.avatarUrl,
                          rank: state.accountSummary?.rank,
                        )
                      : _AccountAppBar.loading(avatarSize: avatarSize.value),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Gap.medium(),
                    HostSubscriptionBanner(
                      isHostTier: state.accountSummary?.isHostTier ?? false,
                      onUpgrade: () => context.goNamed('host-subscription'),
                      isLoading: _isLoading(state),
                    ),
                    Gap.medium(),
                    LifetimeStatsGrid(
                      isLoading: _isLoading(state),
                      challengeStepsTotal: state.accountSummary?.totalSteps ?? 0,
                      challengesJoined: state.accountSummary?.challengesJoined ?? 0,
                      challengesWon: state.accountSummary?.challengesWon ?? 0,
                      avgStepsPerDay: state.accountSummary?.avgStepsPerDay ?? 0,
                    ),
                    Gap.medium(),
                    BlocSignalSelector<AccountCubit, AccountState, Map<AccountHeader, List<String>>>(
                      selector: (AccountState state) => state.groupedOptions,
                      builder: (BuildContext context, Map<AccountHeader, List<String>> groupedOptions) =>
                          AccountContentWidget(
                            groupedOptions: groupedOptions,
                            isStepsSyncActive: state.isStepsSyncActive,
                            onOptionsTap: (String title) => GoRouter.of(context).goNamed(title),
                          ),
                    ),
                    Gap.x2Large(),
                    Gap.custom(AppTheme.defaultNavBarHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountAppBar extends StatelessWidget {
  const _AccountAppBar({
    required this.fullName,
    required this.username,
    required this.isSliverAppBarExpanded,
    required this.avatarSize,
    this.memberSince,
    this.avatarUrl,
    this.rank,
    this.isLoading = false,
  });

  final String? fullName;
  final String? username;
  final DateTime? memberSince;
  final String? avatarUrl;
  final bool isSliverAppBarExpanded;
  final double avatarSize;
  final bool isLoading;
  final UserRank? rank;

  static Widget loading({required double avatarSize}) => _AccountAppBar(
    isSliverAppBarExpanded: true,
    avatarSize: avatarSize,
    fullName: null,
    username: null,
    isLoading: true,
  );

  @override
  Widget build(BuildContext context) {
    final String? effectiveAvatarUrl = (avatarUrl != null && avatarUrl!.isNotEmpty) ? avatarUrl : null;
    final String? effectiveInitials = effectiveAvatarUrl == null
        ? AccountHeaderCard.initialsFromFullName(fullName)
        : null;

    return Skeletonizer(
      enabled: isLoading,
      child: Row(
        children: <Widget>[
          Gap.medium(),
          BaktazAvatar(size: avatarSize, imageUrl: effectiveAvatarUrl, initials: effectiveInitials),
          Gap.medium(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BaktazText(
                  text: fullName ?? '',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (username case final String effectiveUsername) ...<Widget>[
                  Gap.x2Small(),
                  Row(
                    children: <Widget>[
                      BaktazText(
                        text: '@$effectiveUsername',
                        style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (rank != null) ...<Widget>[
                        Gap.small(),
                        BaktazText(
                          text: rank!.label,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: rank!.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (isSliverAppBarExpanded && memberSince != null) ...<Widget>[
                  Gap.xSmall(),
                  BaktazText(
                    text: context.i18n.account.account_header_card.member_since(date: memberSince!.year.toString()),
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

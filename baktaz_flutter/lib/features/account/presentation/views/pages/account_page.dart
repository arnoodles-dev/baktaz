import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/app/utils/app_utils.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_widget.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/challenge_stats_grid.dart';
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

  /// Derive initials from [fullName] (e.g. 'John Doe' → 'JD').
  /// Returns null if input is empty.
  static String? _initialsFromFullName(String? fullName) {
    final String? trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final List<String> parts = trimmed.split(RegExp(r'\s+'));
    final String first = parts.first[0];
    final String last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = useScrollController();
    final ValueNotifier<double> avatarSize = useState(AppSizes.size80);
    final ValueNotifier<TextStyle?> titleStyle = useState(context.textTheme.headlineMedium);

    useEffect(() {
      scrollController.addListener(() {
        AppUtils.isSliverAppBarExpanded(scrollController)
            ? avatarSize.value = AppSizes.size80
            : avatarSize.value = AppSizes.xLarge;
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
                surfaceTintColor: AppColors.transparent,
                pinned: true,
                expandedHeight: AppTheme.defaultAppBarHeight * 2,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: Paddings.verticalSmall,
                  expandedTitleScale: 1,
                  title: !_isLoading(state)
                      ? _AccountAppBar(
                          isSliverAppBarExpanded: AppUtils.isSliverAppBarExpanded(scrollController),
                          avatarSize: avatarSize.value,
                          titleStyle: titleStyle.value,
                          fullName: state.accountSummary?.fullName,
                          username: state.accountSummary?.username,
                          avatarUrl: state.accountSummary?.avatarUrl,
                        )
                      : _AccountAppBar.loading(avatarSize: avatarSize.value, titleStyle: titleStyle.value),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Gap.medium(),
                    ChallengeStatsGrid(
                      isLoading: _isLoading(state),
                      totalSteps: state.accountSummary?.totalSteps ?? 0,
                      challengesJoined: state.accountSummary?.challengesJoined ?? 0,
                      challengesWon: state.accountSummary?.challengesWon ?? 0,
                      winRatePercentage: state.accountSummary?.winRatePercentage ?? 0.0,
                    ),
                    Gap.large(),
                    BlocSignalSelector<AccountCubit, AccountState, Map<AccountHeader, List<String>>>(
                      selector: (AccountState state) => state.groupedOptions,
                      builder: (BuildContext context, Map<AccountHeader, List<String>> groupedOptions) =>
                          AccountContentWidget(
                            groupedOptions: groupedOptions,
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
    required this.titleStyle,
    this.avatarUrl,
    this.isLoading = false,
  });

  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final bool isSliverAppBarExpanded;
  final double avatarSize;
  final TextStyle? titleStyle;
  final bool isLoading;

  static Widget loading({required double avatarSize, required TextStyle? titleStyle}) => _AccountAppBar(
    isSliverAppBarExpanded: true,
    avatarSize: avatarSize,
    titleStyle: titleStyle,
    fullName: null,
    username: null,
    isLoading: true,
  );

  @override
  Widget build(BuildContext context) {
    final String? effectiveAvatarUrl = (avatarUrl != null && avatarUrl!.isNotEmpty) ? avatarUrl : null;
    final String? effectiveInitials = effectiveAvatarUrl == null ? AccountPage._initialsFromFullName(fullName) : null;

    return Skeletonizer(
      enabled: isLoading,
      child: Row(
        children: <Widget>[
          Gap.medium(),
          BaktazAvatar(
            size: avatarSize,
            imageUrl: effectiveAvatarUrl,
            initials: effectiveInitials,
            maxSize: 80,
          ),
          Gap.xSmall(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BaktazText(
                  text: fullName ?? '',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: AppFontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (username case final String effectiveUsername) ...<Widget>[
                  Gap.x2Small(),
                  BaktazText(
                    text: '@$effectiveUsername',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/app/utils/app_utils.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_widget.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final ValueNotifier<double> avatarSize = useState(AppSizes.size80);
    final ValueNotifier<TextStyle?> titleStyle = useState(context.textTheme.headlineMedium);

    useEffect(() {
      scrollController.addListener(() {
        if (AppUtils.isSliverAppBarExpanded(scrollController)) {
          titleStyle.value = context.textTheme.titleLarge;
          avatarSize.value = AppSizes.size80;
        } else {
          titleStyle.value = context.textTheme.titleLarge;
          avatarSize.value = AppSizes.xLarge;
        }
      });

      return null;
    }, <Object?>[]);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<AccountCubit>().initialize(),
        child: BlocBuilder<AccountCubit, AccountState>(
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
                          imageUrl: state.accountSummary?.imageUrl,
                          name: state.accountSummary?.name.getValue() ?? '',
                        )
                      : _AccountAppBar.loading(avatarSize: avatarSize.value, titleStyle: titleStyle.value),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AccountContentHeader(
                      balance: state.accountSummary?.balance.getValue(),
                      connect: state.accountSummary?.connect.getValue().toInt(),
                      isLoading: _isLoading(state),
                    ),

                    Gap.medium(),
                    BlocSelector<AccountCubit, AccountState, Map<AccountHeader, List<String>>>(
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
    required this.name,
    required this.isSliverAppBarExpanded,
    required this.avatarSize,
    required this.titleStyle,
    required this.imageUrl,
    this.isLoading = false,
  });

  final String name;
  final Url? imageUrl;
  final bool isSliverAppBarExpanded;
  final double avatarSize;
  final TextStyle? titleStyle;
  final bool isLoading;

  static Widget loading({required double avatarSize, required TextStyle? titleStyle}) => _AccountAppBar(
    isSliverAppBarExpanded: true,
    avatarSize: avatarSize,
    titleStyle: titleStyle,
    imageUrl: null,
    name: 'Unknown User',
    isLoading: true,
  );

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: isLoading,
    child: Row(
      children: <Widget>[
        Gap.medium(),
        BaktazAvatar(
          size: avatarSize,
          imageUrl: imageUrl?.getValue(),
          isCachedSize: false,
          maxSize: AppSizes.size80.toInt(),
          isLoading: isLoading,
        ),
        Gap.xSmall(),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[BaktazText(text: name, style: titleStyle)],
          ),
        ),
      ],
    ),
  );
}

import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AccountContentHeader extends StatelessWidget {
  const AccountContentHeader({required this.isLoading, required this.balance, required this.connect, super.key});

  final bool isLoading;
  final double? balance;
  final int? connect;

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountCubit, AccountState>(
    builder: (BuildContext context, AccountState state) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: Paddings.horizontalMedium,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.tertiaryContainer,
                    borderRadius: AppTheme.defaultBorderRadius,
                  ),
                  child: Container(
                    padding: Paddings.allMedium,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              BaktazText(
                                text: 'VIP',
                                style: context.textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.extraBold),
                              ),
                              Gap.x2Small(),
                              BaktazText(
                                text: Faker().lorem.words(15).join(' '),
                                maxLines: 2,
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Gap.x2Small(),
                        BaktazIcon(icon: right(Icons.chevron_right)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap.medium(),
        Padding(
          padding: Paddings.horizontalMedium,
          child: Skeletonizer(
            enabled: isLoading,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _AccountHeaderCard(
                    title: 'Balance',
                    icon: right(Icons.wallet),
                    value: 'Php ${MoneyFormatter.formatWithoutSymbol(balance ?? 0)}',
                  ),
                ),
                Gap.medium(),
                Expanded(
                  child: _AccountHeaderCard(
                    title: 'Connects',
                    icon: right(Icons.electric_bolt),
                    value: '${connect ?? 0}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _AccountHeaderCard extends StatelessWidget {
  const _AccountHeaderCard({required this.title, required this.icon, required this.value});

  final String title;
  final Either<String, IconData> icon;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: context.colorScheme.surfaceContainer, borderRadius: AppTheme.defaultBorderRadius),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.small, horizontal: AppSizes.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BaktazText(
                  text: title,
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),
                ),
                Gap.x2Small(),
                BaktazText(
                  text: value,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(AppSizes.x2Small, AppSizes.x2Small),
            child: BaktazIcon(icon: icon, size: AppSizes.xLarge, color: context.colorScheme.primary),
          ),
        ],
      ),
    ),
  );
}

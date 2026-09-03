import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// HostSubscriptionBanner — DESIGN.md §2.1
///
/// Full-width card showing host tier status with upgrade/manage button.
class HostSubscriptionBanner extends StatelessWidget {
  const HostSubscriptionBanner({
    required this.isHostTier,
    required this.onUpgrade,
    this.isLoading = false,
    super.key,
  });

  final bool isHostTier;
  final VoidCallback onUpgrade;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Skeletonizer(
        enabled: isLoading,
        child: Padding(
          padding: Paddings.screenMarginH,
          child: BaktazCard(
            body: Padding(
              padding: Paddings.allMedium,
              child: Row(
                children: <Widget>[
                  BaktazIcon(
                    icon: right(Icons.workspace_premium),
                    color: isHostTier ? context.baktazColors.successOnContainer : context.colorScheme.primary,
                    size: BaktazSpacing.iconMedium,
                  ),
                  Gap.medium(),
                  Expanded(
                    child: BaktazText(
                      text: isHostTier
                          ? context.i18n.account.host_subscription_banner.premium_host
                          : context.i18n.account.host_subscription_banner.regular_user,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  BaktazButton(
                    text: isHostTier
                        ? context.i18n.account.host_subscription_banner.manage_subscription
                        : context.i18n.account.host_subscription_banner.upgrade_host,
                    onPressed: onUpgrade,
                    buttonType: ButtonType.outlined,
                    isEnabled: !isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

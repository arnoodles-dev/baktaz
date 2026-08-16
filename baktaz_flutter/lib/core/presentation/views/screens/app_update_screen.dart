import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/utils/url_launcher_utils.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  void _onUpdateNow(BuildContext context) {
    final String? storeLink = context.read<RemoteConfigCubit>().storeLink;
    if (storeLink?.isNotEmpty ?? false) {
      UrlLauncherUtils.openBrowser(storeLink!);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double widthFactor = 0.8; // 80% of screen width
    const int logoSize = 200;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: Paddings.allLarge,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                //TODO: change to app logo
                Image.asset(
                  Assets.icons.launcherIcon.path,
                  fit: BoxFit.contain,
                  width: logoSize.toDouble(),
                  height: logoSize.toDouble(),
                  cacheHeight: logoSize,
                  cacheWidth: logoSize,
                ),
                Gap.xLarge(),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: BaktazText(
                    text: context.i18n.app_update.label.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                ),
                Gap.large(),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: BaktazText(
                    text: context.i18n.app_update.label.subtitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.secondary),
                  ),
                ),
                const Spacer(),
                BaktazButton(
                  isExpanded: true,
                  text: context.i18n.app_update.button.update_now,
                  onPressed: () => _onUpdateNow(context),
                ),
                Gap.x3Large(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

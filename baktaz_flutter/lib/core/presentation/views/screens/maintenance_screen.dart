import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/app/utils/app_utils.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double widthFactor = 0.8; // 80% of screen width

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
                //TODO: finalize image
                BaktazIcon(
                  icon: left(Assets.images.maintenance.path),
                  size: context.screenWidth * widthFactor,
                  child: Column(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: widthFactor,
                        child: BaktazText(
                          text: context.i18n.maintenance.label.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium?.copyWith(color: context.colorScheme.primary),
                        ),
                      ),
                      Gap.xLarge(),
                      FractionallySizedBox(
                        widthFactor: widthFactor,
                        child: BaktazText(
                          text: context.i18n.maintenance.label.subtitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                BaktazButton(
                  isExpanded: true,
                  text: context.i18n.common.exit.capitalize(),
                  onPressed: AppUtils.closeApp,
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

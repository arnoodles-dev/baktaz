import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportWebviewScreen extends HookWidget {
  const SupportWebviewScreen({required this.option, super.key});

  final SupportOption option;

  Url? _getUrl(BuildContext context, SupportOption option) {
    final Map<String, dynamic> remoteConfig = context.read<RemoteConfigCubit>().state;
    final String? urlString = remoteConfig[option.configKey] as String?;
    return urlString != null ? Url(urlString) : null;
  }

  @override
  Widget build(BuildContext context) {
    final String? supportUrl = _getUrl(context, option)?.getValue();

    useEffect(() {
      if (supportUrl != null && supportUrl.isNotEmpty) {
        final Uri uri = Uri.parse(supportUrl);
        launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
      return null;
    }, <Object?>[supportUrl]);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: BaktazAppBar(
        title: option.name.camelToSentence(),
        backgroundColor: context.colorScheme.surface,
        leading: CloseButton(color: context.colorScheme.onSurface, onPressed: () => GoRouter.of(context).pop()),
      ),
      body: Center(
        child: supportUrl != null && supportUrl.isNotEmpty
            ? Padding(
                padding: Paddings.allLarge,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BaktazButton(
                      isExpanded: true,
                      text: 'Open in Browser',
                      onPressed: () {
                        final Uri uri = Uri.parse(supportUrl);
                        launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      },
                    ),
                  ],
                ),
              )
            : EmptyPage(
                title: 'Page not found',
                subtitle: 'We are sorry but the page you are looking for cannot be found.',
                iconPath: Assets.images.pageNotFound.path,
              ),
      ),
    );
  }
}

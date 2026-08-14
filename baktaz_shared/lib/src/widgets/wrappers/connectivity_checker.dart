import 'dart:async';

import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:toastification/toastification.dart';

final class ConnectivityChecker extends HookWidget {
  const ConnectivityChecker({
    required this.child,
    required this.offlineMessage,
    this.onOfflineShowed,
    this.onOfflineDismissed,
    super.key,
  });

  final Widget child;
  final String offlineMessage;
  final VoidCallback? onOfflineShowed;
  final VoidCallback? onOfflineDismissed;

  static Widget scaffold({
    required Widget body,
    required String offlineMessage,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    bool isUnfocusable = false,
    bool extendBody = false,
  }) => ConnectivityChecker(
    offlineMessage: offlineMessage,
    child: isUnfocusable
        ? UnfocusableScaffold(
            body: body,
            appBar: appBar,
            extendBody: extendBody,
            backgroundColor: backgroundColor,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
          )
        : Scaffold(
            body: body,
            appBar: appBar,
            extendBody: extendBody,
            backgroundColor: backgroundColor,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
          ),
  );

  Future<ToastificationItem> _showOfflineDialog(BuildContext context) async => toastification.show(
    title: BaktazText(text: offlineMessage, overflow: TextOverflow.ellipsis, maxLines: 3),
    icon: Padding(
      padding: const EdgeInsets.only(left: AppSizes.small, right: AppSizes.xSmall),
      child: BaktazIcon(icon: fpdart.right(Icons.wifi_off)),
    ),
    style: ToastificationStyle.flatColored,
    type: ToastificationType.custom('app_error', Theme.of(context).colorScheme.error, Icons.error_outline),
    closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    dismissDirection: DismissDirection.none,
  );

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<ToastificationItem?> toastificationItem = useState<ToastificationItem?>(null);
    final ObjectRef<VoidCallback?> onOfflineShowedRef = useRef<VoidCallback?>(onOfflineShowed)..value = onOfflineShowed;
    final ObjectRef<VoidCallback?> onOfflineDismissedRef = useRef<VoidCallback?>(onOfflineDismissed)
      ..value = onOfflineDismissed;

    useEffect(() {
      final ConnectivityUtils connectivityUtils = ConnectivityUtils.instance;
      Future<void> onStatusChanged(ConnectionStatus connectionStatus) async {
        if (!context.mounted) return;
        switch (connectionStatus) {
          case ConnectionStatus.offline:
            if (toastificationItem.value?.isRunning ?? false) return;
            toastificationItem.value ??= await _showOfflineDialog(context);
            onOfflineShowedRef.value?.call();
          case ConnectionStatus.online:
            if (toastificationItem.value != null) {
              toastification.dismiss(toastificationItem.value!);
              toastificationItem.value = null;
              onOfflineDismissedRef.value?.call();
            }
        }
      }

      final StreamSubscription<ConnectionStatus> subscription = connectivityUtils.internetStatus.listen(
        onStatusChanged,
      );
      return subscription.cancel;
    }, const <Object?>[]);

    return child;
  }
}

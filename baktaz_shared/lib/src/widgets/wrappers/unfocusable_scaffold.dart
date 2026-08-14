import 'package:flutter/material.dart';

class UnfocusableScaffold extends StatelessWidget {
  const UnfocusableScaffold({
    super.key,
    this.onTap,
    this.scaffoldKey,
    this.backgroundColor,
    this.extendBody,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.bottomSheet,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final VoidCallback? onTap;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Color? backgroundColor;
  final bool? extendBody;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap ?? () => FocusManager.instance.primaryFocus?.unfocus(),
    child: Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      extendBody: extendBody ?? false,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    ),
  );
}

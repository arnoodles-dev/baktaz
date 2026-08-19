import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({required this.router, required this.child, super.key});

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) => InheritedGoRouter(goRouter: router, child: child);
}

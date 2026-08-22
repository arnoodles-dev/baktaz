// ignore_for_file: prefer-match-file-name

import 'package:baktaz_server/src/web/widgets/built_with_serverpod_page.dart';
import 'package:serverpod/serverpod.dart';

// ignore: matching_declared_name
class RootRoute extends WidgetRoute {
  @override
  Future<TemplateWidget> build(Session session, Request request) async => BuiltWithServerpodPage();
}

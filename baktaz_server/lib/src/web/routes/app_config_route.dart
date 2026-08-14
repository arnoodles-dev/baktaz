import 'package:serverpod/serverpod.dart';

class AppConfigRoute extends WidgetRoute {
  AppConfigRoute({required ServerConfig apiConfig}) : widget = AppConfigWidget(apiUrl: apiConfig.apiUrl.toString());
  AppConfigWidget widget;

  @override
  Future<WebWidget> build(Session session, Request request) async => widget;
}

class AppConfigWidget extends JsonWidget {
  AppConfigWidget({required this.apiUrl}) : super(object: <String, String>{'apiUrl': apiUrl});
  final String apiUrl;
}

extension on ServerConfig {
  Uri get apiUrl => Uri(scheme: publicScheme, host: publicHost, port: publicPort);
}

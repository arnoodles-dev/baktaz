import 'package:serverpod/serverpod.dart';

abstract class AdminEndpointBase extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => <Scope>{Scope.admin};
}

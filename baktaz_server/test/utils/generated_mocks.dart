import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/service/i_email_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/cache/caches.dart';
import 'package:serverpod/src/cache/local_cache.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IAdminRepository>(),
  MockSpec<IEmailService>(),
  MockSpec<http.Client>(),
  MockSpec<Session>(),
  MockSpec<Caches>(),
  MockSpec<LocalCache>(),
])
void main() {}

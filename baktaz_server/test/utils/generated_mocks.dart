// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<IAdminRepository>(), MockSpec<http.Client>()])
void main() {}

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<BaseCacheManager>(), MockSpec<http.Client>()])
void main() {}

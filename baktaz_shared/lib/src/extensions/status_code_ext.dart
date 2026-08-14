import 'package:baktaz_shared/src/entity/enum/status_code.dart';

extension StatusCodeExt on StatusCode {
  bool get isSuccess => value == 200 || value == 201 || value == 204;
}

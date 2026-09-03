import 'package:characters/characters.dart';

abstract final class UsernameUtils {
  static String sanitizeUsername(String input) {
    final String clean = input.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9_.]'), '');
    return clean.isEmpty ? 'user' : clean;
  }

  static String generateUniqueHandle(String? name, String email) {
    final String baseSource = (name != null && name.trim().isNotEmpty) ? name : email.split('@').first;
    String clean = sanitizeUsername(baseSource);
    clean = clean.replaceAll(RegExp(r'^[^a-z0-9]+|[^a-z0-9]+$'), '');
    if (clean.length < 3) {
      clean = clean.isEmpty ? 'user' : '${clean}user'.characters.take(3).toString();
    }
    if (clean.length > 30) {
      clean = clean.characters.take(30).toString().replaceAll(RegExp(r'[^a-z0-9]+$'), '');
      if (clean.length < 3) {
        clean = 'user';
      }
    }
    return clean;
  }
}

import 'package:flutter/material.dart';

extension StringExt on String {
  bool get toBoolean => switch (toLowerCase()) {
    'true' => true,
    'false' => false,
    _ => throw UnimplementedError(),
  };

  String camelToSentence() {
    final String result = replaceAll(RegExp('(?<!^)(?=[A-Z])'), ' ');
    return result[0].toUpperCase() + result.characters.getRange(1).toString();
  }
}

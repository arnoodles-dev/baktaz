import 'dart:io';

/// Filters `coverage/lcov.info` for a given package according to `.coverage_exclude`.
void main(List<String> args) {
  final targetPath = args.isNotEmpty ? args[0] : Directory.current.path;
  final pkgDir = Directory(targetPath).absolute;

  final excludeFile = File('${pkgDir.path}/.coverage_exclude');
  final lcovFile = File('${pkgDir.path}/coverage/lcov.info');

  if (!excludeFile.existsSync()) {
    stdout.writeln('No .coverage_exclude found at ${excludeFile.path}. Skipping coverage filtering.');
    return;
  }

  if (!lcovFile.existsSync()) {
    stdout.writeln('No coverage/lcov.info found at ${lcovFile.path}. Skipping coverage filtering.');
    return;
  }

  final patterns = parseExcludePatterns(excludeFile);
  if (patterns.isEmpty) {
    stdout.writeln('.coverage_exclude is empty. Skipping filtering.');
    return;
  }

  final matchers = patterns.map(globToRegExp).toList();
  final content = lcovFile.readAsStringSync();
  final records = parseLcovRecords(content);

  if (records.isEmpty) {
    stdout.writeln('coverage/lcov.info has no records to filter.');
    return;
  }

  final pkgNormalizedPath = pkgDir.path.replaceAll(r'\', '/');
  var removedCount = 0;
  final keptRecords = <String>[];

  for (final record in records) {
    final sfPath = extractSfPath(record);
    if (sfPath == null) {
      keptRecords.add(record);
      continue;
    }

    final normalizedSf = sfPath.replaceAll(r'\', '/');
    final relativeSf = computeRelativePath(normalizedSf, pkgNormalizedPath);

    final isExcluded = matchers.any(
      (matcher) => matcher.hasMatch(normalizedSf) || matcher.hasMatch(relativeSf),
    );

    if (isExcluded) {
      removedCount++;
    } else {
      keptRecords.add(record);
    }
  }

  final outputContent = keptRecords.isEmpty ? '' : '${keptRecords.join('\n')}\n';
  lcovFile.writeAsStringSync(outputContent);
  stdout.writeln(
    'Filtered ${lcovFile.path}: removed $removedCount records, kept ${keptRecords.length} records.',
  );
}

/// Parses lines from `.coverage_exclude`, ignoring empty lines and comments (`#`).
List<String> parseExcludePatterns(File file) {
  return file
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toList();
}

/// Converts a glob pattern into a robust RegExp matcher.
RegExp globToRegExp(String glob) {
  var p = glob.trim().replaceAll(r'\', '/');
  if (p.startsWith('./')) {
    p = p.substring(2);
  }

  final buf = StringBuffer();
  buf.write('^');

  if (p.startsWith('**/')) {
    buf.write('(?:.*/)?');
    p = p.substring(3);
  } else if (!p.startsWith('*') && !p.startsWith('/')) {
    buf.write('(?:.*/)?');
  } else if (p.startsWith('/')) {
    p = p.substring(1);
  }

  for (var i = 0; i < p.length; i++) {
    final c = p[i];
    if (c == '*') {
      if (i + 1 < p.length && p[i + 1] == '*') {
        i++;
        if (i + 1 < p.length && p[i + 1] == '/') {
          i++;
          buf.write('(?:.*/)?');
        } else {
          buf.write('.*');
        }
      } else {
        buf.write('.*');
      }
    } else if (c == '?') {
      buf.write('[^/]');
    } else if (r'.+()[]{}^$|\'.contains(c)) {
      buf.write(r'\');
      buf.write(c);
    } else {
      buf.write(c);
    }
  }

  buf.write(r'$');
  return RegExp(buf.toString(), caseSensitive: false);
}

/// Parses `coverage/lcov.info` content into list of individual records (`SF:` through `end_of_record`).
List<String> parseLcovRecords(String content) {
  final lines = content.split('\n');
  final records = <String>[];
  var currentRecord = <String>[];

  for (final line in lines) {
    if (line.trim().isEmpty && currentRecord.isEmpty) {
      continue;
    }
    currentRecord.add(line);
    if (line.trim() == 'end_of_record') {
      records.add(currentRecord.join('\n'));
      currentRecord = [];
    }
  }

  if (currentRecord.isNotEmpty && currentRecord.any((l) => l.trim().isNotEmpty)) {
    records.add(currentRecord.join('\n'));
  }

  return records;
}

/// Extracts source file path (`SF:`) from an lcov record.
String? extractSfPath(String record) {
  for (final line in record.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.startsWith('SF:')) {
      return trimmed.substring(3).trim();
    }
  }
  return null;
}

/// Computes a relative path if [sfPath] starts with [pkgPath].
String computeRelativePath(String sfPath, String pkgPath) {
  if (sfPath.startsWith('$pkgPath/')) {
    return sfPath.substring(pkgPath.length + 1);
  }
  final libIndex = sfPath.indexOf('/lib/');
  if (libIndex != -1) {
    return sfPath.substring(libIndex + 1);
  }
  return sfPath;
}

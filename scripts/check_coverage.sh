#!/bin/bash
# Filters coverage/lcov.info using .coverage_exclude and checks threshold.
# Usage: check_coverage.sh [threshold=80]
# Runs from the package root directory.

set -e

THRESHOLD="${1:-80}"
LCOV_FILE="coverage/lcov.info"
EXCLUDE_FILE=".coverage_exclude"

PKG_CONFIG=".dart_tool/package_config.json"
if [ ! -f "$PKG_CONFIG" ] && [ -f "../.dart_tool/package_config.json" ]; then
  PKG_CONFIG="../.dart_tool/package_config.json"
fi

if [ ! -f "$LCOV_FILE" ]; then
  if [ -d "coverage" ]; then
    echo "coverage/lcov.info not found, but coverage/ directory exists. Generating lcov.info..."
    dart pub global activate coverage >/dev/null
    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages="$PKG_CONFIG" --report-on=lib
  else
    exit 0
  fi
fi

if [ -f "$EXCLUDE_FILE" ]; then
  PATTERNS=""
  while IFS= read -r line || [ -n "$line" ]; do
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$stripped" ] || [ "${stripped#\#}" != "$stripped" ] && continue
    PATTERNS="$PATTERNS '$stripped'"
  done < "$EXCLUDE_FILE"

  if [ -n "$PATTERNS" ]; then
    eval lcov --ignore-errors unused --remove "$LCOV_FILE" $PATTERNS -o "$LCOV_FILE" 2>/dev/null || true
  fi
fi

awk -F: -v threshold="$THRESHOLD" '
  /^LF:/ { lf += $2 }
  /^LH:/ { lh += $2 }
  END {
    if (lf == 0) exit 0
    pct = lh * 100 / lf
    printf "Coverage: %.1f%% (%d/%d)\n", pct, lh, lf
    if (pct < threshold) {
      printf "FAIL: Coverage %.1f%% < %d%% threshold\n", pct, threshold
      exit 1
    }
    printf "OK: Coverage %.1f%% >= %d%% threshold\n", pct, threshold
  }
' "$LCOV_FILE"

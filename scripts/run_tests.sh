#!/bin/bash
set -e

THRESHOLD=80
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Dynamically discover packages from melos workspace
PACKAGES=()
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  # Extract workspace packages from pubspec.yaml
  while IFS= read -r line; do
    # Match lines like "  - package_name" in workspace section
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
      pkg="${BASH_REMATCH[1]}"
      if [ -d "$ROOT_DIR/$pkg" ]; then
        PACKAGES+=("$pkg")
      fi
    fi
  done < <(awk '/^workspace:/,/^[^[:space:]]/ {print}' "$ROOT_DIR/pubspec.yaml" | grep -E '^  - ')
fi

# Fallback: discover all directories with pubspec.yaml (excluding client)
if [ ${#PACKAGES[@]} -eq 0 ]; then
  while IFS= read -r pkg_dir; do
    pkg_name=$(basename "$pkg_dir")
    if [ "$pkg_name" != "baktaz_client" ]; then
      PACKAGES+=("$pkg_name")
    fi
  done < <(find "$ROOT_DIR" -maxdepth 1 -type d -name "baktaz_*" | sort)
fi

LCOV_MAP=()
for pkg in "${PACKAGES[@]}"; do
  # Map package name to short name for coverage output
  case "$pkg" in
    *flutter*) LCOV_MAP+=("app") ;;
    *admin*) LCOV_MAP+=("admin") ;;
    *shared*) LCOV_MAP+=("shared") ;;
    *server*) LCOV_MAP+=("server") ;;
    *site*) LCOV_MAP+=("site") ;;
    *) LCOV_MAP+=("$pkg") ;;
  esac
done

run_for_package() {
  local pkg="$1"
  local pkg_dir="$ROOT_DIR/$pkg"

  if [ ! -d "$pkg_dir" ]; then
    echo "Error: Package not found: $pkg"
    return 1
  fi

  echo ""
  echo "━━━ $pkg ━━━"

  cd "$pkg_dir"

  # Check if it's a Flutter package (has flutter in pubspec.yaml)
  IS_FLUTTER=false
  if grep -q "flutter:" pubspec.yaml 2>/dev/null; then
    IS_FLUTTER=true
  fi

  # Run tests
  if [ "$IS_FLUTTER" = true ]; then
    fvm flutter test --coverage --no-pub 2>&1 | tail -20
  else
    fvm dart test --concurrency=1 2>&1 | tail -20
  fi

  # Generate lcov.info if coverage directory exists
  if [ -d "coverage" ]; then
    PKG_CONFIG=".dart_tool/package_config.json"
    if [ ! -f "$PKG_CONFIG" ] && [ -f "../.dart_tool/package_config.json" ]; then
      PKG_CONFIG="../.dart_tool/package_config.json"
    fi

    if [ "$IS_FLUTTER" = true ]; then
      if [ ! -f "coverage/lcov.info" ]; then
        fvm dart pub global activate coverage >/dev/null 2>&1
        fvm dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages="$PKG_CONFIG" --report-on=lib
      fi
    else
      fvm dart pub global activate coverage >/dev/null 2>&1
      fvm dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages="$PKG_CONFIG"
    fi
  fi
}

generate_lcov() {
  local pkg="$1"
  local pkg_dir="$ROOT_DIR/$pkg"

  if [ ! -d "$pkg_dir" ]; then
    return 1
  fi

  cd "$pkg_dir"

  # Check if it's a Flutter package
  IS_FLUTTER=false
  if grep -q "flutter:" pubspec.yaml 2>/dev/null; then
    IS_FLUTTER=true
  fi

  if [ ! -d "coverage" ] || [ ! -f "coverage/lcov.info" ]; then
    return 0
  fi

  # Apply exclude patterns via filter_coverage.dart
  if [ -f ".coverage_exclude" ]; then
    fvm dart "$SCRIPT_DIR/filter_coverage.dart" "$pkg_dir"
  fi

  # Special handling for server: extract only endpoints/services
  if [[ "$pkg" == *server* ]] && [ "$IS_FLUTTER" = false ]; then
    lcov --ignore-errors unused --extract coverage/lcov.info '*/endpoints/*' '*/services/*' -o coverage/lcov.info 2>/dev/null || true
  fi

  # Generate HTML report
  if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LCOV_CMD="lcov"
    GENHTML_CMD="genhtml"
    OPEN_CMD="open"
  else
    LCOV_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\lcov"
    GENHTML_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\genhtml"
    OPEN_CMD="CMD /C start"
  fi

  if [[ "$pkg" == *server* ]] && [ "$IS_FLUTTER" = false ]; then
    $GENHTML_CMD --ignore-errors empty -o coverage/html coverage/lcov.info 2>/dev/null || $GENHTML_CMD -o coverage/html coverage/lcov.info 2>/dev/null || true
    if [ -f "coverage/html/index.html" ]; then
      if command -v open >/dev/null 2>&1; then open coverage/html/index.html;
      elif command -v xdg-open >/dev/null 2>&1; then xdg-open coverage/html/index.html; fi
    fi
  else
    $GENHTML_CMD --ignore-errors empty -o coverage coverage/lcov.info 2>/dev/null || $GENHTML_CMD -o coverage coverage/lcov.info 2>/dev/null || true
    if [ -f "coverage/index.html" ]; then
      if command -v open >/dev/null 2>&1; then open coverage/index.html;
      elif command -v xdg-open >/dev/null 2>&1; then xdg-open coverage/index.html; fi
    fi
  fi
}

print_coverage_summary() {
  echo ""
  echo "━━━ Coverage Summary ━━━"
  for i in "${!PACKAGES[@]}"; do
    pkg="${PACKAGES[$i]}"
    short="${LCOV_MAP[$i]}"
    lcov_file="$ROOT_DIR/$pkg/coverage/lcov.info"

    if [ -f "$lcov_file" ]; then
      awk -F: -v threshold="$THRESHOLD" -v name="$short" '
        /^LF:/ { lf += $2 }
        /^LH:/ { lh += $2 }
        END {
          if (lf == 0) { print name ": No coverage data"; next }
          pct = lh * 100 / lf
          printf "%s: %.1f%% (%d/%d)", name, pct, lh, lf
          if (pct < threshold) {
            printf " FAIL (below %d%%)\n", threshold
          } else {
            printf " OK\n"
          }
        }
      ' "$lcov_file"
    fi
  done
}

run_all_parallel() {
  local pids=()
  local failed=0

  for pkg in "${PACKAGES[@]}"; do
    run_for_package "$pkg" &
    pids+=($!)
  done

  for pid in "${pids[@]}"; do
    wait "$pid" || failed=1
  done

  if [ $failed -ne 0 ]; then
    echo "Some tests failed."
    exit 1
  fi

  # Generate LCOV for all packages
  for pkg in "${PACKAGES[@]}"; do
    generate_lcov "$pkg"
  done

  print_coverage_summary
}

run_single() {
  local pkg="$1"

  if [ "$pkg" = "all" ]; then
    run_all_parallel
  else
    run_for_package "$pkg"
    generate_lcov "$pkg"
  fi
}

# Main
if [ $# -gt 0 ]; then
  run_single "$1"
else
  run_all_parallel
fi

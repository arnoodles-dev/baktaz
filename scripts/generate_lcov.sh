#!/bin/bash
# Reusable script for generating LCOV coverage reports
# Reads per-package coverage exceptions from .coverage_exclude
# Dynamically discovers packages from workspace

set -e

APP=$1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Dynamically discover packages from melos workspace
PACKAGES=()
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
      pkg="${BASH_REMATCH[1]}"
      if [ -d "$ROOT_DIR/$pkg" ]; then
        PACKAGES+=("$pkg")
      fi
    fi
  done < <(awk '/^workspace:/,/^[^[:space:]]/ {print}' "$ROOT_DIR/pubspec.yaml" | grep -E '^  - ')
fi

# Fallback
if [ ${#PACKAGES[@]} -eq 0 ]; then
  while IFS= read -r pkg_dir; do
    pkg_name=$(basename "$pkg_dir")
    if [ "$pkg_name" != "baktaz_client" ]; then
      PACKAGES+=("$pkg_name")
    fi
  done < <(find "$ROOT_DIR" -maxdepth 1 -type d -name "baktaz_*" | sort)
fi

# Find matching package
TARGET_PKG=""
for pkg in "${PACKAGES[@]}"; do
  case "$pkg" in
    *flutter*) [ "$APP" = "app" ] && TARGET_PKG="$pkg" ;;
    *admin*) [ "$APP" = "admin" ] && TARGET_PKG="$pkg" ;;
    *shared*) [ "$APP" = "shared" ] && TARGET_PKG="$pkg" ;;
    *server*) [ "$APP" = "server" ] && TARGET_PKG="$pkg" ;;
    *site*) [ "$APP" = "site" ] && TARGET_PKG="$pkg" ;;
  esac
done

if [ -z "$TARGET_PKG" ]; then
  echo "Usage: $0 <admin|app|server|site|shared>"
  echo "Available packages: ${PACKAGES[*]}"
  exit 1
fi

cd "$ROOT_DIR/$TARGET_PKG"

# Check if it's a Flutter package
IS_FLUTTER=false
if grep -q "flutter:" pubspec.yaml 2>/dev/null; then
  IS_FLUTTER=true
fi

if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
  LCOV_CMD="lcov"
  GENHTML_CMD="genhtml"
  OPEN_CMD="open"
  OUT_DIR="coverage"
else
  LCOV_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\lcov"
  GENHTML_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\genhtml"
  OPEN_CMD="CMD /C start"
  OUT_DIR="coverage"
fi

read_exclude_patterns() {
  local exclude_file="$1"
  [ ! -f "$exclude_file" ] && return
  while IFS= read -r line || [ -n "$line" ]; do
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$stripped" ] || [ "${stripped#\#}" != "$stripped" ] && continue
    printf "'%s' " "$stripped"
  done < "$exclude_file"
}

if [ "$IS_FLUTTER" = true ]; then
  fvm dart "$SCRIPT_DIR/filter_coverage.dart" "$TARGET_PKG"
  $GENHTML_CMD -o coverage coverage/lcov.info
  $OPEN_CMD $OUT_DIR/index.html
else
  # Server package
  $LCOV_CMD --ignore-errors unused --extract coverage/lcov.info '*/endpoints/*' '*/services/*' -o coverage/lcov.info
  fvm dart "$SCRIPT_DIR/filter_coverage.dart" "$TARGET_PKG"
  $GENHTML_CMD -o coverage/html coverage/lcov.info
  $OPEN_CMD coverage/html/index.html
fi

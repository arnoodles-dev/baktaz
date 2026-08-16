#!/bin/bash
# Script to update Serverpod version across the project
# Dynamically discovers packages from melos workspace

set -e

if [ -z "$1" ]; then
  echo "Usage: ./scripts/update_serverpod_version.sh <version>"
  echo "Example: ./scripts/update_serverpod_version.sh 2.0.0"
  exit 1
fi

NEW_VERSION=$1
echo "Updating Serverpod version to $NEW_VERSION..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Dynamically discover packages from melos workspace
PACKAGES=($(discover_packages "$ROOT_DIR"))

# Update serverpod_* dependencies in all packages
for pkg in "${PACKAGES[@]}"; do
  file="$ROOT_DIR/$pkg/pubspec.yaml"
  if [ -f "$file" ]; then
    sed_inplace "s/(serverpod(_[a-zA-Z0-9_]+)?:[[:space:]]*['\"]?[<>=^]*)[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" "$file"
    echo "Updated serverpod_* dependencies in $file"
  else
    echo "Warning: $file not found!"
  fi
done

# Update Makefile serverpod_cli version
if [ -f "$ROOT_DIR/Makefile" ]; then
  sed_inplace "s/(dart pub global activate serverpod_cli )[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" "$ROOT_DIR/Makefile"
  echo "Updated serverpod_cli version in Makefile"
fi

# Update GitHub Actions workflows
if [ -d "$ROOT_DIR/.github/workflows" ]; then
  find "$ROOT_DIR/.github/workflows" -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
    sed_inplace "s/(dart pub global activate serverpod_cli )[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" "$file"
    echo "Updated serverpod_cli version in $file"
  done
fi

echo "Done!"

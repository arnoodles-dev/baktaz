#!/bin/bash
# Script to update Serverpod version across the project

if [ -z "$1" ]; then
  echo "Usage: ./scripts/update_serverpod_version.sh <version>"
  echo "Example: ./scripts/update_serverpod_version.sh 2.0.0"
  exit 1
fi

NEW_VERSION=$1
echo "Updating Serverpod version to $NEW_VERSION..."

# Minimal inline sed_inplace helper to handle macOS vs GNU sed differences
sed_inplace() {
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i -E "$1" "$2"
  else
    sed -i '' -E "$1" "$2"
  fi
}

# Update serverpod_* dependencies ONLY in specific packages
TARGET_DIRS=("paxa_admin" "paxa_client" "paxa_flutter" "paxa_server")

for dir in "${TARGET_DIRS[@]}"; do
  file="${dir}/pubspec.yaml"
  if [ -f "$file" ]; then
    # Fix regex character class for literal caret and operators
    sed_inplace "s/(serverpod(_[a-zA-Z0-9_]+)?:[[:space:]]*['\"]?[<>=^]*)[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" "$file"
    echo "Updated serverpod_* dependencies in $file"
  else
    echo "Warning: $file not found!"
  fi
done

# Update Makefile serverpod_cli version
if [ -f "Makefile" ]; then
  sed_inplace "s/(dart pub global activate serverpod_cli )[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" Makefile
  echo "Updated serverpod_cli version in Makefile"
fi

# Update GitHub Actions workflows
if [ -d ".github/workflows" ]; then
  find .github/workflows -type f \( -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
    sed_inplace "s/(dart pub global activate serverpod_cli )[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?/\1$NEW_VERSION/g" "$file"
    echo "Updated serverpod_cli version in $file"
  done
fi

echo "Done!"

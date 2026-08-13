#!/bin/bash
# filepath: /Users/Arnold/Projects/paxa/update_flutter_version.sh

if [ -z "$1" ]; then
  echo "Usage: $0 <new_flutter_version>"
  exit 1
fi

NEW_VERSION="$1"

source "$(dirname "$0")/common.sh"

# Update flutter: ">={version}" in pubspec.yaml
find . -type f -name "pubspec.yaml" | while read -r file; do
  sed_inplace "s/([[:space:]]*flutter:[[:space:]]*\")>=([0-9]+\.[0-9]+\.[0-9]+)(\")/\1>=$NEW_VERSION\3/" "$file"
  echo "Updated flutter: >=$NEW_VERSION in $file"
done

# Update flutter: ">={version}" in melos.yaml
find . -type f -name "melos.yaml" | while read -r file; do
  sed_inplace "s/([[:space:]]*flutter:[[:space:]]*\")>=([0-9]+\.[0-9]+\.[0-9]+)(\")/\1>=$NEW_VERSION\3/" "$file"
  echo "Updated flutter: >=$NEW_VERSION in $file"
done

# Update flutter: ">={version}" in pubspec.lock
find . -type f -name "pubspec.lock" | while read -r file; do
  sed_inplace "s/([[:space:]]*flutter:[[:space:]]*\")>=([0-9]+\.[0-9]+\.[0-9]+)(\")/\1>=$NEW_VERSION\3/" "$file"
  echo "Updated flutter: >=$NEW_VERSION in $file"
done

# Update flutterSdkVersion in all fvm_config.json files
find . -type f -name "fvm_config.json" | while read -r file; do
  sed_inplace "s/^([[:space:]]*\"flutterSdkVersion\":[[:space:]]*\")[^\"]+(\")/\1$NEW_VERSION\2/" "$file"
  echo "Updated flutterSdkVersion in $file"
done

# Update fvm ... <version> in Makefile(s) and the ensure_flutter_version comment and note
find . -type f -name "Makefile" | while read -r file; do
  # Update fvm commands
  sed_inplace "s/(fvm[[:space:]]+[a-zA-Z0-9_-]*[[:space:]]+)[0-9]+\.[0-9]+\.[0-9]+/\1$NEW_VERSION/g" "$file"
  # Update the comment for ensure_flutter_version
  sed_inplace "s/(## Ensures flutter version is )[0-9]+\.[0-9]+\.[0-9]+/\1$NEW_VERSION/" "$file"
  # Update the ## Note: comment above ensure_flutter_version
  sed_inplace "s/(## Note: If you are using a specific flutter version, change ')[0-9]+\.[0-9]+\.[0-9]+'( to the desired '\{flutter version\}' you want to use)/\1$NEW_VERSION'\2/" "$file"
  echo "Updated fvm version, comment, and note in $file"
done

echo "Flutter version updated to $NEW_VERSION."
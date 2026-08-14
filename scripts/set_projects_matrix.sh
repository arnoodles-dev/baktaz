#!/usr/bin/env bash
set -e

# Dynamically discover packages from melos workspace
FLUTTER_PROJECTS="[]"
DART_PROJECTS="[]"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Extract workspace packages from pubspec.yaml
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

# Categorize packages
for pkg in "${PACKAGES[@]}"; do
  case "$pkg" in
    *flutter*|*admin*|*shared*)
      FLUTTER_PROJECTS=$(echo "$FLUTTER_PROJECTS" | jq -c '. + ["'"$pkg"'"]')
      ;;
    *server*|*site*)
      DART_PROJECTS=$(echo "$DART_PROJECTS" | jq -c '. + ["'"$pkg"'"]')
      ;;
  esac
done

ALL_PROJECTS=$(echo "$FLUTTER_PROJECTS $DART_PROJECTS" | jq -sc 'add' | jq -c '.')

echo "flutter_projects=$FLUTTER_PROJECTS" >> $GITHUB_OUTPUT
echo "dart_projects=$DART_PROJECTS" >> $GITHUB_OUTPUT
echo "all_projects=$ALL_PROJECTS" >> $GITHUB_OUTPUT

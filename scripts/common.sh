#!/bin/bash

# Cross-platform sed -i
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -E "$1" "$2"
  else
    sed -i -E "$1" "$2"
  fi
}

# Convert string to snake_case
to_snake_case() {
  echo "$1" | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g' | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^_+|_+$//g'
}

# Validate feature name or prompt
validate_or_prompt_feature_name() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [--app <app>] <feature_name>"
    return 1
  fi
  INPUT_NAME="$1"
  return 0
}

print_usage() {
  echo "$1"
  echo "Usage: $0 [--app <app>] <feature_name>"
}

# Discover packages dynamically
discover_packages() {
  local root_dir="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  local packages=()
  if [ -f "$root_dir/pubspec.yaml" ]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
        pkg="${BASH_REMATCH[1]}"
        if [ -d "$root_dir/$pkg" ]; then
          packages+=("$pkg")
        fi
      fi
    done <<< "$(awk '/^workspace:/{flag=1; next} /^[^[:space:]]/{flag=0} flag' "$root_dir/pubspec.yaml" | grep -E '^[[:space:]]*- ')"
  fi
  # Fallback
  if [ ${#packages[@]} -eq 0 ]; then
    while IFS= read -r pkg_dir; do
      pkg_name=$(basename "$pkg_dir")
      packages+=("$pkg_name")
    done <<< "$(find "$root_dir" -maxdepth 1 -type d -name "baktaz_*" | sort)"
  fi
  echo "${packages[@]}"
}

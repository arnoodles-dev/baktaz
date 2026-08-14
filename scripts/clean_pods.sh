#!/bin/bash
# Dynamically find Flutter iOS directories and clean pods

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Find all Flutter packages with ios directories
find "$ROOT_DIR" -type d -name "ios" | while read -r ios_dir; do
  # Check if it's a Flutter project (has Podfile)
  if [ -f "$ios_dir/Podfile" ]; then
    echo "Cleaning pods in: $ios_dir"
    cd "$ios_dir" || exit 1
    rm -f Podfile.lock
    rm -rf .symlinks Pods
    pod install --repo-update
  fi
done

echo "Pods cleaned for all Flutter iOS projects"

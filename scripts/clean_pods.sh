#!/bin/bash
# ponytail: only paxa_flutter exists
cd "$(dirname "$0")/../paxa_flutter/ios" || exit 1
rm -f Podfile.lock
rm -rf .symlinks Pods
pod install --repo-update

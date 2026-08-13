#!/bin/bash
# This script is executed by melos exec within the package directory ($MELOS_PACKAGE_PATH).

VERSION="$1"
if [ -z "$VERSION" ]; then
  VERSION=$(date +"%Y%m%d")
fi

if [ -f "test/flutter_test_config.dart" ]; then
  source "$MELOS_ROOT_PATH/scripts/common.sh"
  sed_inplace "s/(static String get goldensVersion => )['\"][^'\"]+['\"]/\1'$VERSION'/g" "test/flutter_test_config.dart"
  echo "Updated goldensVersion to '$VERSION' in $MELOS_PACKAGE_NAME"
fi

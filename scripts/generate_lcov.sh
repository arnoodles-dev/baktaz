#!/bin/bash
# Reusable script for generating LCOV coverage reports
# Reads per-package coverage exceptions from .coverage_exclude

APP=$1

if [ -z "$APP" ]; then
  echo "Usage: $0 <admin|app|server|site>"
  exit 1
fi

source "$(dirname "$0")/common.sh"
if [[ "$OS_TYPE" == "windows" ]]; then
  LCOV_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\lcov"
  GENHTML_CMD="perl C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\genhtml"
  OPEN_CMD="CMD /C start"
  OUT_ADMIN="coverage\\index.html"
  OUT_APP="coverage\\index.html"
  OUT_SERVER="coverage\\html\\index.html"
  OUT_SITE="coverage\\index.html"
else
  LCOV_CMD="lcov"
  GENHTML_CMD="genhtml"
  OPEN_CMD="open"
  OUT_ADMIN="coverage/index.html"
  OUT_APP="coverage/index.html"
  OUT_SERVER="coverage/html/index.html"
  OUT_SITE="coverage/index.html"
  OUT_SHARED="coverage/index.html"
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

if [ "$APP" = "admin" ]; then
  cd paxa_admin
  PATTERNS=$(read_exclude_patterns ".coverage_exclude")
  $LCOV_CMD --ignore-errors unused --remove coverage/lcov.info $PATTERNS -o coverage/lcov.info
  $GENHTML_CMD -o coverage coverage/lcov.info
  $OPEN_CMD $OUT_ADMIN
elif [ "$APP" = "app" ]; then
  cd paxa_flutter
  PATTERNS=$(read_exclude_patterns ".coverage_exclude")
  $LCOV_CMD --ignore-errors unused --remove coverage/lcov.info $PATTERNS -o coverage/lcov.info
  $GENHTML_CMD -o coverage coverage/lcov.info
  $OPEN_CMD $OUT_APP
elif [ "$APP" = "server" ]; then
  cd paxa_server
  $LCOV_CMD --ignore-errors unused --extract coverage/lcov.info '*/endpoints/*' '*/services/*' -o coverage/lcov.info
  PATTERNS=$(read_exclude_patterns ".coverage_exclude")
  $LCOV_CMD --ignore-errors unused --remove coverage/lcov.info $PATTERNS -o coverage/lcov.info
  $GENHTML_CMD -o coverage/html coverage/lcov.info
  $OPEN_CMD $OUT_SERVER
elif [ "$APP" = "site" ]; then
  cd paxa_site
  PATTERNS=$(read_exclude_patterns ".coverage_exclude")
  $LCOV_CMD --ignore-errors unused --remove coverage/lcov.info $PATTERNS -o coverage/lcov.info
  $GENHTML_CMD -o coverage coverage/lcov.info
  $OPEN_CMD $OUT_SITE
elif [ "$APP" = "shared" ]; then
  cd paxa_shared
  PATTERNS=$(read_exclude_patterns ".coverage_exclude")
  $LCOV_CMD --ignore-errors unused --remove coverage/lcov.info $PATTERNS -o coverage/lcov.info
  $GENHTML_CMD -o coverage coverage/lcov.info
  $OPEN_CMD $OUT_SHARED
else
  echo "Invalid app choice. Must be admin, app, server, site, or shared."
  exit 1
fi

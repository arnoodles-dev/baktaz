#!/bin/bash
set -e

THRESHOLD=80
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PACKAGES=("paxa_flutter" "paxa_admin" "paxa_shared" "paxa_server" "paxa_site")
LCOV_MAP=("app" "admin" "shared" "server" "site")

run_for_package() {
  local pkg="$1"
  local pkg_dir="$ROOT_DIR/$pkg"

  if [ ! -d "$pkg_dir" ]; then
    echo "Error: Package not found: $pkg"
    return 1
  fi

  echo ""
  echo "━━━ $pkg ━━━"
  cd "$pkg_dir"

  local tool=""
  command -v fvm >/dev/null 2>&1 && tool="fvm "

  if grep -q 'sdk: flutter' pubspec.yaml 2>/dev/null; then
    ${tool}flutter test --test-randomize-ordering-seed random --no-pub --coverage || exit $?
  else
    ${tool}dart test --test-randomize-ordering-seed random --concurrency=1 --coverage=coverage || exit $?
  fi

  [ ! -f "coverage/lcov.info" ] && return 0

  if [ -f ".coverage_exclude" ]; then
    local patterns=()
    while IFS= read -r line || [ -n "$line" ]; do
      local stripped
      stripped=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [ -z "$stripped" ] || [ "${stripped:0:1}" = "#" ] && continue
      patterns+=("'$stripped'")
    done < ".coverage_exclude"

    if [ ${#patterns[@]} -gt 0 ]; then
      eval lcov --ignore-errors unused --remove "coverage/lcov.info" "${patterns[@]}" -o "coverage/lcov.info" 2>/dev/null || true
    fi
  fi

  awk -F: -v threshold="$THRESHOLD" '
    /^LF:/ { lf += $2 }
    /^LH:/ { lh += $2 }
    END {
      if (lf == 0) exit 0
      pct = lh * 100 / lf
      printf "Coverage: %.1f%% (%d/%d)\n", pct, lh, lf
      if (pct < threshold) {
        printf "FAIL: Coverage %.1f%% < %d%% threshold\n", pct, threshold
        exit 1
      }
      printf "OK: Coverage %.1f%% >= %d%% threshold\n", pct, threshold
    }
  ' "coverage/lcov.info"
}

generate_lcov() {
  local pkg="$1"
  local idx=-1
  for i in "${!PACKAGES[@]}"; do
    if [ "${PACKAGES[$i]}" = "$pkg" ]; then
      idx=$i
      break
    fi
  done

  if [ $idx -eq -1 ]; then
    return 0
  fi

  local lcov_arg="${LCOV_MAP[$idx]}"

  if [ -f "$ROOT_DIR/scripts/generate_lcov.sh" ]; then
    echo ""
    echo "Generating LCOV report for $lcov_arg..."
    cd "$ROOT_DIR"
    bash "$ROOT_DIR/scripts/generate_lcov.sh" "$lcov_arg" 2>/dev/null || true
  fi
}

run_interactive() {
  echo "Select packages to test:"
  echo ""
  for i in "${!PACKAGES[@]}"; do
    echo "  $((i+1))) ${PACKAGES[$i]}"
  done
  echo ""
  echo "  a) All packages"
  echo "  q) Quit"
  echo ""
  printf "Enter selection (e.g. 1 3, or 'a' for all): "
  read -r input

  if [ "$input" = "q" ] || [ -z "$input" ]; then
    echo "Aborted."
    exit 0
  fi

  local selected=()
  if [ "$input" = "all" ] || [ "$input" = "a" ]; then
    selected=("${PACKAGES[@]}")
  else
    for choice in $input; do
      if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#PACKAGES[@]}" ]; then
        selected+=("${PACKAGES[$((choice-1))]}")
      else
        echo "Invalid selection: $choice"
        exit 1
      fi
    done
  fi

  if [ ${#selected[@]} -eq 0 ]; then
    echo "No packages selected."
    exit 1
  fi

  echo ""
  echo "Running tests for: ${selected[*]}"

  if [ ${#selected[@]} -eq ${#PACKAGES[@]} ]; then
    run_all_parallel
    return
  fi

  local failed=0
  for pkg in "${selected[@]}"; do
    run_for_package "$pkg" || failed=1
    generate_lcov "$pkg"
  done

  if [ $failed -ne 0 ]; then
    echo ""
    echo "Some tests failed."
    exit 1
  fi

  echo ""
  echo "All tests passed."
  print_coverage_summary
}

print_coverage_summary() {
  local total_lf=0
  local total_lh=0
  local pkg_results=()
  local any_coverage=false

  for pkg in "${PACKAGES[@]}"; do
    local lcov="$ROOT_DIR/$pkg/coverage/lcov.info"
    [ ! -f "$lcov" ] && continue

    local lf=0 lh=0 pct=0
    eval "$(awk -F: '
      /^LF:/ { lf += $2 }
      /^LH:/ { lh += $2 }
      END {
        if (lf > 0) {
          printf "lf=%d lh=%d pct=%.1f\n", lf, lh, lh * 100 / lf
        } else {
          printf "lf=0 lh=0 pct=0\n"
        }
      }
    ' "$lcov")"

    [ "$lf" -eq 0 ] && continue

    any_coverage=true
    total_lf=$((total_lf + lf))
    total_lh=$((total_lh + lh))

    local status="OK"
    local pct_int=${pct%.*}
    [ "$pct_int" -lt "$THRESHOLD" ] && status="FAIL"

    pkg_results+=("$pkg|$pct|($lh/$lf)|$status")
  done

  if [ "$any_coverage" = false ]; then
    echo ""
    echo "No coverage data found."
    return
  fi

  local total_pct=0
  [ "$total_lf" -gt 0 ] && total_pct=$(awk "BEGIN { printf \"%.1f\", $total_lh * 100 / $total_lf }")

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Coverage Summary Report"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "  %-18s %7s %10s %6s\n" "Package" "Cover" "Lines" "Status"
  echo "  ────────────────── ─────── ────────── ──────"

  for result in "${pkg_results[@]}"; do
    IFS='|' read -r rpkg rpct rlines rstatus <<< "$result"
    printf "  %-18s %6s%% %10s %6s\n" "$rpkg" "$rpct" "$rlines" "$rstatus"
  done

  echo "  ────────────────── ─────── ────────── ──────"
  printf "  %-18s %6s%% (%d/%d)\n" "TOTAL" "$total_pct" "$total_lh" "$total_lf"

  local overall_int=${total_pct%.*}
  if [ "$overall_int" -lt "$THRESHOLD" ]; then
    printf "  OVERALL: FAIL (below %d%% threshold)\n" "$THRESHOLD"
  else
    printf "  OVERALL: PASS\n"
  fi
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

run_all_parallel() {
  local pids=()
  local failed=0

  echo ""
  echo "Running tests in parallel for: ${PACKAGES[*]}"
  echo ""

  for pkg in "${PACKAGES[@]}"; do
    run_for_package "$pkg" &
    pids+=($!)
  done

  for pid in "${pids[@]}"; do
    wait "$pid" || failed=1
  done

  if [ $failed -ne 0 ]; then
    echo ""
    echo "Some tests failed."
    exit 1
  fi

  echo ""
  echo "All tests passed."
  print_coverage_summary
}

run_single() {
  local pkg="$1"

  if [ "$pkg" = "all" ]; then
    run_all_parallel
  else
    run_for_package "$pkg"
    generate_lcov "$pkg"
  fi
}

# Main
if [ $# -gt 0 ]; then
  run_single "$1"
else
  run_interactive
fi

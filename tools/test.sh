#!/usr/bin/env bash
# Run the app's unit tests on the simulator.
#   tools/test.sh [Name] [simulator name]
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; SIM="${2:-$DEFAULT_SIM}"
ensure_project
log "testing $APP_NAME on '$SIM'"
set +e
xcodebuild -project "$APP_DIR/$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath "$(derived_data)" -quiet test 2>&1 | xcfilter
status=${PIPESTATUS[0]}
set -e
[[ $status -eq 0 ]] && log "TESTS OK" || die "tests failed ($status)"

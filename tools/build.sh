#!/usr/bin/env bash
# Build an app for the iOS simulator, printing only errors/warnings.
#   tools/build.sh [Name] [simulator name]      (defaults: cwd app, "iPhone 17 Pro")
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; SIM="${2:-$DEFAULT_SIM}"
ensure_project
log "building $APP_NAME for '$SIM'"
set +e
xcodebuild -project "$APP_DIR/$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath "$(derived_data)" -quiet build 2>&1 | xcfilter
status=${PIPESTATUS[0]}
set -e
[[ $status -eq 0 ]] && log "BUILD OK" || die "build failed ($status)"

#!/usr/bin/env bash
# Signed Debug build for a physical iPhone (no device needed to be connected).
#   tools/build-device.sh [Name]
# Uses automatic signing with DEVELOPMENT_TEAM from project.yml; creates/refreshes the
# development provisioning profile via -allowProvisioningUpdates (Apple ID signed into Xcode).
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"
ensure_project
log "building $APP_NAME for iOS device (Debug, automatic signing)"
set +e
xcodebuild -project "$APP_DIR/$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -destination 'generic/platform=iOS' -derivedDataPath "$(derived_data)" \
  -allowProvisioningUpdates -quiet build 2>&1 | xcfilter
status=${PIPESTATUS[0]}; set -e
[[ $status -eq 0 ]] || die "build failed ($status)"
APP="$(derived_data)/Build/Products/Debug-iphoneos/$APP_NAME.app"
codesign -dv --verbose=2 "$APP" 2>&1 | grep -E "^(Authority=Apple|TeamIdentifier)" | sed 's/^/  /'
log "BUILD OK → $APP"

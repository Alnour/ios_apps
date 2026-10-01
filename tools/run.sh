#!/usr/bin/env bash
# Build, install and launch an app on a booted simulator; streams the app's console output.
#   tools/run.sh [Name] [simulator name]        (defaults: cwd app, "iPhone 17 Pro")
#   Ctrl-C stops streaming logs; the app stays running in the simulator.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; SIM="${2:-$DEFAULT_SIM}"
"$TOOLS_DIR/build.sh" "$APP_NAME" "$SIM"
UDID="$(sim_udid "$SIM")"
boot_sim "$UDID"
APP="$(find "$(derived_data)/Build/Products/Debug-iphonesimulator" -maxdepth 1 -name "$APP_NAME.app" | head -1)"
[[ -n "$APP" ]] || die "built app not found under DerivedData"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")"
log "installing $BUNDLE_ID"
xcrun simctl install "$UDID" "$APP"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
log "launching (logs follow; Ctrl-C to stop)"
exec xcrun simctl launch --console-pty "$UDID" "$BUNDLE_ID"

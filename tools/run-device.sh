#!/usr/bin/env bash
# Build, install and launch an app on a connected (or paired wireless) iPhone.
#   tools/run-device.sh [Name] [device name or UDID]     (default: first available iPhone)
# Needs: the phone unlocked, Developer Mode on (Settings › Privacy & Security › Developer Mode),
# trusted to this Mac once, and DEVELOPMENT_TEAM set in project.yml (automatic signing).
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; WANT="${2:-}"
ensure_project

# pick a device: match by UDID or name, else first available iPhone
DEVICES_JSON="$(mktemp)"; xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null 2>&1
read -r UDID DNAME < <(python3 - "$DEVICES_JSON" "$WANT" <<'PY'
import json,sys
devs=json.load(open(sys.argv[1]))["result"]["devices"]; want=sys.argv[2]
def ok(d): return d.get("connectionProperties",{}).get("tunnelState")!="unavailable" or want
cands=[d for d in devs if "iPhone" in d["hardwareProperties"].get("productType","") or "iPhone" in d["deviceProperties"].get("name","")]
for d in cands:
    u=d["identifier"]; n=d["deviceProperties"]["name"]
    if want and (want==u or want.lower()==n.lower()): print(u,n); sys.exit(0)
for d in cands:
    if d.get("connectionProperties",{}).get("tunnelState")!="unavailable": print(d["identifier"],d["deviceProperties"]["name"]); sys.exit(0)
sys.exit(1)
PY
) || die "no available iPhone (plug it in / unlock it; 'xcrun devicectl list devices' shows state)"
log "device: $DNAME ($UDID)"

log "building $APP_NAME for device (automatic signing)"
set +e
xcodebuild -project "$APP_DIR/$APP_NAME.xcodeproj" -scheme "$APP_NAME" \
  -destination "id=$UDID" -derivedDataPath "$(derived_data)" \
  -allowProvisioningUpdates -quiet build 2>&1 | xcfilter
status=${PIPESTATUS[0]}; set -e
[[ $status -eq 0 ]] || die "build failed ($status)"

APP="$(find "$(derived_data)/Build/Products/Debug-iphoneos" -maxdepth 1 -name "$APP_NAME.app" | head -1)"
[[ -n "$APP" ]] || die "built app not found"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")"
log "installing $BUNDLE_ID"
xcrun devicectl device install app --device "$UDID" "$APP" >/dev/null
log "launching"
xcrun devicectl device process launch --device "$UDID" --terminate-existing "$BUNDLE_ID" "${@:3}" >/dev/null
log "running on $DNAME. Logs: Console.app or 'xcrun devicectl device process list --device $UDID'"

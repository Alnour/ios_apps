#!/usr/bin/env bash
# Archive a Release build and export an .ipa.
#   tools/archive.sh [Name] [method]      method: development (default) | ad-hoc | app-store-connect
#   Output: <App>/build/<Name>.xcarchive and <App>/build/export-<method>/<Name>.ipa
# development  → installable on your registered devices (Apple Development cert)
# ad-hoc       → installable on registered devices, needs an Apple Distribution cert
# app-store-connect → for TestFlight / App Store (Apple Distribution cert); pair with tools/upload.sh
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; METHOD="${2:-development}"
case "$METHOD" in development|ad-hoc|app-store-connect) ;; *) die "method must be development | ad-hoc | app-store-connect" ;; esac
ensure_project
TEAM="$(grep -E '^\s*DEVELOPMENT_TEAM:' "$APP_DIR/project.yml" | head -1 | sed -E 's/.*: *"?([A-Z0-9]*)"?.*/\1/')"
[[ -n "$TEAM" ]] || die "set DEVELOPMENT_TEAM in project.yml"
OUT="$APP_DIR/build"; ARCHIVE="$OUT/$APP_NAME.xcarchive"; EXPORT="$OUT/export-$METHOD"
mkdir -p "$OUT"; rm -rf "$ARCHIVE" "$EXPORT"

log "archiving $APP_NAME (Release)"
set +e
xcodebuild -project "$APP_DIR/$APP_NAME.xcodeproj" -scheme "$APP_NAME" -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" -derivedDataPath "$(derived_data)" \
  -allowProvisioningUpdates -quiet archive 2>&1 | xcfilter
status=${PIPESTATUS[0]}; set -e
[[ $status -eq 0 ]] || die "archive failed ($status)"

PLIST="$OUT/ExportOptions-$METHOD.plist"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>$METHOD</string>
  <key>teamID</key><string>$TEAM</string>
  <key>signingStyle</key><string>automatic</string>
  <key>destination</key><string>export</string>
  <key>compileBitcode</key><false/>
  <key>stripSwiftSymbols</key><true/>
  <key>thinning</key><string>&lt;none&gt;</string>
$( [[ "$METHOD" == "app-store-connect" ]] && printf '  <key>uploadSymbols</key><true/>\n  <key>manageAppVersionAndBuildNumber</key><false/>\n' )
</dict></plist>
PL

log "exporting .ipa ($METHOD)"
set +e
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath "$EXPORT" -exportOptionsPlist "$PLIST" \
  -allowProvisioningUpdates -quiet 2>&1 | xcfilter
status=${PIPESTATUS[0]}; set -e
[[ $status -eq 0 ]] || die "export failed ($status) — for ad-hoc/app-store-connect you need an 'Apple Distribution' certificate (Xcode › Settings › Accounts › Manage Certificates)"
IPA="$(find "$EXPORT" -name '*.ipa' | head -1)"
log "IPA → $IPA"

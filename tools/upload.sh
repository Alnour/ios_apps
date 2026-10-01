#!/usr/bin/env bash
# Upload an .ipa to App Store Connect (TestFlight) with an App Store Connect API key.
#   tools/upload.sh [Name] [path/to.ipa]        (default ipa: <App>/build/export-app-store-connect/<Name>.ipa)
# Credentials (one-time): create an API key at https://appstoreconnect.apple.com/access/integrations/api
# with role "App Manager" or "Developer", download AuthKey_<KEYID>.p8 into ~/.appstoreconnect/private_keys/
# and export:  ASC_KEY_ID=<KEYID>  ASC_ISSUER_ID=<issuer uuid>   (e.g. in ~/.zshrc)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"
IPA="${2:-$APP_DIR/build/export-app-store-connect/$APP_NAME.ipa}"
[[ -f "$IPA" ]] || die "no ipa at $IPA (run tools/archive.sh $APP_NAME app-store-connect first)"
: "${ASC_KEY_ID:?set ASC_KEY_ID}"; : "${ASC_ISSUER_ID:?set ASC_ISSUER_ID}"
[[ -f "$HOME/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8" ]] || die "missing ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8"
log "validating $IPA"
xcrun altool --validate-app -f "$IPA" -t ios --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID" 2>&1 | tail -3
log "uploading"
xcrun altool --upload-app -f "$IPA" -t ios --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID" 2>&1 | tail -3
log "done — the build appears in App Store Connect › TestFlight after processing (10–30 min)"

#!/usr/bin/env bash
# Show everything that affects signing & device runs: identities, team, profiles, devices, Xcode account hint.
#   tools/signing-doctor.sh [Name]
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
echo "== Xcode";            xcodebuild -version | tr '\n' ' '; echo
echo "== Signing identities (codesigning)"
security find-identity -v -p codesigning 2>/dev/null | sed -n '1,10p'
echo "   (Apple Development = run on your devices; Apple Distribution = ad-hoc / TestFlight / App Store)"
echo "== Team IDs in certificates"
for n in "Apple Development" "Apple Distribution"; do
  subj="$(security find-certificate -c "$n" -p 2>/dev/null | openssl x509 -noout -subject 2>/dev/null || true)"
  if [[ -n "$subj" ]]; then sed -E "s/.*OU *= *([A-Z0-9]+).*/   $n: team \1/" <<<"$subj"; else echo "   $n: (no certificate)"; fi
done
if [[ -n "${1:-}" || -f project.yml ]]; then resolve_app "${1:-}"; echo "== $APP_NAME project.yml"; grep -nE "DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER|CFBundleShortVersionString|CFBundleVersion" "$APP_DIR/project.yml" | sed 's/^/   /'; fi
echo "== Provisioning profiles"
P=~/Library/MobileDevice/Provisioning\ Profiles; P2=~/Library/Developer/Xcode/UserData/Provisioning\ Profiles
for d in "$P" "$P2"; do [[ -d "$d" ]] && for f in "$d"/*.mobileprovision; do [[ -f "$f" ]] || continue
  security cms -D -i "$f" 2>/dev/null | plutil -extract Name raw - 2>/dev/null | sed 's/^/   /'; done; done
echo "== Devices (xcrun devicectl)"
xcrun devicectl list devices 2>/dev/null | tail -n +3 | sed 's/^/   /'
echo "== Reminders"
echo "   • Phone: Settings › Privacy & Security › Developer Mode on; unlock; trust this Mac."
echo "   • Xcode › Settings › Accounts must have the Apple ID for the team (needed by -allowProvisioningUpdates)."

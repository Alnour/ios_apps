#!/usr/bin/env bash
# Shared helpers for the ios_apps tool scripts. Source, don't execute.
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$(cd "$TOOLS_DIR/.." && pwd)"
DEFAULT_SIM="iPhone 17 Pro"

log()  { printf '\033[1;34m▸ %s\033[0m\n' "$*" >&2; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# resolve_app <name-or-empty>  → sets APP_NAME and APP_DIR
# With no name, uses the current directory if it holds a project.yml.
resolve_app() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    [[ -f project.yml ]] || die "no app name given and no project.yml in $(pwd)"
    APP_DIR="$(pwd)"; APP_NAME="$(basename "$APP_DIR")"
  else
    APP_DIR="$APPS_DIR/$name"; APP_NAME="$name"
    [[ -d "$APP_DIR" ]] || die "no app at $APP_DIR"
  fi
}

need() { command -v "$1" >/dev/null 2>&1 || die "missing tool: $1 ($2)"; }

# regenerate the .xcodeproj when the spec is newer (or the project is missing)
ensure_project() {
  need xcodegen "brew install xcodegen"
  local proj="$APP_DIR/$APP_NAME.xcodeproj"
  if [[ ! -d "$proj" || "$APP_DIR/project.yml" -nt "$proj/project.pbxproj" ]]; then
    log "xcodegen generate ($APP_NAME)"
    (cd "$APP_DIR" && xcodegen generate --quiet)
  fi
}

derived_data() { echo "$APP_DIR/DerivedData"; }

# sim_udid <name> → prints the UDID of an available simulator with that name (newest runtime)
sim_udid() {
  xcrun simctl list devices available -j \
    | python3 -c 'import json,sys; n=sys.argv[1]; d=json.load(sys.stdin)["devices"]
rt=sorted(d.keys()); 
for k in reversed(rt):
  for dev in d[k]:
    if dev["name"]==n: print(dev["udid"]); sys.exit(0)
sys.exit(1)' "$1" || die "no available simulator named '$1' (xcrun simctl list devices)"
}

boot_sim() {
  local udid="$1"
  local state; state="$(xcrun simctl list devices -j | python3 -c 'import json,sys; u=sys.argv[1]
for devs in json.load(sys.stdin)["devices"].values():
  for d in devs:
    if d["udid"]==u: print(d["state"])' "$udid")"
  if [[ "$state" != "Booted" ]]; then log "booting simulator $udid"; xcrun simctl boot "$udid"; fi
  open -a Simulator --args -CurrentDeviceUDID "$udid" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
}

# filter xcodebuild output down to what matters; preserve exit status via PIPESTATUS in caller
xcfilter() {
  grep -E --line-buffered -i 'error:|warning:|\*\* (BUILD|TEST) (SUCCEEDED|FAILED)|Test Suite|Test Case.*(passed|failed)|Executed [0-9]+ tests|fatal' \
    | grep -v -E 'warning: .*(DerivedData|xcodegen)' || true
}

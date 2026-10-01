#!/usr/bin/env bash
# Screenshot the booted simulator.
#   tools/screenshot.sh [out.png]     (default: ./screenshot-<timestamp>.png)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
OUT="${1:-./screenshot-$(date +%Y%m%d-%H%M%S).png}"
xcrun simctl io booted screenshot "$OUT" >/dev/null 2>&1 && log "saved $OUT"

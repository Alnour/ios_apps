#!/usr/bin/env bash
# Scaffold a new SwiftUI iOS app from tools/template and generate its Xcode project.
#   tools/new-ios-app.sh <Name> [bundlePrefix]      (default prefix: com.alnourkhalifa)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
[[ $# -ge 1 ]] || { sed -n '2,3p' "$0"; exit 1; }
NAME="$1"; PREFIX="${2:-com.alnourkhalifa}"
[[ "$NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]] || die "name must be a valid Swift identifier (letters/digits, no spaces)"
DEST="$APPS_DIR/$NAME"
[[ -e "$DEST" ]] && die "$DEST already exists"
need xcodegen "brew install xcodegen"

log "creating $DEST"
mkdir -p "$DEST"
# copy template, renaming __NAME__ in paths and contents
(cd "$TOOLS_DIR/template" && find . -type f) | while read -r f; do
  out="$DEST/${f//__NAME__/$NAME}"
  mkdir -p "$(dirname "$out")"
  sed -e "s/__NAME__/$NAME/g" -e "s/__PREFIX__/$PREFIX/g" "$TOOLS_DIR/template/$f" > "$out"
done
mv "$DEST/gitignore" "$DEST/.gitignore"

cat > "$DEST/CLAUDE.md" <<MD
# $NAME

SwiftUI iOS app, iOS 26+, Swift 6. The Xcode project is **generated** by xcodegen from
\`project.yml\` — edit the yml (targets, Info.plist keys, settings), never the \`.xcodeproj\`.

- Build: \`make build\`  ·  Run on simulator: \`make run\`  ·  Tests: \`make test\`
  (wrappers around \`../tools/*.sh\`; see \`../CLAUDE.md\`)
- Before coding against an Apple framework, read its local doc: \`chub get apple/<id> --lang swift\`
  (\`chub search apple\` lists them). Record gotchas with \`chub annotate apple/<id> "..."\`.
MD

(cd "$DEST" && xcodegen generate --quiet)   # no git init: apps live in the single ~/ios_apps repository
log "done. next: tools/run.sh $NAME"

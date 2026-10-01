#!/usr/bin/env bash
# Bump the marketing version and/or build number in project.yml.
#   tools/bump-version.sh [Name] <major|minor|patch|build>     (build is always incremented)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
resolve_app "${1:-}"; PART="${2:-build}"
YML="$APP_DIR/project.yml"
python3 - "$YML" "$PART" <<'PY'
import re,sys
p,part=sys.argv[1],sys.argv[2]; s=open(p).read()
mv=re.search(r'CFBundleShortVersionString: "([0-9.]+)"',s); bv=re.search(r'CFBundleVersion: "(\d+)"',s)
if not mv or not bv: sys.exit("project.yml needs CFBundleShortVersionString and CFBundleVersion under info.properties")
M,m,pt=(list(map(int,(mv.group(1).split('.')+['0','0'])[:3])))
if part=='major': M,m,pt=M+1,0,0
elif part=='minor': m,pt=m+1,0
elif part=='patch': pt+=1
elif part!='build': sys.exit("part must be major|minor|patch|build")
ver=f"{M}.{m}.{pt}" if part!='build' else mv.group(1)
build=int(bv.group(1))+1
s=s.replace(mv.group(0),f'CFBundleShortVersionString: "{ver}"').replace(bv.group(0),f'CFBundleVersion: "{build}"')
open(p,'w').write(s); print(f"version {ver} ({build})")
PY

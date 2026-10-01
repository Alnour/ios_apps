#!/usr/bin/env bash
# Build the local Context Hub source "apple" from Apple's markdown doc pages.
#   tools/fetch-apple-docs.sh [manifest] [out-dir]
#   defaults: tools/apple-docs.manifest  →  ios_apps/docs   (registry in docs/.registry)
# Re-run any time to refresh. Pages that 404 are reported and skipped.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
MANIFEST="${1:-$TOOLS_DIR/apple-docs.manifest}"
OUT="${2:-$APPS_DIR/docs}"
need chub "npm i -g @aisuite/chub"
SDK="$(xcrun --show-sdk-path --sdk iphoneos)"
SDK_VER="$(xcrun --show-sdk-version --sdk iphoneos)"
export MANIFEST OUT TOOLS_DIR SDK SDK_VER
python3 - <<'PY'
import os, re, json, sys, datetime, urllib.request, urllib.error, glob
MANIFEST, OUT, TOOLS, SDK, SDK_VER = (os.environ[k] for k in ("MANIFEST","OUT","TOOLS_DIR","SDK","SDK_VER"))
TODAY = datetime.date.today().isoformat()
BASE = "https://developer.apple.com/documentation/"

# ---- parse manifest
entries, cur = [], None
for raw in open(MANIFEST):
    line = raw.rstrip("\n")
    if not line.strip() or line.lstrip().startswith("#"): continue
    if not line.startswith(" "):
        cur = {"id": line.strip(), "pages": []}; entries.append(cur); continue
    k, _, v = line.strip().partition(":")
    k, v = k.strip(), v.strip()
    if k == "page": cur["pages"].append(v)
    else: cur[k] = v

def fetch(path):
    url = BASE + urllib.parse.quote(path, safe="/():@") + ".md"
    req = urllib.request.Request(url, headers={"User-Agent": "ios_apps-docs/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.read().decode("utf-8"), url
    except urllib.error.HTTPError as e:
        return None, f"{url} ({e.code})"
    except Exception as e:
        return None, f"{url} ({e})"

def split_header(md):
    """Apple pages start with an HTML comment holding JSON metadata."""
    m = re.match(r"\s*<!--\s*(\{.*?\})\s*-->\s*", md, re.S)
    meta = {}
    if m:
        try: meta = json.loads(m.group(1))
        except Exception: pass
        md = md[m.end():]
    md = re.sub(r"\n---\n\nCopyright &copy; .*$", "\n", md, flags=re.S)  # footer
    return meta, md.strip()

def sdk_signatures(framework):
    files = glob.glob(f"{SDK}/System/Library/Frameworks/{framework}.framework/Modules/{framework}.swiftmodule/arm64*-apple-ios.swiftinterface")
    if not files: return ""
    out, avail = [], None
    for line in open(files[0], errors="replace"):
        s = line.rstrip()
        st = s.strip()
        if st.startswith("@available(") and "introduced" in st or st.startswith("@available(iOS"):
            avail = st; continue
        if re.match(r"(public |open |@frozen public |@_originallyDefinedIn.*public |@MainActor public |final public |public final |nonisolated public |public static |extension )", st) \
           or re.match(r"\s*(public |final public |public static |public var |public let |public func |public init|case |indirect case |public enum |public struct |public class |public protocol |public typealias )", st) and "public" in st or st.startswith("case "):
            if "@_spi" in st or "_distributed" in st: continue
            indent = len(s) - len(s.lstrip())
            out.append(" " * min(indent, 4) + st)
    return "\n".join(out)

import urllib.parse
summary = []
for e in entries:
    src, docid = e["id"].split("/", 1)
    d = os.path.join(OUT, src, "docs", docid, "swift"); os.makedirs(d, exist_ok=True)
    parts, missing = [], []
    intro = os.path.join(TOOLS, "apple-docs", e.get("intro", ""))
    if e.get("intro") and os.path.exists(intro):
        parts.append(open(intro).read().strip())
    else:
        parts.append(f"# {docid}\n\n{e.get('description','')}")
    parts.append("\n## Reference (developer.apple.com, fetched " + TODAY + ")\n")
    for p in e["pages"]:
        md, url = fetch(p)
        if md is None: missing.append(url); continue
        meta, body = split_header(md)
        title = meta.get("title") or p
        avail = ", ".join(a for a in meta.get("availability", []) if a.startswith("iOS")) or ""
        body = re.sub(r"^# .*\n", "", body, count=1)                 # drop the H1, we add our own
        body = re.sub(r"(?m)^(#{1,5}) ", lambda m: "#" * (len(m.group(1)) + 2) + " ", body)  # demote headings
        parts.append(f"### {title}" + (f"  \n*{avail}* · <{url.rsplit(' ',1)[0]}>" if avail else f"  \n<{url}>") + "\n\n" + body + "\n")
    if e.get("sdk"):
        sig = sdk_signatures(e["sdk"])
        if sig:
            parts.append(f"\n## SDK signatures ({e['sdk']}, iOS {SDK_VER} swiftinterface — ground truth)\n\n```swift\n{sig}\n```\n")
    body = "\n".join(parts)
    fm = ("---\n"
          f"name: {docid}\n"
          f"description: \"{e.get('description','').replace(chr(34), chr(39))}\"\n"
          "metadata:\n"
          "  languages: \"swift\"\n"
          f"  versions: \"ios-{SDK_VER}\"\n"
          "  revision: 1\n"
          f"  updated-on: \"{TODAY}\"\n"
          "  source: community\n"
          f"  tags: \"{e.get('tags','')}\"\n"
          "---\n\n")
    open(os.path.join(d, "DOC.md"), "w").write(fm + body)
    summary.append((e["id"], len(e["pages"]) - len(missing), len(e["pages"]), len(fm + body) // 1024, missing))

for id_, ok, total, kb, missing in summary:
    print(f"{id_:32s} {ok}/{total} pages  {kb:4d} KB")
    for m in missing: print(f"    MISSING {m}")
PY
log "building registry"
chub build "$OUT" -o "$OUT/.registry" | tail -3
log "done → $OUT/.registry  (register in ~/.chub/config.yaml as source 'apple')"

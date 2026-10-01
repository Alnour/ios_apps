# VoiceCRM

SwiftUI iOS app, iOS 26+, Swift 6. The Xcode project is **generated** by xcodegen from
`project.yml` — edit the yml (targets, Info.plist keys, settings), never the `.xcodeproj`.

- Build: `make build`  ·  Run on simulator: `make run`  ·  Tests: `make test`
  (wrappers around `../tools/*.sh`; see `../CLAUDE.md`)
- Before coding against an Apple framework, read its local doc: `chub get apple/<id> --lang swift`
  (`chub search apple` lists them). Record gotchas with `chub annotate apple/<id> "..."`.

# On-device speech-to-text — SpeechAnalyzer / SpeechTranscriber (iOS 26)

The modern Speech API (replaces `SFSpeechRecognizer` for new code). Fully on device, no
per-request permission for speech, but the **microphone** needs `NSMicrophoneUsageDescription`
and `AVAudioApplication.requestRecordPermission()`.

## How our apps use it

- **File-based transcription after recording** (simplest, keeps the audio for playback):
  ```swift
  guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: .current) else { throw Unsupported() }
  let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)
  // REQUIRED: reserve the locale first, or asset requests fail with "<bundle id> is not subscribed to transcription.en"
  if await !AssetInventory.reservedLocales.contains(where: { $0.identifier == locale.identifier }) {
      _ = try await AssetInventory.reserve(locale: locale)
  }
  if await AssetInventory.status(forModules: [transcriber]) != .installed,
     let req = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
      try await req.downloadAndInstall()          // first run only; show progress
  }
  let analyzer = SpeechAnalyzer(modules: [transcriber])
  let collect = Task { var text = ""; for try await r in transcriber.results where r.isFinal { text += String(r.text.characters) }; return text }
  let file = try AVAudioFile(forReading: url)
  if let last = try await analyzer.analyzeSequence(from: file) { try await analyzer.finalizeAndFinish(through: last) }
  else { await analyzer.cancelAndFinishNow() }
  let transcript = try await collect.value
  ```
- Results arrive as `SpeechTranscriber.Result` with `text: AttributedString` and `isFinal`.
  Non-final results are volatile (may be revised) — only use them for live UI.
- Live mic transcription: `AVAudioEngine` input tap → `AnalyzerInputConverter(analyzerFormat:)`
  → `AsyncStream<AnalyzerInput>` → `analyzer.analyzeSequence(stream)`.
- The system limits concurrent analyzers; one at a time per app is the safe default.
- Audio format: ask `SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith:)` when converting
  yourself; `analyzeSequence(from: AVAudioFile)` converts for you.

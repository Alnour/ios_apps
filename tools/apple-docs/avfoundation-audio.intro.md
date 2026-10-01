# AVFAudio — recording & playback

## How our apps use it
- Session: `AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])`, `setActive(true)`.
- Permission: `await AVAudioApplication.requestRecordPermission()` (iOS 17+ API), plus `NSMicrophoneUsageDescription`.
- Record: `AVAudioRecorder(url:, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1])`,
  `isMeteringEnabled = true` → `updateMeters()` + `averagePower(forChannel: 0)` for a level meter.
- Play: `AVAudioPlayer(contentsOf:)`, `prepareToPlay()`, `play()`; observe `currentTime` with a timer.
- Store files under Application Support/Audio/<uuid>.m4a; exclude from backup if large.

import AVFAudio
import Foundation
import Observation

@MainActor
@Observable
final class AudioRecorder {
    private(set) var isRecording = false
    private(set) var level: Float = 0          // 0…1
    private(set) var elapsed: TimeInterval = 0
    private var recorder: AVAudioRecorder?
    private var meterTask: Task<Void, Never>?

    static func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func start(to url: URL) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try session.setActive(true)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        let r = try AVAudioRecorder(url: url, settings: settings)
        r.isMeteringEnabled = true
        r.prepareToRecord()
        r.record()
        recorder = r
        isRecording = true
        elapsed = 0
        meterTask = Task { [weak self] in
            while let self, !Task.isCancelled, self.isRecording {
                self.tick()
                try? await Task.sleep(for: .milliseconds(80))
            }
        }
    }

    private func tick() {
        guard let recorder else { return }
        recorder.updateMeters()
        let db = recorder.averagePower(forChannel: 0)      // -160…0
        level = max(0, min(1, (db + 50) / 50))
        elapsed = recorder.currentTime
    }

    /// Stops and returns the recorded duration.
    @discardableResult
    func stop() -> TimeInterval {
        meterTask?.cancel()
        let duration = recorder?.currentTime ?? elapsed
        recorder?.stop()
        recorder = nil
        isRecording = false
        level = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return duration
    }
}

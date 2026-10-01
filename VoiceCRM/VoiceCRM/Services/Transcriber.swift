import AVFAudio
import Foundation
import Speech

enum TranscriberError: LocalizedError {
    case unsupportedLocale
    case empty
    case notAuthorized
    case simulator
    var errorDescription: String? {
        switch self {
        case .unsupportedLocale: "On-device transcription is not available for your language."
        case .empty: "No speech was detected in the recording."
        case .notAuthorized: "Speech recognition permission was not granted."
        case .simulator: "The iOS Simulator can't transcribe speech. Run on an iPhone, or type the transcript below."
        }
    }
}

/// File-based on-device transcription with SpeechAnalyzer (iOS 26).
enum Transcriber {
    /// Reserves the locale and downloads the language assets if needed. Called early so the first note doesn't wait.
    static func prepare() async throws {
        _ = try await makeTranscriber()
    }

    /// Locale → reservation → assets. The reservation step is required: without it the system reports
    /// "<bundle id> is not subscribed to transcription.<lang>" when asking for assets.
    private static func makeTranscriber() async throws -> SpeechTranscriber {
        guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: .current) else { throw TranscriberError.unsupportedLocale }
        let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)
        let reserved = await AssetInventory.reservedLocales
        print("[transcriber] locale=\(locale.identifier) reserved=\(reserved.map(\.identifier))")
        if !reserved.contains(where: { $0.identifier == locale.identifier }) {
            let ok = try await AssetInventory.reserve(locale: locale)
            print("[transcriber] reserve → \(ok)")
        }
        do {
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                print("[transcriber] downloading assets…")
                try await request.downloadAndInstall()
                print("[transcriber] assets installed")
            } else {
                print("[transcriber] assets already installed")
            }
        } catch {
            print("[transcriber] asset step failed: \(error)")
            throw error
        }
        return transcriber
    }

    static func transcribe(fileAt url: URL) async throws -> String {
        do {
            return try await transcribeWithAnalyzer(fileAt: url)
        } catch let error as NSError where error.domain == SFSpeechErrorDomain {
            // Assets couldn't be obtained (e.g. iOS Simulator can't download speech assets): use the classic recognizer.
            print("[transcriber] SpeechAnalyzer unavailable (\(error.localizedDescription)); falling back to SFSpeechRecognizer")
            do { return try await transcribeWithLegacyRecognizer(fileAt: url) }
            catch {
                #if targetEnvironment(simulator)
                throw TranscriberError.simulator
                #else
                throw error
                #endif
            }
        }
    }

    private static func transcribeWithAnalyzer(fileAt url: URL) async throws -> String {
        let transcriber = try await makeTranscriber()
        let analyzer = SpeechAnalyzer(modules: [transcriber])

        // Start collecting results before feeding audio.
        let collector = Task<String, Error> {
            var pieces: [String] = []
            for try await result in transcriber.results where result.isFinal {
                pieces.append(String(result.text.characters))
            }
            return pieces.joined(separator: " ")
        }

        let file = try AVAudioFile(forReading: url)
        if let last = try await analyzer.analyzeSequence(from: file) {
            try await analyzer.finalizeAndFinish(through: last)
        } else {
            await analyzer.cancelAndFinishNow()
        }
        let text = try await collector.value
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw TranscriberError.empty }
        return text
    }

    // MARK: - Fallback: SFSpeechRecognizer (pre-iOS 26 API; prefers on-device recognition when offered)

    private static func transcribeWithLegacyRecognizer(fileAt url: URL) async throws -> String {
        let status = await withCheckedContinuation { (c: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { c.resume(returning: $0) }
        }
        guard status == .authorized else { throw TranscriberError.notAuthorized }
        guard let recognizer = SFSpeechRecognizer(locale: .current) ?? SFSpeechRecognizer(), recognizer.isAvailable else {
            throw TranscriberError.unsupportedLocale
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition { request.requiresOnDeviceRecognition = true }
        let text: String = try await withCheckedThrowingContinuation { continuation in
            nonisolated(unsafe) var finished = false
            recognizer.recognitionTask(with: request) { result, error in
                guard !finished else { return }
                if let error { finished = true; continuation.resume(throwing: error); return }
                if let result, result.isFinal { finished = true; continuation.resume(returning: result.bestTranscription.formattedString) }
            }
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TranscriberError.empty }
        return trimmed
    }
}

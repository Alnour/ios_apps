import AVFAudio
import SwiftUI

@MainActor
@Observable
final class AudioPlayback {
    private var player: AVAudioPlayer?
    private var timer: Task<Void, Never>?
    private(set) var isPlaying = false
    private(set) var progress: Double = 0
    private(set) var duration: TimeInterval = 0

    func load(_ url: URL) {
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        duration = player?.duration ?? 0
    }
    func toggle() {
        guard let player else { return }
        if player.isPlaying { player.pause(); isPlaying = false; timer?.cancel() }
        else {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            player.play(); isPlaying = true
            timer = Task { [weak self] in
                while let self, !Task.isCancelled, self.isPlaying {
                    self.progress = player.duration > 0 ? player.currentTime / player.duration : 0
                    if !player.isPlaying { self.isPlaying = false; self.progress = 0 }
                    try? await Task.sleep(for: .milliseconds(100))
                }
            }
        }
    }
    func stop() { player?.stop(); isPlaying = false; timer?.cancel() }
}

struct AudioPlayerView: View {
    let url: URL
    @State private var playback = AudioPlayback()

    var body: some View {
        HStack(spacing: 12) {
            Button { playback.toggle() } label: {
                Image(systemName: playback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
            }
            .buttonStyle(.plain)
            ProgressView(value: playback.progress)
            Text(playback.duration.clockString).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
        .onAppear { playback.load(url) }
        .onDisappear { playback.stop() }
    }
}

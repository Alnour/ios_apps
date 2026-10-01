import SwiftUI

struct StageBadge: View {
    let stage: NoteStage
    var body: some View {
        HStack(spacing: 4) {
            if stage.isBusy { ProgressView().controlSize(.mini) }
            Text(stage.label)
        }
        .font(.caption2.weight(.medium))
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(color.opacity(0.15), in: Capsule())
        .foregroundStyle(color)
    }
    private var color: Color {
        switch stage {
        case .ready: .green
        case .failed: .red
        case .transcribed: .blue
        default: .secondary
        }
    }
}

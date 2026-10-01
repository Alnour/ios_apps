import EventKit
import EventKitUI
import SwiftUI

/// System event editor, prefilled. Runs out of process on iOS 17+: no calendar permission needed.
struct EventEditView: UIViewControllerRepresentable {
    var title: String
    var notes: String
    var start: Date
    var onSaved: @MainActor @Sendable () -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = notes
        event.startDate = start
        event.endDate = start.addingTimeInterval(30 * 60)
        let vc = EKEventEditViewController()
        vc.eventStore = store
        vc.event = event
        vc.editViewDelegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: EKEventEditViewController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        let dismiss = self.dismiss
        let onSaved = self.onSaved
        return Coordinator { saved in
            if saved { onSaved() }
            dismiss()
        }
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onFinish: @MainActor @Sendable (Bool) -> Void
        init(onFinish: @escaping @MainActor @Sendable (Bool) -> Void) { self.onFinish = onFinish }
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            let saved = action == .saved
            let onFinish = self.onFinish
            Task { @MainActor in onFinish(saved) }
        }
    }
}

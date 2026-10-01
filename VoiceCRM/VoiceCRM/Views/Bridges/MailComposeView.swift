import MessageUI
import SwiftUI

/// MessageUI delegates are not main-actor annotated, so the coordinators stay nonisolated
/// and hop to the main actor to dismiss.
final class ComposeFinishCoordinator: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    let onFinish: @MainActor @Sendable () -> Void
    init(onFinish: @escaping @MainActor @Sendable () -> Void) { self.onFinish = onFinish }

    private func finish() {
        let onFinish = self.onFinish
        Task { @MainActor in onFinish() }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) { finish() }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) { finish() }
}

struct MailComposeView: UIViewControllerRepresentable {
    var to: [String]
    var subject: String
    var body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(to)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }
    func updateUIViewController(_ vc: MFMailComposeViewController, context: Context) {}
    func makeCoordinator() -> ComposeFinishCoordinator {
        let dismiss = self.dismiss
        return ComposeFinishCoordinator { dismiss() }
    }
}

struct MessageComposeView: UIViewControllerRepresentable {
    var recipients: [String]
    var body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = body
        return vc
    }
    func updateUIViewController(_ vc: MFMessageComposeViewController, context: Context) {}
    func makeCoordinator() -> ComposeFinishCoordinator {
        let dismiss = self.dismiss
        return ComposeFinishCoordinator { dismiss() }
    }
}

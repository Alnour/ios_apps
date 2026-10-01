import SwiftUI

struct DraftMessageView: View {
    let customer: Customer
    @State var channel: MessageChannel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("senderName") private var senderName = ""
    @State private var intent = ""
    @State private var text = ""
    @State private var drafting = false
    @State private var error: String?
    @State private var showingMail = false
    @State private var showingMessages = false

    private var canDraft: Bool { Intelligence.availability == .available && !intent.trimmingCharacters(in: .whitespaces).isEmpty && !drafting }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Channel", selection: $channel) {
                        ForEach(MessageChannel.allCases) { Label($0.label, systemImage: $0.symbol).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    LabeledContent("To", value: recipient ?? "—")
                }
                Section("What is this message for?") {
                    TextField("e.g. follow up on the proposal, confirm Tuesday's meeting", text: $intent, axis: .vertical)
                    TextField("Your name (for the sign-off)", text: $senderName)
                    Button {
                        Task { await draft() }
                    } label: {
                        HStack {
                            Label("Draft with Apple Intelligence", systemImage: "sparkles")
                            if drafting { Spacer(); ProgressView() }
                        }
                    }
                    .disabled(!canDraft)
                    AIUnavailableBanner()
                }
                Section("Message") {
                    TextEditor(text: $text).frame(minHeight: 180)
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
            }
            .navigationTitle("New \(channel.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(sendLabel) { send() }.disabled(recipient == nil || text.isEmpty)
                }
            }
            .sheet(isPresented: $showingMail) {
                let parts = Outreach.splitEmail(text)
                MailComposeView(to: [recipient ?? ""], subject: parts.subject, body: parts.body).ignoresSafeArea()
            }
            .sheet(isPresented: $showingMessages) {
                MessageComposeView(recipients: [recipient ?? ""], body: text).ignoresSafeArea()
            }
        }
    }

    private var recipient: String? { channel == .email ? customer.primaryEmail : customer.primaryPhone }
    private var sendLabel: String {
        switch channel {
        case .email: "Open in Mail"
        case .sms: "Open in Messages"
        case .whatsapp: "Open WhatsApp"
        }
    }

    private func draft() async {
        drafting = true; error = nil
        defer { drafting = false }
        do {
            let ctx = CustomerContext(customer)
            text = try await Intelligence.draft(for: ctx, channel: channel, intent: intent, senderName: senderName)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch { self.error = error.localizedDescription }
    }

    private func send() {
        guard let recipient else { return }
        switch channel {
        case .email:
            if Outreach.canUseMailSheet { showingMail = true }
            else if let url = Outreach.mailtoURL(to: recipient, subject: Outreach.splitEmail(text).subject, body: Outreach.splitEmail(text).body) { openURL(url) }
        case .sms:
            if Outreach.canUseMessageSheet { showingMessages = true }
            else if let url = Outreach.smsURL(to: recipient, body: text) { openURL(url) }
        case .whatsapp:
            if let url = Outreach.whatsappURL(to: recipient, body: text) { openURL(url) }
        }
    }
}

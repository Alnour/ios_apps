import SwiftData
import SwiftUI

/// Ask about one or several customers; answers come from the on-device model over the knowledge graph,
/// with every mentioned customer linked to their page.
struct AssistantView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Customer.familyName) private var customers: [Customer]
    @Environment(AssistantConversation.self) private var conversation
    @State private var input = ""
    @State private var path: [UUID] = []
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                if conversation.messages.isEmpty { emptyState } else { transcript }
                composer
            }
            .navigationTitle("Assistant")
            .navigationDestination(for: UUID.self) { id in
                if let c = customers.first(where: { $0.id == id }) { CustomerDetailView(customer: c) }
            }
            .toolbar {
                if !conversation.messages.isEmpty {
                    ToolbarItem(placement: .primaryAction) { Button("Clear", systemImage: "trash") { conversation.clear() } }
                }
            }
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "voicecrm", url.host == "customer", let id = UUID(uuidString: url.lastPathComponent) else { return .systemAction }
                path.append(id)
                return .handled
            })
        }
    }

    private var suggestions: [String] {
        var s = ["Who should I follow up with this week?", "Which customers mentioned a budget?"]
        if let c = customers.first { s.insert("What do I know about \(c.fullName)?", at: 0) }
        if customers.count >= 2 { s.append("Compare \(customers[0].givenName) and \(customers[1].givenName).") }
        return s
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles").font(.system(size: 40)).foregroundStyle(.tint).padding(.top, 40)
                Text("Ask about your customers").font(.title3.weight(.semibold))
                Text("Answers come from the facts and notes on this phone. Tap a name in the answer to open the customer.")
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 32)
                AIUnavailableBanner().padding(.horizontal)
                VStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { s in
                        Button { Task { await conversation.ask(s, in: context) } } label: {
                            Text(s).frame(maxWidth: .infinity, alignment: .leading).padding(12)
                                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(customers.isEmpty || Intelligence.availability != .available)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(conversation.messages) { m in
                        MessageBubble(message: m, customers: customers).id(m.id)
                    }
                    if conversation.isThinking {
                        HStack(spacing: 8) { ProgressView(); Text("Thinking…").foregroundStyle(.secondary) }
                            .padding(.horizontal).id("thinking")
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: conversation.messages.count) { _, _ in
                withAnimation { proxy.scrollTo(conversation.messages.last?.id, anchor: .bottom) }
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("Ask about a customer…", text: $input, axis: .vertical)
                .lineLimit(1...4).textFieldStyle(.roundedBorder).focused($focused)
                .onSubmit { send() }
            Button { send() } label: { Image(systemName: "arrow.up.circle.fill").font(.title) }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || conversation.isThinking)
        }
        .padding()
        .background(.bar)
    }

    private func send() {
        let q = input; input = ""
        Task { await conversation.ask(q, in: context) }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let customers: [Customer]

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            Text(attributed)
                .textSelection(.enabled)
                .padding(12)
                .background(message.role == .user ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary.opacity(0.5)), in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(message.role == .user ? .white : (message.isError ? .red : .primary))
            if message.role == .assistant, !message.customerIDs.isEmpty {
                HStack(spacing: 8) {
                    ForEach(message.customerIDs, id: \.self) { id in
                        if let c = customers.first(where: { $0.id == id }) {
                            NavigationLink(value: c.id) {
                                HStack(spacing: 6) { AvatarView(customer: c, size: 22); Text(c.fullName).font(.caption.weight(.medium)) }
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(.tint.opacity(0.12), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        .padding(.horizontal)
    }

    private var attributed: AttributedString {
        (try? AttributedString(markdown: message.text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(message.text)
    }
}

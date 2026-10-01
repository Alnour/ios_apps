import SwiftData
import SwiftUI

@main
struct VoiceCRMApp: App {
    @State private var pipeline = NotePipeline()
    @State private var conversation = AssistantConversation()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(pipeline)
                .environment(conversation)
        }
        .modelContainer(for: [Customer.self, VoiceNote.self, Fact.self, FollowUp.self])
    }
}

enum AppTab: String { case customers, followUps, assistant }

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(NotePipeline.self) private var pipeline
    @Environment(AssistantConversation.self) private var conversation
    @State private var tab: AppTab = .customers

    var body: some View {
        TabView(selection: $tab) {
            Tab("Customers", systemImage: "person.crop.rectangle.stack", value: .customers) { CustomersListView() }
            Tab("Follow-ups", systemImage: "checklist", value: .followUps) { FollowUpsView() }
            Tab("Assistant", systemImage: "sparkles", value: .assistant) { AssistantView() }
        }
        .task {
            // Warm the speech assets early so the first note doesn't wait on a download.
            try? await Transcriber.prepare()
            #if DEBUG
            await DebugSeed.runIfRequested(context: context, pipeline: pipeline, conversation: conversation)
            if let t = DebugSeed.requestedTab { tab = t }
            #endif
        }
    }
}

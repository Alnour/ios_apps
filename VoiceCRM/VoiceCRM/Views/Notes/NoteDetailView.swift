import SwiftData
import SwiftUI

struct NoteDetailView: View {
    @Bindable var note: VoiceNote
    @Environment(\.modelContext) private var context
    @Environment(NotePipeline.self) private var pipeline
    @State private var editingTranscript = false
    @State private var transcriptDraft = ""

    var body: some View {
        List {
            Section {
                AudioPlayerView(url: note.audioURL)
                HStack {
                    StageBadge(stage: note.stage)
                    Spacer()
                    Text(note.createdAt.formatted(date: .long, time: .shortened)).font(.caption).foregroundStyle(.secondary)
                }
                if let msg = note.failureMessage, note.stage == .failed {
                    Text(msg).font(.footnote).foregroundStyle(.red)
                    Button("Retry", systemImage: "arrow.clockwise") { Task { await pipeline.process(note, in: context) } }
                }
            }
            if let s = note.summary {
                Section("Summary") { Text(s) }
            }
            Section {
                if editingTranscript {
                    TextEditor(text: $transcriptDraft).frame(minHeight: 160)
                    HStack {
                        Button("Cancel") { editingTranscript = false }
                        Spacer()
                        Button("Save & re-extract") {
                            note.transcript = transcriptDraft; editingTranscript = false
                            try? context.save()
                            Task { await pipeline.extract(note, in: context) }
                        }.buttonStyle(.borderedProminent)
                    }
                } else if let t = note.transcript {
                    Text(t).textSelection(.enabled)
                } else {
                    Text("Not transcribed yet.").foregroundStyle(.secondary)
                }
            } header: {
                HStack {
                    Text("Transcript")
                    Spacer()
                    if note.transcript != nil, !editingTranscript, !note.stage.isBusy {
                        Button("Edit") { transcriptDraft = note.transcript ?? ""; editingTranscript = true }.font(.caption)
                        if Intelligence.availability == .available {
                            Button("Re-extract") { Task { await pipeline.extract(note, in: context) } }.font(.caption)
                        }
                    }
                }
            }
            if !note.facts.isEmpty, let customer = note.customer {
                Section("Facts from this note") {
                    ForEach(note.facts) { f in FactRow(fact: f, customer: customer) }
                }
            }
            if !note.followUps.isEmpty {
                Section("Follow-ups from this note") {
                    ForEach(note.followUps) { fu in FollowUpRow(followUp: fu, showCustomer: false, onSchedule: nil) }
                }
            }
        }
        .navigationTitle(note.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

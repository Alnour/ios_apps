import SwiftData
import SwiftUI

struct RecordNoteView: View {
    let customer: Customer
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(NotePipeline.self) private var pipeline
    @State private var recorder = AudioRecorder()
    @State private var fileName = AudioStore.newFileName()
    @State private var permissionDenied = false
    @State private var error: String?
    @State private var note: VoiceNote?

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()
                if let note {
                    ProcessingView(note: note)
                } else {
                    Text(customer.fullName).font(.title3.weight(.semibold))
                    Text(recorder.elapsed.clockString).font(.system(size: 48, weight: .light).monospacedDigit())
                    recordButton
                    Text(recorder.isRecording ? "Tap to stop" : "Tap to start recording")
                        .foregroundStyle(.secondary)
                    if permissionDenied {
                        Text("Microphone access is off. Enable it in Settings › VoiceCRM.").font(.footnote).foregroundStyle(.red).multilineTextAlignment(.center)
                    }
                    if let error { Text(error).font(.footnote).foregroundStyle(.red) }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Voice note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(note == nil ? "Cancel" : "Done") {
                        if recorder.isRecording { recorder.stop(); AudioStore.delete(fileName: fileName) }
                        dismiss()
                    }
                }
            }
            .task { Intelligence.prewarm() }
            .interactiveDismissDisabled(recorder.isRecording)
        }
    }

    private var recordButton: some View {
        Button { Task { await toggle() } } label: {
            ZStack {
                Circle().fill(.red.opacity(0.15))
                    .frame(width: 140 + CGFloat(recorder.level) * 60, height: 140 + CGFloat(recorder.level) * 60)
                    .animation(.easeOut(duration: 0.1), value: recorder.level)
                Circle().fill(.red).frame(width: 110, height: 110)
                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill").font(.system(size: 40)).foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 210)
    }

    private func toggle() async {
        if recorder.isRecording {
            let duration = recorder.stop()
            guard duration > 0.5 else { AudioStore.delete(fileName: fileName); error = "That was too short."; return }
            let n = VoiceNote(audioFileName: fileName, duration: duration, customer: customer)
            context.insert(n)
            try? context.save()
            note = n
            await pipeline.process(n, in: context)
        } else {
            guard await AudioRecorder.requestPermission() else { permissionDenied = true; return }
            do { error = nil; try recorder.start(to: AudioStore.url(for: fileName)) }
            catch { self.error = error.localizedDescription }
        }
    }
}

/// Live status while the pipeline transcribes and extracts; then the result.
struct ProcessingView: View {
    @Bindable var note: VoiceNote
    var body: some View {
        VStack(spacing: 16) {
            if note.stage.isBusy {
                ProgressView().controlSize(.large)
                Text(note.stage.label).font(.headline)
                Text(note.stage == .transcribing ? "Transcribing on your device…" : "Apple Intelligence is pulling out facts and follow-ups…")
                    .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            } else if note.stage == .failed {
                Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.red)
                Text(note.failureMessage ?? "Something went wrong.").multilineTextAlignment(.center)
                Text("The recording is saved; you can retry from the note.").font(.footnote).foregroundStyle(.secondary)
            } else {
                Image(systemName: "checkmark.circle.fill").font(.largeTitle).foregroundStyle(.green)
                Text(note.displayTitle).font(.headline)
                if let s = note.summary { Text(s).multilineTextAlignment(.center).foregroundStyle(.secondary) }
                HStack(spacing: 16) {
                    Label("\(note.facts.count) facts", systemImage: "tag")
                    Label("\(note.followUps.count) follow-ups", systemImage: "checklist")
                }
                .font(.footnote).foregroundStyle(.secondary)
                if note.stage == .transcribed { AIUnavailableBanner() }
            }
        }
        .padding()
    }
}

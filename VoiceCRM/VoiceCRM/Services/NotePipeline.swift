import Foundation
import Observation
import SwiftData

/// Drives a note from recorded → transcribing → transcribed → extracting → ready, persisting each stage.
@MainActor
@Observable
final class NotePipeline {
    private(set) var active: Set<UUID> = []

    func process(_ note: VoiceNote, in context: ModelContext) async {
        guard !active.contains(note.id) else { return }
        active.insert(note.id)
        defer { active.remove(note.id) }

        if note.transcript == nil {
            note.stage = .transcribing
            note.failureMessage = nil
            try? context.save()
            do {
                note.transcript = try await Transcriber.transcribe(fileAt: note.audioURL)
                note.stage = .transcribed
            } catch {
                note.stage = .failed
                note.failureMessage = error.localizedDescription
                try? context.save()
                return
            }
            try? context.save()
        }
        await extract(note, in: context)
    }

    /// (Re)runs the extraction step. Removes facts/follow-ups previously produced by this note.
    func extract(_ note: VoiceNote, in context: ModelContext) async {
        guard let transcript = note.transcript, let customer = note.customer else { return }
        guard Intelligence.availability == .available else {
            note.stage = .transcribed          // transcript is usable; AI part skipped
            try? context.save()
            return
        }
        note.stage = .extracting
        try? context.save()
        do {
            let extraction = ExtractionCleaner.clean(try await Intelligence.extract(transcript: transcript, customerName: customer.fullName, noteDate: note.createdAt), customerName: customer.fullName)
            for old in note.facts { context.delete(old) }
            for old in note.followUps where !old.isDone { context.delete(old) }
            note.title = extraction.title.nilIfBlank
            note.summary = extraction.summary.nilIfBlank
            for f in extraction.facts where !f.value.isEmpty {
                let cat = FactCategory(rawValue: String(describing: f.category)) ?? .other
                let fact = Fact(attribute: f.attribute, value: f.value, category: cat, customer: customer, sourceNote: note)
                context.insert(fact)
            }
            for f in extraction.followUps where !f.title.isEmpty {
                let due = DueDateParser.date(from: f.dueText, relativeTo: note.createdAt)
                let fu = FollowUp(title: f.title, dueDate: due, customer: customer, sourceNote: note)
                context.insert(fu)
            }
            note.stage = .ready
            try? context.save()
            await refreshOverview(for: customer, in: context)
        } catch {
            note.stage = .failed
            note.failureMessage = error.localizedDescription
            try? context.save()
        }
    }

    func refreshOverview(for customer: Customer, in context: ModelContext) async {
        guard Intelligence.availability == .available, !customer.facts.isEmpty || !customer.notes.isEmpty else { return }
        let snapshot = CustomerContext(customer)
        if let text = try? await Intelligence.overview(for: snapshot) {
            customer.overview = text.trimmingCharacters(in: .whitespacesAndNewlines)
            customer.overviewUpdatedAt = .now
            try? context.save()
        }
    }
}

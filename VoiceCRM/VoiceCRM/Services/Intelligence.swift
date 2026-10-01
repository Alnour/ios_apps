import Foundation
import FoundationModels

// MARK: - Generable shapes (kept small: the schema is sent to the model as tokens)

@Generable
struct NoteExtraction {
    @Guide(description: "Short title for the note, at most 6 words")
    var title: String
    @Guide(description: "Summary of the note in at most 2 sentences")
    var summary: String
    @Guide(description: "Durable facts about the customer worth remembering", .maximumCount(10))
    var facts: [FactDraft]
    @Guide(description: "Actions the speaker explicitly said they will do, one per commitment", .maximumCount(4))
    var followUps: [FollowUpDraft]
}

@Generable
struct FactDraft {
    @Guide(description: "What the fact is about, 1-3 words, e.g. spouse, budget, prefers")
    var attribute: String
    @Guide(description: "The value, short")
    var value: String
    var category: FactCategoryDraft
}

@Generable
enum FactCategoryDraft {
    case personal, business, preference, relationship, event, other
}

@Generable
struct FollowUpDraft {
    @Guide(description: "The action, imperative, at most 8 words")
    var title: String
    @Guide(description: "When it is due, exactly as said, e.g. 'next Tuesday'; empty if not said")
    var dueText: String
}

enum MessageChannel: String, CaseIterable, Identifiable {
    case email, sms, whatsapp
    var id: String { rawValue }
    var label: String {
        switch self {
        case .email: "Email"
        case .sms: "Message"
        case .whatsapp: "WhatsApp"
        }
    }
    var symbol: String {
        switch self {
        case .email: "envelope"
        case .sms: "message"
        case .whatsapp: "phone.bubble"
        }
    }
}

/// Plain-value snapshot of a customer, safe to carry into async model calls.
struct CustomerContext: Sendable {
    var name: String
    var company: String
    var facts: [String]          // "attribute: value"
    var recentSummaries: [String]
    var openFollowUps: [String]

    @MainActor
    init(_ c: Customer) {
        name = c.fullName
        company = c.company
        facts = c.facts.sorted { $0.createdAt > $1.createdAt }.map(\.line)
        recentSummaries = c.sortedNotes.prefix(3).compactMap(\.summary)
        openFollowUps = c.openFollowUps.map(\.title)
    }

    /// Compact block for prompts; limits cap how many facts and note summaries are included.
    func block(factLimit: Int = 40, summaryLimit: Int = 3) -> String {
        var lines = ["Customer: \(name)" + (company.isEmpty ? "" : " (\(company))")]
        if facts.isEmpty, recentSummaries.isEmpty { lines.append("No facts or notes recorded yet.") }
        if !facts.isEmpty { lines.append("Known facts:\n" + facts.prefix(factLimit).map { "- " + $0 }.joined(separator: "\n")) }
        if !recentSummaries.isEmpty, summaryLimit > 0 { lines.append("Recent notes:\n" + recentSummaries.prefix(summaryLimit).map { "- " + $0 }.joined(separator: "\n")) }
        if !openFollowUps.isEmpty { lines.append("Open follow-ups:\n" + openFollowUps.map { "- " + $0 }.joined(separator: "\n")) }
        return lines.joined(separator: "\n")
    }
}

enum IntelligenceError: LocalizedError {
    case unavailable(String)
    case tooLong
    var errorDescription: String? {
        switch self {
        case .unavailable(let why): why
        case .tooLong: "There is too much information for the on-device model. Try a shorter note."
        }
    }
}

/// Apple Intelligence (on-device Foundation Models). One fresh session per task; 4096-token window per session.
enum Intelligence {
    static let inputBudget = 2_500   // tokens of transcript per extraction call

    enum Availability: Equatable {
        case available
        case unavailable(String)
    }

    static var availability: Availability {
        switch SystemLanguageModel.default.availability {
        case .available: return .available
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return .unavailable("This device doesn't support Apple Intelligence.")
            case .appleIntelligenceNotEnabled: return .unavailable("Turn on Apple Intelligence in Settings to extract facts and draft messages.")
            case .modelNotReady: return .unavailable("Apple Intelligence is still downloading its model. Try again shortly.")
            @unknown default: return .unavailable("Apple Intelligence is unavailable.")
            }
        }
    }

    static func requireAvailable() throws {
        if case .unavailable(let why) = availability { throw IntelligenceError.unavailable(why) }
    }

    static func tokenCount(_ text: String) async -> Int {
        if #available(iOS 26.4, *), let n = try? await SystemLanguageModel.default.tokenCount(for: text) { return n }
        return TranscriptChunker.estimateTokens(text)
    }

    /// Warm the model right before a likely call (e.g. when the record screen opens).
    static func prewarm() {
        guard availability == .available else { return }
        LanguageModelSession().prewarm()
    }

    // MARK: Extraction

    static func extract(transcript: String, customerName: String, noteDate: Date) async throws -> NoteExtraction {
        try requireAvailable()
        let chunks = TranscriptChunker.chunks(of: transcript, maxTokens: inputBudget)
        var merged: NoteExtraction?
        var carry = ""
        for chunk in chunks {
            let part = try await extractChunk(chunk, customerName: customerName, noteDate: noteDate, previousSummary: carry)
            carry = part.summary
            merged = merged.map { Self.merge($0, part) } ?? part
        }
        guard let merged else { throw TranscriberError.empty }
        return merged
    }

    private static func extractChunk(_ text: String, customerName: String, noteDate: Date, previousSummary: String) async throws -> NoteExtraction {
        let instructions = """
        You turn a salesperson's spoken note about one customer into CRM data. \
        Facts are durable things about the customer: family, role, company, budget, preferences, people they mention, upcoming events. \
        Do not record the note's own date, the meeting itself, or that they are a customer. \
        Follow-ups are only the actions the salesperson explicitly said they would do, each listed once with its due time if said. \
        Be concise and literal; do not invent.
        """
        var prompt = "Customer: \(customerName). Note date: \(noteDate.formatted(date: .long, time: .omitted)).\n"
        if !previousSummary.isEmpty { prompt += "Earlier part of this note, summarised: \(previousSummary)\n" }
        prompt += "Note:\n\(text)"
        return try await withContextRetry {
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: prompt, generating: NoteExtraction.self).content
        } fallback: {
            // Halve the input and try once more.
            let shorter = String(text.prefix(text.count / 2))
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: "Customer: \(customerName).\nNote:\n\(shorter)", generating: NoteExtraction.self).content
        }
    }

    static func merge(_ a: NoteExtraction, _ b: NoteExtraction) -> NoteExtraction {
        var out = a
        out.summary = [a.summary, b.summary].filter { !$0.isEmpty }.joined(separator: " ")
        for f in b.facts where !a.facts.contains(where: { $0.attribute.lowercased() == f.attribute.lowercased() && $0.value.lowercased() == f.value.lowercased() }) {
            out.facts.append(f)
        }
        for f in b.followUps where !a.followUps.contains(where: { $0.title.lowercased() == f.title.lowercased() }) {
            out.followUps.append(f)
        }
        return out
    }

    // MARK: Overview

    static func overview(for context: CustomerContext) async throws -> String {
        try requireAvailable()
        let instructions = "You write a brief 'where we stand' overview of a customer for a salesperson. One paragraph, at most 4 sentences, plain language, no headings."
        return try await withContextRetry {
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: context.block()).content
        } fallback: {
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: context.block(factLimit: 15)).content
        }
    }

    // MARK: Drafting

    static func draft(for context: CustomerContext, channel: MessageChannel, intent: String, senderName: String) async throws -> String {
        try requireAvailable()
        let style: String = switch channel {
        case .email: "an email: first line is 'Subject: …', then a blank line, then the body of at most 150 words, ending with the sender's first name"
        case .sms: "a text message of at most 60 words, friendly, no subject line, no sign-off block"
        case .whatsapp: "a WhatsApp message of at most 60 words, warm and casual, no subject line"
        }
        let instructions = "You draft \(style). Sender: \(senderName.isEmpty ? "the salesperson" : senderName). Use the customer's facts only where relevant. Never invent commitments."
        let prompt = context.block(factLimit: 25) + "\n\nPurpose of the message: \(intent)"
        return try await withContextRetry {
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: prompt).content
        } fallback: {
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: context.block(factLimit: 8) + "\n\nPurpose: \(intent)").content
        }
    }

    // MARK: Helpers

    private static func withContextRetry<T>(_ op: () async throws -> T, fallback: () async throws -> T) async throws -> T {
        do { return try await op() }
        catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            do { return try await fallback() }
            catch LanguageModelSession.GenerationError.exceededContextWindowSize { throw IntelligenceError.tooLong }
        }
    }
}

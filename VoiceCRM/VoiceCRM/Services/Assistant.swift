import Foundation
import FoundationModels
import Observation
import SwiftData

/// Finds the customers a question is about: explicit name/company mentions first, then keyword hits in facts and notes.
enum Retriever {
    @MainActor
    static func customers(for question: String, in context: ModelContext, limit: Int = 6) -> (mentioned: [Customer], related: [Customer]) {
        let all = (try? context.fetch(FetchDescriptor<Customer>())) ?? []
        let q = question.lowercased()
        let words = Set(q.split { !$0.isLetter && !$0.isNumber }.map(String.init).filter { $0.count >= 3 })

        // 1. Mentions: full name, family name, given name (if unique), company.
        var mentioned: [Customer] = []
        for c in all {
            let given = c.givenName.lowercased(), family = c.familyName.lowercased(), company = c.company.lowercased()
            let givenUnique = all.filter { $0.givenName.lowercased() == given }.count == 1
            let hit = (!c.fullName.isEmpty && q.contains(c.fullName.lowercased()))
                || (family.count >= 3 && words.contains(family))
                || (givenUnique && given.count >= 3 && words.contains(given))
                || (company.count >= 3 && q.contains(company))
            if hit { mentioned.append(c) }
        }

        // 2. Keyword hits over facts, summaries and transcripts.
        var score: [UUID: Int] = [:]
        let stop: Set<String> = ["what", "who", "when", "where", "which", "about", "tell", "know", "does", "have", "with", "from", "that", "this", "their", "them", "they", "should", "could", "would", "the", "and", "for", "are", "was", "has", "did", "any", "all", "how", "give", "show", "list", "overview", "customer", "customers", "note", "notes", "week", "month", "today"]
        let terms = words.subtracting(stop)
        if !terms.isEmpty {
            for c in all where !mentioned.contains(where: { $0.id == c.id }) {
                var s = 0
                for f in c.facts { for t in terms where f.value.lowercased().contains(t) || f.attribute.lowercased().contains(t) { s += 3 } }
                for n in c.notes {
                    let text = ((n.summary ?? "") + " " + (n.transcript ?? "")).lowercased()
                    for t in terms where text.contains(t) { s += 1 }
                }
                if s > 0 { score[c.id] = s }
            }
        }
        let related = score.sorted { $0.value > $1.value }.prefix(limit).compactMap { entry in all.first { $0.id == entry.key } }
        return (mentioned, related)
    }
}

struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    var text: String                 // markdown; customer mentions are links voicecrm://customer/<uuid>
    var customerIDs: [UUID] = []
    var isError = false
}

/// A conversation with the on-device model about the customer knowledge graph.
@MainActor
@Observable
final class AssistantConversation {
    private(set) var messages: [ChatMessage] = []
    private(set) var isThinking = false
    static let promptBudget = 2_800      // tokens; leaves room for the schema-free answer

    func clear() { messages.removeAll() }

    func ask(_ question: String, in context: ModelContext) async {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !isThinking else { return }
        messages.append(ChatMessage(role: .user, text: q))
        isThinking = true
        defer { isThinking = false }
        do {
            try Intelligence.requireAvailable()
            let (mentioned, related) = Retriever.customers(for: q, in: context)
            let all = (try? context.fetch(FetchDescriptor<Customer>())) ?? []
            var focus = mentioned + related
            if focus.isEmpty { focus = Array(all.prefix(12)) }      // general question: the roster
            let prompt = await buildPrompt(question: q, focus: focus, roster: all, detailed: !mentioned.isEmpty || !related.isEmpty)
            let instructions = """
            You are a CRM assistant. The data below is everything that is known; it comes from the user's own notes. \
            Answer only from that data and never add people, numbers or events that are not in it. \
            If a customer has no facts or notes recorded, say that nothing has been recorded yet. \
            Be brief and specific; plain sentences, no headings. Refer to customers by their full name exactly as written in the data.
            """
            let session = LanguageModelSession(instructions: instructions)
            let answer = try await session.respond(to: prompt).content.trimmingCharacters(in: .whitespacesAndNewlines)
            let (linked, ids) = Self.linkCustomers(in: answer, customers: all)
            messages.append(ChatMessage(role: .assistant, text: linked, customerIDs: ids))
        } catch {
            messages.append(ChatMessage(role: .assistant, text: error.localizedDescription, isError: true))
        }
    }

    // MARK: Prompt assembly within the token budget

    private func buildPrompt(question: String, focus: [Customer], roster: [Customer], detailed: Bool) async -> String {
        let snapshots = focus.map { CustomerContext($0) }
        let recent = messages.dropLast().suffix(4).map { ($0.role == .user ? "User: " : "Assistant: ") + String($0.text.prefix(300)) }
        func assemble(factLimit: Int, summaries: Int) -> String {
            var parts: [String] = []
            if detailed {
                parts.append(snapshots.map { $0.block(factLimit: factLimit, summaryLimit: summaries) }.joined(separator: "\n\n"))
            } else {
                parts.append("Customers:\n" + roster.prefix(25).map { c in
                    var line = "- \(c.fullName)" + (c.company.isEmpty ? "" : " (\(c.company))")
                    let open = c.openFollowUps
                    if !open.isEmpty { line += "; open follow-ups: " + open.prefix(3).map { $0.title + ($0.dueDate.map { " due \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "") }.joined(separator: ", ") }
                    if let o = c.overview?.split(separator: ".").first, summaries > 0 { line += "; \(o)." }
                    return line
                }.joined(separator: "\n"))
            }
            if !recent.isEmpty { parts.append("Earlier in this conversation:\n" + recent.joined(separator: "\n")) }
            parts.append("Question: \(question)\nAnswer from the data above only.")
            return parts.joined(separator: "\n\n")
        }
        var factLimit = 30, summaries = 3
        var prompt = assemble(factLimit: factLimit, summaries: summaries)
        while await Intelligence.tokenCount(prompt) > Self.promptBudget, factLimit > 4 {
            factLimit = max(4, factLimit / 2); summaries = max(0, summaries - 1)
            prompt = assemble(factLimit: factLimit, summaries: summaries)
        }
        return prompt
    }

    /// Turns customer names in the answer into markdown links. Longest names first so "Kate Bell" wins over "Kate".
    static func linkCustomers(in text: String, customers: [Customer]) -> (String, [UUID]) {
        var out = text
        var firstSeen: [UUID: Int] = [:]
        let candidates = customers.flatMap { c -> [(String, UUID)] in
            var names = [(c.fullName, c.id)]
            let givenUnique = customers.filter { $0.givenName == c.givenName }.count == 1
            if givenUnique, c.givenName.count >= 3 { names.append((c.givenName, c.id)) }
            return names
        }.sorted { $0.0.count > $1.0.count }
        for (name, id) in candidates where !name.isEmpty {
            guard let regex = try? NSRegularExpression(pattern: "(?<![\\w\\[])" + NSRegularExpression.escapedPattern(for: name) + "(?![\\w\\]])", options: [.caseInsensitive]) else { continue }
            let range = NSRange(out.startIndex..., in: out)
            let matches = regex.matches(in: out, options: [], range: range)
            guard !matches.isEmpty else { continue }
            let first = matches[0].range.location
            firstSeen[id] = min(firstSeen[id] ?? first, first)
            for m in matches.reversed() {
                guard let r = Range(m.range, in: out) else { continue }
                // Skip if this match already sits inside a link we inserted.
                out.replaceSubrange(r, with: "[\(out[r])](voicecrm://customer/\(id.uuidString))")
            }
        }
        let ids = firstSeen.sorted { $0.value < $1.value }.map(\.key)
        return (out, ids)
    }
}

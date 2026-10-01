import Foundation

enum TranscriptChunker {
    /// Rough token estimate when the model's own counter is unavailable (~3.5 chars/token in English).
    static func estimateTokens(_ text: String) -> Int { max(1, Int(Double(text.count) / 3.5)) }

    /// Split text on sentence boundaries into chunks whose estimated token count stays under `maxTokens`.
    static func chunks(of text: String, maxTokens: Int, estimate: (String) -> Int = estimateTokens) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        if estimate(trimmed) <= maxTokens { return [trimmed] }
        var sentences: [String] = []
        trimmed.enumerateSubstrings(in: trimmed.startIndex..., options: [.bySentences, .localized]) { s, _, _, _ in
            if let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty { sentences.append(s) }
        }
        if sentences.isEmpty { sentences = [trimmed] }
        var out: [String] = []
        var current = ""
        for s in sentences {
            let candidate = current.isEmpty ? s : current + " " + s
            if estimate(candidate) > maxTokens, !current.isEmpty {
                out.append(current); current = s
            } else {
                current = candidate
            }
        }
        if !current.isEmpty { out.append(current) }
        return out
    }
}

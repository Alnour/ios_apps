import Foundation

/// Deterministic clean-up of what the small on-device model returns: drops restatements and duplicates.
enum ExtractionCleaner {
    static func clean(_ e: NoteExtraction, customerName: String) -> NoteExtraction {
        var out = e
        let nameParts = Set(customerName.lowercased().split(separator: " ").map(String.init))
        let junkAttributes: Set<String> = ["other", "name", "customer", "client", "note", "date", "meeting"]
        let junkValues: Set<String> = ["customer", "client", "prospect", "unknown", "n/a", "none", ""]

        var seenFacts = Set<String>()
        out.facts = e.facts.filter { f in
            let attr = f.attribute.trimmingCharacters(in: .whitespaces).lowercased()
            let value = f.value.trimmingCharacters(in: .whitespaces).lowercased()
            if junkAttributes.contains(attr) || junkValues.contains(value) { return false }
            if attr == "relationship", junkValues.contains(value) { return false }
            if value.contains("'s name") || nameParts.contains(value) { return false }     // "Kate's name", "Kate"
            if attr.isEmpty || value.isEmpty { return false }
            return seenFacts.insert(attr + "=" + value).inserted
        }

        var seenTitles = Set<String>()
        let generic = try! NSRegularExpression(pattern: "^(follow[- ]?up|call|email|check[- ]?in)( (with )?(him|her|them|kate|customer|client))?\\.?$", options: [.caseInsensitive])
        out.followUps = e.followUps.filter { f in
            let title = f.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = title.lowercased()
            guard !title.isEmpty, seenTitles.insert(key).inserted else { return false }
            let isGeneric = generic.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)) != nil
            return !isGeneric
        }
        // If everything was generic, keep the first one so the commitment isn't lost.
        if out.followUps.isEmpty, let first = e.followUps.first(where: { !$0.title.isEmpty }) { out.followUps = [first] }
        return out
    }
}

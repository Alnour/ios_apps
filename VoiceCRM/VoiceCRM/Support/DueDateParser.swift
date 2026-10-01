import Foundation

enum DueDateParser {
    /// Resolve a phrase like "next Tuesday" or "in two weeks" to a date, relative to `reference`.
    /// NSDataDetector always resolves relative to now, so the day offset from now is re-applied to the reference date.
    static func date(from phrase: String, relativeTo reference: Date = .now, now: Date = .now, calendar: Calendar = .current) -> Date? {
        let text = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = detector.firstMatch(in: text, options: [], range: range), let detected = match.date else { return nil }
        let dayDelta = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: detected)).day ?? 0
        var time = calendar.dateComponents([.hour, .minute], from: detected)
        // Phrases without a time land at noon; 9:00 is a better default calendar slot.
        if time.hour == 12, time.minute == 0 { time.hour = 9 }
        guard let day = calendar.date(byAdding: .day, value: dayDelta, to: calendar.startOfDay(for: reference)) else { return nil }
        return calendar.date(bySettingHour: time.hour ?? 9, minute: time.minute ?? 0, second: 0, of: day)
    }
}

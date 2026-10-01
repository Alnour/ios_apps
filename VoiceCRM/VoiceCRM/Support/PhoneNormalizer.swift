import Foundation

enum PhoneNormalizer {
    /// Digits only, suitable for wa.me and sms: links. Keeps a leading country code; "00" prefix becomes nothing.
    static func digits(_ raw: String) -> String {
        var s = raw.filter { $0.isNumber || $0 == "+" }
        if s.hasPrefix("+") { s.removeFirst() }
        if s.hasPrefix("00") { s.removeFirst(2) }
        return s.filter(\.isNumber)
    }
}

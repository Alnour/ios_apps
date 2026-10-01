import Foundation
import MessageUI
import UIKit

/// Hands a message to Mail / Messages / WhatsApp. The compose sheets are presented by the views
/// (see Bridges); these helpers build the URL fallbacks used when a sheet isn't available (simulator, no account).
enum Outreach {
    @MainActor static var canUseMailSheet: Bool { MFMailComposeViewController.canSendMail() }
    @MainActor static var canUseMessageSheet: Bool { MFMessageComposeViewController.canSendText() }
    @MainActor static var hasWhatsApp: Bool {
        URL(string: "whatsapp://send").map { UIApplication.shared.canOpenURL($0) } ?? false
    }

    static func mailtoURL(to address: String, subject: String, body: String) -> URL? {
        var c = URLComponents(); c.scheme = "mailto"; c.path = address
        c.queryItems = [URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: body)]
        return c.url
    }
    static func smsURL(to phone: String, body: String) -> URL? {
        var c = URLComponents(); c.scheme = "sms"; c.path = "+" + PhoneNormalizer.digits(phone)
        c.queryItems = [URLQueryItem(name: "body", value: body)]
        return c.url
    }
    static func whatsappURL(to phone: String, body: String) -> URL? {
        var c = URLComponents(); c.scheme = "https"; c.host = "wa.me"; c.path = "/" + PhoneNormalizer.digits(phone)
        c.queryItems = body.isEmpty ? nil : [URLQueryItem(name: "text", value: body)]
        return c.url
    }

    /// Splits an AI email draft of the form "Subject: …\n\nbody" into its parts.
    static func splitEmail(_ draft: String) -> (subject: String, body: String) {
        let lines = draft.split(separator: "\n", omittingEmptySubsequences: false)
        if let first = lines.first, first.lowercased().hasPrefix("subject:") {
            let subject = first.dropFirst("subject:".count).trimmingCharacters(in: .whitespaces)
            let body = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            return (subject, body)
        }
        return ("", draft)
    }
}

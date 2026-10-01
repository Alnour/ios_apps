import Foundation
import SwiftData

enum FactCategory: String, Codable, CaseIterable, Identifiable {
    case personal, business, preference, relationship, event, other
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .personal: "person"
        case .business: "briefcase"
        case .preference: "heart"
        case .relationship: "person.2"
        case .event: "calendar"
        case .other: "tag"
        }
    }
}

/// One edge of the customer's knowledge graph: customer —attribute→ value.
@Model
final class Fact {
    @Attribute(.unique) var id: UUID
    var attribute: String
    var value: String
    var categoryRaw: String
    var createdAt: Date

    var customer: Customer?
    var sourceNote: VoiceNote?

    init(attribute: String, value: String, category: FactCategory, customer: Customer, sourceNote: VoiceNote? = nil) {
        self.id = UUID()
        self.attribute = attribute
        self.value = value
        self.categoryRaw = category.rawValue
        self.createdAt = .now
        self.customer = customer
        self.sourceNote = sourceNote
    }

    var category: FactCategory {
        get { FactCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    /// Compact line used when feeding the model.
    var line: String { "\(attribute): \(value)" }
}

import Foundation
import SwiftData

@Model
final class FollowUp {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date?
    var isDone: Bool
    var scheduledAt: Date?
    var createdAt: Date

    var customer: Customer?
    var sourceNote: VoiceNote?

    init(title: String, dueDate: Date? = nil, customer: Customer, sourceNote: VoiceNote? = nil) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.isDone = false
        self.createdAt = .now
        self.customer = customer
        self.sourceNote = sourceNote
    }

    var isOverdue: Bool {
        guard let dueDate, !isDone else { return false }
        return dueDate < Calendar.current.startOfDay(for: .now)
    }

    static func byDue(_ a: FollowUp, _ b: FollowUp) -> Bool {
        switch (a.dueDate, b.dueDate) {
        case let (x?, y?): return x < y
        case (nil, _?): return false
        case (_?, nil): return true
        default: return a.createdAt < b.createdAt
        }
    }
}

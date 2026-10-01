import Foundation
import SwiftData

@Model
final class Customer {
    @Attribute(.unique) var id: UUID
    var givenName: String
    var familyName: String
    var company: String
    var jobTitle: String
    var emails: [String]
    var phones: [String]
    @Attribute(.externalStorage) var thumbnail: Data?
    var contactIdentifier: String?
    var createdAt: Date
    var overview: String?
    var overviewUpdatedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \VoiceNote.customer) var notes: [VoiceNote]
    @Relationship(deleteRule: .cascade, inverse: \Fact.customer) var facts: [Fact]
    @Relationship(deleteRule: .cascade, inverse: \FollowUp.customer) var followUps: [FollowUp]

    init(givenName: String, familyName: String, company: String = "", jobTitle: String = "",
         emails: [String] = [], phones: [String] = [], thumbnail: Data? = nil, contactIdentifier: String? = nil) {
        self.id = UUID()
        self.givenName = givenName
        self.familyName = familyName
        self.company = company
        self.jobTitle = jobTitle
        self.emails = emails
        self.phones = phones
        self.thumbnail = thumbnail
        self.contactIdentifier = contactIdentifier
        self.createdAt = .now
        self.notes = []
        self.facts = []
        self.followUps = []
    }

    var fullName: String {
        let name = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? (company.isEmpty ? "Unnamed" : company) : name
    }
    var initials: String {
        let parts = [givenName, familyName].compactMap { $0.first.map(String.init) }
        return parts.isEmpty ? "?" : parts.joined()
    }
    var primaryEmail: String? { emails.first }
    var primaryPhone: String? { phones.first }
    var openFollowUps: [FollowUp] { followUps.filter { !$0.isDone }.sorted(by: FollowUp.byDue) }
    var sortedNotes: [VoiceNote] { notes.sorted { $0.createdAt > $1.createdAt } }
}

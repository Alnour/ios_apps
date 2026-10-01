import Foundation
import Testing
@testable import VoiceCRM

struct PhoneNormalizerTests {
    @Test func stripsFormatting() {
        #expect(PhoneNormalizer.digits("+1 (555) 123-4567") == "15551234567")
        #expect(PhoneNormalizer.digits("0044 20 7946 0958") == "442079460958")
        #expect(PhoneNormalizer.digits("555-1234") == "5551234")
    }
}

struct TranscriptChunkerTests {
    @Test func shortTextIsOneChunk() {
        #expect(TranscriptChunker.chunks(of: "Hello there.", maxTokens: 100) == ["Hello there."])
    }
    @Test func splitsOnSentencesUnderBudget() {
        let text = "One sentence here. Two sentences here. Three sentences here. Four sentences here."
        // 1 token per character makes the budget easy to reason about.
        let chunks = TranscriptChunker.chunks(of: text, maxTokens: 40) { $0.count }
        #expect(chunks.count == 3)   // "One…" + "Two…" fit in 40 chars together; the rest do not
        #expect(chunks.allSatisfy { $0.count <= 40 })
        #expect(chunks.joined(separator: " ") == text)
    }
    @Test func emptyGivesNothing() {
        #expect(TranscriptChunker.chunks(of: "  \n ", maxTokens: 10).isEmpty)
    }
}

struct DueDateParserTests {
    @Test func relativePhraseShiftsFromReference() throws {
        let now = Date()
        let reference = now.addingTimeInterval(-7 * 86_400)   // note recorded a week ago
        let d = try #require(DueDateParser.date(from: "in two weeks", relativeTo: reference, now: now))
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: reference), to: cal.startOfDay(for: d)).day ?? 0
        #expect(days == 14)
        #expect(Calendar.current.component(.hour, from: d) == 9)
    }
    @Test func nothingForPlainText() {
        #expect(DueDateParser.date(from: "when convenient") == nil)
        #expect(DueDateParser.date(from: "") == nil)
    }
}

struct OutreachTests {
    @Test func splitsEmailDraft() {
        let (s, b) = Outreach.splitEmail("Subject: Proposal follow-up\n\nHi Kate,\nThanks.")
        #expect(s == "Proposal follow-up")
        #expect(b == "Hi Kate,\nThanks.")
        let (s2, b2) = Outreach.splitEmail("Just a body")
        #expect(s2.isEmpty && b2 == "Just a body")
    }
    @Test func buildsURLs() {
        #expect(Outreach.whatsappURL(to: "+1 555 123 4567", body: "hi there")?.absoluteString == "https://wa.me/15551234567?text=hi%20there")
        #expect(Outreach.smsURL(to: "555 1234", body: "x")?.absoluteString == "sms:+5551234?body=x")
        #expect(Outreach.mailtoURL(to: "a@b.c", subject: "S", body: "B")?.absoluteString == "mailto:a@b.c?subject=S&body=B")
    }
}

struct IntelligenceMergeTests {
    @Test func mergeDeduplicates() {
        let a = NoteExtraction(title: "T", summary: "A.", facts: [FactDraft(attribute: "spouse", value: "Ana", category: .personal)], followUps: [FollowUpDraft(title: "Call", dueText: "")])
        let b = NoteExtraction(title: "T2", summary: "B.", facts: [FactDraft(attribute: "Spouse", value: "ana", category: .personal), FactDraft(attribute: "budget", value: "50k", category: .business)], followUps: [FollowUpDraft(title: "call", dueText: "")])
        let m = Intelligence.merge(a, b)
        #expect(m.summary == "A. B.")
        #expect(m.facts.count == 2)
        #expect(m.followUps.count == 1)
    }
}

import SwiftData

@MainActor
struct AssistantLinkingTests {
    private func container() throws -> ModelContainer {
        try ModelContainer(for: Customer.self, VoiceNote.self, Fact.self, FollowUp.self,
                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    @Test func linksFullAndUniqueFirstNames() throws {
        let c = try container()
        let kate = Customer(givenName: "Kate", familyName: "Bell", company: "Creative Consulting")
        let john = Customer(givenName: "John", familyName: "Appleseed")
        let john2 = Customer(givenName: "John", familyName: "Doe")
        for x in [kate, john, john2] { c.mainContext.insert(x) }
        let (text, ids) = AssistantConversation.linkCustomers(in: "Kate Bell prefers email. Kate also has a budget. John Appleseed and John Doe are new; John is ambiguous.", customers: [kate, john, john2])
        #expect(text.contains("[Kate Bell](voicecrm://customer/\(kate.id.uuidString))"))
        #expect(text.contains("[Kate](voicecrm://customer/\(kate.id.uuidString)) also"))
        #expect(text.contains("[John Appleseed](voicecrm://customer/\(john.id.uuidString))"))
        #expect(text.contains("[John Doe](voicecrm://customer/\(john2.id.uuidString))"))
        #expect(text.hasSuffix("John is ambiguous."))          // ambiguous first name stays plain
        #expect(ids == [kate.id, john.id, john2.id])
    }

    @Test func retrieverFindsMentionsAndKeywords() throws {
        let c = try container()
        let kate = Customer(givenName: "Kate", familyName: "Bell", company: "Creative Consulting")
        let omar = Customer(givenName: "Omar", familyName: "Haddad", company: "Haddad Logistics")
        c.mainContext.insert(kate); c.mainContext.insert(omar)
        c.mainContext.insert(Fact(attribute: "budget", value: "50k", category: .business, customer: kate))
        c.mainContext.insert(Fact(attribute: "spouse", value: "Lina", category: .personal, customer: omar))
        try c.mainContext.save()
        let byName = Retriever.customers(for: "what do I know about kate?", in: c.mainContext)
        #expect(byName.mentioned.map(\.id) == [kate.id])
        let byCompany = Retriever.customers(for: "anything on Haddad Logistics", in: c.mainContext)
        #expect(byCompany.mentioned.map(\.id) == [omar.id])
        let byKeyword = Retriever.customers(for: "who mentioned a budget?", in: c.mainContext)
        #expect(byKeyword.mentioned.isEmpty && byKeyword.related.map(\.id) == [kate.id])
    }
}

struct ExtractionCleanerTests {
    @Test func dropsJunkFactsAndGenericDuplicateFollowUps() {
        let raw = NoteExtraction(
            title: "T", summary: "S",
            facts: [FactDraft(attribute: "budget", value: "$50,000", category: .business),
                    FactDraft(attribute: "relationship", value: "customer", category: .relationship),
                    FactDraft(attribute: "other", value: "Kate's name", category: .other),
                    FactDraft(attribute: "spouse", value: "James", category: .personal),
                    FactDraft(attribute: "Spouse", value: "james", category: .personal)],
            followUps: [FollowUpDraft(title: "Send Revised Proposal", dueText: "Friday"),
                        FollowUpDraft(title: "Follow Up", dueText: ""),
                        FollowUpDraft(title: "Call Kate", dueText: "next Tuesday"),
                        FollowUpDraft(title: "Follow up", dueText: ""),
                        FollowUpDraft(title: "Confirm Kickoff", dueText: "next Tuesday")])
        let c = ExtractionCleaner.clean(raw, customerName: "Kate Bell")
        #expect(c.facts.map(\.attribute) == ["budget", "spouse"])
        #expect(c.followUps.map(\.title) == ["Send Revised Proposal", "Confirm Kickoff"])
    }
    @Test func keepsOneGenericFollowUpIfThatIsAllThereIs() {
        let raw = NoteExtraction(title: "", summary: "", facts: [], followUps: [FollowUpDraft(title: "Follow up", dueText: "next week")])
        #expect(ExtractionCleaner.clean(raw, customerName: "X").followUps.count == 1)
    }
}

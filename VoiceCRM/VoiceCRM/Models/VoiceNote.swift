import Foundation
import SwiftData

enum NoteStage: String, Codable, CaseIterable {
    case recorded, transcribing, transcribed, extracting, ready, failed

    var label: String {
        switch self {
        case .recorded: "Recorded"
        case .transcribing: "Transcribing…"
        case .transcribed: "Transcribed"
        case .extracting: "Extracting…"
        case .ready: "Ready"
        case .failed: "Failed"
        }
    }
    var isBusy: Bool { self == .transcribing || self == .extracting }
}

@Model
final class VoiceNote {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var duration: TimeInterval
    var audioFileName: String
    var transcript: String?
    var title: String?
    var summary: String?
    var stageRaw: String
    var failureMessage: String?

    var customer: Customer?
    @Relationship(deleteRule: .nullify, inverse: \Fact.sourceNote) var facts: [Fact]
    @Relationship(deleteRule: .nullify, inverse: \FollowUp.sourceNote) var followUps: [FollowUp]

    init(audioFileName: String, duration: TimeInterval, customer: Customer) {
        self.id = UUID()
        self.createdAt = .now
        self.duration = duration
        self.audioFileName = audioFileName
        self.stageRaw = NoteStage.recorded.rawValue
        self.customer = customer
        self.facts = []
        self.followUps = []
    }

    var stage: NoteStage {
        get { NoteStage(rawValue: stageRaw) ?? .recorded }
        set { stageRaw = newValue.rawValue }
    }
    var displayTitle: String { title ?? createdAt.formatted(date: .abbreviated, time: .shortened) }
    var audioURL: URL { AudioStore.url(for: audioFileName) }
}

import Foundation
import SwiftData

#if DEBUG
/// Debug-only: `-seed-audio /path/to/file.m4a` creates a sample customer with that recording and runs the pipeline,
/// so the whole flow can be exercised on the simulator from the command line.
enum DebugSeed {
    nonisolated(unsafe) static var seededCustomerID: UUID?
    static var requestedTab: AppTab? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-tab"), i + 1 < args.count else { return nil }
        return AppTab(rawValue: args[i + 1])
    }
    static var opensSeededCustomer: Bool { ProcessInfo.processInfo.arguments.contains("-open-seeded") }

    @MainActor
    static func runIfRequested(context: ModelContext, pipeline: NotePipeline, conversation: AssistantConversation) async {
        let args = ProcessInfo.processInfo.arguments
        if opensSeededCustomer, !args.contains("-seed-audio"),
           let existing = try? context.fetch(FetchDescriptor<Customer>(predicate: #Predicate { $0.familyName == "Bell" })).first {
            seededCustomerID = existing.id
        }
        guard let i = args.firstIndex(of: "-seed-audio"), i + 1 < args.count else { return }
        let source = URL(fileURLWithPath: args[i + 1])
        print("[seed] Apple Intelligence: \(Intelligence.availability)")

        let customer: Customer
        if let existing = try? context.fetch(FetchDescriptor<Customer>(predicate: #Predicate { $0.familyName == "Bell" })).first {
            customer = existing
        } else {
            customer = Customer(givenName: "Kate", familyName: "Bell", company: "Creative Consulting", jobTitle: "Producer",
                                emails: ["kate-bell@mac.com"], phones: ["(555) 564-8583"])
            context.insert(customer)
        }
        seededCustomerID = customer.id
        let fileName = AudioStore.newFileName()
        do { try FileManager.default.copyItem(at: source, to: AudioStore.url(for: fileName)) }
        catch { print("[seed] cannot copy audio: \(error)"); return }
        let note = VoiceNote(audioFileName: fileName, duration: 20, customer: customer)
        // `-seed-transcript "text"` skips transcription (the Simulator can't run either speech engine).
        if let t = args.firstIndex(of: "-seed-transcript"), t + 1 < args.count {
            note.transcript = args[t + 1]
            note.stage = .transcribed
        }
        context.insert(note)
        try? context.save()
        print("[seed] note created, processing…")
        await pipeline.process(note, in: context)
        print("[seed] stage=\(note.stage.rawValue) failure=\(note.failureMessage ?? "-")")
        print("[seed] title=\(note.title ?? "-")\n[seed] summary=\(note.summary ?? "-")")
        print("[seed] transcript=\(note.transcript ?? "-")")
        for f in note.facts { print("[seed] fact \(f.category.rawValue): \(f.attribute) = \(f.value)") }
        for f in note.followUps { print("[seed] follow-up: \(f.title) due=\(f.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "-")") }
        print("[seed] overview=\(customer.overview ?? "-")")

        // `-ask "question"` (repeatable) runs the assistant and prints the linked answer.
        for (j, a) in args.enumerated() where a == "-ask" && j + 1 < args.count {
            print("[ask] Q: \(args[j + 1])")
            await conversation.ask(args[j + 1], in: context)
            if let last = conversation.messages.last { print("[ask] A: \(last.text)\n[ask] links: \(last.customerIDs.count)") }
        }
    }
}
#endif

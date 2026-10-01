import SwiftData
import SwiftUI

struct CustomerDetailView: View {
    @Bindable var customer: Customer
    @Environment(\.modelContext) private var context
    @Environment(NotePipeline.self) private var pipeline
    @Environment(\.openURL) private var openURL

    @State private var showingRecorder = false
    @State private var draftChannel: MessageChannel?
    @State private var scheduling: FollowUp?
    @State private var showingSchedule = false
    @State private var showingEdit = false
    @State private var addingFact = false
    @State private var refreshingOverview = false

    var body: some View {
        List {
            header
            overviewSection
            factsSection
            followUpsSection
            notesSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(customer.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit details", systemImage: "pencil") { showingEdit = true }
                    Button("Add fact", systemImage: "plus.circle") { addingFact = true }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button { showingRecorder = true } label: {
                Label("Record a note", systemImage: "mic.fill")
                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .background(.bar)
        }
        .sheet(isPresented: $showingRecorder) { RecordNoteView(customer: customer) }
        .sheet(item: $draftChannel) { ch in DraftMessageView(customer: customer, channel: ch) }
        .sheet(isPresented: $showingSchedule) {
            EventEditView(title: "Meeting with \(customer.fullName)",
                          notes: scheduleNotes,
                          start: scheduling?.dueDate ?? nextHour) {
                scheduling?.scheduledAt = .now
                try? context.save()
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingEdit) { EditCustomerView(customer: customer) }
        .sheet(isPresented: $addingFact) { EditFactView(customer: customer, fact: nil) }
    }

    // MARK: Sections

    private var header: some View {
        Section {
            VStack(spacing: 12) {
                AvatarView(customer: customer, size: 72)
                VStack(spacing: 2) {
                    Text(customer.fullName).font(.title2.bold())
                    let sub = [customer.jobTitle, customer.company].filter { !$0.isEmpty }.joined(separator: " · ")
                    if !sub.isEmpty { Text(sub).foregroundStyle(.secondary) }
                }
                HStack(spacing: 10) {
                    actionButton(.email, enabled: customer.primaryEmail != nil)
                    actionButton(.sms, enabled: customer.primaryPhone != nil)
                    actionButton(.whatsapp, enabled: customer.primaryPhone != nil)
                    Button { scheduling = nil; showingSchedule = true } label: {
                        VStack { Image(systemName: "calendar.badge.plus"); Text("Schedule").font(.caption2).lineLimit(1).minimumScaleFactor(0.7) }
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }

    private func actionButton(_ ch: MessageChannel, enabled: Bool) -> some View {
        Button { draftChannel = ch } label: {
            VStack { Image(systemName: ch.symbol); Text(ch.label).font(.caption2).lineLimit(1).minimumScaleFactor(0.7) }.frame(maxWidth: .infinity)
        }
        .disabled(!enabled)
    }

    private var overviewSection: some View {
        Section {
            if let o = customer.overview {
                Text(o)
                if let at = customer.overviewUpdatedAt {
                    Text("Updated \(at.formatted(.relative(presentation: .named)))").font(.caption2).foregroundStyle(.tertiary)
                }
            } else {
                Text("Record a note and Apple Intelligence will summarise where things stand.").foregroundStyle(.secondary)
            }
            AIUnavailableBanner()
        } header: {
            HStack {
                Label("Overview", systemImage: "sparkles")
                Spacer()
                if refreshingOverview { ProgressView().controlSize(.small) }
                else if Intelligence.availability == .available, !customer.facts.isEmpty || !customer.notes.isEmpty {
                    Button("Regenerate") {
                        Task { refreshingOverview = true; await pipeline.refreshOverview(for: customer, in: context); refreshingOverview = false }
                    }.font(.caption)
                }
            }
        }
    }

    private var factsSection: some View {
        Section {
            if customer.facts.isEmpty {
                Text("Nothing known yet. Record a note, or add a fact from the ⋯ menu.").foregroundStyle(.secondary)
            }
            ForEach(FactCategory.allCases) { cat in
                let items = customer.facts.filter { $0.category == cat }.sorted { $0.createdAt > $1.createdAt }
                if !items.isEmpty {
                    Label(cat.label, systemImage: cat.symbol)
                        .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .listRowSeparator(.hidden)
                    ForEach(items) { f in FactRow(fact: f, customer: customer) }
                        .onDelete { idx in for i in idx { context.delete(items[i]) }; try? context.save() }
                }
            }
        } header: {
            HStack {
                Text("Facts (\(customer.facts.count))")
                Spacer()
                Button("Add", systemImage: "plus") { addingFact = true }.font(.caption).labelStyle(.titleAndIcon)
            }
        } footer: {
            if !customer.facts.isEmpty { Text("Tap a fact to edit it, swipe to delete. Facts come from your notes and feed the overview, drafts and the assistant.") }
        }
    }

    private var followUpsSection: some View {
        Section("Follow-ups") {
            let open = customer.openFollowUps
            if open.isEmpty { Text("No open follow-ups.").foregroundStyle(.secondary) }
            ForEach(open) { fu in
                FollowUpRow(followUp: fu, showCustomer: false) {
                    scheduling = fu; showingSchedule = true
                }
            }
            let done = customer.followUps.filter(\.isDone)
            if !done.isEmpty {
                DisclosureGroup("Done (\(done.count))") {
                    ForEach(done) { fu in FollowUpRow(followUp: fu, showCustomer: false, onSchedule: nil) }
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Voice notes") {
            if customer.notes.isEmpty { Text("No notes yet.").foregroundStyle(.secondary) }
            ForEach(customer.sortedNotes) { n in
                NavigationLink { NoteDetailView(note: n) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(n.displayTitle).font(.body.weight(.medium)).lineLimit(1)
                            Spacer()
                            StageBadge(stage: n.stage)
                        }
                        HStack {
                            Text(n.createdAt.formatted(date: .abbreviated, time: .shortened))
                            Text("·")
                            Text(n.duration.clockString)
                        }
                        .font(.caption).foregroundStyle(.secondary)
                        if let s = n.summary { Text(s).font(.subheadline).foregroundStyle(.secondary).lineLimit(2) }
                    }
                }
            }
            .onDelete { idx in
                let notes = customer.sortedNotes
                for i in idx { AudioStore.delete(fileName: notes[i].audioFileName); context.delete(notes[i]) }
                try? context.save()
            }
        }
    }

    private var nextHour: Date {
        let c = Calendar.current
        let next = c.date(byAdding: .hour, value: 1, to: .now) ?? .now
        return c.date(bySetting: .minute, value: 0, of: next) ?? next
    }
    private var scheduleNotes: String {
        var lines: [String] = []
        if let fu = scheduling { lines.append("Follow-up: \(fu.title)") }
        if let e = customer.primaryEmail { lines.append("Email: \(e)") }
        if let o = customer.overview { lines.append(""); lines.append(o) }
        return lines.joined(separator: "\n")
    }
}

struct FactRow: View {
    @Bindable var fact: Fact
    let customer: Customer
    @State private var editing = false
    var body: some View {
        Button { editing = true } label: {
            HStack(alignment: .firstTextBaseline) {
                Text(fact.attribute).foregroundStyle(.secondary).frame(width: 110, alignment: .leading).lineLimit(2)
                Text(fact.value).foregroundStyle(.primary)
                Spacer()
            }
        }
        .sheet(isPresented: $editing) { EditFactView(customer: customer, fact: fact) }
    }
}

struct EditFactView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let customer: Customer
    let fact: Fact?
    @State private var attribute = ""
    @State private var value = ""
    @State private var category: FactCategory = .other

    var body: some View {
        NavigationStack {
            Form {
                TextField("Attribute (e.g. spouse, budget)", text: $attribute)
                TextField("Value", text: $value, axis: .vertical)
                Picker("Category", selection: $category) {
                    ForEach(FactCategory.allCases) { Text($0.label).tag($0) }
                }
                if let f = fact, let n = f.sourceNote {
                    LabeledContent("From note", value: n.displayTitle)
                }
            }
            .navigationTitle(fact == nil ? "New fact" : "Edit fact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let f = fact { f.attribute = attribute; f.value = value; f.category = category }
                        else { context.insert(Fact(attribute: attribute, value: value, category: category, customer: customer)) }
                        try? context.save(); dismiss()
                    }.disabled(attribute.isEmpty || value.isEmpty)
                }
            }
            .onAppear { if let f = fact { attribute = f.attribute; value = f.value; category = f.category } }
        }
    }
}

struct FollowUpRow: View {
    @Bindable var followUp: FollowUp
    var showCustomer: Bool
    var onSchedule: (() -> Void)?
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                followUp.isDone.toggle(); try? context.save()
            } label: {
                Image(systemName: followUp.isDone ? "checkmark.circle.fill" : "circle").font(.title3)
            }
            .buttonStyle(.plain).foregroundStyle(followUp.isDone ? .green : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(followUp.title).strikethrough(followUp.isDone)
                HStack(spacing: 6) {
                    if showCustomer, let c = followUp.customer { Text(c.fullName) }
                    if let d = followUp.dueDate {
                        Text(d.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(followUp.isOverdue ? .red : .secondary)
                    }
                    if followUp.scheduledAt != nil { Label("Scheduled", systemImage: "calendar").labelStyle(.iconOnly) }
                }
                .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if let onSchedule, !followUp.isDone {
                Button("Schedule", systemImage: "calendar.badge.plus", action: onSchedule)
                    .labelStyle(.iconOnly).buttonStyle(.bordered).controlSize(.small)
            }
        }
    }
}

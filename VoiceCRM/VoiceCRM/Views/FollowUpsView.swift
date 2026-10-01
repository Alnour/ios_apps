import SwiftData
import SwiftUI

struct FollowUpsView: View {
    @Query(filter: #Predicate<FollowUp> { !$0.isDone }) private var open: [FollowUp]
    @State private var scheduling: FollowUp?
    @Environment(\.modelContext) private var context

    private var sorted: [FollowUp] { open.sorted(by: FollowUp.byDue) }
    private var overdue: [FollowUp] { sorted.filter(\.isOverdue) }
    private var upcoming: [FollowUp] { sorted.filter { !$0.isOverdue } }

    var body: some View {
        NavigationStack {
            Group {
                if open.isEmpty {
                    ContentUnavailableView("All caught up", systemImage: "checkmark.circle", description: Text("Follow-ups extracted from your notes will show up here."))
                } else {
                    List {
                        if !overdue.isEmpty {
                            Section("Overdue") { ForEach(overdue) { row($0) } }
                        }
                        Section(overdue.isEmpty ? "Open" : "Upcoming") { ForEach(upcoming) { row($0) } }
                    }
                }
            }
            .navigationTitle("Follow-ups")
            .navigationDestination(for: Customer.self) { CustomerDetailView(customer: $0) }
            .sheet(item: $scheduling) { fu in
                EventEditView(title: "Meeting with \(fu.customer?.fullName ?? "customer")",
                              notes: "Follow-up: \(fu.title)",
                              start: fu.dueDate ?? .now.addingTimeInterval(3600)) {
                    fu.scheduledAt = .now; try? context.save()
                }
                .ignoresSafeArea()
            }
        }
    }

    private func row(_ fu: FollowUp) -> some View {
        Group {
            if let c = fu.customer {
                NavigationLink(value: c) { FollowUpRow(followUp: fu, showCustomer: true) { scheduling = fu } }
            } else {
                FollowUpRow(followUp: fu, showCustomer: true) { scheduling = fu }
            }
        }
    }
}

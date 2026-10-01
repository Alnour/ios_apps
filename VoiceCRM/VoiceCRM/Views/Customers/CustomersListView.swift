import Contacts
import SwiftData
import SwiftUI

struct CustomersListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Customer.familyName), SortDescriptor(\Customer.givenName)]) private var customers: [Customer]
    @State private var query = ""
    @State private var showingPicker = false
    @State private var showingManual = false
    @State private var path: [UUID] = []

    private var filtered: [Customer] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return customers }
        return customers.filter { $0.fullName.localizedStandardContains(q) || $0.company.localizedStandardContains(q) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if customers.isEmpty {
                    ContentUnavailableView {
                        Label("No customers yet", systemImage: "person.crop.rectangle.stack")
                    } description: {
                        Text("Add someone from your Contacts, then record a voice note about them.")
                    } actions: {
                        Button("Add from Contacts") { showingPicker = true }.buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(filtered) { c in
                            NavigationLink(value: c.id) { CustomerRow(customer: c) }
                        }
                        .onDelete { idx in
                            for i in idx { delete(filtered[i]) }
                        }
                    }
                    .searchable(text: $query, prompt: "Name or company")
                }
            }
            .navigationTitle("Customers")
            .navigationDestination(for: UUID.self) { id in
                if let c = customers.first(where: { $0.id == id }) { CustomerDetailView(customer: c) }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("From Contacts", systemImage: "person.crop.circle.badge.plus") { showingPicker = true }
                        Button("Enter manually", systemImage: "square.and.pencil") { showingManual = true }
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingPicker) {
                ContactPickerView { contact in
                    let c = Customer.make(from: contact)
                    context.insert(c)
                    try? context.save()
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showingManual) { EditCustomerView(customer: nil) }
            #if DEBUG
            .task {
                // Wait for the seed to settle, then push the seeded customer.
                guard DebugSeed.opensSeededCustomer else { return }
                for _ in 0..<100 {
                    if let id = DebugSeed.seededCustomerID, customers.contains(where: { $0.id == id }) { path = [id]; return }
                    try? await Task.sleep(for: .milliseconds(200))
                }
            }
            #endif
        }
    }

    private func delete(_ c: Customer) {
        for n in c.notes { AudioStore.delete(fileName: n.audioFileName) }
        context.delete(c)
        try? context.save()
    }
}

struct CustomerRow: View {
    let customer: Customer
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(customer: customer)
            VStack(alignment: .leading, spacing: 2) {
                Text(customer.fullName).font(.body.weight(.medium))
                if !customer.company.isEmpty { Text(customer.company).font(.subheadline).foregroundStyle(.secondary) }
            }
            Spacer()
            let open = customer.openFollowUps.count
            if open > 0 {
                Text("\(open)").font(.caption.weight(.semibold))
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(.tint.opacity(0.15), in: Capsule())
            }
        }
    }
}

/// Minimal manual entry / edit form.
struct EditCustomerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let customer: Customer?
    @State private var given = ""
    @State private var family = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("First name", text: $given)
                TextField("Last name", text: $family)
                TextField("Company", text: $company)
                TextField("Email", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                TextField("Phone", text: $phone).keyboardType(.phonePad)
            }
            .navigationTitle(customer == nil ? "New customer" : "Edit customer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(given.isEmpty && family.isEmpty && company.isEmpty)
                }
            }
            .onAppear {
                if let c = customer {
                    given = c.givenName; family = c.familyName; company = c.company
                    email = c.primaryEmail ?? ""; phone = c.primaryPhone ?? ""
                }
            }
        }
    }

    private func save() {
        let emails = email.nilIfBlank.map { [$0] } ?? []
        let phones = phone.nilIfBlank.map { [$0] } ?? []
        if let c = customer {
            c.givenName = given; c.familyName = family; c.company = company
            c.emails = emails + c.emails.dropFirst(); c.phones = phones + c.phones.dropFirst()
        } else {
            context.insert(Customer(givenName: given, familyName: family, company: company, emails: emails, phones: phones))
        }
        try? context.save()
        dismiss()
    }
}

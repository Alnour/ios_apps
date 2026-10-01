import Contacts
import ContactsUI
import SwiftUI

/// Plain-value copy of what we keep from a picked contact (CNContact itself isn't Sendable).
struct PickedContact: Sendable {
    var givenName: String
    var familyName: String
    var company: String
    var jobTitle: String
    var emails: [String]
    var phones: [String]
    var thumbnail: Data?
    var identifier: String

    init(_ c: CNContact) {
        givenName = c.givenName
        familyName = c.familyName
        company = c.organizationName
        jobTitle = c.jobTitle
        emails = c.emailAddresses.map { String($0.value) }
        phones = c.phoneNumbers.map { $0.value.stringValue }
        thumbnail = c.thumbnailImageData
        identifier = c.identifier
    }
}

extension Customer {
    @MainActor
    static func make(from p: PickedContact) -> Customer {
        Customer(givenName: p.givenName, familyName: p.familyName, company: p.company, jobTitle: p.jobTitle,
                 emails: p.emails, phones: p.phones, thumbnail: p.thumbnail, contactIdentifier: p.identifier)
    }
}

/// System contact picker. Runs out of process: no Contacts permission needed.
struct ContactPickerView: UIViewControllerRepresentable {
    var onPick: @MainActor @Sendable (PickedContact) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let vc = CNContactPickerViewController()
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: CNContactPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        let dismiss = self.dismiss
        let onPick = self.onPick
        return Coordinator { picked in
            if let picked { onPick(picked) }
            dismiss()
        }
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onFinish: @MainActor @Sendable (PickedContact?) -> Void
        init(onFinish: @escaping @MainActor @Sendable (PickedContact?) -> Void) { self.onFinish = onFinish }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let picked = PickedContact(contact)
            let onFinish = self.onFinish
            Task { @MainActor in onFinish(picked) }
        }
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            let onFinish = self.onFinish
            Task { @MainActor in onFinish(nil) }
        }
    }
}

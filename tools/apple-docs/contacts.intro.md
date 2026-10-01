# Contacts / ContactsUI

## How our apps use it
- **Pick, don't read**: `CNContactPickerViewController` runs out-of-process and needs **no
  permission string**; the picked `CNContact` carries full data (name, org, emails, phones,
  thumbnail, `identifier`). Wrap in `UIViewControllerRepresentable`, implement
  `contactPicker(_:didSelect contact:)` and `contactPickerDidCancel`.
- Phone numbers come as `CNPhoneNumber` (`stringValue`); normalise to digits for `wa.me`/`sms:`.
- Only needed if the app wants to *re-sync* later: `CNContactStore` + `NSContactsUsageDescription`.

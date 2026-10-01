# EventKit / EventKitUI

## How our apps use it
- **Create via the system editor**: `EKEventEditViewController` with `eventStore = EKEventStore()`
  and a prefilled `EKEvent(eventStore:)` (`title`, `startDate`, `endDate`, `notes`). On iOS 17+
  it runs **out of process and needs no calendar permission or usage string**.
- Delegate `eventEditViewController(_:didCompleteWith action:)` → `.saved/.canceled/.deleted`;
  do **not** read the saved event back (we don't have calendar access) — record "scheduled" in
  our own model.
- Attendees cannot be set programmatically; put the customer's email in `notes`.

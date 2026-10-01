# MessageUI

## How our apps use it
- Email: `MFMailComposeViewController.canSendMail()` → compose sheet (`setToRecipients`,
  `setSubject`, `setMessageBody(_:isHTML:)`), delegate dismisses. If `false` (simulator, no Mail
  account) open `mailto:addr?subject=&body=` (percent-encode with `.urlQueryAllowed`).
- SMS/iMessage: `MFMessageComposeViewController.canSendText()` → sheet (`recipients`, `body`);
  fallback `sms:+123&body=...`.
- WhatsApp isn't MessageUI: `https://wa.me/<digits>?text=<encoded>` via `UIApplication.shared.open`;
  add `whatsapp` to `LSApplicationQueriesSchemes` to test `canOpenURL(whatsapp://)` for the label.
- Both sheets must be presented from a view controller → `UIViewControllerRepresentable` + Coordinator.

---
name: messageui
description: "MessageUI compose sheets: MFMailComposeViewController and MFMessageComposeViewController, with URL fallbacks"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,messageui,mail,sms,imessage"
---

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

## Reference (developer.apple.com, fetched 2026-10-01)

### MFMailComposeViewController  
*iOS: 3.0.0 -* · <https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller.md>


A standard view controller, whose interface lets the user manage, edit, and send email messages.

```
@MainActor class MFMailComposeViewController
```

#### Overview

Use this view controller to display a standard email interface inside your app. Before presenting the interface, populate the fields with initial values for the subject, email recipients, body text, and attachments of the email. After presenting the interface, the person can edit your initial values before sending the email.

The composition interface doesn’t guarantee the delivery of your email message; it only lets you construct the initial message and present it for user approval. The person may opt to cancel the composition interface which discards the message and its contents. If the person opts to send the message, the message queues in the user’s Mail app outbox. The Mail app is ultimately responsible for sending the message.

![Screenshot of the email composition view in Mail, indicating the fields for recipients, subject, and body. ](images/com.apple.messageui/media-4288076@2x.png)

> Important:
> You must not modify the view hierarchy presented by this view controller. However, you can customize the appearance of the interface using the <doc://com.apple.documentation/documentation/UIKit/UIAppearance> protocol.

An alternate way to compose emails is to create and open a URL that uses the `mailto` scheme. URLs of that type go directly to the built-in Mail app, which uses your URL to configure a message. For information about the structure of `mailto` URLs, see [Apple URL Scheme Reference](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007899).

##### Checking the availability of the composition interface

Before presenting the mail compose view controller, always call the [`canSendMail()`](/documentation/MessageUI/MFMailComposeViewController/canSendMail()) method to see if the person configured the current device to send email. If the person’s device isn’t set up for the delivery of email, you can notify the person or disable the email dispatch features in your application. You shouldn’t attempt to use this interface if the [`canSendMail()`](/documentation/MessageUI/MFMailComposeViewController/canSendMail()) method returns <doc://com.apple.documentation/documentation/Swift/false>.

**Swift:**

```swift
if !MFMailComposeViewController.canSendMail() {
    print("Mail services are not available")
    return
}
```

**Obj-C:**

```objc
if (![MFMailComposeViewController canSendMail]) {
   NSLog(@"Mail services are not available.");
   return;
}
```

##### Configuring and displaying the composition interface

After verifying that mail services are available, you can create and configure the mail composition view controller and then present it as any other view controller. Use the methods of this class to specify the subject, recipients, and message body of the email, including any attachments you want to send with the message. The sample code below shows how to configure the composition interface and present it modally. Always assign a delegate to the [`mailComposeDelegate`](/documentation/MessageUI/MFMailComposeViewController/mailComposeDelegate) property, because the delegate is responsible for dismissing the composition interface later.

**Swift:**

```swift
let composeVC = MFMailComposeViewController()
composeVC.mailComposeDelegate = self
 
// Configure the fields of the interface.
composeVC.setToRecipients(["address@example.com"])
composeVC.setSubject("Hello!")
composeVC.setMessageBody("Hello from California!", isHTML: false)
// Present the view controller modally.
self.present(composeVC, animated: true, completion: nil)
```

**Obj-C:**

```objc
MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
composeVC.mailComposeDelegate = self;
 
// Configure the fields of the interface.
[composeVC setToRecipients:@[@"address@example.com"]];
[composeVC setSubject:@"Hello!"];
[composeVC setMessageBody:@"Hello from California!" isHTML:NO];
 
// Present the view controller modally.
[self presentViewController:composeVC animated:YES completion:nil];
```

> Important:
> After presenting a mail compose view controller, the system ignores any attempts to modify the email using the methods of this class. The user can still edit the content of the email, but your app can’t. Therefore, always configure the fields of your email *before* presenting the view controller.

The mail compose view controller isn’t dismissed automatically. When the user taps the buttons to send the email or cancel the interface, the mail compose view controller calls the [`mailComposeController(_:didFinishWith:error:)`](/documentation/MessageUI/MFMailComposeViewControllerDelegate/mailComposeController(_:didFinishWith:error:)) method of its delegate. Your implementation of that method must dismiss the view controller explicitly, as shown in sample code below. You can also use this method to check the result of the operation.

**Swift:**

```swift
func mailComposeController(controller: MFMailComposeViewController,
                           didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    controller.dismiss(animated: true, completion: nil)
}
```

**Obj-C:**

```objc
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
   // Check the result or perform other tasks.
 
   // Dismiss the mail compose view controller.
   [self dismissViewControllerAnimated:YES completion:nil];
}
```

The user can delete a queued message before it’s sent. Although the view controller reports the success or failure of the operation to its delegate, this class doesn’t provide a way for you to verify if the email sent.

For more information on how to present and dismiss view controllers, see [View Controller Programming Guide for iOS](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457).

#### Topics

##### Responding to the view controller dismissal

[`var mailComposeDelegate: (any MFMailComposeViewControllerDelegate)?`](/documentation/MessageUI/MFMailComposeViewController/mailComposeDelegate)

The mail composition view controller’s delegate.

[`protocol MFMailComposeViewControllerDelegate`](/documentation/MessageUI/MFMailComposeViewControllerDelegate)

An interface for responding to user interactions with a mail compose view controller.

##### Determining mail availability

[`class func canSendMail() -> Bool`](/documentation/MessageUI/MFMailComposeViewController/canSendMail())

Returns a Boolean that indicates whether the current device is able to send email.

##### Setting mail fields programmatically

[`func setSubject(String)`](/documentation/MessageUI/MFMailComposeViewController/setSubject(_:))

Sets the initial text for the subject line of the email.

[`func setToRecipients([String]?)`](/documentation/MessageUI/MFMailComposeViewController/setToRecipients(_:))

Sets the initial recipients to include in the email’s To field.

[`func setCcRecipients([String]?)`](/documentation/MessageUI/MFMailComposeViewController/setCcRecipients(_:))

Sets the initial recipients to include in the email’s Cc field.

[`func setBccRecipients([String]?)`](/documentation/MessageUI/MFMailComposeViewController/setBccRecipients(_:))

Sets the initial recipients to include in the email’s Bcc field.

[`func setMessageBody(String, isHTML: Bool)`](/documentation/MessageUI/MFMailComposeViewController/setMessageBody(_:isHTML:))

Sets the initial body text to include in the email.

[`func addAttachmentData(Data, mimeType: String, fileName: String)`](/documentation/MessageUI/MFMailComposeViewController/addAttachmentData(_:mimeType:fileName:))

Adds the specified data as an attachment to the message.

[`func setPreferredSendingEmailAddress(String)`](/documentation/MessageUI/MFMailComposeViewController/setPreferredSendingEmailAddress(_:))

Sets the preferred email address to use in the From field, if such an address is available.

##### Responding to errors

[`struct MFMailComposeError`](/documentation/MessageUI/MFMailComposeError)

Mail composition errors.

[`let MFMailComposeErrorDomain: String`](/documentation/MessageUI/MFMailComposeErrorDomain)

The domain used for error objects that are associated with the mail composition interface.

[`enum Code`](/documentation/MessageUI/MFMailComposeError/Code)

Error codes for <doc://com.apple.documentation/documentation/Foundation/NSError> objects that are associated with the mail composition interface.

##### Instance Methods

[`func insertCollaborationItemProvider(NSItemProvider, completionHandler: (Bool) -> Void)`](/documentation/MessageUI/MFMailComposeViewController/insertCollaborationItemProvider(_:completionHandler:))

#### Relationships

##### Conforms To

[`UIPasteConfigurationSupporting`](/documentation/UIKit/UIPasteConfigurationSupporting)

[`UIActivityItemsConfigurationProviding`](/documentation/UIKit/UIActivityItemsConfigurationProviding)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`CVarArg`](/documentation/Swift/CVarArg)

[`Sendable`](/documentation/Swift/Sendable)

[`UITraitChangeObservable-67e94`](/documentation/UIKit/UITraitChangeObservable-67e94)

[`UIStateRestoring`](/documentation/UIKit/UIStateRestoring)

[`Hashable`](/documentation/Swift/Hashable)

[`NSTouchBarProvider`](/documentation/AppKit/NSTouchBarProvider)

[`UIUserActivityRestoring`](/documentation/UIKit/UIUserActivityRestoring)

[`UIFocusEnvironment`](/documentation/UIKit/UIFocusEnvironment)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`UITraitEnvironment`](/documentation/UIKit/UITraitEnvironment)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`UIResponderStandardEditActions`](/documentation/UIKit/UIResponderStandardEditActions)

[`Equatable`](/documentation/Swift/Equatable)

[`NSExtensionRequestHandling`](/documentation/Foundation/NSExtensionRequestHandling)

[`UIContentContainer`](/documentation/UIKit/UIContentContainer)

[`UIAppearanceContainer`](/documentation/UIKit/UIAppearanceContainer)

##### Inherits From

[`UINavigationController`](/documentation/UIKit/UINavigationController)

### MFMessageComposeViewController  
*iOS: 4.0.0 -* · <https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller.md>


A standard view controller whose interface lets the user compose and send SMS or MMS messages.

```
class MFMessageComposeViewController
```

#### Overview

Use an [`MFMessageComposeViewController`](/documentation/MessageUI/MFMessageComposeViewController) object to display the standard message composition interface inside your app. Before presenting the interface, populate the fields with the set of initial recipients and the message you want to send. After presenting the interface, a person can edit your initial values before sending the message.

The composition interface doesn’t guarantee the delivery of your message; it only lets you construct the initial message and present it for a person’s approval. The person may opt to cancel the composition interface which discards the message and its contents. If the person opts to send the message, the Messages app takes on the responsibility of sending the message.

![a screenshot of the New Message screen, with a phone number in the To field and a short sentence in the composition text field.](images/com.apple.messageui/media-4288093@2x.png)

> Important:
> You must not modify the view hierarchy presented by this view controller. However, you can customize the appearance of the interface using the <doc://com.apple.documentation/documentation/UIKit/UIAppearance> protocol.

An alternate way to compose SMS messages is to create and open a URL that uses the `sms` scheme. URLs of that type go directly to the Messages app, which uses your URL to configure the message. For information about the structure of `sms` URLs, see [Apple URL Scheme Reference](https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007899).

##### Checking the availability of the composition interface

Before presenting the message compose view controller, always call the [`canSendText()`](/documentation/MessageUI/MFMessageComposeViewController/canSendText()) method to see if the person configured the current device to send messages. If the user’s device isn’t set up to send or receive messages, you can notify the user or disable the messaging features in your application. You shouldn’t attempt to use this interface if the [`canSendText()`](/documentation/MessageUI/MFMessageComposeViewController/canSendText()) method returns <doc://com.apple.documentation/documentation/Swift/false>. If messaging is available, you can also use the [`canSendAttachments()`](/documentation/MessageUI/MFMessageComposeViewController/canSendAttachments()) and [`canSendSubject()`](/documentation/MessageUI/MFMessageComposeViewController/canSendSubject()) methods to determine if those specific messaging features are available.

**Swift:**

```swift
if !MFMessageComposeViewController.canSendText() {
    print("SMS services are not available")
}
```

**Obj-C:**

```objc
if (![MFMessageComposeViewController canSendText]) {
   NSLog(@"Message services are not available.");
}
```

##### Configuring and displaying the composition interface

After verifying that message services are available, you can create and configure the message composition view controller and then present it like any other view controller. Use the methods of this class to specify the message’s recipients and the contents of the message. If attachments or a subject line are supported, you can set values for them as well. The sample code below shows how to configure the composition interface and present it modally. Always assign a delegate to the [`messageComposeDelegate`](/documentation/MessageUI/MFMessageComposeViewController/messageComposeDelegate) property, because the delegate is responsible for dismissing the composition interface later. The delegate object must conform to the [`MFMessageComposeViewControllerDelegate`](/documentation/MessageUI/MFMessageComposeViewControllerDelegate) protocol.

**Swift:**

```swift
let composeVC = MFMessageComposeViewController()
composeVC.messageComposeDelegate = self
 
// Configure the fields of the interface.
composeVC.recipients = ["4085551212"]
composeVC.body = "Hello from California!"
 
// Present the view controller modally.
self.present(composeVC, animated: true, completion: nil)
```

**Obj-C:**

```objc
MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
composeVC.messageComposeDelegate = self;
 
// Configure the fields of the interface.
composeVC.recipients = @[@"14085551212"];
composeVC.body = @"Hello from California!";
 
// Present the view controller modally.
[self present:composeVC animated:YES completion:nil];
```

The message compose view controller isn’t dismissed automatically. When the user taps the buttons to send the message or cancel the interface, the message compose view controller calls the [`messageComposeViewController(_:didFinishWith:)`](/documentation/MessageUI/MFMessageComposeViewControllerDelegate/messageComposeViewController(_:didFinishWith:)) method of its delegate. Your implementation of that method must dismiss the view controller explicitly, as shown in the sample code below. You can also use this method to check the result of the operation.

**Swift:**

```swift
func messageComposeViewController(controller: MFMessageComposeViewController,
                                  didFinishWithResult result: MessageComposeResult) {
    // Check the result or perform other tasks.
    
    // Dismiss the message compose view controller.
    controller.dismissViewControllerAnimated(true, completion: nil)}
```

**Obj-C:**

```objc
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
   // Check the result or perform other tasks.    // Dismiss the message compose view controller.
   [self dismissViewControllerAnimated:YES completion:nil];}
```

For more information on how to present and dismiss view controllers, see [View Controller Programming Guide for iOS](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457).

##### Detecting changes to the availability of messaging

Add an observer to the [`MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification`](/documentation/MessageUI/MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification) notification to get notified of changes to the messaging capabilities of the current device. The system delivers that notification to your observer when the status of messaging changes.

#### Topics

##### Responding to the view controller dismissal

[`var messageComposeDelegate: (any MFMessageComposeViewControllerDelegate)?`](/documentation/MessageUI/MFMessageComposeViewController/messageComposeDelegate)

The delegate to which message-related notifications should be sent.

[`protocol MFMessageComposeViewControllerDelegate`](/documentation/MessageUI/MFMessageComposeViewControllerDelegate)

An interface for responding to user interactions with a message compose view controller.

##### Determining if message composition is available

[`class func canSendText() -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/canSendText())

Returns a Boolean value that indicates whether the current device is capable of sending text messages.

[`class func canSendAttachments() -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/canSendAttachments())

Indicates whether or not messages can include attachments.

[`class func canSendSubject() -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/canSendSubject())

Indicates whether or not messages can include subject lines, according to the user’s configuration in Settings.

[`class func isSupportedAttachmentUTI(String) -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/isSupportedAttachmentUTI(_:))

Indicates whether or not the message can accept a file, with the specified UTI, as an attachment.

##### Setting the initial message information

[`var recipients: [String]?`](/documentation/MessageUI/MFMessageComposeViewController/recipients)

An array of strings that contains the initial recipients of the message.

[`var subject: String?`](/documentation/MessageUI/MFMessageComposeViewController/subject)

The initial subject of the message.

[`var body: String?`](/documentation/MessageUI/MFMessageComposeViewController/body)

The initial content of the message.

[`var message: MSMessage?`](/documentation/MessageUI/MFMessageComposeViewController/message)

A message object from your iMessage app extension.

##### Managing attachments

[`func disableUserAttachments()`](/documentation/MessageUI/MFMessageComposeViewController/disableUserAttachments())

Disables the camera/attachment button in the message composition view.

[`var attachments: [[AnyHashable : Any]]?`](/documentation/MessageUI/MFMessageComposeViewController/attachments)

Returns an array of dictionaries that describe the properties of an attachment.

[`func addAttachmentURL(URL, withAlternateFilename: String?) -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/addAttachmentURL(_:withAlternateFilename:))

Attaches a specified file to the message.

[`func addAttachmentData(Data, typeIdentifier: String, filename: String) -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/addAttachmentData(_:typeIdentifier:filename:))

Attaches arbitrary content to the message.

[`let MFMessageComposeViewControllerAttachmentURL: String`](/documentation/MessageUI/MFMessageComposeViewControllerAttachmentURL)

The URL for the item that is attached to the message.

[`let MFMessageComposeViewControllerAttachmentAlternateFilename: String`](/documentation/MessageUI/MFMessageComposeViewControllerAttachmentAlternateFilename)

The key for the alternate filename for the file-based item attached to the message.

[`func insertCollaborationItemProvider(NSItemProvider) -> Bool`](/documentation/MessageUI/MFMessageComposeViewController/insertCollaborationItemProvider(_:))

##### Handling notifications

[`extern NSString * const MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification;`](/documentation/MessageUI/MFMessageComposeViewControllerTextMessageAvailabilityDidChangeNotification)

Posted when the value returned by the [`canSendText()`](/documentation/MessageUI/MFMessageComposeViewController/canSendText()) class method has changed.

[`let MFMessageComposeViewControllerTextMessageAvailabilityKey: String`](/documentation/MessageUI/MFMessageComposeViewControllerTextMessageAvailabilityKey)

The value of this key is a number object that contains a Boolean value.

##### Configuring device validation

[`func setUPIVerificationCodeSendCompletion((Bool) -> Void)`](/documentation/MessageUI/MFMessageComposeViewController/setUPIVerificationCodeSendCompletion(_:))

Configures the instance of a view for Unified Payments Interface (UPI) device validation.

##### Structures

[`struct TextMessageAvailabilityDidChangeMessage`](/documentation/MessageUI/MFMessageComposeViewController/TextMessageAvailabilityDidChangeMessage)

Message type for text message availability change notifications.

#### Relationships

##### Conforms To

[`CVarArg`](/documentation/Swift/CVarArg)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Sendable`](/documentation/Swift/Sendable)

[`NSExtensionRequestHandling`](/documentation/Foundation/NSExtensionRequestHandling)

[`UIAppearanceContainer`](/documentation/UIKit/UIAppearanceContainer)

[`UIFocusEnvironment`](/documentation/UIKit/UIFocusEnvironment)

[`Equatable`](/documentation/Swift/Equatable)

[`NSTouchBarProvider`](/documentation/AppKit/NSTouchBarProvider)

[`UIStateRestoring`](/documentation/UIKit/UIStateRestoring)

[`UIActivityItemsConfigurationProviding`](/documentation/UIKit/UIActivityItemsConfigurationProviding)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`UITraitChangeObservable-67e94`](/documentation/UIKit/UITraitChangeObservable-67e94)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`Hashable`](/documentation/Swift/Hashable)

[`UIContentContainer`](/documentation/UIKit/UIContentContainer)

[`UIPasteConfigurationSupporting`](/documentation/UIKit/UIPasteConfigurationSupporting)

[`UITraitEnvironment`](/documentation/UIKit/UITraitEnvironment)

[`UIUserActivityRestoring`](/documentation/UIKit/UIUserActivityRestoring)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`UIResponderStandardEditActions`](/documentation/UIKit/UIResponderStandardEditActions)

##### Inherits From

[`UINavigationController`](/documentation/UIKit/UINavigationController)

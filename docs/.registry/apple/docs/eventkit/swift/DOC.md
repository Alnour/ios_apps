---
name: eventkit
description: "EventKit + EventKitUI: EKEventEditViewController (out-of-process, no permission), EKEvent, EKEventStore"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,eventkit,calendar,ekevent"
---

# EventKit / EventKitUI

## How our apps use it
- **Create via the system editor**: `EKEventEditViewController` with `eventStore = EKEventStore()`
  and a prefilled `EKEvent(eventStore:)` (`title`, `startDate`, `endDate`, `notes`). On iOS 17+
  it runs **out of process and needs no calendar permission or usage string**.
- Delegate `eventEditViewController(_:didCompleteWith action:)` → `.saved/.canceled/.deleted`;
  do **not** read the saved event back (we don't have calendar access) — record "scheduled" in
  our own model.
- Attendees cannot be set programmatically; put the customer's email in `notes`.

## Reference (developer.apple.com, fetched 2026-10-01)

### EKEventEditViewController  
*iOS: 4.0.0 -* · <https://developer.apple.com/documentation/eventkitui/ekeventeditviewcontroller.md>


A view controller for creating, editing, and deleting calendar events.

```
class EKEventEditViewController
```

#### Overview

Presented modally, the event edit view controller provides a way for users to add new events, as well as edit or delete events from their calendar. New events are added to the user’s default calendar unless they choose another calendar in the UI.

The controller includes delegates to receive a notification when the user saves an edit or deletes an event, or cancels from an edit session. The delegate must conform to [`EKEventEditViewDelegate`](/documentation/EventKitUI/EKEventEditViewDelegate).

#### Topics

##### Managing the Event Editing Interface

[`var editViewDelegate: (any EKEventEditViewDelegate)?`](/documentation/EventKitUI/EKEventEditViewController/editViewDelegate)

The delegate to notify when editing an event.

[`protocol EKEventEditViewDelegate`](/documentation/EventKitUI/EKEventEditViewDelegate)

A notification sent to the delegate when the user finishes editing an event.

##### Creating and Saving Events

[`var event: EKEvent?`](/documentation/EventKitUI/EKEventEditViewController/event)

The event the user creates or edits using this view controller.

[`var eventStore: EKEventStore!`](/documentation/EventKitUI/EKEventEditViewController/eventStore)

The event store used to save the event.

##### Canceling Edits to Events

[`func cancelEditing()`](/documentation/EventKitUI/EKEventEditViewController/cancelEditing())

Ends the editing session and discards any changes that were made to the event.

#### Relationships

##### Conforms To

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`UIResponderStandardEditActions`](/documentation/UIKit/UIResponderStandardEditActions)

[`UIActivityItemsConfigurationProviding`](/documentation/UIKit/UIActivityItemsConfigurationProviding)

[`Equatable`](/documentation/Swift/Equatable)

[`NSExtensionRequestHandling`](/documentation/Foundation/NSExtensionRequestHandling)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`NSTouchBarProvider`](/documentation/AppKit/NSTouchBarProvider)

[`UITraitChangeObservable-67e94`](/documentation/UIKit/UITraitChangeObservable-67e94)

[`UIAppearanceContainer`](/documentation/UIKit/UIAppearanceContainer)

[`UIPasteConfigurationSupporting`](/documentation/UIKit/UIPasteConfigurationSupporting)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`UITraitEnvironment`](/documentation/UIKit/UITraitEnvironment)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`Hashable`](/documentation/Swift/Hashable)

[`UIContentContainer`](/documentation/UIKit/UIContentContainer)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`UIFocusEnvironment`](/documentation/UIKit/UIFocusEnvironment)

[`UIStateRestoring`](/documentation/UIKit/UIStateRestoring)

[`CVarArg`](/documentation/Swift/CVarArg)

[`UIUserActivityRestoring`](/documentation/UIKit/UIUserActivityRestoring)

[`Sendable`](/documentation/Swift/Sendable)

##### Inherits From

[`UINavigationController`](/documentation/UIKit/UINavigationController)

### EKEvent  
*iOS: 4.0.0 -* · <https://developer.apple.com/documentation/eventkit/ekevent.md>


A class that represents an event in a calendar.

```
class EKEvent
```

#### Overview

Use the [`init(eventStore:)`](/documentation/EventKit/EKEvent/init(eventStore:)) method to create a new event. Use the properties in the class to get and modify certain information about an event. Other properties, such as the event’s title and calendar, are inherited from the parent class [`EKCalendarItem`](/documentation/EventKit/EKCalendarItem).

#### Topics

##### Creating Events

[`init(eventStore: EKEventStore)`](/documentation/EventKit/EKEvent/init(eventStore:))

Creates and returns a new event belonging to a specified event store.

##### Scheduling Events

[`enum EKEventStatus`](/documentation/EventKit/EKEventStatus)

The event’s status.

[`enum EKEventAvailability`](/documentation/EventKit/EKEventAvailability)

The event’s availability setting for scheduling purposes.

##### Comparing Events

[`func compareStartDate(with: EKEvent) -> ComparisonResult`](/documentation/EventKit/EKEvent/compareStartDate(with:))

Compares the start date of the receiving event with the start date of another event.

##### Accessing Event Properties

[`var eventIdentifier: String!`](/documentation/EventKit/EKEvent/eventIdentifier)

A unique identifier for the event.

[`var availability: EKEventAvailability`](/documentation/EventKit/EKEvent/availability)

The availability setting for the event.

[`var startDate: Date!`](/documentation/EventKit/EKEvent/startDate)

The start date of the event.

[`var endDate: Date!`](/documentation/EventKit/EKEvent/endDate)

The end date for the event.

[`var isAllDay: Bool`](/documentation/EventKit/EKEvent/isAllDay)

A Boolean value that indicates whether the event is an all-day event.

[`var occurrenceDate: Date!`](/documentation/EventKit/EKEvent/occurrenceDate)

The original occurrence date of an event if it is part of a recurring series.

[`var isDetached: Bool`](/documentation/EventKit/EKEvent/isDetached)

A Boolean value that indicates whether an event is a detached instance of a repeating event.

[`var organizer: EKParticipant?`](/documentation/EventKit/EKEvent/organizer)

The organizer associated with the event.

[`var status: EKEventStatus`](/documentation/EventKit/EKEvent/status)

The status of the event.

[`var birthdayContactIdentifier: String?`](/documentation/EventKit/EKEvent/birthdayContactIdentifier)

The contact identifier of the person for this birthday event.

[`var structuredLocation: EKStructuredLocation?`](/documentation/EventKit/EKEvent/structuredLocation)

The event’s location with a potential geocoordinate.

[`var birthdayPersonID: Int`](/documentation/EventKit/EKEvent/birthdayPersonID)

The Address Book framework record identifier of the person for this birthday event.

[`var birthdayPersonUniqueID: String?`](/documentation/EventKit/EKEvent/birthdayPersonUniqueID)

The Address Book framework record identifier of the person for this birthday event.

##### Refreshing Event Data

[`func refresh() -> Bool`](/documentation/EventKit/EKEvent/refresh())

Updates the event’s data with the current information in the Calendar database.

#### Relationships

##### Conforms To

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Equatable`](/documentation/Swift/Equatable)

[`CVarArg`](/documentation/Swift/CVarArg)

[`Hashable`](/documentation/Swift/Hashable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

##### Inherits From

[`EKCalendarItem`](/documentation/EventKit/EKCalendarItem)

### EKEventStore  
*iOS: 4.0.0 -* · <https://developer.apple.com/documentation/eventkit/ekeventstore.md>


An object that accesses a person’s calendar events and reminders and supports the scheduling of new events.

```
class EKEventStore
```

#### Overview

The `EKEventStore` class is an app’s point of contact for accessing calendar and reminder data.

After initializing the event store, you must request access to events or reminders before attempting to fetch or create data. To request access to reminders, call [`requestFullAccessToReminders(completion:)`](/documentation/EventKit/EKEventStore/requestFullAccessToReminders(completion:)). To request access to events, call [`requestWriteOnlyAccessToEvents(completion:)`](/documentation/EventKit/EKEventStore/requestWriteOnlyAccessToEvents(completion:)) or [`requestFullAccessToEvents(completion:)`](/documentation/EventKit/EKEventStore/requestFullAccessToEvents(completion:)).

> Important:
> To request access to events and reminders, your app needs to include permission strings in its `Info.plist` file that explain to someone why the app needs access. For more information, see <doc://com.apple.eventkit/documentation/EventKit/accessing-the-event-store>.

A typical workflow for using an event store is:

1. Create a predicate, or a search query for events, with [`predicateForEvents(withStart:end:calendars:)`](/documentation/EventKit/EKEventStore/predicateForEvents(withStart:end:calendars:)).
2. Fetch and process events that match the predicate with the [`events(matching:)`](/documentation/EventKit/EKEventStore/events(matching:)) and [`enumerateEvents(matching:using:)`](/documentation/EventKit/EKEventStore/enumerateEvents(matching:using:)) methods.
3. Save and delete events from the event store with the [`save(_:span:commit:)`](/documentation/EventKit/EKEventStore/save(_:span:commit:)) and [`remove(_:span:commit:)`](/documentation/EventKit/EKEventStore/remove(_:span:commit:)) methods.

Use similar methods to access and manipulate reminders.

After receiving an object from an event store, don’t use that object with a different event store. This restriction applies to [`EKObject`](/documentation/EventKit/EKObject) subclasses such as [`EKEvent`](/documentation/EventKit/EKEvent), [`EKReminder`](/documentation/EventKit/EKReminder), [`EKCalendar`](/documentation/EventKit/EKCalendar), and [`EKSource`](/documentation/EventKit/EKSource), as well as predicates that the event store creates. For example, don’t fetch an event from one event store, modify the event, and then pass it to [`save(_:span:)`](/documentation/EventKit/EKEventStore/save(_:span:)) in a different store.

#### Topics

##### Creating event stores

[`init()`](/documentation/EventKit/EKEventStore/init())

Creates a new event store.

[`init(sources: [EKSource])`](/documentation/EventKit/EKEventStore/init(sources:))

Creates an event store that contains data for the specified sources.

[`var eventStoreIdentifier: String`](/documentation/EventKit/EKEventStore/eventStoreIdentifier)

The unique identifier for the event store.

[`- (id) initWithAccessToEntityTypes:(EKEntityMask) entityTypes;`](/documentation/EventKit/EKEventStore/initWithAccessToEntityTypes:)

Initializes access to the event store with support for the given entity type.

##### Requesting access to events and reminders

[`func requestWriteOnlyAccessToEvents(completion: (Bool, (any Error)?) -> Void)`](/documentation/EventKit/EKEventStore/requestWriteOnlyAccessToEvents(completion:))

Prompts the person using your app to grant or deny write access to event data.

[`func requestFullAccessToEvents(completion: (Bool, (any Error)?) -> Void)`](/documentation/EventKit/EKEventStore/requestFullAccessToEvents(completion:))

Prompts people to grant or deny read and write access to event data.

[`func requestFullAccessToReminders(completion: (Bool, (any Error)?) -> Void)`](/documentation/EventKit/EKEventStore/requestFullAccessToReminders(completion:))

Prompts people to grant or deny read and write access to reminders.

[`class func authorizationStatus(for: EKEntityType) -> EKAuthorizationStatus`](/documentation/EventKit/EKEventStore/authorizationStatus(for:))

Determines the authorization status for the given entity type.

[`enum EKAuthorizationStatus`](/documentation/EventKit/EKAuthorizationStatus)

The current authorization status for a specific entity type.

[`typealias EKEventStoreRequestAccessCompletionHandler`](/documentation/EventKit/EKEventStoreRequestAccessCompletionHandler)

The signature for a closure that EventKit calls when requesting access to event and reminder data.

  <doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSCalendarsFullAccessUsageDescription>

  <doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSCalendarsWriteOnlyAccessUsageDescription>

  <doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSRemindersFullAccessUsageDescription>

##### Accessing account sources

[`var sources: [EKSource]`](/documentation/EventKit/EKEventStore/sources)

An unordered array of objects that represent accounts that contain calendars.

[`var delegateSources: [EKSource]`](/documentation/EventKit/EKEventStore/delegateSources)

The event sources delegated to the person using your app.

[`func source(withIdentifier: String) -> EKSource?`](/documentation/EventKit/EKEventStore/source(withIdentifier:))

Locates an event source with the specified identifier.

##### Saving and restoring state

[`func commit() throws`](/documentation/EventKit/EKEventStore/commit())

Commits all unsaved changes to the event store.

[`func reset()`](/documentation/EventKit/EKEventStore/reset())

Reverts the event store to its saved state.

[`func refreshSourcesIfNecessary()`](/documentation/EventKit/EKEventStore/refreshSourcesIfNecessary())

Pulls new data from remote sources, if necessary.

##### Accessing calendars

[`var defaultCalendarForNewEvents: EKCalendar?`](/documentation/EventKit/EKEventStore/defaultCalendarForNewEvents)

The calendar that events are added to by default, as specified by user settings.

[`func defaultCalendarForNewReminders() -> EKCalendar?`](/documentation/EventKit/EKEventStore/defaultCalendarForNewReminders())

Identifies the default calendar for adding reminders to, as specified by user settings.

[`func calendars(for: EKEntityType) -> [EKCalendar]`](/documentation/EventKit/EKEventStore/calendars(for:))

Identifies the calendars that support a given entity type, such as reminders or events.

[`func calendar(withIdentifier: String) -> EKCalendar?`](/documentation/EventKit/EKEventStore/calendar(withIdentifier:))

Locates a calendar with the specified identifier.

[`func saveCalendar(EKCalendar, commit: Bool) throws`](/documentation/EventKit/EKEventStore/saveCalendar(_:commit:))

Saves a calendar to the event store by either committing or batching the changes.

[`func removeCalendar(EKCalendar, commit: Bool) throws`](/documentation/EventKit/EKEventStore/removeCalendar(_:commit:))

Removes a calendar from the event store by either committing or batching the changes.

[`var calendars: [EKCalendar]`](/documentation/EventKit/EKEventStore/calendars)

The calendars associated with the event store.

##### Accessing calendar events

[`func event(withIdentifier: String) -> EKEvent?`](/documentation/EventKit/EKEventStore/event(withIdentifier:))

Locates the first occurrence of an event with a given identifier.

[`func calendarItem(withIdentifier: String) -> EKCalendarItem?`](/documentation/EventKit/EKEventStore/calendarItem(withIdentifier:))

Locates a reminder or the first occurrence of an event with the specified identifier.

[`func calendarItems(withExternalIdentifier: String) -> [EKCalendarItem]`](/documentation/EventKit/EKEventStore/calendarItems(withExternalIdentifier:))

Locates all reminders or the first occurrences of all events with the specified external identifier.

[`func remove(EKEvent, span: EKSpan) throws`](/documentation/EventKit/EKEventStore/remove(_:span:))

Removes an event from the event store.

[`func remove(EKEvent, span: EKSpan, commit: Bool) throws`](/documentation/EventKit/EKEventStore/remove(_:span:commit:))

Removes an event or recurring events from the event store by either committing or batching the changes.

[`func remove(EKReminder, commit: Bool) throws`](/documentation/EventKit/EKEventStore/remove(_:commit:))

Removes a reminder from the event store by either committing or batching the changes.

[`func save(EKEvent, span: EKSpan) throws`](/documentation/EventKit/EKEventStore/save(_:span:))

Saves changes to an event permanently.

[`func save(EKEvent, span: EKSpan, commit: Bool) throws`](/documentation/EventKit/EKEventStore/save(_:span:commit:))

Saves an event or recurring events to the event store by either committing or batching the changes.

[`func save(EKReminder, commit: Bool) throws`](/documentation/EventKit/EKEventStore/save(_:commit:))

Saves changes to a reminder by either committing or batching the changes.

##### Searching calendars

[`func enumerateEvents(matching: NSPredicate, using: EKEventSearchCallback)`](/documentation/EventKit/EKEventStore/enumerateEvents(matching:using:))

Finds all events that match a given predicate and calls a given callback for each event found.

[`func events(matching: NSPredicate) -> [EKEvent]`](/documentation/EventKit/EKEventStore/events(matching:))

Finds all events that match a given predicate.

[`func fetchReminders(matching: NSPredicate, completion: ([EKReminder]?) -> Void) -> Any`](/documentation/EventKit/EKEventStore/fetchReminders(matching:completion:))

Fetches reminders that match a given predicate.

[`func cancelFetchRequest(Any)`](/documentation/EventKit/EKEventStore/cancelFetchRequest(_:))

Cancels the request to fetch reminders.

[`func predicateForEvents(withStart: Date, end: Date, calendars: [EKCalendar]?) -> NSPredicate`](/documentation/EventKit/EKEventStore/predicateForEvents(withStart:end:calendars:))

Creates a predicate to identify events that occur within a given date range.

[`func predicateForReminders(in: [EKCalendar]?) -> NSPredicate`](/documentation/EventKit/EKEventStore/predicateForReminders(in:))

Creates a predicate to identify all reminders in a collection of calendars.

[`func predicateForCompletedReminders(withCompletionDateStarting: Date?, ending: Date?, calendars: [EKCalendar]?) -> NSPredicate`](/documentation/EventKit/EKEventStore/predicateForCompletedReminders(withCompletionDateStarting:ending:calendars:))

Creates a predicate to identify all completed reminders that occur within a given date range.

[`func predicateForIncompleteReminders(withDueDateStarting: Date?, ending: Date?, calendars: [EKCalendar]?) -> NSPredicate`](/documentation/EventKit/EKEventStore/predicateForIncompleteReminders(withDueDateStarting:ending:calendars:))

Creates a predicate to identify all incomplete reminders that occur within a given date range.

[`typealias EKEventSearchCallback`](/documentation/EventKit/EKEventSearchCallback)

The signature for a closure that operates on events when enumerating them.

##### Deprecated methods

[`func requestAccess(to: EKEntityType, completion: (Bool, (any Error)?) -> Void)`](/documentation/EventKit/EKEventStore/requestAccess(to:completion:))

Prompts the person using your app to grant or deny access to event or reminder data.

##### Structures

[`struct EventStoreChanged`](/documentation/EventKit/EKEventStore/EventStoreChanged)

A notification posted when changes are made to the Calendar or Reminders database.

#### Relationships

##### Conforms To

[`CVarArg`](/documentation/Swift/CVarArg)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Equatable`](/documentation/Swift/Equatable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`Hashable`](/documentation/Swift/Hashable)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### Accessing Calendar using EventKit and EventKitUI  
*iOS: 16.4.0 -* · <https://developer.apple.com/documentation/eventkit/accessing-calendar-using-eventkit-and-eventkitui.md>


Choose and implement the appropriate Calendar access level in your app.

#### Overview

Prior to iOS 17, your app needs to include the [`NSCalendarsUsageDescription`](doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSCalendarsUsageDescription) key
in its `Info.plist` and request authorization from the user before it can access the user’s calendar data. `NSCalendarsUsageDescription` indicates how your
app intends to use calendar data. If the user approves the request, the app gets full access to all events on all the user’s calendars,
including the ones the app didn’t create. If the user denies the request, the app gets no access to the user’s data.

Starting in iOS 17, your app should only request the specific level of access it requires to complete its calendar data tasks. The iOS 17 SDK introduces
new calendar usage description strings, the ability to add events to Calendar without prompting the user for access, and a new write-only access.
See [`Accessing the event store`](doc://com.apple.documentation/documentation/EventKit/accessing-the-event-store) for details.

This sample consists of three targets that illustrate how to implement Calendar access level using EventKit and EventKitUI. The `DropInLessons` target
builds an app that saves events to Calendar without prompting the user for authorization. The `RepeatingLessons` target, which implements the write-only
access feature, builds an app that saves events directly to Calendar with user permission. The `MonthlyEvents` target, which illustrates the full-access
feature, builds an app that fetches and displays all events occuring within a month in all the user’s calendars.

> Note: This sample code project is associated with WWDC23 session [10052: Discover Calendar and EventKit](https://developer.apple.com/wwdc23/10052/).

##### Configure the sample code project

Before you run the sample code project in Xcode:

- Open the sample with Xcode 15 or later.
- Select the top-level Calendar Access project.
- For the three targets, choose your team from the Team menu in the Signing & Capabilities pane to let Xcode automatically manage your provisioning profile.
- Select the target you wish to build, then build and run it in the Simulator, in Mac Catalyst, or on a device.

##### Save events without prompting the user for access

In iOS 17, your app can add events to Calendar without prompting the user for access using [`EKEventEditViewController`](doc://com.apple.documentation/documentation/EventKitUI/EKEventEditViewController).
If the purpose of your app is to create, configure, and present calendar events in an editor UI, consider saving events to Calendar without
prompting the user for authorization in your app following these steps:

- Build your app with Xcode 15 and link against the iOS 17 SDK.
- If your app includes [`NSCalendarsUsageDescription`](doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSCalendarsUsageDescription), remove this key.
- If your app requests permission using [`requestAccess(to:completion:)`](https://developer.apple.com/documentation/eventkit/ekeventstore/requestaccess)
  or `requestAccess(to:)`, remove these instance methods from your source code.

The `DropInLessons` app writes data to Calendar without performing any other operations on the user’s events. Because its workflow doesn’t interact
with the user’s calendar data, the app isn’t required to include any calendar usage strings or prompt the user for access. [`EKEventStore`](doc://com.apple.documentation/documentation/EventKit/EKEventStore) allows apps to request permission from the user, and read and
write data to Calendar. `DropInLessons` creates an instance of the event store, `store`.

```swift
@State private var store = EKEventStore()
```

When the user schedules a lesson, `DropInLessons` creates a `selectedEvent`, then presents an event edit view controller.

```swift
    .sheet(isPresented: $showEventEditViewController,
           onDismiss: didDismissEventEditController, content: {
       EventEditViewController(event: $selectedEvent, eventStore: store)
})
```

The app creates `selectedEvent` in the event store, adds it to the default calendar for the store, then configures `selectedEvent` with the selected
lesson’s details. The view controller takes `selectedEvent` and `store` as parameters.

```swift
let controller = EKEventEditViewController()
controller.eventStore = eventStore
controller.event = event
controller.editViewDelegate = context.coordinator
```

`DropInLessons` relinquishes control once the editor is presented. Because the event edit view controller renders its content out of process, it has
full access to all the user’s calendars on the device, regardless of the access granted to the app. This allows the user to get a full-featured editing
experience, such as choosing another calendar to save the selected lesson or changing presented information in the editor. However, the app isn’t aware
of any of these changes. When the user taps the Add button in the UI, the system saves the lesson to the user’s selected or default calendar, then
dismisses the editor.

```swift
func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
    parent.presentationMode.wrappedValue.dismiss()
}
```

Because the calendar edits happen out of process, inspecting the properties of the dismissed `controller`, such as [`event`](doc://com.apple.documentation/documentation/EventKitUI/EKEventEditViewController/event), to determine what the user
added to Calendar doesn’t return any useful information. The app isn’t aware of the changes, which naturally means it can’t see them.

##### Request write-only access

In iOS 17, an app with write-only access can create and save events to Calendar, display events using [`EKEventEditViewController`](doc://com.apple.documentation/documentation/EventKitUI/EKEventEditViewController), and allow the user to
select another calendar using [`EKCalendarChooser`](doc://com.apple.documentation/documentation/EventKitUI/EKCalendarChooser). If your app needs to write
data directly, consider implementing write-only access in your app following these steps:

- Build your app with Xcode 15 and link against the iOS 17 SDK.
- Add the `NSCalendarsWriteOnlyAccessUsageDescription` key to the `Info.plist` file of the target building your app.
- To request write-only access to events, use `requestWriteOnlyAccessToEvents(completion:)` or `requestWriteOnlyAccessToEvents()`.

> Note: `EKEventEditViewController` and `EKCalendarChooser` require write-only or full access. `EKEventEditViewController` doesn’t require any user permission.

`RepeatingLessons` displays a list of recurring lessons and a “Select calendar” button in the toolbar. The app offers the lessons on specific dates and times
and doesn’t fetch any events from the user’s calendars. `RepeatingLessons` can’t let the user or the system make any changes to these events. Because
of these reasons, the app requires write-only access so it can control the date and time of every event added to Calendar. When the user selects a
lesson, then taps the booking button, the app first checks whether it has authorization to access the user’s calendar data. If the authorization
status is [`.notDetermined`](doc://com.apple.documentation/documentation/EventKit/EKAuthorizationStatus/notDetermined), the app uses an instance of [`EKEventStore`](doc://com.apple.documentation/documentation/EventKit/EKEventStore), `eventStore`, to prompt the user for write-only access.

```swift
return try await eventStore.requestWriteOnlyAccessToEvents()
```

`RepeatingLessons` includes `NSCalendarsWriteOnlyAccessUsageDescription` in its `Info.plist` file and uses its value when showing an alert. The alert
prompts the user for write-only acess to save repeating lessons to a calendar that the user chooses. If the user grants the request, the app
receives a `.writeOnly` authorization status, creates a recurring event using the selected lesson’s details, then saves it to Calendar without the
user making any changes to this event.

```swift
try self.eventStore.save(newEvent, span: .futureEvents)
```

The “Select calendar” button in the toolbar allows the user to choose another calendar to save the recurring events using `EKCalendarChooser`. The app turns off the button by default. The app
turns it on when the user grants write-only or full access to the app. When the user taps the button, `RepeatingLessons` presents a calendar chooser
with an instance of [`EKCalendar`](doc://com.apple.documentation/documentation/EventKit/EKCalendar), `calendar`, which keeps track of calendars the user
chooses in the view controller.

```swift
.sheet(isPresented: $showCalendarChooser) {
    CalendarChooser(calendar: $calendar)
}
```

The [`displayStyle`](doc://com.apple.documentation/documentation/EventKitUI/EKCalendarChooserDisplayStyle) property of `EKCalendarChooser` specifies
whether to display writable calendars only or all calendars. In write-only access apps, the calendar chooser ignores the value of the `displayStyle`
setting and this setting always behaves as if it’s set to [`.writableCalendarsOnly`](doc://com.apple.documentation/documentation/EventKitUI/EKCalendarChooserDisplayStyle/writableCalendarsOnly).
As a result, the app only allows the user to select a single writable calendar from the list presented in the calendar chooser.

```swift
// Initializes a calendar chooser that allows the user to select a single calendar from a list of writable calendars only.
let calendarChooser = EKCalendarChooser(selectionStyle: .single,
                                        displayStyle: .writableCalendarsOnly,
                                        entityType: .event,
                                        eventStore: storeManager.store)
```

The app sets the [`selectedCalendars`](doc://com.apple.documentation/documentation/EventKitUI/EKCalendarChooser/selectedCalendars)
property of `EKCalendarChooser` to `calendar`, which is empty when the user hasn’t selected a calendar.

```swift
/*
    Set up the selected calendars property. If the user previously selected a calendar from the view controller, update the property with it.
    Otherwise, update selected calendars with an empty set.
*/
if let calendar = calendar {
    let selectedCalendar: Set<EKCalendar> = [calendar]
    calendarChooser.selectedCalendars = selectedCalendar
} else {
    calendarChooser.selectedCalendars = []
}
```

`RepeatingLessons` configures the chooser to show the Done and Cancel buttons.

```swift
calendarChooser.delegate = context.coordinator
// Configure the chooser to display Done and Cancel buttons.
calendarChooser.showsDoneButton = true
calendarChooser.showsCancelButton = true
return UINavigationController(rootViewController: calendarChooser)
```

If the user chooses a calendar from the view controller, `RepeatingLessons` adds recurring events to that calendar. If the user doesn’t make any
selection, the app saves the events to the user’s default calendar.

##### Request full access

In iOS 17, an app with full access can create, edit, save, delete, and fetch all events on all the user’s calendars. Additionally, the app can
display events using [`EKEventViewController`](doc://com.apple.documentation/documentation/EventKitUI/EKEventViewController) and allow the user to
select another calendar using [`EKCalendarChooser`](doc://com.apple.documentation/documentation/EventKitUI/EKCalendarChooser). Implement full access if
your app needs to read and write data to Calendar. If your app only needs to write data directly to Calendar, implement write-only access instead. If your
app only uses EventKit APIs to create and set up events, consider saving events to Calendar without prompting the user for authorization.

To implement full access in your app, follow these steps:

- Build your app with Xcode 15 and link against the iOS 17 SDK.
- Add the `NSCalendarsFullAccessUsageDescription` key to the `Info.plist` file of the target building your app.
- To request full access to events, use `requestFullAccessToEvents(completion:)` or `requestFullAccessToEvents()`.

Upon its first launch, the `MonthlyEvents` app registers for [`EKEventStoreChanged`](https://developer.apple.com/documentation/foundation/nsnotification/name/ekeventstorechanged) notifications
to listen for any changes to the event store.

```swift
let center = NotificationCenter.default
let notifications = center.notifications(named: .EKEventStoreChanged).map({ (notification: Notification) in notification.name })
for await _ in notifications {
    guard await dataStore.isFullAccessAuthorized else { return }
    await self.fetchLatestEvents()
}
```

Then, the app checks whether it’s authorized to access the user’s calendar data.

```swift
let status = EKEventStore.authorizationStatus(for: .event)
```

If the authorization status is [`.notDetermined`](doc://com.apple.documentation/documentation/EventKit/EKAuthorizationStatus/notDetermined), the app uses
an instance of [`EKEventStore`](doc://com.apple.documentation/documentation/EventKit/EKEventStore), `eventStore`, to prompt the user for full access.

```swift
return try await eventStore.requestFullAccessToEvents()
```

`MonthlyEvents` includes `NSCalendarsFullAccessUsageDescription` in its `Info.plist` file and uses its value when showing an alert. The alert  prompts
the user for  full access to fetch events in all the user’s calendars and delete the ones the user selects in the app. If the user grants the request, the app
receives a `.fullAccess` authorization status.

```swift
EKEventStore.authorizationStatus(for: .event) == .fullAccess
```

Then, the app fetches and displays all events occuring within a month in all the user’s calendars sorted by start date in ascending order.

```swift
let start = Date.now
let end = start.oneMonthOut
let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
return eventStore.events(matching: predicate).sortedEventByAscendingDate()
```

If the user denies the request, the app does nothing. In subsequent launches, the app displays a message prompting the user to grant the app full
access in Settings on their device.

Because the user authorized the app for full access, the user can additionally select and delete one or more events in `MonthlyEvents`. The app
iterates through an array of events that the user chose to delete. It calls and sets the `commit` parameter of the [`remove(_:span:commit:)`](/documentation/EventKit/EKEventStore/remove(_:span:commit:)) function to `false` to batch the
deletion of each event in the array.

```swift
try self.eventStore.remove(event, span: .thisEvent, commit: false)
```

Then, the app commits the changes once it’s done iterating through the array.

```swift
try eventStore.commit()
```

When you assign `true` to `commit` to immediately save or remove the event in your app, the event store automatically rolls back any changes if the
commit operation fails. However, if you set `commit` to `false` and your app successfully removes some events and fails removing others, this can
result in a later commit failing. Every subsequent commit fails until you roll back the changes. Call [`reset()`](/documentation/EventKit/EKEventStore/reset())
to manually roll back the changes.

```swift
eventStore.reset()
```

##### Run apps on operating system earlier than iOS 17

If you build your app with Xcode 15, link it against the iOS 17 SDK, and need to run it on systems earlier than iOS 17:

- Add [`NSCalendarsUsageDescription`](doc://com.apple.documentation/documentation/BundleResources/Information-Property-List/NSCalendarsUsageDescription)
  to the `Info.plist` file of the target building your app. If your app that’s linked on iOS 10 through iOS 16 doesn’t
  include `NSCalendarsUsageDescription`, your app crashes.
- To request access to events, use [`requestAccess(to:completion:)`](/documentation/EventKit/EKEventStore/requestAccess(to:completion:))
  or `requestAccess(to: .event)`.
- To determine whether your app is authorized to access the user’s calendar data, confirm that [`authorizationStatus(for:)`](https://developer.apple.com/documentation/eventkit/ekeventstore/authorizationstatus) is set to [`.authorized`](doc://com.apple.documentation/documentation/EventKit/EKAuthorizationStatus).

> Note: The new request methods are unavailable on systems earlier than iOS 17, which may cause your app to crash when running on these versions. Check
> that these methods are available in the iOS version that you wish to run your app on before calling them in your app. See [Declaration Attributes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language) for details.

The `DropInLessons`, `MonthlyEvents`, and `RepeatingLessons` targets in the sample project have a deployment target of iOS 16.4, meaning their apps can run on
devices running iOS 16.4 and later. These apps include `NSCalendarsUsageDescription` in their `Info.plist` and use `requestAccess(to: .event`) when requesting permission from the user.

```swift
// Fall back on earlier versions.
return try await eventStore.requestAccess(to: .event)
```

> Important: In iOS 17, calling `requestAccess(to: .event)` or `requestAccess(to:completion:)` doesn’t prompt the user for access and throws an error.

`MonthlyEvents` and `RepeatingLessons` confirm that they have an [`.authorized`](doc://com.apple.documentation/documentation/EventKit/EKAuthorizationStatus) authorization status.

```swift
// Fall back on earlier versions.
EKEventStore.authorizationStatus(for: .event) == .authorized
```

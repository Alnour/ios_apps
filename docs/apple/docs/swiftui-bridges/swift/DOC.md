---
name: swiftui-bridges
description: "SwiftUI pieces used for UIKit bridging and app structure: UIViewControllerRepresentable, @Observable, NavigationStack, searchable, TabView"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,swiftui,uikit,representable,observable,navigation"
---

# SwiftUI — structure & UIKit bridges

## How our apps use it
- App structure: `TabView` → `NavigationStack` per tab; `.searchable(text:)` on lists.
- State: `@Observable` classes (Observation framework) injected with `.environment(obj)` and read
  with `@Environment(Type.self)`; `@State` for view-local.
- UIKit sheets (Mail, Messages, Contacts picker, Event editor): `UIViewControllerRepresentable`
  with a `Coordinator` that is the delegate; present with `.sheet(isPresented:)`.
- Keep `@MainActor` on anything touching UI or `ModelContext` from async code.

## Reference (developer.apple.com, fetched 2026-10-01)

### UIViewControllerRepresentable  
*iOS: 13.0.0 -* · <https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable.md>


A view that represents a UIKit view controller.

```
@MainActor @preconcurrency protocol UIViewControllerRepresentable : View where Self.Body == Never
```

#### Overview

Use a [`UIViewControllerRepresentable`](/documentation/SwiftUI/UIViewControllerRepresentable) instance to create and manage a
<doc://com.apple.documentation/documentation/UIKit/UIViewController> object in your
SwiftUI interface. Adopt this protocol in one of your app’s custom
instances, and use its methods to create, update, and tear down your view
controller. The creation and update processes parallel the behavior of
SwiftUI views, and you use them to configure your view controller with your
app’s current state information. Use the teardown process to remove your
view controller cleanly from your SwiftUI. For example, you might use the
teardown process to notify other objects that the view controller is
disappearing.

To add your view controller into your SwiftUI interface, create your
[`UIViewControllerRepresentable`](/documentation/SwiftUI/UIViewControllerRepresentable) instance and add it to your SwiftUI
interface. The system calls the methods of your custom instance at
appropriate times.

The system doesn’t automatically communicate changes occurring within your
view controller to other parts of your SwiftUI interface. When you want your
view controller to coordinate with other SwiftUI views, you must provide a
[`Coordinator`](/documentation/SwiftUI/NSViewControllerRepresentable/Coordinator) instance to facilitate those
interactions. For example, you use a coordinator to forward target-action
and delegate messages from your view controller to any SwiftUI views.

> Warning: SwiftUI fully controls the layout of the UIKit view controller’s
> view using the view’s
> <doc://com.apple.documentation/documentation/UIKit/UIView/center>,
> <doc://com.apple.documentation/documentation/UIKit/UIView/bounds>,
> <doc://com.apple.documentation/documentation/UIKit/UIView/frame>, and
> <doc://com.apple.documentation/documentation/UIKit/UIView/transform>
> properties. Don’t directly set these layout-related properties on the view
> managed by a `UIViewControllerRepresentable` instance from your own
> code because that conflicts with SwiftUI and results in undefined behavior.

#### Topics

##### Creating and updating the view controller

[`func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType`](/documentation/SwiftUI/UIViewControllerRepresentable/makeUIViewController(context:))

Creates the view controller object and configures its initial state.

[`func updateUIViewController(Self.UIViewControllerType, context: Self.Context)`](/documentation/SwiftUI/UIViewControllerRepresentable/updateUIViewController(_:context:))

Updates the state of the specified view controller with new information
from SwiftUI.

[`typealias Context`](/documentation/SwiftUI/UIViewControllerRepresentable/Context)

[`associatedtype UIViewControllerType : UIViewController`](/documentation/SwiftUI/UIViewControllerRepresentable/UIViewControllerType)

The type of view controller to present.

##### Specifying a size

[`func sizeThatFits(ProposedViewSize, uiViewController: Self.UIViewControllerType, context: Self.Context) -> CGSize?`](/documentation/SwiftUI/UIViewControllerRepresentable/sizeThatFits(_:uiViewController:context:))

Given a proposed size, returns the preferred size of the composite view.

##### Cleaning up the view controller

[`static func dismantleUIViewController(Self.UIViewControllerType, coordinator: Self.Coordinator)`](/documentation/SwiftUI/UIViewControllerRepresentable/dismantleUIViewController(_:coordinator:))

Cleans up the presented view controller (and coordinator) in
anticipation of their removal.

##### Providing a custom coordinator object

[`func makeCoordinator() -> Self.Coordinator`](/documentation/SwiftUI/UIViewControllerRepresentable/makeCoordinator())

Creates the custom instance that you use to communicate changes from
your view controller to other parts of your SwiftUI interface.

[`associatedtype Coordinator = Void`](/documentation/SwiftUI/UIViewControllerRepresentable/Coordinator)

A type to coordinate with the view controller.

##### Performing layout

[`typealias LayoutOptions`](/documentation/SwiftUI/UIViewControllerRepresentable/LayoutOptions)

#### Relationships

##### Inherits From

[`View`](/documentation/SwiftUI/View)

### Observable()  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/observation/observable().md>


Defines and implements conformance of the Observable protocol.

```
@attached(member, names: named(_$observationRegistrar), named(access), named(withMutation), named(shouldNotifyObservers)) @attached(memberAttribute) @attached(extension, conformances: Observable) macro Observable()
```

#### Overview

This macro adds observation support to a custom type and conforms the type
to the [`Observable`](/documentation/Observation/Observable) protocol. For example, the
following code applies the `Observable` macro to the type `Car` making it
observable:

```
@Observable 
class Car {
   var name: String = ""
   var needsRepairs: Bool = false

   init(name: String, needsRepairs: Bool = false) {
       self.name = name
       self.needsRepairs = needsRepairs
   }
}
```

### NavigationStack  
*iOS: 16.0.0 -* · <https://developer.apple.com/documentation/swiftui/navigationstack.md>


A view that displays a root view and enables you to present additional
views over the root view.

```
nonisolated struct NavigationStack<Data, Root> where Root : View
```

#### Overview

Use a navigation stack to present a stack of views over a root view.
People can add views to the top of the stack by clicking or tapping a
[`NavigationLink`](/documentation/SwiftUI/NavigationLink), and remove views using built-in, platform-appropriate
controls, like a Back button or a swipe gesture. The stack always displays
the most recently added view that hasn’t been removed, and doesn’t allow
the root view to be removed.

To create navigation links, associate a view with a data type by adding a
[`navigationDestination(for:destination:)`](/documentation/SwiftUI/View/navigationDestination(for:destination:)) modifier inside
the stack’s view hierarchy. Then initialize a [`NavigationLink`](/documentation/SwiftUI/NavigationLink) that
presents an instance of the same kind of data. The following stack displays
a `ParkDetails` view for navigation links that present data of type `Park`:

```
NavigationStack {
    List(parks) { park in
        NavigationLink(park.name, value: park)
    }
    .navigationDestination(for: Park.self) { park in
        ParkDetails(park: park)
    }
}
```

In this example, the [`List`](/documentation/SwiftUI/List) acts as the root view and is always
present. Selecting a navigation link from the list adds a `ParkDetails`
view to the stack, so that it covers the list. Navigating back removes
the detail view and reveals the list again. The system disables backward
navigation controls when the stack is empty and the root view, namely
the list, is visible.

##### Manage navigation state

By default, a navigation stack manages state to keep track of the views on
the stack. However, your code can share control of the state by initializing
the stack with a binding to a collection of data values that you create.
The stack adds items to the collection as it adds views to the stack and
removes items when it removes views. For example, you can create a [`State`](/documentation/SwiftUI/State)
property to manage the navigation for the park detail view:

```
@State private var presentedParks: [Park] = []
```

Initializing the state as an empty array indicates a stack with no views.
Provide a [`Binding`](/documentation/SwiftUI/Binding) to this state property using the dollar sign (`$`)
prefix when you create a stack using the [`init(path:root:)`](/documentation/SwiftUI/NavigationStack/init(path:root:))
initializer:

```
NavigationStack(path: $presentedParks) {
    List(parks) { park in
        NavigationLink(park.name, value: park)
    }
    .navigationDestination(for: Park.self) { park in
        ParkDetails(park: park)
    }
}
```

Like before, when someone taps or clicks the navigation link for a
park, the stack displays the `ParkDetails` view using the associated park
data. However, now the stack also puts the park data in the `presentedParks`
array. Your code can observe this array to read the current stack state. It
can also modify the array to change the views on the stack. For example, you
can create a method that configures the stack with a specific set of parks:

```
func showParks() {
    presentedParks = [Park("Yosemite"), Park("Sequoia")]
}
```

The `showParks` method replaces the stack’s display with a view that shows
details for Sequoia, the last item in the new `presentedParks` array.
Navigating back from that view removes Sequoia from the array, which
reveals a view that shows details for Yosemite. Use a path to support
deep links, state restoration, or other kinds of programmatic navigation.

##### Navigate to different view types

To create a stack that can present more than one kind of view, you can add
multiple [`navigationDestination(for:destination:)`](/documentation/SwiftUI/View/navigationDestination(for:destination:)) modifiers
inside the stack’s view hierarchy, with each modifier presenting a
different data type. The stack matches navigation links with navigation
destinations based on their respective data types.

To create a path for programmatic navigation that contains more than one
kind of data, you can use a [`NavigationPath`](/documentation/SwiftUI/NavigationPath) instance as the path.

#### Topics

##### Creating a navigation stack

[`init(root: () -> Root)`](/documentation/SwiftUI/NavigationStack/init(root:))

Creates a navigation stack that manages its own navigation state.

##### Creating a navigation stack with a path

[`init(path:root:)`](/documentation/SwiftUI/NavigationStack/init(path:root:))

Creates a navigation stack with homogeneous navigation state that you
can control.

#### Relationships

##### Conforms To

[`View`](/documentation/SwiftUI/View)

### searchable(text:placement:prompt:)  
*iOS: 16.0.0 -* · <https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:).md>


Marks this view as searchable, which configures the display of a
search field.

```
@export(implementation) nonisolated func searchable(text: Binding<String>, placement: SearchFieldPlacement = .automatic, prompt: LocalizedStringResource) -> some View
```

#### Parameters

`text`

The text to display and edit in the search field.

`placement`

The preferred placement of the search field within the
containing view hierarchy.

`prompt`

Text resource for the localized prompt of the search field
which provides users with guidance on what to search for.

#### Discussion

For more information about using searchable modifiers, see
[Adding a search interface to your app](/documentation/SwiftUI/Adding-a-search-interface-to-your-app).

### TabView  
*iOS: 13.0.0 -* · <https://developer.apple.com/documentation/swiftui/tabview.md>


A view that switches between multiple child views using interactive user
interface elements.

```
nonisolated struct TabView<SelectionValue, Content> where SelectionValue : Hashable, Content : View
```

#### Overview

To create a user interface with tabs, place instances of [`Tab`](/documentation/SwiftUI/Tab)  in a
`TabView`. On iOS, you can also use one of the badge modifiers, like
[`badge(_:)`](/documentation/SwiftUI/TabContent/badge(_:)), to assign a badge to each of the tabs.

The following example creates a tab view with three tabs, each presenting a
custom child view. The first tab has a numeric badge and the third has a
string badge.

```
TabView {
    Tab("Received", systemImage: "tray.and.arrow.down.fill") {
        ReceivedView()
    }
    .badge(2)

    Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
        SentView()
    }

    Tab("Account", systemImage: "person.crop.circle.fill") {
        AccountView()
    }
    .badge("!")
}
```

![A tab bar with three tabs, each with an icon image and a text label.](images/com.apple.SwiftUI/TabView-1@2x.png)

To programmatically select different tabs, use the
[`init(selection:content:)`](/documentation/SwiftUI/TabView/init(selection:content:)) initializer. You can assign a selection
value to each tab using a `Tab` initializer that takes a value. Each
tab should have a unique selection value and all tabs should have the
same selection value type. When people select a tab in the tab view,
the tab view updates the selection binding to the value of the currently
selected tab.

The following example creates a tab view that supports programatic selection
and has 3 tabs.

```
TabView(selection: $selection) {
    Tab("Received", systemImage: "tray.and.arrow.down.fill", value: 0) {
        ReceivedView()
    }

    Tab("Sent", systemImage: "tray.and.arrow.up.fill", value: 1) {
        SentView()
    }

    Tab("Account", systemImage: "person.crop.circle.fill", value: 2) {
        AccountView()
    }
}
```

You can use the [`page`](/documentation/SwiftUI/TabViewStyle/page) style to display a tab view with
multiple scrolling pages of content.

The following example uses a `ForEach` to create a scrolling tab view
that shows the temperatures of various cities.

```
TabView {
    ForEach(cities) { city in
        TemperatureView(city)
    }
}
.tabViewStyle(.page)
```

##### Using tab sections

The [`sidebarAdaptable`](/documentation/SwiftUI/TabViewStyle/sidebarAdaptable) style supports
declaring a secondary tab hierarchy by grouping tabs with a [`TabSection`](/documentation/SwiftUI/TabSection).

On iPadOS, tab sections appear in both the sidebar and the tab bar. On
iOS and the horizontally compact size class on iPadOS, secondary tabs appear
in the tab bar. When secondary tabs appear in the tab bar, the section
header doesn’t appear in the tab bar. Consider limiting the number of tabs
on iOS and the iPadOS horizontal compact size class so all tabs fit in the
tab bar.

The following example has 5 tabs, three of which are grouped within a
[`TabSection`](/documentation/SwiftUI/TabSection).

```
TabView {
    Tab("Requests", systemImage: "paperplane") {
        RequestsView()
    }

    Tab("Account", systemImage: "person.crop.circle.fill") {
        AccountView()
    }

    TabSection("Messages") {
        Tab("Received", systemImage: "tray.and.arrow.down.fill") {
            ReceivedView()
        }

        Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
            SentView()
        }

        Tab("Drafts", systemImage: "pencil") {
            DraftsView()
        }
    }
}
.tabViewStyle(.sidebarAdaptable)
```

##### Changing tab structure between horizontal and regular size classes

The following example shows a `TabView` with 4 tabs in compact and
5 tabs in regular. In compact, one of the tabs is a ‘Browse’ tab that
displays a custom list view. This list view allows navigating to the destinations
that are contained within the ‘Library’ and ‘Playlists’ sections in the
horizontally regular size class. The navigation path and the selection state
are updated when the number of tabs changes.

```
struct BrowseTabExample: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: MusicTab = .listenNow
    @State private var browseTabPath: [MusicTab] = []
    @State private var playlists = [
        Playlist("All Playlists"), Playlist("Running"),
    ]

    var body: some View {
            TabView(selection: $selection) {
                Tab("Listen Now", systemImage: "play.circle", value: .listenNow) {
                    ListenNowView()
                }

                Tab("Radio", systemImage: "dot.radiowaves.left.and.right", value: .radio) {
                    RadioView()
                }

                Tab("Search", systemImage: "magnifyingglass", value: .search) {
                    SearchDetailView()
                }

                Tab("Browse", systemImage: "list.bullet", value: .browse) {
                    LibraryView(path: $browseTabPath)
                }
                .hidden(sizeClass != .compact)

                TabSection("Library") {
                    Tab("Recently Added", systemImage: "clock", value: MusicTab.library(.recentlyAdded)) {
                        RecentlyAddedView()
                    }

                    Tab("Artists", systemImage: "music.mic", value: MusicTab.library(.artists)) {
                        ArtistsView()
                    }
                }
                .hidden(sizeClass == .compact)

                TabSection("Playlists") {
                    ForEach(playlists) { playlist in
                        Tab(playlist.name, image: playlist.image, value: MusicTab.playlists(playlist)) {
                            playlist.detailView()
                        }
                    }
                }
                .hidden(sizeClass == .compact)
            }
            .tabViewStyle(.sidebarAdaptable)
            .onChange(of: sizeClass, initial: true) { _, sizeClass in
                if sizeClass == .compact && selection.showInBrowseTab {
                    browseTabPath = [selection]
                    selection = .browse
                } else if sizeClass == .regular && selection == .browse {
                    selection = browseTabPath.last ?? .library(.recentlyAdded)
                }
            }
        }
    }
}

struct LibraryView: View {
    @Binding var path: [MusicTab]

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(MusicLibraryTab.allCases, id: \.self) { tab in
                    NavigationLink(tab.rawValue, value: MusicTab.library(tab))
                }
                // Code to add playlists here
            }
            .navigationDestination(for: MusicTab.self) { tab in
                tab.detail()
            }
        }
    }
}
```

##### Adding support for customization

You can allow people to customize the tabs in a `TabView` by using
`sidebarAdaptable` style with the [`tabViewCustomization(_:)`](/documentation/SwiftUI/View/tabViewCustomization(_:))
modifier. Customization allows people to drag tabs from the sidebar to the
tab bar, hide tabs, and rearrange tabs in the sidebar.

All tabs and tab sections that support customization need to have
a customization ID. You can mark a tab as being non-customizable
by specifying a [`disabled`](/documentation/SwiftUI/TabCustomizationBehavior/disabled) behavior
in all adaptable tab bar placements
using [`customizationBehavior(_:for:)`](/documentation/SwiftUI/TabContent/customizationBehavior(_:for:)).

On macOS, a default interaction is provided for reordering sections but
not for controlling the visibility of individual tabs. A custom
experience should be provided if desired by setting the visibility of
the tab on the customization.

You can use `@AppStorage` or `@SceneStorage` to automatically persist
any visibility or section order customizations a person makes.

The following example supports customizing all 4 tabs in the tab view
and uses `@AppStorage` to persist the customizations a person makes.

```
@AppStorage
private var customization: TabViewCustomization

TabView {
    Tab("Home", systemImage: "house") {
        MyHomeView()
    }
    .customizationID("com.myApp.home")

    Tab("Reports", systemImage: "chart.bar") {
        MyReportsView()
    }
    .customizationID("com.myApp.reports")

    TabSection("Categories") {
        Tab("Climate", systemImage: "fan") {
            ClimateView()
        }
        .customizationID("com.myApp.climate")

        Tab("Lights", systemImage: "lightbulb") {
            LightsView()
        }
        .customizationID("com.myApp.lights")
    }
    .customizationID("com.myApp.browse")
}
.tabViewStyle(.sidebarAdaptable)
.tabViewCustomization($customization)
```

#### Topics

##### Creating a tab view

[`init(content:)`](/documentation/SwiftUI/TabView/init(content:))

[`init(selection:content:)`](/documentation/SwiftUI/TabView/init(selection:content:))

Creates a tab view that uses a builder to create and specify
selection values for its tabs.

##### Configuring search activation

[`struct TabSearchActivation`](/documentation/SwiftUI/TabSearchActivation)

Configures the activation behavior of search in the search tab.

#### Relationships

##### Conforms To

[`View`](/documentation/SwiftUI/View)

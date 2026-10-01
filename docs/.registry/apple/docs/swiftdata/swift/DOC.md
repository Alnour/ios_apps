---
name: swiftdata
description: "SwiftData persistence: @Model, relationships, ModelContext, @Query, #Predicate"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,swiftdata,persistence,model,query,predicate"
---

# SwiftData

## How our apps use it
- `@Model final class` per entity; `@Relationship(deleteRule: .cascade)` on the owning side,
  `inverse:` declared on exactly one side. Store enums as `Codable` raw values or `String`.
- Container: `.modelContainer(for: [Customer.self, ...])` on the `WindowGroup`; views get
  `@Environment(\.modelContext)` and `@Query(sort:)`.
- Background work (transcription/AI) runs in a `ModelActor` or re-fetches by `PersistentIdentifier`
  on the main context — never pass `@Model` objects across actors.
- Search: `#Predicate<Fact> { $0.value.localizedStandardContains(term) }`; predicates can't call
  arbitrary methods, keep them to comparisons/contains and combine with `||`.
- Files (audio) live outside the store; the model keeps a relative file name.

## Reference (developer.apple.com, fetched 2026-10-01)

### SwiftData  
*iOS: 17.0 -* · <https://developer.apple.com/documentation/swiftdata.md>


Write your model code declaratively to add managed persistence and efficient
model fetching.

#### Overview

Combining Core Data’s proven persistence technology and Swift’s modern
concurrency features, SwiftData enables you to add persistence to your app
quickly, with minimal code and no external dependencies. Using modern language
features like macros, SwiftData enables you to write code that is fast,
efficient, and safe, enabling you to describe the entire model layer
(or object graph) for your app. The framework handles storing the underlying
model data, and optionally, syncing that data across multiple devices.

SwiftData has uses beyond persisting locally created content. For example, an
app that fetches data from a remote web service might use SwiftData to
implement a lightweight caching mechanism and provide limited offline
functionality.

![A white Swift logo containing ones and zeros on a blueprint-style background.](images/com.apple.SwiftData/swiftdata-hero@2x.png)

SwiftData is unintrusive by design and supplements your app’s existing model
classes. Attach the [`Model()`](/documentation/SwiftData/Model()) macro to any model class to make it persistable.
Customize the behavior of that model’s properties with the [`Attribute(_:originalName:hashModifier:)`](/documentation/SwiftData/Attribute(_:originalName:hashModifier:))
and [`Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:)`](/documentation/SwiftData/Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:))
macros. Use the [`ModelContext`](/documentation/SwiftData/ModelContext) class to insert, update, and delete instances
of that model, and to write unsaved changes to disk.

To display models in a SwiftUI view, use the [`Query()`](/documentation/SwiftData/Query()) macro and specify a
predicate or fetch descriptor. SwiftData performs the fetch when the view
appears, and tells SwiftUI about any subsequent changes to the fetched models
so the view can update accordingly. You can access the model context in any
SwiftUI view using the <doc://com.apple.documentation/documentation/SwiftUI/EnvironmentValues/modelContext>
environment value, and specify a particular model container or context for a
view with the <doc://com.apple.documentation/documentation/SwiftUI/View/modelContainer(_:)>
and <doc://com.apple.documentation/documentation/SwiftUI/View/modelContext(_:)>
view modifiers.

#### Topics

##### Essentials

[Preserving your app’s model data across launches](/documentation/SwiftData/Preserving-your-apps-model-data-across-launches)

Describe your model classes to SwiftData using the framework’s macros, and
store instances of those models so they exist beyond the app’s runtime.

[Adding and editing persistent data in your app](/documentation/SwiftData/Adding-and-editing-persistent-data-in-your-app)

Create a data entry form for collecting and changing data managed by SwiftData.

  <doc://com.apple.documentation/documentation/CoreData/adopting-swiftdata-for-a-core-data-app>

  <doc://com.apple.documentation/documentation/Updates/SwiftData>

[Adopting inheritance in SwiftData](/documentation/SwiftData/Adopting-inheritance-in-SwiftData)

Add flexibility to your models using class inheritance.

##### Model definition

[`macro Model()`](/documentation/SwiftData/Model())

Converts a Swift class into a stored model that’s managed by SwiftData.

[`macro Attribute(Schema.Attribute.Option..., originalName: String?, hashModifier: String?)`](/documentation/SwiftData/Attribute(_:originalName:hashModifier:))

Specifies the custom behavior that SwiftData applies to the annotated property
when managing the owning class.

[`macro Unique<T>([PartialKeyPath<T>]...)`](/documentation/SwiftData/Unique(_:))

Specifies the key-paths that SwiftData uses to enforce the uniqueness of model
instances.

[`macro Index<T>([PartialKeyPath<T>]...)`](/documentation/SwiftData/Index(_:)-74ia2)

Specifies the key-paths that SwiftData uses to create one or more binary
indices for the associated model.

[`macro Index<T>(Schema.Index<T>.Types<T>...)`](/documentation/SwiftData/Index(_:)-7d4z0)

Specifies the key-paths that SwiftData uses to create one or more indicies for
the associated model, where each index is either binary or R-tree.

[Defining data relationships with enumerations and model classes](/documentation/SwiftData/Defining-data-relationships-with-enumerations-and-model-classes)

Create relationships for static and dynamic data stored in your app.

[`macro Relationship(Schema.Relationship.Option..., deleteRule: Schema.Relationship.DeleteRule, minimumModelCount: Int?, maximumModelCount: Int?, originalName: String?, inverse: AnyKeyPath?, hashModifier: String?)`](/documentation/SwiftData/Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:))

Specifies the options that SwiftData needs to manage the annotated property as
a relationship between two models.

[`macro Transient()`](/documentation/SwiftData/Transient())

Tells SwiftData not to persist the annotated property when managing the owning
class.

##### Model life cycle

[`class ModelContainer`](/documentation/SwiftData/ModelContainer)

An object that manages an app’s schema and model storage configuration.

[`class ModelContext`](/documentation/SwiftData/ModelContext)

An object that enables you to fetch, insert, and delete models, and save any
changes to disk.

[Fetching and filtering time-based model changes](/documentation/SwiftData/Fetching-and-filtering-time-based-model-changes)

Track all inserts, updates, and deletes that occur in a data store and process
them as a series of chronological transactions.

  <doc:History>

[`HistoryDescriptor`](/documentation/SwiftData/HistoryDescriptor)

[Deleting persistent data from your app](/documentation/SwiftData/Deleting-persistent-data-from-your-app)

Explore different ways to use SwiftData to delete persistent data.

[Reverting data changes using the undo manager](/documentation/SwiftData/Reverting-data-changes-using-the-undo-manager)

Automatically record data change operations that people perform in your
SwiftUI app, and let them undo and redo those changes.

[Syncing model data across a person’s devices](/documentation/SwiftData/Syncing-model-data-across-a-persons-devices)

Add the required capabilities and define a compatible schema to enable
SwiftData to automatically sync your app’s model data using iCloud.

[Concurrency support](/documentation/SwiftData/ConcurrencySupport)

Types you use to access model attributes and perform storage-related tasks in
a safe and isolated way.

##### Model fetch

[Filtering and sorting persistent data](/documentation/SwiftData/Filtering-and-sorting-persistent-data)

Manage data store presentation using predicates and dynamic queries.

[`macro Query()`](/documentation/SwiftData/Query())

Fetches all instances of the attached model type.

[Additional query macros](/documentation/SwiftData/AdditionalQueryMacros)

Supplementary macros that enable you to narrow query results and tell SwiftData
how to sort, order, and section those results.

[`struct Query`](/documentation/SwiftData/Query)

A type that fetches models using the specified criteria, and manages those
models so they remain in sync with the underlying data.

[`struct FetchDescriptor`](/documentation/SwiftData/FetchDescriptor)

A type that describes the criteria, sort order, and any additional
configuration to use when performing a fetch.

##### Model storage

[Maintaining a local copy of server data](/documentation/SwiftData/Maintaining-a-local-copy-of-server-data)

Create and update a persistent store to cache read-only network data.

[`class DefaultStore`](/documentation/SwiftData/DefaultStore)

A data store that uses Core Data as its undelying storage mechanism.

[`protocol DataStore`](/documentation/SwiftData/DataStore)

An interface that enables SwiftData to read and write model data without
knowledge of the underlying storage mechanism.

[`protocol DataStoreBatching`](/documentation/SwiftData/DataStoreBatching)

An interface that enables a custom data store to support batch requests.

[`protocol HistoryProviding`](/documentation/SwiftData/HistoryProviding)

An interface that enables a custom data store to provide the history of changes
for its persisted models.

  <doc://com.apple.documentation/documentation/SwiftUI/Building-a-document-based-app-using-SwiftData>

[`struct ModelDocument`](/documentation/SwiftData/ModelDocument)

A document type that uses SwiftData to manage its storage.

##### History life cycle

[`enum HistoryChange`](/documentation/SwiftData/HistoryChange)

Values that describe data history transactions.

[`protocol HistoryDelete`](/documentation/SwiftData/HistoryDelete)

An interface that enables a custom data store to delete items from the history of changes to its persisted models.

[`protocol HistoryInsert`](/documentation/SwiftData/HistoryInsert)

[`protocol HistoryToken`](/documentation/SwiftData/HistoryToken)

[`protocol HistoryTransaction`](/documentation/SwiftData/HistoryTransaction)

[`protocol HistoryUpdate`](/documentation/SwiftData/HistoryUpdate)

[`struct HistoryTombstone`](/documentation/SwiftData/HistoryTombstone)

[`struct DefaultHistoryInsert`](/documentation/SwiftData/DefaultHistoryInsert)

[`struct DefaultHistoryUpdate`](/documentation/SwiftData/DefaultHistoryUpdate)

[`struct DefaultHistoryDelete`](/documentation/SwiftData/DefaultHistoryDelete)

[`struct DefaultHistoryToken`](/documentation/SwiftData/DefaultHistoryToken)

[`struct DefaultHistoryTransaction`](/documentation/SwiftData/DefaultHistoryTransaction)

##### Data store observation

[`class ResultsObserver`](/documentation/SwiftData/ResultsObserver)

Observes and tracks changes to a collection of persistent models in a model context.

[`class HistoryObserver`](/documentation/SwiftData/HistoryObserver)

Monitors a model container’s data stores for remote changes and notifies
when new history transactions are available.

##### Codeable support

[`enum DataStoreSnapshotCodingKey`](/documentation/SwiftData/DataStoreSnapshotCodingKey)

The key space to use when implementing custom coders and decoders for data store snapshots,

##### Errors

[`struct SwiftDataError`](/documentation/SwiftData/SwiftDataError)

A type that describes a SwiftData error.

[`enum DataStoreError`](/documentation/SwiftData/DataStoreError)

A type that describes a data store error.

##### Structures

[`struct ResultsSection`](/documentation/SwiftData/ResultsSection)

A section of fetched results grouped by a common section key path value.

[`struct SectionedResults`](/documentation/SwiftData/SectionedResults)

A `RandomAccessCollection` of [`ResultsSection`](/documentation/SwiftData/ResultsSection) instances representing sectioned query results.

### Model()  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/swiftdata/model().md>


Converts a Swift class into a stored model that’s managed by SwiftData.

```
@attached(member, conformances: Observable, PersistentModel, Sendable, names: named(_$backingData), named(persistentBackingData), named(schemaMetadata), named(init), named(_$observationRegistrar), named(_SwiftDataNoType), named(access), named(withMutation)) @attached(memberAttribute) @attached(extension, conformances: Observable, PersistentModel, Sendable) macro Model()
```

#### Overview

Annotate your model classes with the `@Model` macro to make them persistable.
At build time, the macro expands to provide conformance to the [`PersistentModel`](/documentation/SwiftData/PersistentModel)
and <doc://com.apple.documentation/documentation/Observation/Observable>
protocols.

```swift
@Model
class RemoteImage {
    var sourceURL: URL
    var data: Data
    
    init(sourceURL: URL, data: Data = Data()) {
        self.sourceURL = sourceURL
        self.data = data
    }
}
```

For more information about defining models, see [Preserving your app’s model data across launches](/documentation/SwiftData/Preserving-your-apps-model-data-across-launches).

### Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:)  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/swiftdata/relationship(_:deleteRule:minimummodelcount:maximummodelcount:originalname:inverse:hashmodifier:).md>


Specifies the options that SwiftData needs to manage the annotated property as
a relationship between two models.

```
@attached(peer) macro Relationship(_ options: Schema.Relationship.Option..., deleteRule: Schema.Relationship.DeleteRule = .nullify, minimumModelCount: Int? = 0, maximumModelCount: Int? = 0, originalName: String? = nil, inverse: AnyKeyPath? = nil, hashModifier: String? = nil)
```

#### Parameters

`options`

A list of options to apply to the annotated property to customize its behavior. For possible values, see [`Schema.Relationship.Option`](/documentation/SwiftData/Schema/Relationship/Option).

`deleteRule`

The rule to apply when you delete the relationship’s owning persistent model. For possible values, see [`Schema.Relationship.DeleteRule`](/documentation/SwiftData/Schema/Relationship/DeleteRule-swift.enum). The default value is [`Schema.Relationship.DeleteRule.nullify`](/documentation/SwiftData/Schema/Relationship/DeleteRule-swift.enum/nullify).

`minimumModelCount`

The minimum number of models the relationship can reference. The default value is `0`.

`maximumModelCount`

The maximum number of models the relationship can reference. The default value is `0`.

`originalName`

The previous name of the attribute, if it’s different to the one in the current schema version. The default value is `nil`.

`inverse`

The key path of the relationship that represents the inverse of this relationship. The default value is `nil`.

`hashModifier`

A unique hash value that represents the most recent version of the annotated property. The default value is `nil`.

#### Overview

If one or more of a model’s properties represent relationships between their
containing model and another model, annotate those properties with the
`@Relationship` macro. This enables SwiftData to enforce those relationships at
runtime — including what happens if you delete related data – as well as write
any associated metadata to the persistent storage so the relationships exist
across app launches.

In the following example, a remote image may belong to a category, and a
category can contain zero, one, or more images.

```swift
@Model
class RemoteImage {
    @Attribute(.unique) var sourceURL: URL
    @Relationship(inverse: \Category.images) var category: Category?
    var data: Data

    init(sourceURL: URL, data: Data = Data()) {
        self.sourceURL = sourceURL
        self.data = data
    }
}

@Model
class Category {
    @Attribute(.unique) var name: String
    @Relationship var images = [RemoteImage]()

    init(name: String) {
        self.name = name
    }
}
```

> Note: If you declare a relationship attribute as optional when defining your
> persistent models, SwiftData only enforces `minimumModelCount` and
> `maximumModelCount` when that attribute isn’t nil.

For more information about defining relationships between models, see
[Defining data relationships with enumerations and model classes](/documentation/SwiftData/Defining-data-relationships-with-enumerations-and-model-classes).

### ModelContext  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/swiftdata/modelcontext.md>


An object that enables you to fetch, insert, and delete models, and save any
changes to disk.

```
class ModelContext
```

#### Overview

A model context is central to SwiftData as it’s responsible for managing the
entire lifecycle of your persistent models. You use a context to insert new
models, track and persist changes to those models, and to delete those models
when you no longer need them. A context understands your app’s schema but
doesn’t know about any individual models until you tell it to fetch some from
the persistent storage or populate it with new models. Afterwards, any changes
made to those models exist only in memory until the context implicitly writes
them to the persistent storage, or you manually invoke [`save()`](/documentation/SwiftData/ModelContext/save()). For more
information about implicit writes, see [`autosaveEnabled`](/documentation/SwiftData/ModelContext/autosaveEnabled).

If your app’s schema describes relationships between models, you don’t need to
manually insert each model into the context when you first create them.
Instead, create the graph of related models and insert only the graph’s root
model into the context. The context recognizes the hierarchy and automatically
handles the insertion of the related models. The same behavior applies even if
the graph contains both new and existing models.

A model context depends on a model container for knowledge about your app’s
schema and persistent storage. After you attach a container to your app’s
window group or view hierarchy, an associated context becomes available in the
SwiftUI environment. This context is bound to the main actor and the framework
configures the context to implicitly save future model changes. The
[`Query()`](/documentation/SwiftData/Query()) macros use the same context to perform their fetches.

```swift
struct LastModifiedView: View {
    @Environment(\.modelContext) private var modelContext

}
```

> Important: If you don’t explicitly attach a model container, the environment
> provides a context bound to an in-memory, schema-less container. Any attempt
> to insert a model into this context causes the framework to throw an error, and
> any fetches you run will return empty results.

After you establish access to a model context, use that context’s
[`insert(_:)`](/documentation/SwiftData/ModelContext/insert(_:)) and [`delete(_:)`](/documentation/SwiftData/ModelContext/delete(_:)) methods to add and remove models. You can
also delete several models at once using
[`delete(model:where:includeSubclasses:)`](/documentation/SwiftData/ModelContext/delete(model:where:includeSubclasses:)). There isn’t a corresponding method
to update a model because the context automatically tracks all changes to its
known models. Use the [`hasChanges`](/documentation/SwiftData/ModelContext/hasChanges) property to determine if the context has
unsaved changes, and call [`rollback()`](/documentation/SwiftData/ModelContext/rollback()) to discard any pending inserts and
deletes and any restore changed models to their most recent saved state.

Although you fetch models primarily with the `Query()` macro (and its
variants), you can use a model context to perform almost identical fetches. For
example, use the [`fetch(_:)`](/documentation/SwiftData/ModelContext/fetch(_:)) and [`fetch(_:batchSize:)`](/documentation/SwiftData/ModelContext/fetch(_:batchSize:)) methods to retrieve
all models of a certain type that match a set of criteria. And use
[`fetchCount(_:)`](/documentation/SwiftData/ModelContext/fetchCount(_:)) to determine the number of models that match some criteria
without the overhead of fetching the models themselves. If you need to be able
to identify models that match some criteria but don’t require all of the
associated data, use [`fetchIdentifiers(_:)`](/documentation/SwiftData/ModelContext/fetchIdentifiers(_:)) and [`fetchIdentifiers(_:batchSize:)`](/documentation/SwiftData/ModelContext/fetchIdentifiers(_:batchSize:))
to retrieve only those models’ persistent identifiers.

A model context posts a [`willSave`](/documentation/SwiftData/ModelContext/willSave) notification before it attempts a save
operation, and a [`didSave`](/documentation/SwiftData/ModelContext/didSave) notification immediately after that operation
succeeds. Subscribe to one, or both, of these notifications if your app needs
to be aware of these events. The `didSave` notification provides additional
information about any inserted, updated, and deleted models.

```swift
struct LastModifiedView: View {
    @Environment(\.modelContext) private var context
    @State private var lastModified = Date.now
    
    private var didSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: context)
    }
    
    var body: some View {
        Text(lastModified.formatted(date: .abbreviated, time: .shortened))
            .onReceive(didSavePublisher) { _ in
                lastModified = Date.now
            }
    }
}
```

> Note: To avoid receiving unwanted or unexpected notifications, always specify
> the model context as the `object` parameter when creating a publisher.

#### Topics

##### Creating a model context

[`init(ModelContainer)`](/documentation/SwiftData/ModelContext/init(_:))

Creates a context that belongs to the specified model container.

[`class ModelContainer`](/documentation/SwiftData/ModelContainer)

An object that manages an app’s schema and model storage configuration.

##### Fetching models

[`func fetch<T>(FetchDescriptor<T>) throws -> [T]`](/documentation/SwiftData/ModelContext/fetch(_:))

Returns an array of typed models that match the criteria of the specified fetch
descriptor.

[`func fetch<T>(FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<T>`](/documentation/SwiftData/ModelContext/fetch(_:batchSize:))

Returns a collection of typed models, in batches, which match the criteria of
the specified fetch descriptor.

[`func fetchCount<T>(FetchDescriptor<T>) throws -> Int`](/documentation/SwiftData/ModelContext/fetchCount(_:))

Returns the number of models that match the criteria of the specified fetch
descriptor.

[`struct FetchDescriptor`](/documentation/SwiftData/FetchDescriptor)

A type that describes the criteria, sort order, and any additional
configuration to use when performing a fetch.

[`struct FetchResultsCollection`](/documentation/SwiftData/FetchResultsCollection)

A collection that efficiently provides the results of a completed fetch.

[`func enumerate<T>(FetchDescriptor<T>, batchSize: Int, allowEscapingMutations: Bool, block: (T) throws -> Void) throws`](/documentation/SwiftData/ModelContext/enumerate(_:batchSize:allowEscapingMutations:block:))

Runs a closure for each model that matches the criteria of the specified fetch
descriptor.

[`func model(for: PersistentIdentifier) -> any PersistentModel`](/documentation/SwiftData/ModelContext/model(for:))

Returns the persistent model for the specified identifier.

[`func registeredModel<T>(for: PersistentIdentifier) -> T?`](/documentation/SwiftData/ModelContext/registeredModel(for:))

Returns the typed model for the specified identifier.

##### Inserting models

[`var insertedModelsArray: [any PersistentModel]`](/documentation/SwiftData/ModelContext/insertedModelsArray)

The array of inserted models that the context is yet to persist.

[`func insert<T>(T)`](/documentation/SwiftData/ModelContext/insert(_:))

Registers the specified model with the context so it can include the model in
the next save operation.

##### Modifying models

[`var hasChanges: Bool`](/documentation/SwiftData/ModelContext/hasChanges)

A Boolean value that indicates whether the context has unsaved changes.

[`var changedModelsArray: [any PersistentModel]`](/documentation/SwiftData/ModelContext/changedModelsArray)

The array of registered models that have unsaved changes.

##### Deleting models

[`var deletedModelsArray: [any PersistentModel]`](/documentation/SwiftData/ModelContext/deletedModelsArray)

The array of registered models that the context will remove from the persistent
storage during the next save operation.

[`func delete<T>(T)`](/documentation/SwiftData/ModelContext/delete(_:))

Removes the specified model from the persistent storage during the next save
operation.

[`func delete<T>(model: T.Type, where: Predicate<T>?, includeSubclasses: Bool) throws`](/documentation/SwiftData/ModelContext/delete(model:where:includeSubclasses:))

Removes each model satisfying the given predicate from the persistent storage
during the next save operation.

##### Persisting unsaved changes

[`var autosaveEnabled: Bool`](/documentation/SwiftData/ModelContext/autosaveEnabled)

A Boolean value that indicates whether the context should automatically save
any pending changes when certain events occur.

[`func save() throws`](/documentation/SwiftData/ModelContext/save())

Writes any pending inserts, changes, and deletes to the persistent storage.

[`func transaction(block: () throws -> Void) throws`](/documentation/SwiftData/ModelContext/transaction(block:))

Runs the provided closure, and once it finishes, writes any pending inserts,
changes, and deletes to the persistent storage.

[`func rollback()`](/documentation/SwiftData/ModelContext/rollback())

Discards pending inserts and deletes, restores changed models to their most
recent committed state, and empties the undo stack.

##### Fetching only persistent identifiers

[`func fetchIdentifiers<T>(FetchDescriptor<T>) throws -> [PersistentIdentifier]`](/documentation/SwiftData/ModelContext/fetchIdentifiers(_:))

Returns an array of persistent identifiers, where each identifier represents a
single model that satisfies the criteria of the specified fetch descriptor.

[`func fetchIdentifiers<T>(FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<PersistentIdentifier>`](/documentation/SwiftData/ModelContext/fetchIdentifiers(_:batchSize:))

Returns a collection of persistent identifiers, in batches, where each
identifier represents a single model that satisfies the criteria of the
specified fetch descriptor.

##### Accessing the container

[`var container: ModelContainer`](/documentation/SwiftData/ModelContext/container)

The context’s model container.

##### Performing undo and redo

[`func processPendingChanges()`](/documentation/SwiftData/ModelContext/processPendingChanges())

Tells the undo manager to record any changes made to the context’s registered
models.

[`var undoManager: UndoManager?`](/documentation/SwiftData/ModelContext/undoManager)

The object that provides undo support for the context.

##### Registering for notifications

[`static let willSave: Notification.Name`](/documentation/SwiftData/ModelContext/willSave)

A notification that posts when the context is about to process pending inserts,
changes, and deletes.

[`static let didSave: Notification.Name`](/documentation/SwiftData/ModelContext/didSave)

A notification that posts when the context finishes processing pending inserts,
changes, and deletes.

[`enum NotificationKey`](/documentation/SwiftData/ModelContext/NotificationKey)

Describes the data in the user info dictionary of a notification sent by a model context.

##### Comparing contexts

##### Debugging contexts

[`var debugDescription: String`](/documentation/SwiftData/ModelContext/debugDescription)

A textual representation of the context, suitable for debugging.

##### Instance Properties

[`var author: String?`](/documentation/SwiftData/ModelContext/author)

[`var editingState: EditingState`](/documentation/SwiftData/ModelContext/editingState)

##### Instance Methods

[`func deleteHistory<T>(HistoryDescriptor<T>) throws`](/documentation/SwiftData/ModelContext/deleteHistory(_:))

[`func fetchHistory<T>(HistoryDescriptor<T>) throws -> [T]`](/documentation/SwiftData/ModelContext/fetchHistory(_:))

#### Relationships

##### Conforms To

[`Equatable`](/documentation/Swift/Equatable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### Query  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/swiftdata/query.md>


A type that fetches models using the specified criteria, and manages those
models so they remain in sync with the underlying data.

```
@MainActor @preconcurrency struct Query<Element, Result> where Element : PersistentModel
```

#### Topics

##### Creating a query

[`init(FetchDescriptor<Element>, animation: Animation)`](/documentation/SwiftData/Query/init(_:animation:))

Create a query with a SwiftData fetch descriptor.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], animation: Animation)`](/documentation/SwiftData/Query/init(filter:sort:animation:))

Create a query with a predicate, and a list of sort descriptors.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, animation: Animation)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:)-1qfoj)

Creates a query with a predicate, a key path to a property for sorting,
and the order to sort by.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, animation: Animation)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:)-3qovd)

Creates a query with a predicate, a key path to a property for sorting,
and the order to sort by.

[`init(FetchDescriptor<Element>, transaction: Transaction?)`](/documentation/SwiftData/Query/init(_:transaction:))

Create a query with a SwiftData fetch descriptor.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], transaction: Transaction?)`](/documentation/SwiftData/Query/init(filter:sort:transaction:))

Create a query with a predicate, and a list of sort descriptors.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, transaction: Transaction?)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:)-2bx9a)

Create a query with a predicate, a key path to a property for sorting,
and the order to sort by.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, transaction: Transaction?)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:)-8q7vs)

Create a query with a predicate, a key path to a property for sorting,
and the order to sort by.

##### Creating an unsorted, sectioned query

##### Creating a sorted, sectioned query

##### Getting query configuration

[`var modelContext: ModelContext`](/documentation/SwiftData/Query/modelContext)

Current model context `Query` interacts with.

[`var fetchError: (any Error)?`](/documentation/SwiftData/Query/fetchError)

An error encountered during the most recent attempt to fetch data.

##### Accessing the value

[`var wrappedValue: Result`](/documentation/SwiftData/Query/wrappedValue)

The most recent fetched result from the Query.

##### Accessing sections

[`var sections: SectionedResults<Element, String>`](/documentation/SwiftData/Query/sections)

The sections computed from the current results, grouped by the `sectionBy` key path.

##### Updating the value

##### Initializers

[`init(FetchDescriptor<Element>, animation: Animation, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(_:animation:sectionBy:)-1yoyc)

Creates a sectioned query from a fetch descriptor, grouped into sections by a required String key path.

[`init(FetchDescriptor<Element>, animation: Animation, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(_:animation:sectionBy:)-8yip7)

Creates a sectioned query from a fetch descriptor, grouped by a required optional-String key path.

[`init(FetchDescriptor<Element>, transaction: Transaction?, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(_:transaction:sectionBy:)-3pg23)

Creates a sectioned query from a fetch descriptor, grouped into sections by a required String key path.

[`init(FetchDescriptor<Element>, transaction: Transaction?, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(_:transaction:sectionBy:)-8ecyq)

Creates a sectioned query from a fetch descriptor, grouped by a required optional-String key path.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], animation: Animation, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:animation:sectionBy:)-1sjv1)

Creates a sectioned query with sort descriptors, grouped by a required optional-String key path.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], animation: Animation, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:animation:sectionBy:)-35eif)

Creates a sectioned query with sort descriptors, grouped into sections by a required String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, animation: Animation, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:sectionBy:)-39v3n)

Creates a sectioned query sorted by an optional key path, grouped by a required optional-String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, animation: Animation, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:sectionBy:)-3myq0)

Creates a sectioned query sorted by a key path, grouped into sections by a required String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, animation: Animation, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:sectionBy:)-4peqq)

Creates a sectioned query sorted by a key path, grouped by a required optional-String key path. `nil` values share the empty-string section.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, animation: Animation, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:order:animation:sectionBy:)-6td6n)

Creates a sectioned query sorted by an optional key path, grouped into sections by a required String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, transaction: Transaction?, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:sectionBy:)-2kk0t)

Creates a sectioned query sorted by an optional key path, grouped into sections by a required String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value?>, order: SortOrder, transaction: Transaction?, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:sectionBy:)-62fdm)

Creates a sectioned query sorted by an optional key path, grouped by a required optional-String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, transaction: Transaction?, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:sectionBy:)-68vqy)

Creates a sectioned query sorted by a key path, grouped by a required optional-String key path.

[`init<Value>(filter: Predicate<Element>?, sort: KeyPath<Element, Value>, order: SortOrder, transaction: Transaction?, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:order:transaction:sectionBy:)-8finq)

Creates a sectioned query sorted by a key path, grouped into sections by a required String key path.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], transaction: Transaction?, sectionBy: KeyPath<Element, String?>)`](/documentation/SwiftData/Query/init(filter:sort:transaction:sectionBy:)-353r3)

Creates a sectioned query with sort descriptors, grouped by a required optional-String key path.

[`init(filter: Predicate<Element>?, sort: [SortDescriptor<Element>], transaction: Transaction?, sectionBy: KeyPath<Element, String>)`](/documentation/SwiftData/Query/init(filter:sort:transaction:sectionBy:)-90bbe)

Creates a sectioned query with sort descriptors, grouped into sections by a required String key path.

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`DynamicProperty`](/documentation/SwiftUI/DynamicProperty)

### Predicate  
*iOS: 17.0.0 -* · <https://developer.apple.com/documentation/foundation/predicate.md>


A logical condition used to test a set of input values for searching or filtering.

```
struct Predicate<each Input>
```

#### Overview

A predicate is a logical condition that evaluates to a Boolean value (true or false).  You use predicates for operations like filtering a collection or searching for matching elements.

To create a predicate, use the `Predicate(_:)` macro.  For example:

```swift
let messagePredicate = #Predicate<Message> { message in
    message.length < 100 && message.sender == "Jeremy"
}
```

In the example above, the closure that contains the predicate’s conditions takes one argument — the value being tested. Even though you write the predicate using a closure, the macro transforms that closure into a predicate when you compile. The code in the closure isn’t run as part of your program.

In the predicate’s definition, you can use the following operations:

- Arithmetic (`+`, `-`, `*`, `/`, `%`)
- Unary minus (`-`)
- Range (`...`, `..<`)
- Comparison (`<`, `<=`, `>`, `>=`, `==`, `!=`)
- Ternary conditional (`?:`)
- Conditional expressions
- Boolean logic (`&&`, `||`, `!`)
- Swift optionals (`?`, `??`, `!`, `flatMap(_:)`, `if`-`let` expressions)
- Types (`as`, `as?`, `as!`, `is`)
- Sequence operations (`allSatisfy()`, `filter()`, `contains()`, `contains(where:)`, `starts(with:)`, `max()`, `min()`)
- Subscript and member access (`[]`, `.`)
- String comparisons (`contains(_:)`, `localizedStandardContains(_:)`, `caseInsensitiveCompare(_:)`, `localizedCompare(_:)`)

A predicate can’t contain any nested declarations, use any flow control such as `for` loops, or modify variables from its enclosing scope. However, it can refer to constants that are in scope.

To express more complex queries, you can nest expressions in the predicate:

```swift
let messagePredicate = #Predicate<Message> { message in
    message.recipients.contains {
        $0.firstName == message.sender.firstName
    }
}
```

You can safely encode and decode predicates, pass predicates across concurrency boundaries, and load a predicate from a file. To define a list of types and key paths that are allowed when reading an archived predicate, use [`PredicateCodableConfiguration`](/documentation/Foundation/PredicateCodableConfiguration).

You can transform a predicate into another representation — for example, to express a predicate in another query language, or to create a modified predicate — using the [`expression`](/documentation/Foundation/Predicate/expression) property.

#### Topics

##### Inspecting and transforming a predicate

[`let expression: any StandardPredicateExpression<Bool>`](/documentation/Foundation/Predicate/expression)

The component expressions of the predicate.

##### Initializers

[`init((repeat PredicateExpressions.Variable<each Input>) -> any StandardPredicateExpression<Bool>)`](/documentation/Foundation/Predicate/init(_:))

[`init(all: some BidirectionalCollection<Predicate<repeat each Input>>)`](/documentation/Foundation/Predicate/init(all:))

[`init(any: some BidirectionalCollection<Predicate<repeat each Input>>)`](/documentation/Foundation/Predicate/init(any:))

##### Instance Properties

[`let variable: (repeat PredicateExpressions.Variable<each Input>)`](/documentation/Foundation/Predicate/variable)

##### Instance Methods

[`func evaluate(repeat each Input) throws -> Bool`](/documentation/Foundation/Predicate/evaluate(_:))

##### Type Properties

[`static var `false`: Predicate<repeat each Input>`](/documentation/Foundation/Predicate/false)

[`static var `true`: Predicate<repeat each Input>`](/documentation/Foundation/Predicate/true)

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Encodable`](/documentation/Swift/Encodable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`EncodableWithConfiguration`](/documentation/Foundation/EncodableWithConfiguration)

[`Copyable`](/documentation/Swift/Copyable)

[`DecodableWithConfiguration`](/documentation/Foundation/DecodableWithConfiguration)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Escapable`](/documentation/Swift/Escapable)

[`Decodable`](/documentation/Swift/Decodable)

### Preserving your app’s model data across launches  
<https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches.md>


Describe your model classes to SwiftData using the framework’s macros, and
store instances of those models so they exist beyond the app’s runtime.

#### Discussion

Most apps define a number of custom types that model the data
it creates or consumes. For example, a travel app might define classes that
represent trips, flights, and booked accommodations. Using SwiftData, you can
quickly and efficiently persist that data so it’s available across app
launches, and leverage the framework’s integration with SwiftUI to refetch that
data and display it onscreen.

By design, SwiftData supplements your existing model classes. The framework
provides tools such as macros and property wrappers that enable you to
expressively describe your app’s schema in Swift code, removing any reliance on
external dependencies such as model and migration mapping files.

##### Turn classes into models to make them persistable

To let SwiftData save instances of a model class, import the framework and
annotate that class with the [`Model()`](/documentation/SwiftData/Model()) macro. The macro updates the class with
conformance to the [`PersistentModel`](/documentation/SwiftData/PersistentModel) protocol, which SwiftData uses to
examine the class and generate an internal schema. Additionally, the macro
enables change tracking for the class by adding conformance to the
<doc://com.apple.documentation/documentation/Observation/Observable>
protocol.

```swift
import SwiftData

// Annotate new or existing model classes with the @Model macro.
@Model
class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var accommodation: Accommodation?
}
```

By default, SwiftData includes all noncomputed properties of a class as long
as they use compatible types. The framework supports primitive types such as
<doc://com.apple.documentation/documentation/Swift/Bool>,
<doc://com.apple.documentation/documentation/Swift/Int>, and
<doc://com.apple.documentation/documentation/Swift/String>, as well as complex
value types such as structures, enumerations, and other value types that
conform to the <doc://com.apple.documentation/documentation/Swift/Codable>
protocol.

The code you write to define your model classes now serves as the source of
truth for your app’s model layer, and the framework uses that to keep the
persisted data in a consistent state.

##### Customize the persistence behavior of model attributes

An *attribute* is a property of a model class that SwiftData manages. In most
cases, the framework’s default behavior for attributes is sufficient. However,
if you need to alter how SwiftData handles the persistence of a particular
attribute, use one of the provided schema macros. For example, you may want to
avoid conflicts in your model data by specifying that an attribute’s value is
unique across all instances of that model.

To customize an attribute’s behavior, annotate the property with the
[`Attribute(_:originalName:hashModifier:)`](/documentation/SwiftData/Attribute(_:originalName:hashModifier:)) macro and specify values for the
options that drive the desired behavior:

```swift
@Attribute(.unique) var name: String
```

Aside from enforcing unique constraints, `@Attribute` supports, among others,
preserving deleted values, Spotlight indexing, and encryption. You can also use
the `@Attribute` macro to correctly handle renamed attributes if you want to
preserve the original name in the underlying model data.

When a model contains an attribute whose type is also a model (or a collection
of models), SwiftData implicitly manages the relationship between those models
for you. By default, the framework sets relationship attributes to `nil` after
you delete a related model instance. To specify a different deletion rule,
annotate the property with the [`Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:)`](/documentation/SwiftData/Relationship(_:deleteRule:minimumModelCount:maximumModelCount:originalName:inverse:hashModifier:))
macro. For example, you may want to delete any related accommodations when
deleting a trip. For more information about delete rules,
see [`Schema.Relationship.DeleteRule`](/documentation/SwiftData/Schema/Relationship/DeleteRule-swift.enum).

```swift
@Relationship(.cascade) var accommodation: Accommodation?
```

SwiftData persists all noncomputed attributes of a model by default, but you
may not always want this to happen. For example, one or more properties on a
class may only ever contain temporary data that doesn’t need saving, such as
the current weather at an upcoming trip’s destination. In such scenarios,
annotate those properties with the [`Transient()`](/documentation/SwiftData/Transient()) macro and SwiftData won’t
write their values to disk.

```swift
@Transient var destinationWeather = Weather.current()
```

##### Configure the model storage

Before SwiftData can examine your models and generate the required schema, you
need to tell it — at runtime — which models to persist, and optionally, the
configuration to use for the underlying storage. For example, you may want the
storage to exist only in memory when running tests, or to use a specific
CloudKit container when syncing model data across devices.

To set up the default storage, use the <doc://com.apple.documentation/documentation/SwiftUI/View/modelContainer(for:inMemory:isAutosaveEnabled:isUndoEnabled:onSetup:)-18hhy>
view modifier (or the scene equivalent) and specify the array of model types to
persist. If you use the view modifier, add it at the very top of the view
hierarchy so all nested views inherit the properly configured environment:

```swift
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Trip.self,
                    Accommodation.self
                ])
        }
    }
}
```

If you’re not using SwiftUI, create a model container manually using the
appropriate initializer:

```swift
import SwiftData

let container = try ModelContainer([
    Trip.self, 
    Accommodation.self
])
```

> Tip: If a model type contains a relationship, you may omit the destination
> model type from the array. SwiftData automatically traverses a model’s
> relationships and includes any destination model types for you.

Alternatively, use [`ModelConfiguration`](/documentation/SwiftData/ModelConfiguration) to create custom storage. The type
provides a number of options to configure including whether:

- the storage exists only in memory.
- the storage is read-only.
- the app uses a specific App Group to store its model data.

```swift
let configuration = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: false)

let container = try ModelContainer(
    for: Trip.self, Accommodation.self, 
    configurations: configuration
)
```

> Important: Automatic iCloud sync relies on the presence of the CloudKit
> entitlement, and SwiftData uses the first container it finds in that
> entitlement. If your app needs a particular container, use an instance of
> `ModelConfiguration` to specify that container.

##### Save models for later use

To manage instances of your model classes at runtime, use a *model context* —
the object responsible for the in-memory model data and coordination with the
model container to successfully persist that data. To get a context for your
model container that’s bound to the main actor, use the <doc://com.apple.documentation/documentation/SwiftUI/EnvironmentValues/modelContext>
environment variable:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
}
```

Outside of a view, or if you’re not using SwiftUI, access the same actor-bound
context directly using the model container:

```swift
let context = container.mainContext
```

In both instances, the returned context periodically checks whether it contains
unsaved changes, and if so, implicitly saves those changes on your behalf. For
contexts you create manually, set the [`autosaveEnabled`](/documentation/SwiftData/ModelContext/autosaveEnabled) property
to `true` to get the same behavior.

To enable SwiftData to persist a model instance and begin tracking changes to
it, insert the instance into the context:

```swift
var trip = Trip(name: name, 
                destination: destination, 
                startDate: startDate, 
                endDate: endDate)

context.insert(trip)
```

Following the insert, you can save immediately by invoking the context’s
[`save()`](/documentation/SwiftData/ModelContext/save()) method, or rely on the context’s implicit save
behavior instead. Contexts automatically track changes to their known model
instances and include those changes in subsequent saves. In addition to saving,
you can use a context to fetch, enumerate, and delete model instances. For more
information, see [`ModelContext`](/documentation/SwiftData/ModelContext).

##### Fetch models for display or additional processing

After you begin persisting model data, you’ll likely want to retrieve that
data, materialized as model instances, and display those instances in a view or
take some other action on them. SwiftData provides the [`Query`](/documentation/SwiftData/Query) property
wrapper and the [`FetchDescriptor`](/documentation/SwiftData/FetchDescriptor) type for performing fetches.

To fetch model instances, and optionally apply search criteria and a preferred
sort order, use `@Query` in your SwiftUI view. The `@Model` macro adds
`Observable` conformance to your model classes, enabling SwiftUI to refresh the
containing view whenever changes occur to any of the fetched instances.

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \.startDate, order: .reverse) var allTrips: [Trip]
    
    var body: some View {
        List {
            ForEach(allTrips) {
                TripView(for: $0)
            }
        }
    }
}
```

Outside of a view, or if you’re not using SwiftUI, use one of the two fetch
methods on [`ModelContext`](/documentation/SwiftData/ModelContext). Each method expects an instance of
[`FetchDescriptor`](/documentation/SwiftData/FetchDescriptor) containing a predicate and a sort order. The fetch
descriptor allows for additional configuration that influences batching,
offsets, and prefetching, among others.

```swift
let context = container.mainContext

let upcomingTrips = FetchDescriptor<Trip>(
    predicate: #Predicate { $0.startDate > Date.now },
    sortBy: [
        .init(\.startDate)
    ]
)
upcomingTrips.fetchLimit = 50
upcomingTrips.includePendingChanges = true

let results = context.fetch(upcomingTrips)
```

For more information about predicates, see <doc://com.apple.documentation/documentation/Foundation/Predicate>.

# SwiftUI — structure & UIKit bridges

## How our apps use it
- App structure: `TabView` → `NavigationStack` per tab; `.searchable(text:)` on lists.
- State: `@Observable` classes (Observation framework) injected with `.environment(obj)` and read
  with `@Environment(Type.self)`; `@State` for view-local.
- UIKit sheets (Mail, Messages, Contacts picker, Event editor): `UIViewControllerRepresentable`
  with a `Coordinator` that is the delegate; present with `.sheet(isPresented:)`.
- Keep `@MainActor` on anything touching UI or `ModelContext` from async code.

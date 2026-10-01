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

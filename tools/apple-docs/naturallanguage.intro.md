# NaturalLanguage & NSDataDetector

## How our apps use it
- Due dates from free text ("next Tuesday", "in two weeks"): `NSDataDetector(types: .date)`
  on the phrase, `match.date`; it resolves relative to *now*, so for notes recorded earlier
  shift by the note's age or pass the phrase through unchanged for display.
- Semantic search (stretch): `NLContextualEmbedding(language: .english)`, `load()`, then
  `embeddingResult(for:language:)` → mean-pool token vectors → cosine similarity against stored
  vectors for facts/summaries. Assets download on first use (`requestAssets`).

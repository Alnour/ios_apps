# Apple Intelligence on device — FoundationModels (iOS 26)

The on-device LLM behind Apple Intelligence, exposed to apps as the `FoundationModels`
framework. No network, no API key, no cost; runs on Apple-silicon devices with Apple
Intelligence enabled (iPhone 15 Pro and later, and on the iOS Simulator when the host Mac has
Apple Intelligence turned on).

## How our apps use it (read before writing any AI code)

1. **One fresh `LanguageModelSession` per task.** The context window is **4096 tokens per
   session** and *everything* counts: instructions, prompts, Generable schemas, tool
   definitions, tool outputs, every response. A session that keeps accumulating turns will hit
   `LanguageModelSession.GenerationError.exceededContextWindowSize`. So:
   `let session = LanguageModelSession(instructions: ...)` → one `respond` → discard.
2. **Gate on availability.** `SystemLanguageModel.default.availability` is `.available` or
   `.unavailable(reason)` (`.deviceNotEligible`, `.appleIntelligenceNotEnabled`,
   `.modelNotReady`). Show the reason; keep the non-AI parts of the feature working.
3. **Measure before you prompt.** `SystemLanguageModel.default.tokenCount(for:)` (prompt,
   instructions, tools, schema, transcript entries) and `contextSize` exist from iOS 26.4.
   Rule of thumb: ~3–4 characters per token in English. Budget ≈ 2500 tokens of input to leave
   room for the schema and the response.
4. **Feed the model condensed facts, never raw history.** For "summarise this customer" pass the
   stored facts list + last few note summaries. For long transcripts chunk by sentence, extract
   per chunk (carry the previous chunk's summary in the prompt), merge in code.
5. **Guided generation.** Mark output types `@Generable`; add `@Guide(description:)` only where
   a name is ambiguous; cap arrays with `@Guide(.maximumCount(n))`. Keep types small — the
   schema is sent as tokens. Call `session.respond(to: prompt, generating: MyType.self)` and
   read `.content`.
6. **Prompts are short and imperative.** 1–3 paragraphs max. Put the target length in the prompt
   ("in 2 sentences", "at most 60 words"). Use `GenerationOptions(maximumResponseTokens:)` only
   as a safety net — it truncates mid-sentence.
7. **Handle the error path**: catch `exceededContextWindowSize`, halve the context (drop oldest
   facts), retry once with a new session, then surface a readable error. Also catch
   `.guardrailViolation` (safety filter) and `.unsupportedLanguageOrLocale`.
8. **Tools** (`protocol Tool`) are for when the *model* must decide whether to fetch something.
   If the data is always needed, fetch it yourself and put it in the prompt — cheaper.
9. **Prewarm** a session with `session.prewarm()` right before a likely call (e.g. when the
   record screen opens) to cut first-token latency.
10. `SystemLanguageModel(useCase: .contentTagging)` is a specialised variant for tags/entities;
    the default model is right for extraction, summaries and drafting.

### Shapes we use

```swift
@Generable struct NoteExtraction {
    @Guide(description: "Short title, max 6 words") var title: String
    @Guide(description: "Two-sentence summary") var summary: String
    @Guide(.maximumCount(10)) var facts: [FactDraft]
    @Guide(.maximumCount(5)) var followUps: [FollowUpDraft]
}
@Generable struct FactDraft { var attribute: String; var value: String; var category: FactCategory }
@Generable enum FactCategory { case personal, business, preference, relationship, event, other }
@Generable struct FollowUpDraft { var title: String; @Guide(description: "When, as said, e.g. 'next Tuesday'") var dueText: String? }

let session = LanguageModelSession(instructions: "You extract CRM facts from a salesperson's voice note about one customer.")
let r = try await session.respond(to: "Customer: \(name).\nNote:\n\(transcript)", generating: NoteExtraction.self)
let extraction = r.content
```

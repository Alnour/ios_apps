---
name: foundation-models
description: "Apple Intelligence on-device LLM (FoundationModels, iOS 26): LanguageModelSession, @Generable/@Guide guided generation, tools, availability, 4096-token context budget"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,foundationmodels,apple-intelligence,llm,generable,on-device"
---

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

## Reference (developer.apple.com, fetched 2026-10-01)

### Foundation Models  
<https://developer.apple.com/documentation/foundationmodels.md>


Perform tasks with models that specialize in language understanding, structured output, and tool calling.

#### Overview

The Foundation Models framework provides access to any large language model, like
the on-device and Private Cloud Compute models designed for Apple
Intelligence. These models help you perform intelligent tasks specific to your use case.

![An illustration that represents a foundation model.](images/com.apple.foundationmodels/foundation-models-framework-hero@2x.png)

On-device models excel at a diverse range of text generation tasks, like
summarization, entity extraction, text and image understanding, refinement,
dialog for games, generating creative content, and more. When you need more
reasoning capabilities and context size, use Private Cloud Compute
or any server model provider.

The dynamic profile API provides the flexibility to select the best model configuration
for your task, and lets you build many useful abstractions, such as agents or skills.

Generate entire Swift data structures with guided generation. With the `@Generable`
macro, you can define custom data structures and the framework provides strong
guarantees that the model generates instances of your type.

Use [`Tool`](/documentation/FoundationModels/Tool) to create custom tools that the model can call to assist with handling
your request. For example, the model can call a tool that searches a local or
online database for information, or calls a service in your app.

To use Apple Foundation Models, people need a device that supports Apple
Intelligence. For a list of supported devices, see
[Apple Intelligence](https://www.apple.com/apple-intelligence/).

##### What’s new

[Adding server-side intelligence with Private Cloud Compute](/documentation/FoundationModels/adding-server-side-intelligence-with-private-cloud-compute)

Access a larger context window and stronger reasoning by routing session requests
through Private Cloud Compute.

[Composing dynamic sessions with instructions and profiles](/documentation/FoundationModels/composing-dynamic-sessions-with-instructions-and-profiles)

Adapt sessions dynamically at runtime by loading instructions and tools based
on the state of your app.

[Analyzing images with multimodal prompting](/documentation/FoundationModels/analyzing-images-with-multimodal-prompting)

Analyze and extract information from images by combining them with descriptive text prompts.

  <doc://com.apple.documentation/videos/play/wwdc2026/242>

  <doc://com.apple.documentation/videos/play/wwdc2026/339>

  <doc://com.apple.documentation/videos/play/wwdc2026/243>

#### Topics

##### Essentials

  <doc://com.apple.documentation/documentation/Updates/FoundationModels>

[Generating content and performing tasks with Foundation Models](/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)

Enhance the experience in your app by prompting an on-device large language model.

[Adding intelligent app features with generative models](/documentation/FoundationModels/adding-intelligent-app-features-with-generative-models)

Build robust apps with guided generation and tool calling by adopting the Foundation Models framework.

##### Sessions and prompts

[Prompting an on-device foundation model](/documentation/FoundationModels/prompting-an-on-device-foundation-model)

Tailor your prompts to get effective results from an on-device model.

[Managing the context window](/documentation/FoundationModels/managing-the-context-window)

Optimize your app’s token usage when prompting a model with the Foundation Models
framework.

[Updating prompts for new model versions](/documentation/FoundationModels/updating-prompts-for-new-model-versions)

Manage the prompts your app uses by versioning them to make the most out of
model improvements.

[`class LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession)

An object that represents a session that interacts with a language model.

[`struct Instructions`](/documentation/FoundationModels/Instructions)

Details you provide that define the model’s intended behavior on prompts.

[`struct Prompt`](/documentation/FoundationModels/Prompt)

A prompt from a person to the model.

[`struct GenerationOptions`](/documentation/FoundationModels/GenerationOptions)

Options that control how the model generates its response to a prompt.

[`struct ContextOptions`](/documentation/FoundationModels/ContextOptions)

Options that configure details that should appear in the prompt.

##### Session transcripts

[Transcripts](/documentation/FoundationModels/transcripts)

Inspect a session’s history and work with the entries, segments, and
attachments it contains.

##### Prompt attachments

[Analyzing images with multimodal prompting](/documentation/FoundationModels/analyzing-images-with-multimodal-prompting)

Analyze and extract information from images by combining them with descriptive text prompts.

[`struct Attachment`](/documentation/FoundationModels/Attachment)

An asset provided to the model.

[`struct ImageAttachmentContent`](/documentation/FoundationModels/ImageAttachmentContent)

A type that holds image data.

[`struct ImageReference`](/documentation/FoundationModels/ImageReference)

A reference to an image in a session’s transcript.

##### Dynamic profiles

[Composing dynamic sessions with instructions and profiles](/documentation/FoundationModels/composing-dynamic-sessions-with-instructions-and-profiles)

Adapt sessions dynamically at runtime by loading instructions and tools based
on the state of your app.

[Origami: Crafting a dynamic tutorial for Apple Intelligence](/documentation/FoundationModels/origami-crafting-a-dynamic-tutorial-for-apple-intelligence)

Build interactive experiences with Foundation Models and Private Cloud Compute using multimodal prompts.

[`protocol DynamicInstructions`](/documentation/FoundationModels/DynamicInstructions)

A type that represents dynamic instructions.

[`struct DynamicInstructionsForEach`](/documentation/FoundationModels/DynamicInstructionsForEach)

Dynamic instructions that produce content for each element of a collection.

[`protocol DynamicProfile`](/documentation/FoundationModels/LanguageModelSession/DynamicProfile)

A dynamic profile that contains one or more profiles.

[`protocol DynamicProfileModifier`](/documentation/FoundationModels/LanguageModelSession/DynamicProfileModifier)

A protocol for creating reusable wrappers around dynamic profile content.

[`struct Profile`](/documentation/FoundationModels/LanguageModelSession/Profile)

A profile that contains dynamic instructions.

##### Structured output

[Generating Swift data structures with guided generation](/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation)

Create robust apps by describing output you want programmatically.

[`macro Generable(description: String?)`](/documentation/FoundationModels/Generable(description:))

[`macro Guide(description: String)`](/documentation/FoundationModels/Guide(description:))

[`protocol Generable`](/documentation/FoundationModels/Generable)

A type that the model uses when responding to prompts.

[`struct GenerationSchema`](/documentation/FoundationModels/GenerationSchema)

A type that describes the properties of an object and any guides
on their values.

[`struct DynamicGenerationSchema`](/documentation/FoundationModels/DynamicGenerationSchema)

The dynamic counterpart to the generation schema type that you use to construct schemas at runtime.

[`struct GeneratedContent`](/documentation/FoundationModels/GeneratedContent)

A type that represents structured, generated content.

[`protocol ConvertibleToGeneratedContent`](/documentation/FoundationModels/ConvertibleToGeneratedContent)

A type that can be converted to generated content.

[`protocol ConvertibleFromGeneratedContent`](/documentation/FoundationModels/ConvertibleFromGeneratedContent)

A type that can be initialized from generated content.

##### Tools

[Expanding generation with tool calling](/documentation/FoundationModels/expanding-generation-with-tool-calling)

Build tools that enable the model to perform tasks that are specific to your use case.

[Generate dynamic game content with guided generation and tools](/documentation/FoundationModels/generate-dynamic-game-content-with-guided-generation-and-tools)

Make gameplay more lively with AI generated dialog and encounters personalized to the player.

[`protocol Tool`](/documentation/FoundationModels/Tool)

A tool that a model can call to gather information at runtime or perform side effects.

##### System language model

[Supporting languages and locales with Foundation Models](/documentation/FoundationModels/supporting-languages-and-locales-with-foundation-models)

Generate content in the language people prefer when they interact with your app.

[Categorizing and organizing data with content tags](/documentation/FoundationModels/categorizing-and-organizing-data-with-content-tags)

Identify topics, actions, objects, and emotions in input text with a content tagging model.

[`class SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel)

An on-device Apple Foundation Model capable of text generation tasks.

[`enum LanguageModelError`](/documentation/FoundationModels/LanguageModelError)

A failure that may occur while generating a response when using any language model.

##### Private Cloud Compute

[Adding server-side intelligence with Private Cloud Compute](/documentation/FoundationModels/adding-server-side-intelligence-with-private-cloud-compute)

Access a larger context window and stronger reasoning by routing session requests
through Private Cloud Compute.

  <doc://com.apple.documentation/documentation/BundleResources/Entitlements/com.apple.developer.private-cloud-compute>

[`class PrivateCloudComputeLanguageModel`](/documentation/FoundationModels/PrivateCloudComputeLanguageModel)

A variant of Apple Foundation Models that runs on Private Cloud Compute to provide enhanced
capabilities while maintaining privacy guarantees.

##### Custom language model provider

[Running a Core AI model in a Foundation Models session](/documentation/FoundationModels/running-a-core-ai-model-in-a-foundation-models-session)

Send requests on device to an open source model you export with Core AI to get a consistent API experience.

[Optimizing key-value caching in language model sessions](/documentation/FoundationModels/optimizing-key-value-caching-in-language-model-sessions)

Prevent repeated token processing by preserving the cached state across turns.

[`protocol LanguageModel`](/documentation/FoundationModels/LanguageModel)

A protocol that you use to interface with a model.

[`struct LanguageModelCapabilities`](/documentation/FoundationModels/LanguageModelCapabilities)

A set of capabilities that a language model provides.

[`protocol LanguageModelExecutor`](/documentation/FoundationModels/LanguageModelExecutor)

A protocol that defines the interface for responding to session requests.

[`struct LanguageModelExecutorGenerationChannel`](/documentation/FoundationModels/LanguageModelExecutorGenerationChannel)

A type you use to send model output deltas and updates to the framework.

[`struct LanguageModelExecutorGenerationRequest`](/documentation/FoundationModels/LanguageModelExecutorGenerationRequest)

A type that contains the details for a generation request.

##### Custom session properties

[`struct SessionProperty`](/documentation/FoundationModels/LanguageModelSession/SessionProperty)

A property wrapper that provides access to properties from within profiles, dynamic
instructions, and tools.

[`protocol SessionPropertyKey`](/documentation/FoundationModels/SessionPropertyKey)

A protocol for defining a custom session property key.

[`class SessionPropertyValues`](/documentation/FoundationModels/SessionPropertyValues)

A container for property values.

[`macro SessionPropertyEntry()`](/documentation/FoundationModels/SessionPropertyEntry())

##### Safety

[Improving the safety of generative model output](/documentation/FoundationModels/improving-the-safety-of-generative-model-output)

Create generative experiences that appropriately handle sensitive inputs and respect people.

##### Performance and evaluation

[Evaluating prompts to measure performance and improve model responses](/documentation/FoundationModels/evaluating-prompts-to-measure-performance-and-improve-model-responses)

Systematically measure and improve the quality of your prompts by using structured evaluation.

  <doc://com.apple.documentation/documentation/Evaluations/evaluating-language-model-responses>

[Analyzing the runtime performance of your Foundation Models app](/documentation/FoundationModels/analyzing-the-runtime-performance-of-your-foundation-models-app)

Measure how prompts, responses, and tool calls affect token consumption and
response times in Instruments.

##### Protocols

[`protocol DataAttachmentRepresentable`](/documentation/FoundationModels/DataAttachmentRepresentable)

A type that you use as the content of a data attachment.

[`protocol DataEntryRepresentable`](/documentation/FoundationModels/DataEntryRepresentable)

A type that a model can produce and represent as a top-level transcript entry.

### Generating content and performing tasks with Foundation Models  
<https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models.md>


Enhance the experience in your app by prompting an on-device large language model.

#### Discussion

The Foundation Models framework lets you tap into the on-device large models at
the core of Apple Intelligence. You can enhance your app by using generative
models to create content or perform tasks. The framework supports language
understanding and generation based on model capabilities.

For design guidance, see Human Interface Guidelines > Technologies > [Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai).

#### Understand model capabilities

When considering features for your app, it helps to know what the on-device
language model can do. The on-device model supports text generation and
understanding that you can use to:

|Capability              |Prompt example                                                |
|------------------------|--------------------------------------------------------------|
|Summarize               |“Summarize this article.”                                     |
|Extract entities        |“List the people and places mentioned in this text.”          |
|Understand text         |“What happens to the dog in this story?”                      |
|Refine or edit text     |“Change this story to be in second person.”                   |
|Classify or judge text  |“Is this text relevant to the topic ‘Swift’?”                 |
|Compose creative writing|“Generate a short bedtime story about a fox.”                 |
|Generate tags from text |“Provide two tags that describe the main topics of this text.”|
|Generate game dialog    |“Respond in the voice of a friendly inn keeper.”              |

The on-device language model may not be suitable for handling all requests, like:

|Capabilities to avoid    |Prompt example                                                |
|-------------------------|--------------------------------------------------------------|
|Do basic math            |“How many b’s are there in bagel?”                            |
|Create code              |“Generate a Swift navigation list.”                           |
|Perform logical reasoning|“If I’m at Apple Park facing Canada, what direction is Texas?”|

The model can complete complex generative tasks when you use guided generation or
tool calling. For more on handling complex tasks, or tasks that require extensive
world-knowledge, see [Generating Swift data structures with guided generation](/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation)
and [Expanding generation with tool calling](/documentation/FoundationModels/expanding-generation-with-tool-calling).

#### Check for availability

Before you use the on-device model in your app, check that the model is available
by creating an instance of [`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel) with the [`default`](/documentation/FoundationModels/SystemLanguageModel/default)
property.

Model availability depends on whether the device and region supports Apple
Intelligence. For a list of supported devices, see
[Apple Intelligence](https://www.apple.com/apple-intelligence/).

> Note: It can take some time for the model to download and become available when
> a person turns on Apple Intelligence.

Always verify model availability first, and plan for a fallback experience in
case the model is unavailable.

```swift
struct GenerativeView: View {
    // Create a reference to the system language model.
    private var model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            // Show your intelligence UI.
        case .unavailable(.deviceNotEligible):
            // Show an alternative UI.
        case .unavailable(.modelNotReady):
            // The model isn't ready because it's downloading or because of other system reasons.
        case .unavailable(let other):
            // The model is unavailable for an unknown reason.
        }
    }
}
```

#### Create a session

After confirming that the model is available, create a [`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession)
object to call the model. For a single-turn interaction, create a new session
each time you call the model:

```swift
// Create a session with the system model.
let session = LanguageModelSession()
```

For a multiturn interaction — where the model retains some knowledge of what
it produced — reuse the same session each time you call the model.

#### Provide a prompt to the model

A [`Prompt`](/documentation/FoundationModels/Prompt) is an input that the model responds to. Prompt engineering is the art
of designing high-quality prompts so that the model generates a best possible
response for the request you make. A prompt can be as short as “hello”, or as
long as multiple paragraphs. The process of designing a prompt involves a lot of
exploration to discover the best prompt, and involves optimizing prompt length
and writing style.

When thinking about the prompt you want to use in your app, consider using
conversational language in the form of a question or command. For example,
“What’s a good month to visit Paris?” or “Generate a food truck menu.”

Write prompts that focus on a single and specific task, like “Write a profile
for the dog breed Siberian Husky”. When a prompt is long and complicated, the
model takes longer to respond, and may respond in unpredictable ways. If you
have a complex generation task in mind, break the task down into a series of
specific prompts.

You can refine your prompt by telling the model exactly how much content it
should generate. A prompt like, “Write a profile for the dog breed Siberian
Husky” often takes a long time to process as the model generates a full
multi-paragraph essay. If you specify “using three sentences”, it speeds up
processing and generates a concise summary. Use phrases like “in a single
sentence” or “in a few words” to shorten the generation time and produce shorter
text.

```swift
// Generate a longer response for a specific command.
let simple = "Write me a story about pears."

// Quickly generate a concise response.
let quick = "Write the profile for the dog breed Siberian Husky using three sentences."
```

#### Provide instructions to the model

[`Instructions`](/documentation/FoundationModels/Instructions) help steer the model in a way that fits the use case of your app.
The model obeys prompts at a lower priority than the instructions you provide.
When you provide instructions to the model, consider specifying details like:

- What the model’s role is; for example, “You are a mentor,” or “You are a movie
  critic”.
- What the model should do, like “Help the person extract calendar events,” or
  “Help the person by recommending search suggestions”.
- What the style preferences are, like “Respond as briefly as possible”.
- What the possible safety measures are, like “Respond
  with ‘I can’t help with that’ if you’re asked to do something dangerous”.

Use content you trust in instructions because the model follows them more
closely than the prompt itself. When you initialize a session with instructions,
it affects all prompts the model responds to in that session. Instructions can
also include example responses to help steer the model. When you add examples to
your prompt, you provide the model with a template that shows the model what a
good response looks like.

#### Generate a response

To call the model with a prompt, call [`respond(to:options:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:options:)-b2re)
on your session. The response call is asynchronous because it may take a few
seconds for the on-device foundation model to generate the response.

```swift
let instructions = """
    Suggest five related topics. Keep them concise (three to seven words) and make sure they \
    build naturally from the person's topic.
    """

let session = LanguageModelSession(instructions: instructions)

let prompt = "Making homemade bread"
let response = try await session.respond(to: prompt)
```

> Note: A session can only handle a single request at a time, and causes a runtime
> error if you call it again before the previous request finishes. Check ``doc://com.apple.foundationmodels/documentation/FoundationModels/LanguageModelSession/isResponding``
> to verify the session is done processing the previous request before sending a new one.

Instead of working with raw string output from the model, the framework offers
guided generation to generate a custom Swift data structure you define. For more
information about guided generation, see
[Generating Swift data structures with guided generation](/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation).

When you make a request to the model, you can provide custom tools to help the
model complete the request. If the model determines that a [`Tool`](/documentation/FoundationModels/Tool) can assist with
the request, the framework calls your [`Tool`](/documentation/FoundationModels/Tool) to perform additional actions like
retrieving content from your local database. For more information about tool
calling, see [Expanding generation with tool calling](/documentation/FoundationModels/expanding-generation-with-tool-calling)

#### Consider context size limits per session

The *context window size* is a limit on how much data the model can process for a
session instance. A token is a chunk of text the model processes, and the system
model supports up to 4,096 tokens. A single token corresponds to three or four
characters in languages like English, Spanish, or German, and one token per character
in languages like Japanese, Chinese, or Korean. In a single session, the
sum of all tokens in the instructions, all prompts, and all outputs count toward
the context window size.

If your session processes a large amount of tokens that exceed the context
window, the framework throws the error [`LanguageModelError.contextSizeExceeded(_:)`](/documentation/FoundationModels/LanguageModelError/contextSizeExceeded(_:)).
When you encounter the error, remove entries from the transcript and try again.
If you need to process a large amount of data that won’t fit in a single context
window limit, break your data into smaller chunks, process each chunk in a
separate session, and then combine the results.

For more information on managing the context window size, see
[Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Tune generation options and optimize performance

To get the best results for your prompt, experiment with different generation
options. [`GenerationOptions`](/documentation/FoundationModels/GenerationOptions) affects the runtime parameters of the
model, and you can customize them for every request you make.

```swift
// Customize the temperature to increase creativity.
let options = GenerationOptions(temperature: 1.0)

let session = LanguageModelSession()

let prompt = "Write me a story about coffee."
let response = try await session.respond(
    to: prompt,
    options: options
)
```

When you test apps that use the framework, use Xcode Instruments to understand
more about the requests you make, like the time it takes to perform a request. When
you make a request, you can access the [`Transcript`](/documentation/FoundationModels/Transcript) entries that describe the actions
the model takes during your [`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession).

### Improving the safety of generative model output  
<https://developer.apple.com/documentation/foundationmodels/improving-the-safety-of-generative-model-output.md>


Create generative experiences that appropriately handle sensitive inputs and respect people.

#### Discussion

Generative AI models have powerful creativity, but with this creativity comes the
risk of unintended or unexpected results. For any generative AI feature, safety
needs to be an essential part of your design.

The Foundation Models framework has two base layers of safety, where the framework
uses:

- Apple Foundation Models, running on-device and on Private Cloud Compute, trained
  to handle sensitive topics with care.
- Guardrails that aim to block harmful or sensitive content, such as self-harm,
  violence, and adult materials.

Because safety risks are often contextual, some harms might bypass both built-in
framework safety layers. It’s vital to consider whether to design additional
safety layers specific to your app. When developing your feature, decide what’s
acceptable or might be harmful in your generative AI feature, based on your app’s
use case, cultural context, and audience.

For more information on designing generative AI experiences responsibly, see
Human Interface Guidelines > Foundations > [Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai).

#### Review guardrails for a model

Guardrails are a safety system tied to a specific model. For example, all
on-device Apple Foundation Models you use through [`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel) have
guardrails that check the input prompt and the model’s output. Use
[`SystemLanguageModel.Guardrails`](/documentation/FoundationModels/SystemLanguageModel/Guardrails) to configure the guardrail level most
appropriate for your use case. The Apple Foundation Models on
Private Cloud Compute (PCC) also have guardrails, but they have different policies
that you can’t directly configure.

For any foundation model you use, consider the following questions early when
designing your feature:

- Does the model have a guardrail system? If so, are they configurable?
- When does the model throw errors like [`LanguageModelError.guardrailViolation(_:)`](/documentation/FoundationModels/LanguageModelError/guardrailViolation(_:))
  or [`LanguageModelError.refusal(_:)`](/documentation/FoundationModels/LanguageModelError/refusal(_:))?
- When might this model respond with a refusal message such as *“Sorry I cannot help…”*?

Additionally, consider the following questions for your use case and audience:

- Where might the model or its guardrails be too permissive? This is where you
  need to design additional layers of protection specific to your app.
- Where might the model or its guardrails be too restrictive? This is where you
  need to work with the model’s guardrail configurations, if any exist, or design
  your feature to better fit within the model’s policy to provide a better user
  experience.

#### Handle guardrail errors

When you send a prompt to the model, the input prompt and the model output are
both checked by a guardrail. If either fails the safety check, the model session
throws a [`LanguageModelError.guardrailViolation(_:)`](/documentation/FoundationModels/LanguageModelError/guardrailViolation(_:)) error:

```swift
do {
    let session = LanguageModelSession()
    let topic = "" // A potentially sensitive topic.
    let prompt = "Write a respectful and funny story about \(topic)."
    let response = try await session.respond(to: prompt)
} catch LanguageModelError.guardrailViolation(let violation) {
    // Handle the safety error.
}
```

If you encounter a guardrail violation error for any built-in prompt in your app,
experiment with re-phrasing the prompt to determine which phrases are activating
the guardrails, and avoid those phrases. If the error is thrown in response to
a prompt created by someone using your app, give people a clear message that
explains the issue. For example, you might say “Sorry, this feature isn’t designed
to handle that kind of input” and offer people the opportunity to try a different
prompt.

#### Handle model refusals

A model can freely refuse to respond to an input. For example, the on-device
[`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel) isn’t suitable for all topics, and it may refuse to discuss
sensitive subjects. When you generate a string response and the model refuses a
request, it generates a message that might begin with a refusal like *“Sorry, I
can’t help with that…”*.

Design your app experience with refusal messages in mind and present the message
to the person using your app. You might not be able to programmatically determine
whether a string response is a normal response or a refusal, so design the
experience to anticipate both. If it’s critical to determine whether the response is a
refusal message, initialize a new [`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession) and prompt the model
to classify whether the string is a refusal.

When you use guided generation to generate Swift structures or types, there’s no
placeholder for a refusal message. Instead, the model throws a [`LanguageModelError.refusal(_:)`](/documentation/FoundationModels/LanguageModelError/refusal(_:))
error. When you catch the error, ask the model to generate a string refusal message:

```swift
do {
    let session = LanguageModelSession()
    let topic = ""  // A sensitive topic.
    let response = try await session.respond(
        to: "List five key points about: \(topic)",
        generating: [String].self
    )
} catch LanguageModelError.refusal(let refusal) {
    do {
        // Attempt to retrieve an explanation for the refusal.
        let explanation = try await refusal.explanation.content
    } catch {
        // The explanation request may fail, so fall back to the debug text.
        let explanation = refusal.debugDescription
    }
}
```

Display the explanation in your app to tell people why a request failed, and
offer people the opportunity to try a different prompt. Retrieving an explanation
message is asynchronous and takes time for the model to generate.

If you encounter a refusal message, or refusal error, for any built-in prompts in
your app, experiment with re-phrasing your prompt to avoid any sensitive topics
that might cause the refusal.

For more information about guided generation, see
[Generating Swift data structures with guided generation](/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation).

#### Consider multimodal safety

Multimodal models accept more than one type of input. For example, Apple Foundation
Models can take both images and text in their input, and Apple’s guardrails
cover both input types. When handling multimodal input, consider:

- Each media input individually.
- The full multimedia input considered together.

For example, an inappropriate image may be in the same prompt as a benign text
question, or a sensitive text question might be in the same prompt as a seemingly
harmless image. There are also cases where both the text and image may be harmless
on their own, but become inappropriate or offensive when taken together.

If your feature uses a person’s personal photos in a prompt, it’s your
responsibility to be transparent about any privacy risks. While Apple Foundation
Models on-device and on PCC are designed to protect a person’s privacy, sending
a photo to some model providers may mean inadvertently giving that photo to the
model provider to use in their training data or other uses. Get to know the
privacy features of any model you use and clearly communicate how your app uses
a photo when you request access to a person’s Photos library. For more, see
Human Interface Guidelines > Foundations >
[Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy).

#### Build boundaries on input and output

Safety risks increase when a prompt includes direct input from a person using
your app, or from an unverified external source, like a webpage. An untrusted
source makes it difficult to anticipate what the input contains. Whether
accidentally or on purpose, someone could input sensitive content that causes
the model to respond poorly.

> Tip: The more you can define the intended usage and outcomes for your feature,
> the more you can ensure generation works great for your app’s specific use cases.
> Add boundaries to limit out-of-scope usage and minimize low generation quality
> from out-of-scope uses.

Whenever possible, avoid open input in prompts and place boundaries for controlling
what the input can be. This approach helps when you want generative content to
stay within the bounds of a particular topic or task. For the highest level of
safety on input, give people a fixed set of prompts to choose from. This gives
you the highest certainty that sensitive content won’t make its way into your app:

```swift
enum TopicOptions {
    case family
    case nature
    case work 
}
let topicChoice = TopicOptions.nature
let prompt = """
    Generate a wholesome and empathetic journal prompt that helps \
    this person reflect on \(topicChoice)
    """
```

If your app allows people to freely input a prompt, placing boundaries on
the output can also offer stronger safety guarantees. Using guided generation,
create an enumeration to restrict the model’s output to a set of predefined
options designed to be safe no matter what:

```swift
@Generable
enum Breakfast {
    case waffles
    case pancakes
    case bagels
    case eggs 
}
let session = LanguageModelSession()
let userInput = "I want something sweet."
let prompt = "Pick the ideal breakfast for request: \(userInput)"
let response = try await session.respond(to: prompt, generating: Breakfast.self)
```

#### Instruct the model for added safety

Consider adding detailed session [`Instructions`](/documentation/FoundationModels/Instructions) that tell the model how to handle
sensitive content. The language model prioritizes following its instructions
over any prompt, so instructions are an effective tool for improving safety and
overall generation quality. Use uppercase words to emphasize the importance of
certain phrases for the model:

```swift
do {
    let instructions = """
        Always respond in a respectful way. \
        If someone asks you to generate content that might be sensitive, \
        you must decline with 'Sorry, I can't do that.'
        """
    let session = LanguageModelSession(instructions: instructions)
    let prompt = "" // Open input from a person using the app.
    let response = try await session.respond(to: prompt)
} catch LanguageModelError.guardrailViolation(let violation) {
    // Handle the safety error.
}
```

> Note: A session obeys instructions over a prompt, so don’t include input from
> people or any unverified input in the instructions. Using unverified input in
> instructions makes your app vulnerable to prompt injection attacks, so write
> instructions with content you trust.

If you want to include open-input from people, instructions for safety are recommended.
For an additional layer of safety, use a format string in normal prompts that
wraps people’s input in your own content that specifies how the model should respond:

```swift
let userInput = "" // The input a person enters in the app.
let prompt = """
    Generate a wholesome and empathetic journal prompt that helps \
    this person reflect on their day. They said: \(userInput)
    """
```

Adding [`Instructions`](/documentation/FoundationModels/Instructions) is a way to help reduce over-blocking by helping a
model understand what content is appropriate in your context. The very beginning
of an [`Instructions`](/documentation/FoundationModels/Instructions) string is an effective place to give the model a clear
role with permission to work in a domain, such as *“You are an AI assistant for
a personal finance app who can assist with…”* or *“You are an AI tutor who can
help secondary school students understand biology”*. By telling the model more
about your app’s goal and audience, you help the model more accurately assess
the safety of a request.

#### Add a deny list of blocked terms

If you allow prompt input from people or outside sources, consider adding your
own deny list of terms. A deny list is anything you don’t want people to be
able to input to your app, including unsafe terms, names of people or products,
or anything that’s not relevant to the feature you provide. Implement a deny
list similarly to guardrails by creating a function that checks the input and
the model output:

```swift
let session = LanguageModelSession()
let userInput = "" // The input a person enters in the app.
let prompt = "Generate a wholesome story about: \(userInput)"

// A function you create that evaluates whether the input 
// contains anything in your deny list.
if verifyText(prompt) { 
    let response = try await session.respond(to: prompt)
    
    // Compare the output to evaluate whether it contains anything in your deny list.
    if verifyText(response.content) { 
        return response 
    } else {
        // Handle the unsafe output.
    }
} else {
    // Handle the unsafe input.
}
```

A deny list can be a simple list of strings in your code that you distribute with
your app. Alternatively, you can host a deny list on a server so your app can
download the latest deny list when it’s connected to the network. Hosting your
deny list allows you to update your list when you need to and avoids requiring
a full app update if a safety issue arise.

#### Use permissive guardrail mode for sensitive content

The default [`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel) guardrails may throw a
[`LanguageModelError.guardrailViolation(_:)`](/documentation/FoundationModels/LanguageModelError/guardrailViolation(_:)) error for
sensitive source material. For example, it may be appropriate for your app to
work with certain inputs from people and unverified sources that might contain
sensitive content:

- When you want the model to tag the topic of conversations in a chat app when
  some messages contain profanity.
- When you want to use the model to explain notes in your study app that discuss
  sensitive topics.

To allow the model to reason about sensitive source material,
use [`permissiveContentTransformations`](/documentation/FoundationModels/SystemLanguageModel/Guardrails/permissiveContentTransformations) when you
initialize [`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel):

```swift
let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
```

This mode only works for generating a string value. When you use guided generation,
the framework runs the default guardrails against model input and output as
usual, and generates [`LanguageModelError.guardrailViolation(_:)`](/documentation/FoundationModels/LanguageModelError/guardrailViolation(_:))
and [`LanguageModelError.refusal(_:)`](/documentation/FoundationModels/LanguageModelError/refusal(_:))errors as usual.

Before you use permissive content mode, consider what’s appropriate for your
audience. The session skips the guardrail checks in this mode, so it never throws
a [`LanguageModelError.guardrailViolation(_:)`](/documentation/FoundationModels/LanguageModelError/guardrailViolation(_:)) error when
generating string responses.

However, even with the [`SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel) guardrails off, the on-device
system language model still has a layer of safety. For some content, the model
may still produce a refusal message that’s similar to, “Sorry, I can’t help with
that.”

#### Create a risk assessment

Conduct a risk assessment to proactively address what might go wrong. Risk
assessment is an exercise that helps you brainstorm potential safety risks in
your app and map each risk to an actionable mitigation. You can write a risk
assessment in any format that includes these essential elements:

- List each AI feature in your app.
- For each feature, list possible safety risks that could occur, even if they seem unlikely.
- For each safety risk, score how serious the harm would be if that thing occurred, from mild to critical.
- For each safety risk, assign a strategy for how you’ll mitigate the risk in your app.

For example, an app might include one feature with the fixed-choice input pattern
for generation and one feature with the open-input pattern for generation, which
is higher safety risk:

|Feature                                                                        |Harm                                                       |Severity|Mitigation                                                                                       |
|-------------------------------------------------------------------------------|-----------------------------------------------------------|--------|-------------------------------------------------------------------------------------------------|
|Player can input any text to chat with nonplayer characters in the coffee shop.|A character might respond in an insensitive or harmful way.|Critical|Instructions and prompting to steer characters responses to be safe; safety testing.             |
|Image generation of an imaginary dream customer, like a fairy or a frog.       |Generated image could look weird or scary.                 |Mild    |Include in the prompt examples of images to generate that are cute and not scary; safety testing.|
|Player can make a coffee from a fixed menu of options.                         |None identified.                                           |        |                                                                                                 |
|Generate a review of the coffee the player made, based on the customer’s order.|Review could be insulting.                                 |Moderate|Instructions and prompting to encourage posting a polite review; safety testing.                 |

Besides obvious harms, like a poor-quality model output, think about
how your generative AI feature might affect people, including real-world scenarios
where someone might act based on information generated by your app.

#### Write and maintain safety tests

Although most people will interact with your app in respectful ways, it’s
important to anticipate possible failure modes where certain input or contexts
could cause the model to generate something harmful. Especially if your app takes
input from people, test your experience’s safety on input like:

- Input that is nonsensical, snippets of code, or random characters.
- Input that includes sensitive content.
- Input that includes controversial topics.
- Vague or unclear input that’s easy to misinterpret.

Create a list of potentially harmful prompt inputs that you can run as part of
your app’s tests. Include every prompt in your app, even safe ones, as part of
your app testing. For each prompt test, log the timestamp, full input prompt,
the model’s response, and whether it activates any built-in safety or mitigations
you’ve included in your app. When starting out, manually read the model’s response
on all tests to ensure it meets your design and safety goals. To scale your tests,
consider using a frontier LLM to auto-grade the safety of each prompt. Building a
test pipeline for prompts and safety is a worthwhile investment for tracking
changes in how your app responds over time.

> Tip: Evaluations are tests for generative model features. Use the
> <doc://com.apple.documentation/documentation/Evaluations> framework to create
> them for your app.

Someone might purposefully attempt to break your feature or produce bad
output — especially someone who won’t be harmed by their actions. But, keep
in mind that it’s very important to identify cases where someone might
*accidentally* be harmed during normal app use.

> Tip: Prioritize protecting people using your app with good intentions. Accidental
> safety failures often only occur in specific contexts, which make them hard to
> identify during testing. Test for a longer series of interactions, and test for
> inputs that could become sensitive only when combined with other aspects of your app.

Don’t engage in any testing that could cause you or others harm. Apple’s built-in
responsible AI and safety measures, like safety guardrails, are built by experts
with extensive training and support. These built-in measures aim to block egregious
harms, allowing you to focus on the borderline harmful cases that need your judgement.
Before conducting any safety testing, ensure that you’re in a safe location and
that you have the health and well-being support you need.

#### Report safety concerns

It’s important to include a way that people can report potentially harmful content.
Continuously monitor the feedback you receive, and be responsive when handling
any safety issues that arise. If someone reports a safety concern that you believe
isn’t handled by Apple’s built-in guardrails, report it to Apple using
[Feedback Assistant](https://support.apple.com/guide/feedback-assistant/get-started-fbab81460adb/mac).

When you provide a report, include:

- The model your app is calling.
- The prompt and any guided generation types in the request.
- The name and argument types of any tools in the request.
- The language and region.

Use [`logFeedbackAttachment(sentiment:issues:desiredOutput:)`](/documentation/FoundationModels/LanguageModelSession/logFeedbackAttachment(sentiment:issues:desiredOutput:))
to produce a `Data` object containing the session’s transcript and any feedback
information you specify. Save the JSON-encoded feedback to a file and include it
in the report you send with Feedback Assistant.

#### Monitor safety for model or guardrail updates

Apple releases updates to the on-device model as part of regular OS updates. If
you participate in the developer beta program you can test your app with new model
versions ahead of people using your app.

When any model you use updates, it’s important to re-run all of your prompt tests
in addition to your adversarial safety tests because the model’s response may
change. Your risk assessment helps you track any change to safety risks in
your app. Use the <doc://com.apple.documentation/documentation/Evaluations>
framework to regularly test your prompts and help you track your test results
over time.

### LanguageModelSession  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/languagemodelsession.md>


An object that represents a session that interacts with a language model.

```
final class LanguageModelSession
```

#### Overview

A session is a single context that you use to generate content with, and maintains state between
requests. You can reuse the existing instance or create a new one each time you call the model. When
you create a session you can provide instructions that tell the model what its role is and
provide guidance on how to respond.

```swift
let session = LanguageModelSession(instructions: """
    You are a motivational workout coach that provides quotes to inspire \
    and motivate athletes.
    """
)
let prompt = "Generate a motivational quote for my next workout."
let response = try await session.respond(to: prompt)
```

The framework records each call to the model in a [`Transcript`](/documentation/FoundationModels/Transcript) that includes all prompts and
responses. If your session exceeds the available context size, it throws
[`LanguageModelError.contextSizeExceeded(_:)`](/documentation/FoundationModels/LanguageModelError/contextSizeExceeded(_:)). For more information on managing
the context window size, see [Managing the context window](/documentation/FoundationModels/managing-the-context-window).

Use Instruments to analyze token consumption while your app is running and to look for
opportunities to improve performance, like with [`prewarm(promptPrefix:)`](/documentation/FoundationModels/LanguageModelSession/prewarm(promptPrefix:)). For more
information on Instruments, see
[Analyzing the runtime performance of your Foundation Models app](/documentation/FoundationModels/analyzing-the-runtime-performance-of-your-foundation-models-app).

#### Topics

##### Creating a session

[`convenience(model:tools:instructions:)`](/documentation/FoundationModels/LanguageModelSession/init(model:tools:instructions:))

Creates a session in a blank slate state with an instructions builder.

[`convenience(model:tools:transcript:)`](/documentation/FoundationModels/LanguageModelSession/init(model:tools:transcript:))

Creates a session by rehydrating from a transcript.

##### Creating a session with a dynamic profile

[`convenience init(profile: sending some LanguageModelSession.DynamicProfile, history: some Collection<Transcript.Entry>)`](/documentation/FoundationModels/LanguageModelSession/init(profile:history:))

Creates a session with a profile.

[`convenience init(model: some LanguageModel, dynamicInstructions: sending some DynamicInstructions, history: some Collection<Transcript.Entry>)`](/documentation/FoundationModels/LanguageModelSession/init(model:dynamicInstructions:history:))

Creates a session with dynamic instructions.

[`protocol DynamicProfile`](/documentation/FoundationModels/LanguageModelSession/DynamicProfile)

A dynamic profile that contains one or more profiles.

[`protocol DynamicProfileModifier`](/documentation/FoundationModels/LanguageModelSession/DynamicProfileModifier)

A protocol for creating reusable wrappers around dynamic profile content.

[`struct ConditionalDynamicProfile`](/documentation/FoundationModels/LanguageModelSession/ConditionalDynamicProfile)

A dynamic profile that resolves to one of two profiles, depending on a condition.

[`struct DynamicProfileBuilder`](/documentation/FoundationModels/LanguageModelSession/DynamicProfileBuilder)

A type that represents a dynamic profile builder.

[`struct DynamicProfileModifierContent`](/documentation/FoundationModels/LanguageModelSession/DynamicProfileModifierContent)

A type that represents the dynamic profile a modifier applies to.

[`struct ModifiedDynamicProfile`](/documentation/FoundationModels/LanguageModelSession/ModifiedDynamicProfile)

A dynamic profile with a modifier applied to it.

[`struct AnyDynamicProfile`](/documentation/FoundationModels/LanguageModelSession/AnyDynamicProfile)

A type-erased dynamic profile.

[`struct Profile`](/documentation/FoundationModels/LanguageModelSession/Profile)

A profile that contains dynamic instructions.

##### Preloading the model

[`func prewarm(promptPrefix: Prompt?)`](/documentation/FoundationModels/LanguageModelSession/prewarm(promptPrefix:))

Loads the resources required for this session into memory ahead of a request.

##### Accessing session properties

[`var properties: SessionPropertyValues`](/documentation/FoundationModels/LanguageModelSession/properties)

The values of the session’s managed properties.

##### Inspecting the accumulated usage

[`var usage: LanguageModelSession.Usage`](/documentation/FoundationModels/LanguageModelSession/usage-swift.property)

The total accumulated usage across all responses generated by this session.

[`struct Usage`](/documentation/FoundationModels/LanguageModelSession/Usage-swift.struct)

Information about how many tokens were used by a response.

##### Configuring the transcript error handling policy

[`var transcriptErrorHandlingPolicy: TranscriptErrorHandlingPolicy?`](/documentation/FoundationModels/LanguageModelSession/transcriptErrorHandlingPolicy)

The session’s policy for managing the transcript when errors occur.

[`struct TranscriptErrorHandlingPolicy`](/documentation/FoundationModels/TranscriptErrorHandlingPolicy)

Options for controlling how a language model session manages the transcript when errors occur.

##### Generating a response

[`var isResponding: Bool`](/documentation/FoundationModels/LanguageModelSession/isResponding)

A Boolean value that indicates whether a response is being generated.

[`func respond(options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<String>`](/documentation/FoundationModels/LanguageModelSession/respond(options:prompt:))

Produces a response to a prompt.

[`func respond<Content>(generating: Content.Type, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<Content>`](/documentation/FoundationModels/LanguageModelSession/respond(generating:includeSchemaInPrompt:options:prompt:))

Produces a generable object as a response to a prompt.

[`func respond(schema: GenerationSchema, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<GeneratedContent>`](/documentation/FoundationModels/LanguageModelSession/respond(schema:includeSchemaInPrompt:options:prompt:))

Produces a generated content type as a response to a prompt and schema.

[`func respond(to:options:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:options:))

Produces a response to a prompt.

[`func respond(to:generating:includeSchemaInPrompt:options:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:generating:includeSchemaInPrompt:options:))

Produces a generable object as a response to a prompt.

[`func respond(to:schema:includeSchemaInPrompt:options:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:schema:includeSchemaInPrompt:options:))

Produces a generated content type as a response to a prompt and schema.

[`struct Response`](/documentation/FoundationModels/LanguageModelSession/Response)

A structure that stores the output of a response call.

##### Generating a response with metadata

[`func respond(options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<String>`](/documentation/FoundationModels/LanguageModelSession/respond(options:contextOptions:metadata:prompt:))

Produces a response to a prompt.

[`func respond<Content>(generating: Content.Type, options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<Content>`](/documentation/FoundationModels/LanguageModelSession/respond(generating:options:contextOptions:metadata:prompt:))

Produces a generable object as a response to a prompt.

[`func respond(schema: GenerationSchema, options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<GeneratedContent>`](/documentation/FoundationModels/LanguageModelSession/respond(schema:options:contextOptions:metadata:prompt:))

Produces a generated content type as a response to a prompt and schema.

[`func respond(to:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:options:contextOptions:metadata:))

Produces a response to a prompt.

[`func respond(to:generating:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:generating:options:contextOptions:metadata:))

Produces a generable object as a response to a prompt.

[`func respond(to:schema:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/respond(to:schema:options:contextOptions:metadata:))

Produces a generated content type as a response to a prompt and schema.

##### Streaming a response

[`func streamResponse(options: GenerationOptions, prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<String>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(options:prompt:))

Produces a response stream to a prompt.

[`func streamResponse<Content>(generating: Content.Type, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<Content>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(generating:includeSchemaInPrompt:options:prompt:))

Produces a response stream to a prompt.

[`func streamResponse(schema: GenerationSchema, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<GeneratedContent>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(schema:includeSchemaInPrompt:options:prompt:))

Produces a response stream to a prompt and schema.

[`func streamResponse(to:options:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:options:))

Produces a response stream to a prompt.

[`func streamResponse(to:generating:includeSchemaInPrompt:options:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:generating:includeSchemaInPrompt:options:))

Produces a response stream to a prompt.

[`func streamResponse(to:schema:includeSchemaInPrompt:options:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:schema:includeSchemaInPrompt:options:))

Produces a response stream to a prompt and schema.

[`struct ResponseStream`](/documentation/FoundationModels/LanguageModelSession/ResponseStream)

An async sequence of snapshots of partially generated content.

##### Streaming a response with metadata

[`func streamResponse(options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<String>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(options:contextOptions:metadata:prompt:))

Produces a response stream to a prompt.

[`func streamResponse<Content>(generating: Content.Type, options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<Content>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(generating:options:contextOptions:metadata:prompt:))

Produces a response stream to a prompt.

[`func streamResponse(schema: GenerationSchema, options: GenerationOptions, contextOptions: ContextOptions, metadata: [String : any ConvertibleToGeneratedContent], prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<GeneratedContent>`](/documentation/FoundationModels/LanguageModelSession/streamResponse(schema:options:contextOptions:metadata:prompt:))

Produces a response stream to a prompt and schema.

[`func streamResponse(to:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:options:contextOptions:metadata:))

Produces a response stream to a prompt.

[`func streamResponse(to:generating:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:generating:options:contextOptions:metadata:))

Produces a response stream to a prompt.

[`func streamResponse(to:schema:options:contextOptions:metadata:)`](/documentation/FoundationModels/LanguageModelSession/streamResponse(to:schema:options:contextOptions:metadata:))

Produces a response stream to a prompt and schema.

##### Accessing the transcript

[`var transcript: Transcript`](/documentation/FoundationModels/LanguageModelSession/transcript)

A full history of interactions, including user inputs and model responses.

##### Generating feedback

[`func logFeedbackAttachment(sentiment: LanguageModelFeedback.Sentiment?, issues: [LanguageModelFeedback.Issue], desiredOutput: Transcript.Entry?) -> Data`](/documentation/FoundationModels/LanguageModelSession/logFeedbackAttachment(sentiment:issues:desiredOutput:))

Logs and serializes a feedback attachment that can be submitted to Apple.

[`func logFeedbackAttachment(sentiment: LanguageModelFeedback.Sentiment?, issues: [LanguageModelFeedback.Issue], desiredResponseContent: (any ConvertibleToGeneratedContent)?) -> Data`](/documentation/FoundationModels/LanguageModelSession/logFeedbackAttachment(sentiment:issues:desiredResponseContent:))

Logs and serializes a feedback attachment that includes the content you expected.

[`func logFeedbackAttachment(sentiment: LanguageModelFeedback.Sentiment?, issues: [LanguageModelFeedback.Issue], desiredResponseText: String?) -> Data`](/documentation/FoundationModels/LanguageModelSession/logFeedbackAttachment(sentiment:issues:desiredResponseText:))

Logs and serializes a feedback attachment that includes the response text you expected.

[`struct LanguageModelFeedback`](/documentation/FoundationModels/LanguageModelFeedback)

Feedback appropriate for logging or attaching to Feedback Assistant.

##### Session properties

[`struct SessionProperty`](/documentation/FoundationModels/LanguageModelSession/SessionProperty)

A property wrapper that provides access to properties from within profiles, dynamic
instructions, and tools.

##### Errors

[`enum Error`](/documentation/FoundationModels/LanguageModelSession/Error)

A failure caused by incorrect use of a language model session.

[`struct ToolCallError`](/documentation/FoundationModels/LanguageModelSession/ToolCallError)

An error that occurs while a language model is calling a tool.

[`enum GenerationError`](/documentation/FoundationModels/LanguageModelSession/GenerationError)

An error that may occur while generating a response.

#### Relationships

##### Conforms To

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Observable`](/documentation/Observation/Observable)

[`Escapable`](/documentation/Swift/Escapable)

[`Sendable`](/documentation/Swift/Sendable)

[`Copyable`](/documentation/Swift/Copyable)

### SystemLanguageModel  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel.md>


An on-device Apple Foundation Model capable of text generation tasks.

```
final class SystemLanguageModel
```

#### Overview

The `SystemLanguageModel` refers to the on-device text foundation model that powers Apple
Intelligence. Use [`default`](/documentation/FoundationModels/SystemLanguageModel/default) to access the base version of the model and perform general-purpose
text generation tasks. To access a specialized version of the model, initialize the model
with [`SystemLanguageModel.UseCase`](/documentation/FoundationModels/SystemLanguageModel/UseCase) to perform tasks like [`contentTagging`](/documentation/FoundationModels/SystemLanguageModel/UseCase/contentTagging). Apple periodically
updates `SystemLanguageModel` in routine OS updates to improve the on-device model’s abilities
and performance. Currently, there are 3 model versions that align with:

- iOS, iPadOS, macOS, and visionOS **26.0 - 26.3**
- iOS, iPadOS, macOS, visionOS **26.4**
- iOS, iPadOS, macOS, and visionOS **27.0**

For more information about how model versions affect your app, see
[Updating prompts for new model versions](/documentation/FoundationModels/updating-prompts-for-new-model-versions).

Before you use the model, you need to verify its availability. Model availability depends on whether
the device and region supports Apple Intelligence. For a list of supported devices, see
[Apple Intelligence](https://www.apple.com/apple-intelligence/).

Use [`SystemLanguageModel.Availability`](/documentation/FoundationModels/SystemLanguageModel/Availability-swift.enum) to change what your app shows to people based on the availability condition:

```swift
struct GenerativeView: View {
    // Create a reference to the system language model.
    private var model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            // Show your intelligence UI.
        case .unavailable(.deviceNotEligible):
            // Show an alternative UI.
        case .unavailable(.modelNotReady):
            // The model isn't ready because it's downloading or because
            // of other system reasons.
        case .unavailable(let other):
            // The model is unavailable for an unknown reason.
        }
    }
}
```

#### Topics

##### Getting the default model

[`static var `default`: SystemLanguageModel`](/documentation/FoundationModels/SystemLanguageModel/default)

The base version of the model.

##### Creating a model for a use case

[`convenience init(useCase: SystemLanguageModel.UseCase, guardrails: SystemLanguageModel.Guardrails)`](/documentation/FoundationModels/SystemLanguageModel/init(useCase:guardrails:))

Creates a system language model instance for a specific use case.

[`struct UseCase`](/documentation/FoundationModels/SystemLanguageModel/UseCase)

A type that represents the use case for prompting.

[`struct Guardrails`](/documentation/FoundationModels/SystemLanguageModel/Guardrails)

A set of controls that flag sensitive content from model input and output.

##### Accessing the model variant

[`var variant: SystemLanguageModel.Variant`](/documentation/FoundationModels/SystemLanguageModel/variant-swift.property)

The variant of the on-device model backing this instance.

[`struct Variant`](/documentation/FoundationModels/SystemLanguageModel/Variant-swift.struct)

The variant of an on-device model.

##### Checking model availability

[`var isAvailable: Bool`](/documentation/FoundationModels/SystemLanguageModel/isAvailable)

A Boolean value that indicates whether the system is entirely ready.

[`var availability: SystemLanguageModel.Availability`](/documentation/FoundationModels/SystemLanguageModel/availability-swift.property)

The availability of the language model.

[`enum Availability`](/documentation/FoundationModels/SystemLanguageModel/Availability-swift.enum)

The availability status for a specific system language model.

##### Inspecting model capabilities

[`var contextSize: Int`](/documentation/FoundationModels/SystemLanguageModel/contextSize)

The maximum context size in tokens that the model supports.

[`var supportedLanguages: Set<Locale.Language>`](/documentation/FoundationModels/SystemLanguageModel/supportedLanguages)

Languages that the model supports.

[`func supportsLocale(Locale) -> Bool`](/documentation/FoundationModels/SystemLanguageModel/supportsLocale(_:))

Returns a Boolean value that indicates whether the given locale is supported by the model.

##### Counting tokens

[`func tokenCount(for:)`](/documentation/FoundationModels/SystemLanguageModel/tokenCount(for:))

Returns the token count for the specified instructions.

##### Handling a language model error

[`enum Error`](/documentation/FoundationModels/SystemLanguageModel/Error)

An error specific to the on-device system language model.

##### Default Implementations

[LanguageModel Implementations](/documentation/FoundationModels/SystemLanguageModel/LanguageModel-Implementations)

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`LanguageModel`](/documentation/FoundationModels/LanguageModel)

[`Copyable`](/documentation/Swift/Copyable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Observable`](/documentation/Observation/Observable)

[`Escapable`](/documentation/Swift/Escapable)

### SystemLanguageModel.Availability  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel/availability-swift.enum.md>


The availability status for a specific system language model.

```
@frozen enum Availability
```

#### Overview> SeeAlso: ``doc://com.apple.foundationmodels/documentation/FoundationModels/SystemLanguageModel/availability-swift.property``

#### Topics

##### Checking for availability

[`case available`](/documentation/FoundationModels/SystemLanguageModel/Availability-swift.enum/available)

The system is ready to make requests.

[`case unavailable(SystemLanguageModel.Availability.UnavailableReason)`](/documentation/FoundationModels/SystemLanguageModel/Availability-swift.enum/unavailable(_:))

The system isn’t ready for requests.

[`enum UnavailableReason`](/documentation/FoundationModels/SystemLanguageModel/Availability-swift.enum/UnavailableReason)

The reason the system language model is unavailable.

#### Relationships

##### Conforms To

[`Equatable`](/documentation/Swift/Equatable)

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### Generable  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/generable.md>


A type that the model uses when responding to prompts.

```
protocol Generable : ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent
```

#### Overview

Annotate your Swift structure or enumeration with the `@Generable` macro to
allow the model to respond to prompts by generating an instance of your type.
Use the `@Guide` macro to provide natural language descriptions of your
properties, and programmatically control the values that the model can generate.

```swift
@Generable
struct SearchSuggestions {
    @Guide(description: "A list of suggested search terms.", .count(4))
    var searchTerms: [SearchTerm]
    @Generable
    struct SearchTerm {
        // Use a generation identifier for data structures the framework generates.
        var id: GenerationID
        @Guide(description: "A two- or three- word search term, like 'Beautiful sunsets'.")
        var searchTerm: String
    }
}
```

For every [`Generable`](/documentation/FoundationModels/Generable) type in a request, the framework converts its type and
format information to a JSON schema and provides it to the model. This contributes
to the available context window size. If the [`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession) exceeds
the available context size, it throws [`LanguageModelError.contextSizeExceeded(_:)`](/documentation/FoundationModels/LanguageModelError/contextSizeExceeded(_:)).
To reduce the size of your generable type:

- Reduce the complexity of your [`Generable`](/documentation/FoundationModels/Generable) type by evaluating whether properties
  are necessary to complete the task.
- Give your properties short and clear names.
- Use [`Guide(description:)`](/documentation/FoundationModels/Guide(description:)) on properties only when it improves response quality.
- Add a [`Guide(description:_:)`](/documentation/FoundationModels/Guide(description:_:)) with [`maximumCount(_:)`](/documentation/FoundationModels/GenerationGuide/maximumCount(_:)) to
  reduce token usage.

If the [`Generable`](/documentation/FoundationModels/Generable) type includes properties with clear names the model may have
all it needs to generate your type, eliminating the need of [`Guide(description:)`](/documentation/FoundationModels/Guide(description:)).
For more information on managing the context window size, see
[Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Topics

##### Creating a Generable type

[`macro Generable(description: String?)`](/documentation/FoundationModels/Generable(description:))

[`macro Generable(description: String?, representNilExplicitlyInGeneratedContent: Bool)`](/documentation/FoundationModels/Generable(description:representNilExplicitlyInGeneratedContent:))

[`macro Generable(name: String, description: String?, representNilExplicitlyInGeneratedContent: Bool)`](/documentation/FoundationModels/Generable(name:description:representNilExplicitlyInGeneratedContent:))

##### Creating a guide

[`macro Guide(description: String)`](/documentation/FoundationModels/Guide(description:))

[`macro Guide(description:_:)`](/documentation/FoundationModels/Guide(description:_:))

[`struct GenerationGuide`](/documentation/FoundationModels/GenerationGuide)

Guides that control how values are generated.

##### Getting the schema

[`static var generationSchema: GenerationSchema`](/documentation/FoundationModels/Generable/generationSchema)

An instance of the generation schema.

##### Converting to partially generated

[`func asPartiallyGenerated() -> Self.PartiallyGenerated`](/documentation/FoundationModels/Generable/asPartiallyGenerated())

Returns the partially generated representation of the current instance.

[`associatedtype PartiallyGenerated : ConvertibleFromGeneratedContent = Self`](/documentation/FoundationModels/Generable/PartiallyGenerated)

A representation of partially generated content

#### Relationships

##### Conforming Types

[`GeneratedContent`](/documentation/FoundationModels/GeneratedContent)

[`ImageReference`](/documentation/FoundationModels/ImageReference)

##### Inherits From

[`InstructionsRepresentable`](/documentation/FoundationModels/InstructionsRepresentable)

[`ConvertibleToGeneratedContent`](/documentation/FoundationModels/ConvertibleToGeneratedContent)

[`PromptRepresentable`](/documentation/FoundationModels/PromptRepresentable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`ConvertibleFromGeneratedContent`](/documentation/FoundationModels/ConvertibleFromGeneratedContent)

### Guide(description:)  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/guide(description:).md>


```
@attached(peer) macro Guide(description: String)
```

### GenerationGuide  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/generationguide.md>


Guides that control how values are generated.

```
struct GenerationGuide<Value>
```

#### Topics

##### Getting the pattern

[`static func pattern<Output>(Regex<Output>) -> GenerationGuide<String>`](/documentation/FoundationModels/GenerationGuide/pattern(_:))

Enforces that the string follows the pattern.

##### Getting the element

[`static func element<Element>(GenerationGuide<Element>) -> GenerationGuide<[Element]>`](/documentation/FoundationModels/GenerationGuide/element(_:))

Enforces a guide on the elements within the array.

##### Getting the count

[`static count(_:)`](/documentation/FoundationModels/GenerationGuide/count(_:))

Enforces that the array has exactly a certain number of elements.

##### Getting the constant

[`static func constant(String) -> GenerationGuide<String>`](/documentation/FoundationModels/GenerationGuide/constant(_:))

Enforces that the string be precisely the given value.

[`static func anyOf([String]) -> GenerationGuide<String>`](/documentation/FoundationModels/GenerationGuide/anyOf(_:))

Enforces that the string be one of the provided values.

##### Getting a range

[`static range(_:)`](/documentation/FoundationModels/GenerationGuide/range(_:))

Enforces values that fall within a range.

##### Getting the minimum value

[`static minimum(_:)`](/documentation/FoundationModels/GenerationGuide/minimum(_:))

Enforces a minimum value.

[`static func minimumCount<Element>(Int) -> GenerationGuide<[Element]>`](/documentation/FoundationModels/GenerationGuide/minimumCount(_:))

Enforces a minimum number of elements in the array.

##### Getting the maximum value

[`static maximum(_:)`](/documentation/FoundationModels/GenerationGuide/maximum(_:))

Enforces a maximum value.

[`static func maximumCount<Element>(Int) -> GenerationGuide<[Element]>`](/documentation/FoundationModels/GenerationGuide/maximumCount(_:))

Enforces a maximum number of elements in the array.

### Tool  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/tool.md>


A tool that a model can call to gather information at runtime or perform side effects.

```
protocol Tool<Arguments, Output> : Sendable
```

#### Overview

Tool calling gives the model the ability to call your code to incorporate
up-to-date information like recent events and data from your app. A tool
includes a name and a description that the framework puts in the prompt to let
the model decide when and how often to call your tool.

A `Tool` defines a [`call(arguments:)`](/documentation/FoundationModels/Tool/call(arguments:)) method that takes arguments that conforms to
[`ConvertibleFromGeneratedContent`](/documentation/FoundationModels/ConvertibleFromGeneratedContent), and returns an output of any type that conforms to
[`PromptRepresentable`](/documentation/FoundationModels/PromptRepresentable), allowing the model to understand and reason about in subsequent
interactions. Typically, [`Output`](/documentation/FoundationModels/Tool/Output) is a `String` or any [`Generable`](/documentation/FoundationModels/Generable) types.

```swift
struct FindContacts: Tool {
    let name = "findContacts"
    let description = "Finds a specific number of contacts"

    @Generable
    struct Arguments {
        @Guide(description: "The number of contacts to get", .range(1...10))
        let count: Int
    }

    func call(arguments: Arguments) async throws -> [String] {
        var contacts: [CNContact] = []
        // Fetch a number of contacts using the arguments.
        let formattedContacts = contacts.map {
            "\($0.givenName) \($0.familyName)"
        }
        return formattedContacts
    }
}
```

Tools must conform to <doc://com.apple.documentation/documentation/Swift/Sendable>
so the framework can run them concurrently. If the model needs to pass the output
of one tool as the input to another, it executes back-to-back tool calls.

You control the life cycle of your tool, so you can track the state of it between
calls to the model. For example, you might store a list of database records that
you don’t want to reuse between tool calls.

Prompting the model with tools contributes to the available context window size.
When you provide a tool in your generation request, the framework puts the tool
definitions — name, description, parameter information — in the prompt so the
model can decide when and how often to call the tool. After calling your tool,
the framework returns the tool’s output back to the model for further processing.
For more information on managing the context window size, see [Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Topics

##### Calling a tool

[`func call(arguments: Self.Arguments) async throws -> Self.Output`](/documentation/FoundationModels/Tool/call(arguments:))

Performs the tool’s action when a language model wants to use this tool.

[`associatedtype Arguments : ConvertibleFromGeneratedContent`](/documentation/FoundationModels/Tool/Arguments)

The arguments that this tool should accept.

[`associatedtype Output : PromptRepresentable`](/documentation/FoundationModels/Tool/Output)

The output that this tool produces for the language model to reason about in subsequent
interactions.

##### Inspecting a tool

[`var name: String`](/documentation/FoundationModels/Tool/name)

A unique name for the tool.

[`var description: String`](/documentation/FoundationModels/Tool/description)

A natural language description of when and how to use the tool.

[`var parameters: GenerationSchema`](/documentation/FoundationModels/Tool/parameters)

A schema for the parameters this tool accepts.

[`var includesSchemaInInstructions: Bool`](/documentation/FoundationModels/Tool/includesSchemaInInstructions)

A Boolean value that indicates whether the framework includes this tool’s definition
in the session’s instructions.

[`typealias SessionProperty`](/documentation/FoundationModels/Tool/SessionProperty)

A property wrapper that provides access to a session property from within a tool.

#### Relationships

##### Inherits From

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### GenerationOptions  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/generationoptions.md>


Options that control how the model generates its response to a prompt.

```
struct GenerationOptions
```

#### Overview

Generation options determine the decoding strategy the framework uses to adjust
the way the model chooses output tokens. When you interact with the model, it
converts your input to a token sequence, and uses it to generate the response.

Only use [`maximumResponseTokens`](/documentation/FoundationModels/GenerationOptions/maximumResponseTokens) when you need to protect against unexpectedly
verbose responses. Enforcing a strict token response limit can lead to the model
producing malformed results or grammatically incorrect responses.

All input to the model contributes tokens to the context window of the
[`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession) — including the [`Instructions`](/documentation/FoundationModels/Instructions), [`Prompt`](/documentation/FoundationModels/Prompt), [`Tool`](/documentation/FoundationModels/Tool),
and [`Generable`](/documentation/FoundationModels/Generable) types, and the model’s responses. If your session exceeds the
available context size, it throws
[`LanguageModelError.contextSizeExceeded(_:)`](/documentation/FoundationModels/LanguageModelError/contextSizeExceeded(_:)). For more
information on managing the context window size, see
[Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Topics

##### Creating options

[`init(samplingMode: GenerationOptions.SamplingMode?, temperature: Double?, maximumResponseTokens: Int?)`](/documentation/FoundationModels/GenerationOptions/init(samplingMode:temperature:maximumResponseTokens:))

Creates generation options that control token sampling behavior.

[`init(samplingMode: GenerationOptions.SamplingMode?, temperature: Double?, maximumResponseTokens: Int?, toolCallingMode: GenerationOptions.ToolCallingMode?)`](/documentation/FoundationModels/GenerationOptions/init(samplingMode:temperature:maximumResponseTokens:toolCallingMode:))

Creates generation options that control token sampling behavior.

[`init(sampling: GenerationOptions.SamplingMode?, temperature: Double?, maximumResponseTokens: Int?)`](/documentation/FoundationModels/GenerationOptions/init(sampling:temperature:maximumResponseTokens:))

Creates generation options that control token sampling behavior.

##### Configuring options

[`var temperature: Double?`](/documentation/FoundationModels/GenerationOptions/temperature)

A value that influences the confidence of the model’s response.

[`var sampling: GenerationOptions.SamplingMode?`](/documentation/FoundationModels/GenerationOptions/sampling)

A sampling strategy for how the model picks tokens when generating a
response.

[`var samplingMode: GenerationOptions.SamplingMode?`](/documentation/FoundationModels/GenerationOptions/samplingMode-swift.property)

A sampling strategy for how the model picks tokens when generating a
response.

[`struct SamplingMode`](/documentation/FoundationModels/GenerationOptions/SamplingMode-swift.struct)

A type that defines how values are sampled from a probability distribution.

[`var toolCallingMode: GenerationOptions.ToolCallingMode?`](/documentation/FoundationModels/GenerationOptions/toolCallingMode-swift.property)

The tool calling requirements.

[`struct ToolCallingMode`](/documentation/FoundationModels/GenerationOptions/ToolCallingMode-swift.struct)

A value that describes how the model uses tools.

[`var maximumResponseTokens: Int?`](/documentation/FoundationModels/GenerationOptions/maximumResponseTokens)

The maximum number of tokens the model is allowed to produce in its response.

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`Equatable`](/documentation/Swift/Equatable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### Transcript  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/transcript.md>


A linear history of entries that reflect an interaction with a session.

```
struct Transcript
```

#### Overview

Use a `Transcript` to visualize previous instructions, prompts and model responses. If you use tool
calling, a `Transcript` includes a history of tool calls and their results.

```swift
struct HistoryView: View {
    let session: LanguageModelSession

    var body: some View {
        ScrollView {
            ForEach(session.transcript) { entry in
                switch entry {
                case let .instructions(instructions):
                    MyInstructionsView(instructions)
                case let .prompt(prompt):
                    MyPromptView(prompt)
                case let .reasoning(reasoning):
                    MyReasoningView(reasoning)
                case let .toolCalls(toolCalls):
                    MyToolCallsView(toolCalls)
                case let .toolOutput(toolOutput):
                    MyToolOutputView(toolOutput)
                case let .response(response):
                    MyResponseView(response)
                }
            }
        }
    }
}
```

When you create a new [`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession) it doesn’t contain the state of a
previous session. You can initialize a new session with a list of entries you
get from a session [`transcript`](/documentation/FoundationModels/LanguageModelSession/transcript):

```swift
// Create a new session with the first and last entries from a previous session.
func newContextualSession(with originalSession: LanguageModelSession) -> LanguageModelSession {
    let allEntries = originalSession.transcript

    // Collect the entries to keep from the original session.
    let entries = [allEntries.first, allEntries.last].compactMap { $0 }
    let transcript = Transcript(entries: entries)

    // Create a new session with the result and preload the session resources.
    var session = LanguageModelSession(transcript: transcript)
    session.prewarm()
    return session
}
```

#### Topics

##### Creating a transcript

[`init(entries: some Sequence<Transcript.Entry>)`](/documentation/FoundationModels/Transcript/init(entries:))

Creates a transcript.

##### Accessing the transcript history

[`var history: Transcript.HistoryView`](/documentation/FoundationModels/Transcript/history)

The transcript entries excluding the leading instructions entry, if present.

[`struct HistoryView`](/documentation/FoundationModels/Transcript/HistoryView)

A mutable view into the conversational entries of a transcript.

##### Constructing entries

[`enum Entry`](/documentation/FoundationModels/Transcript/Entry)

An entry in a transcript.

[`struct Instructions`](/documentation/FoundationModels/Transcript/Instructions)

Instructions you provide to the model that define its behavior.

[`struct Prompt`](/documentation/FoundationModels/Transcript/Prompt)

A prompt from the user to the model.

[`struct Response`](/documentation/FoundationModels/Transcript/Response)

A response from the model.

[`struct Reasoning`](/documentation/FoundationModels/Transcript/Reasoning)

A reasoning entry from the model.

##### Accessing entry segments

[`enum Segment`](/documentation/FoundationModels/Transcript/Segment)

The types of segments that may be included in a transcript entry.

[`struct TextSegment`](/documentation/FoundationModels/Transcript/TextSegment)

A segment containing text.

[`struct StructuredSegment`](/documentation/FoundationModels/Transcript/StructuredSegment)

A segment containing structured content.

[`struct AttachmentSegment`](/documentation/FoundationModels/Transcript/AttachmentSegment)

A segment containing attached files or images.

##### Getting the nontext payload

[`enum Attachment`](/documentation/FoundationModels/Transcript/Attachment)

The types of attached content.

[`struct ImageAttachment`](/documentation/FoundationModels/Transcript/ImageAttachment)

An image attachment in a transcript entry.

##### Inspecting tool calls

[`struct ToolDefinition`](/documentation/FoundationModels/Transcript/ToolDefinition)

A definition of a tool.

[`struct ToolCalls`](/documentation/FoundationModels/Transcript/ToolCalls)

A collection of tool calls generated by the model.

[`struct ToolCall`](/documentation/FoundationModels/Transcript/ToolCall)

A tool call generated by the model containing the name of a tool and arguments to pass to it.

[`struct ToolOutput`](/documentation/FoundationModels/Transcript/ToolOutput)

A tool output provided back to the model.

##### Configuring the output format

[`struct ResponseFormat`](/documentation/FoundationModels/Transcript/ResponseFormat)

A response format that the model must conform its output to.

##### Structures

[`struct DataAttachment`](/documentation/FoundationModels/Transcript/DataAttachment)

A data attachment payload in a serialized, portable format.

[`struct DataEntry`](/documentation/FoundationModels/Transcript/DataEntry)

A top-level transcript entry payload in a serialized, portable format.

##### Instance Properties

[`var structuredTranscript: StructuredTranscript`](/documentation/FoundationModels/Transcript/structuredTranscript)

A structured representation of this transcript, with tool calls, outputs, and responses collected into typed arrays.

##### Default Implementations

[RandomAccessCollection Implementations](/documentation/FoundationModels/Transcript/RandomAccessCollection-Implementations)

#### Relationships

##### Conforms To

[`BidirectionalCollection`](/documentation/Swift/BidirectionalCollection)

[`Copyable`](/documentation/Swift/Copyable)

[`Collection`](/documentation/Swift/Collection)

[`Encodable`](/documentation/Swift/Encodable)

[`Equatable`](/documentation/Swift/Equatable)

[`Sendable`](/documentation/Swift/Sendable)

[`Escapable`](/documentation/Swift/Escapable)

[`Sequence`](/documentation/Swift/Sequence)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`RangeReplaceableCollection`](/documentation/Swift/RangeReplaceableCollection)

[`RandomAccessCollection`](/documentation/Swift/RandomAccessCollection)

[`Decodable`](/documentation/Swift/Decodable)

[`MutableCollection`](/documentation/Swift/MutableCollection)

### LanguageModelSession.GenerationError  
*iOS: 26.0.0 - 27.0.0* · <https://developer.apple.com/documentation/foundationmodels/languagemodelsession/generationerror.md>


An error that may occur while generating a response.

```
enum GenerationError
```

#### Topics

##### Generation errors

[`case assetsUnavailable(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/assetsUnavailable(_:))

An error that indicates the assets required for the session are unavailable.

[`case decodingFailure(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/decodingFailure(_:))

An error that indicates the session failed to deserialize a valid generable type from model output.

[`case exceededContextWindowSize(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/exceededContextWindowSize(_:))

An error that signals the session reached its context window size limit.

[`case guardrailViolation(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/guardrailViolation(_:))

An error that indicates the system’s safety guardrails are triggered by content in a
prompt or the response generated by the model.

[`case rateLimited(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/rateLimited(_:))

An error that indicates your session has been rate limited.

[`case refusal(LanguageModelSession.GenerationError.Refusal, LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/refusal(_:_:))

An error indicating that the model refused to answer.

[`case concurrentRequests(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/concurrentRequests(_:))

An error that happens if you attempt to make a session respond to a
second prompt while it’s still responding to the first one.

[`case unsupportedGuide(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/unsupportedGuide(_:))

An error that indicates a generation guide with an unsupported pattern was used.

[`case unsupportedLanguageOrLocale(LanguageModelSession.GenerationError.Context)`](/documentation/FoundationModels/LanguageModelSession/GenerationError/unsupportedLanguageOrLocale(_:))

An error that indicates an error that occurs if the model is prompted to respond in a language
that it does not support.

[`struct Context`](/documentation/FoundationModels/LanguageModelSession/GenerationError/Context)

The context in which the error occurred.

[`struct Refusal`](/documentation/FoundationModels/LanguageModelSession/GenerationError/Refusal)

A refusal produced by a language model.

##### Getting the error description

[`var errorDescription: String?`](/documentation/FoundationModels/LanguageModelSession/GenerationError/errorDescription)

A string representation of the error description.

##### Getting the failure reason

[`var failureReason: String?`](/documentation/FoundationModels/LanguageModelSession/GenerationError/failureReason)

A string representation of the failure reason.

##### Getting the recovery suggestion

[`var recoverySuggestion: String?`](/documentation/FoundationModels/LanguageModelSession/GenerationError/recoverySuggestion)

A string representation of the recovery suggestion.

##### Default Implementations

[LocalizedError Implementations](/documentation/FoundationModels/LanguageModelSession/GenerationError/LocalizedError-Implementations)

#### Relationships

##### Conforms To

[`LocalizedError`](/documentation/Foundation/LocalizedError)

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Error`](/documentation/Swift/Error)

### Instructions  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/instructions.md>


Details you provide that define the model’s intended behavior on prompts.

```
struct Instructions
```

#### Overview

You typically provide instructions to define the role and behavior of
the model. In the code below, the instructions specify that the model replies
with topics rather than, for example, a recipe:

```swift
let instructions = """
    Suggest related topics. Keep them concise (three to seven words) and make sure they \
    build naturally from the person's topic.
    """

let session = LanguageModelSession(instructions: instructions)

let prompt = "Making homemade bread"
let response = try await session.respond(to: prompt)
```

Don’t include untrusted content in instructions: the model is typically trained to obey
instructions over any commands it receives in prompts. For more on how instructions
impact generation quality and safety, see [Improving the safety of generative model output](/documentation/FoundationModels/improving-the-safety-of-generative-model-output).

All input to the model contributes tokens to the context window of the
[`LanguageModelSession`](/documentation/FoundationModels/LanguageModelSession) — including the [`Instructions`](/documentation/FoundationModels/Instructions), [`Prompt`](/documentation/FoundationModels/Prompt), [`Tool`](/documentation/FoundationModels/Tool),
and [`Generable`](/documentation/FoundationModels/Generable) types, and the model’s responses. If your session exceeds the
available context size, it throws  [`LanguageModelError.contextSizeExceeded(_:)`](/documentation/FoundationModels/LanguageModelError/contextSizeExceeded(_:)).

Instructions can consume a lot of tokens that contribute to the context window
size. To reduce your instruction size:

- Write shorter instructions to save tokens.
- Provide only the information necessary to perform the task.
- Use concise and imperative language instead of indirect or jargon that the model might misinterpret.
- Aim for one to three paragraphs instead of including a significant amount of background information,
  policy, or extra content.

For more information on managing the context window size, see [Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Topics

##### Creating instructions

[`init(_:)`](/documentation/FoundationModels/Instructions/init(_:))

Creates instructions from the content of a builder closure.

[`struct InstructionsBuilder`](/documentation/FoundationModels/InstructionsBuilder)

A type that represents an instructions builder.

[`protocol InstructionsRepresentable`](/documentation/FoundationModels/InstructionsRepresentable)

A type that can be represented as instructions.

#### Relationships

##### Conforms To

[`DynamicInstructions`](/documentation/FoundationModels/DynamicInstructions)

[`Escapable`](/documentation/Swift/Escapable)

[`InstructionsRepresentable`](/documentation/FoundationModels/InstructionsRepresentable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Copyable`](/documentation/Swift/Copyable)

[`Sendable`](/documentation/Swift/Sendable)

### Prompt  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/foundationmodels/prompt.md>


A prompt from a person to the model.

```
struct Prompt
```

#### Overview

Prompts can contain content written by you, an outside source, or input directly from people using
your app. You can initialize a `Prompt` from a string literal:

```swift
let prompt = Prompt("What are miniature schnauzers known for?")
```

Use [`PromptBuilder`](/documentation/FoundationModels/PromptBuilder) to dynamically control the prompt’s content based on your app’s state. The
code below shows if the Boolean is `true`, the prompt includes a second line of text:

```swift
let responseShouldRhyme = true
let prompt = Prompt {
    "Answer the following question: Do Siberian Huskies love cold weather?"
    if responseShouldRhyme {
        "Your response MUST rhyme!"
    }
}
```

If your prompt includes input from people, consider wrapping the input in a string template with your
own prompt to better steer the model’s response. For more information on handling inputs in your
prompts, see [Improving the safety of generative model output](/documentation/FoundationModels/improving-the-safety-of-generative-model-output).

Prompting the same session eventually leads to exceeding the context window size. You can recover
from this error by removing entries from the transcript and trying again. For more information on
managing the context window size, see [Managing the context window](/documentation/FoundationModels/managing-the-context-window).

#### Topics

##### Creating a prompt

[`init(_:)`](/documentation/FoundationModels/Prompt/init(_:))

Creates a prompt from the content of a builder closure.

[`struct PromptBuilder`](/documentation/FoundationModels/PromptBuilder)

A type that represents a prompt builder.

[`protocol PromptRepresentable`](/documentation/FoundationModels/PromptRepresentable)

A type whose value can represent a prompt.

#### Relationships

##### Conforms To

[`Copyable`](/documentation/Swift/Copyable)

[`Escapable`](/documentation/Swift/Escapable)

[`Sendable`](/documentation/Swift/Sendable)

[`PromptRepresentable`](/documentation/FoundationModels/PromptRepresentable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### TN3193: Managing the on-device foundation model’s context window  
<https://developer.apple.com/documentation/technotes/tn3193-managing-the-on-device-foundation-model-s-context-window.md>


Learn how to budget for the context window limit of Apple’s on-device foundation model and handle the error when reaching the limit.

#### Overview

The [Foundation Models framework](doc://com.apple.documentation/documentation/FoundationModels) provides access to Apple’s on-device foundation model at the core of Apple Intelligence. With the framework, you can build AI-powered features that enhance your app.

Like other Large Language Models (LLMs), Apple’s on-device foundation model processes text in units called tokens. A token corresponds to roughly three to four characters in Latin alphabet languages like English, as elaborated in the WWDC25 session 286: [Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/?time=468). For multi-byte languages like Chinese, Japanese, and Korean, it is roughly one character per token.

The maximum number of tokens a LLM can process at once is called the context window. Context window size is determined by model architecture and hardware limits. An on-device LLM running on your iPhone needs a relatively small context window to run efficiently.

Apple’s on-device foundation model has a context window of 4096 tokens per [language model session](doc://com.apple.documentation/documentation/FoundationModels/LanguageModelSession). To adapt to this limit, consider techniques to effectively budget for the context window, achieve your use-cases using fewer tokens, and handle the error when you reach the limit.

#### Understand how your app consumes tokens

When you interact with a LLM, the model converts your input to a token sequence, and uses it to generate a probability distribution that reflects which token in the model’s vocabulary could be the next. Based on the decoding strategy, which is derived from the [generation options](doc://com.apple.documentation/documentation/FoundationModels/GenerationOptions) when you use the Foundation Models framework, the model picks the next token, appends it to the sequence, and uses the updated sequence as the input for the next generation cycle. This process repeats until it reaches a stop condition. The final token sequence, after being converted to human-readable content, is the response you get.

With the Foundation Models framework, you interact with the model using [instructions](doc://com.apple.documentation/documentation/FoundationModels/Instructions), [prompts](doc://com.apple.documentation/documentation/FoundationModels/Prompt), [tool calling](doc://com.apple.documentation/documentation/FoundationModels/Tool), and [Generable](doc://com.apple.documentation/documentation/FoundationModels/Generable) types, which are passed to the model as part of the input. All the input and response in the generation process contribute tokens to the context window of the current language model session, including instructions, all prompts, the information of tools (schemas, input, and output), `Generable` schemas, and all the model’s responses.

To understand how your input consumes tokens, use [tokenCount(for:)](doc://com.apple.documentation/documentation/FoundationModels/SystemLanguageModel/tokenCount(for:)) to retrieve the token count for your instructions, prompts, tools, [schema](https://developer.apple.com/documentation/foundationmodels/generationschema), and [transcript entries](https://developer.apple.com/documentation/foundationmodels/transcript/entry).

The Foundation Models instrument allows you to profile your app to observe token consumption while your app is running. To use the instrument:

1. In Xcode, open your project and click Product > Profile to launch Instruments.
2. Select the Blank template, and click the Choose button.
3. Click the + Instrument button, and choose the Foundation Models instrument from the list.
4. Start recording your app, have your app interact with the models, and observe the token count.

For more information about profiling your app with the instrument, see the WWDC25 session 259: [Code-along: Bring on-device AI to your app using the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/259/?time=1473).

#### Split a large task into multiple language model sessions

When doing a task that needs a larger context window size, explore if you can split the task into smaller steps, run each step with a new language model session, and then assemble the results together.

As an example, to generate a summary for a long article on device, consider separating the article into smaller chunks that the model can handle, summarizing each chunk with a new session, combining the results together, and then repeating this process, until getting a summary with ideal size. To avoid completely losing the context of the article when summarizing a chunk, consider adding the result of the previous summarization to the prompt so it conveys the contextual information.

#### Ask the model for less content

One way to budget tokens is to ask the model to produce fewer response tokens. If you notice the model producing long, detailed responses, try:

- Include your target response length in your prompt, for example, “In 3 sentences….” or “List 3 reasons that…”.
- Add a [`@Guide`](doc://com.apple.documentation/documentation/FoundationModels/Guide(description:)) to any `Generable` arrays (for example, tag lists or name lists) you are generating and specify the max count using <doc://com.apple.documentation/documentation/FoundationModels/GenerationGuide/maximumCount(_:)>.

Use <doc://com.apple.documentation/documentation/FoundationModels/GenerationOptions/maximumResponseTokens> only when you need to protect against unexpectedly verbose responses and runaway generations, since enforcing a strict token response limit can lead the model to produce malformed results or grammatically incorrect partial responses like “A cat is a small.”

#### Reduce the prompt size

Prompts and instructions can consume a lot of tokens, especially in multi-turn scenarios where you’re sending multiple prompts to the same language model session. Writing shorter prompts and instructions is a way to save tokens without sacrificing response quality.

Give the model only the information needed for a specific task. Avoid instructions that give the model significant amount background information, policy, or extra context. Long instructions with large amount information consume more tokens, and may lower the quality of the responses.

Use concise and imperative language in your instructions and prompts. Make sure your prompt has a clear verb that tells the model what to do, for example,  “Generate a story…” or “List 5 things that…”. Avoid indirect language, formal language, or jargon the foundation model might misinterpret. Aim for a maximum of 1–3 paragraphs for prompts and instructions, and in general, use the shortest prompt that can achieve your task.

#### Use Generable types efficiently

`Generable` types consume tokens in multiple ways. For every `Generable` type in your generation request, the framework converts its type and format information to a JSON schema, and passes that schema text to the model. Any `@Guide` descriptions you write also consume tokens. To make your `Generable` types more efficient:

- Reduce the size and complexity of your type. As a rule of thumb, think about how much screen space your `@Generable` code takes with normal code formatting. More screen space roughly corresponds to more token use.
- Give your properties short, clear names.
- Use `@Guide` only where needed. If your `Generable` type’s properties are clearly named, the model may have all the information it needs to generate your type. Try generating first with no `@Guide` annotations, and then add in `@Guide` annotations where needed to improve response quality.

#### Use tool calling efficiently

Tool calling allows the model to request and incorporate the information from your code, but consumes tokens in a similar fashion to `Generable` types. When you provide a tool in your generation request, the framework puts the tool definitions, which includes the tool name, description, and parameter information, in the prompt so the model can decide when and how often to call the tool. When the model calls a tool, the framework returns the tool’s output back to the model for further processing, which consumes additional tokens. To use tool calling efficiently:

- Keep your tool description and `@Guide` descriptions to a short phrase each.
- Give the model a maximum of 3–5 tools to choose from.

Look for opportunities to save tokens by skipping tool calling entirely. Use a tool only when you need the model to decide if it needs the tool. In the cases where the model should always have information from a tool, run the tool directly before you call the model and integrate the tool’s output to the prompt directly.

If you’re reaching the context window limit, consider breaking up tool calls across multiple language model sessions, if appropriate for your use case. In cases where you need the model to generate appropriate tool arguments, consider asking the model to generate those in one session, then run your tool using normal programming, then have the model process the tool’s output in a new, second session.

#### Integrate a retrieval system to fetch information dynamically

Retrieval-Augmented Generation, or RAG, is a technique that combines a retrieval system (like a search engine or vector database) with a language model. If your use case has a large amount of information, notes, or documents you’d like the model to reference, you may have too much information to fit in the context window. Using RAG, you can dynamically fetch snippets of the relevant information when needed, and pass only the snippets to the model to stay within the context window.

There are many methods for RAG, but they typically follow these general steps:

1. Choose an approach that fits your use case for text chunking and embedding.
2. Split your knowledge base into chunks, vectorize the chunks into embeddings, and store the result in a database.
3. Gather a user query, vectorize it, and use the result to retrieve the most relevant chunks from the database.
4. Feed the query and the most relevant chunks to the model and collect the response.

For the first step, consider using a chunking model and an embedding model. The former splits large pieces of text to smaller ones; the latter takes text as input, vectorizes it, and outputs a list of numbers that represents the text. After determining the models that work for your use case, integrate them into your app using APIs such as <doc://com.apple.documentation/documentation/CoreML>. The <doc://com.apple.documentation/documentation/NaturalLanguage> framework provides APIs for tokenizing and embedding text — if that meets your needs. See <doc://com.apple.documentation/documentation/NaturalLanguage/tokenizing-natural-language-text> and <doc://com.apple.documentation/documentation/NaturalLanguage/finding-similarities-between-pieces-of-text> for more information.

In the second step, vectorizing the whole knowledge base may be computationally heavy and take time. You can do it with a dedicated data preparation process that runs separate from the app and then stores the final chunks and embeddings in your app, or makes them available to the app through a server your app uses. RAG can be used as a tool call, or as a step you run before calling the on-device foundation model.

#### Handle the exceeding context window size error elegantly

Even with carefully designed architecture and prompts, you might still exceed the context window limit in some cases. In an open-ended conversation implemented with one large language session, for example, people can continue the chat for long time, and eventually reach the limit.

When that happens, the Foundation Models framework throws an [`.exceededContextWindowSize`](doc://com.apple.documentation/documentation/FoundationModels/LanguageModelSession/GenerationError/exceededContextWindowSize(_:)) error, and the session won’t be able to respond. To catch the error:

```swift
do {
   let response = try await largeLanguageSession.respond(to: <prompt>)
   ...
} catch let error as LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
    ... // Handle .exceededContextWindowSize error.
} catch let error {
    ... // Handle other errors.
}
```

To handle the error, consider creating a new session to continue your workflow. A new session has a new context window, but doesn’t convey the state of the original session. If you need to keep the state, consider the following options:

- Collect the content of the original session through its <doc://com.apple.documentation/documentation/FoundationModels/LanguageModelSession/transcript> property, do a summary, and create a new session with the result.
- Pick some important entries from the original session’s transcript, and use them to create a new session.

The following example shows how to create a new session with the first and last entries of the original session:

```swift
func newContextualSession(with originalSession: LanguageModelSession) -> LanguageModelSession {
    let allEntries = originalSession.transcript
    let condensedEntries = [allEntries.first, allEntries.last].compactMap { $0 }
    let condensedTranscript = Transcript(entries: condensedEntries)
    var newSession = LanguageModelSession(transcript: condensedTranscript)
    newSession.prewarm()
    return newSession
}
```

For an example that includes instructions and tool calling, see <doc://com.apple.documentation/documentation/FoundationModels/generate-dynamic-game-content-with-guided-generation-and-tools>.

#### Revision History

- **2026-03-31** Updated with the new API introduced in iOS, iPadOS, macOS, visionOS 26.4.
- **2025-10-06** First published.


## SDK signatures (FoundationModels, iOS 26.5 swiftinterface — ground truth)

```swift
public import CoreGraphics
public import Foundation
public import Observation
public import Swift
public import _Concurrency
public import _StringProcessing
public import _SwiftConcurrencyShims
public protocol Generable : FoundationModels.ConvertibleFromGeneratedContent, FoundationModels.ConvertibleToGeneratedContent {
extension FoundationModels.Generable {
  public func asPartiallyGenerated() -> Self.PartiallyGenerated
public protocol ConvertibleFromGeneratedContent : Swift.SendableMetatype {
public protocol ConvertibleToGeneratedContent : FoundationModels.InstructionsRepresentable, FoundationModels.PromptRepresentable {
extension FoundationModels.ConvertibleToGeneratedContent {
  public var instructionsRepresentation: FoundationModels.Instructions {
  public var promptRepresentation: FoundationModels.Prompt {
extension FoundationModels.Generable {
  public typealias PartiallyGenerated = Self
extension Swift.Optional where Wrapped : FoundationModels.Generable {
  public typealias PartiallyGenerated = Wrapped.PartiallyGenerated
extension Swift.Optional : FoundationModels.ConvertibleToGeneratedContent, FoundationModels.PromptRepresentable, FoundationModels.InstructionsRepresentable where Wrapped : FoundationModels.ConvertibleToGeneratedContent {
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Bool : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.String : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Int : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Float : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Double : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Foundation.Decimal : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Array : FoundationModels.Generable where Element : FoundationModels.Generable {
  public typealias PartiallyGenerated = [Element.PartiallyGenerated]
  public static var generationSchema: FoundationModels.GenerationSchema {
extension Swift.Array : FoundationModels.ConvertibleToGeneratedContent where Element : FoundationModels.ConvertibleToGeneratedContent {
  public var generatedContent: FoundationModels.GeneratedContent {
extension Swift.Array : FoundationModels.ConvertibleFromGeneratedContent where Element : FoundationModels.ConvertibleFromGeneratedContent {
  public init(_ content: FoundationModels.GeneratedContent) throws
extension Swift.Never : FoundationModels.Generable {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
public struct GeneratedContent : Swift.Sendable, Swift.Equatable, FoundationModels.Generable, Swift.CustomDebugStringConvertible {
  public static var generationSchema: FoundationModels.GenerationSchema {
  public var id: FoundationModels.GenerationID?
  public init(_ content: FoundationModels.GeneratedContent) throws
  public var generatedContent: FoundationModels.GeneratedContent {
  public init(properties: Swift.KeyValuePairs<Swift.String, any FoundationModels.ConvertibleToGeneratedContent>, id: FoundationModels.GenerationID? = nil)
  public init<S>(properties: S, id: FoundationModels.GenerationID? = nil, uniquingKeysWith combine: (FoundationModels.GeneratedContent, FoundationModels.GeneratedContent) throws -> some ConvertibleToGeneratedContent) rethrows where S : Swift.Sequence, S.Element == (Swift.String, any FoundationModels.ConvertibleToGeneratedContent)
  public init<S>(elements: S, id: FoundationModels.GenerationID? = nil) where S : Swift.Sequence, S.Element == any FoundationModels.ConvertibleToGeneratedContent
  public init(_ value: some ConvertibleToGeneratedContent)
  public init(_ value: some ConvertibleToGeneratedContent, id: FoundationModels.GenerationID)
  public init(json: Swift.String) throws
  public var jsonString: Swift.String {
  public func value<Value>(_ type: Value.Type = Value.self) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent
  public func value<Value>(_ type: Value.Type = Value.self, forProperty property: Swift.String) throws -> Value where Value : FoundationModels.ConvertibleFromGeneratedContent
  public func value<Value>(_ type: Value?.Type = Value?.self, forProperty property: Swift.String) throws -> Value? where Value : FoundationModels.ConvertibleFromGeneratedContent
  public var debugDescription: Swift.String {
  public var isComplete: Swift.Bool {
  public static func == (a: FoundationModels.GeneratedContent, b: FoundationModels.GeneratedContent) -> Swift.Bool
extension FoundationModels.GeneratedContent {
  public enum Kind : Swift.Equatable, Swift.Sendable {
    case null
    case bool(Swift.Bool)
    case number(Swift.Double)
    case string(Swift.String)
    case array([FoundationModels.GeneratedContent])
    case structure(properties: [Swift.String : FoundationModels.GeneratedContent], orderedKeys: [Swift.String])
    public static func == (a: FoundationModels.GeneratedContent.Kind, b: FoundationModels.GeneratedContent.Kind) -> Swift.Bool
  public init(kind: FoundationModels.GeneratedContent.Kind, id: FoundationModels.GenerationID? = nil)
  public var kind: FoundationModels.GeneratedContent.Kind {
public struct GenerationGuide<Value> {
extension FoundationModels.GenerationGuide where Value == Swift.String {
  public static func constant(_ value: Swift.String) -> FoundationModels.GenerationGuide<Swift.String>
  public static func anyOf(_ values: [Swift.String]) -> FoundationModels.GenerationGuide<Swift.String>
  public static func pattern<Output>(_ regex: _StringProcessing.Regex<Output>) -> FoundationModels.GenerationGuide<Swift.String>
extension FoundationModels.GenerationGuide where Value == Swift.Int {
  public static func minimum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>
  public static func maximum(_ value: Swift.Int) -> FoundationModels.GenerationGuide<Swift.Int>
  public static func range(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<Swift.Int>
extension FoundationModels.GenerationGuide where Value == Swift.Float {
  public static func minimum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>
  public static func maximum(_ value: Swift.Float) -> FoundationModels.GenerationGuide<Swift.Float>
  public static func range(_ range: Swift.ClosedRange<Swift.Float>) -> FoundationModels.GenerationGuide<Swift.Float>
extension FoundationModels.GenerationGuide where Value == Foundation.Decimal {
  public static func minimum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>
  public static func maximum(_ value: Foundation.Decimal) -> FoundationModels.GenerationGuide<Foundation.Decimal>
  public static func range(_ range: Swift.ClosedRange<Foundation.Decimal>) -> FoundationModels.GenerationGuide<Foundation.Decimal>
extension FoundationModels.GenerationGuide where Value == Swift.Double {
  public static func minimum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>
  public static func maximum(_ value: Swift.Double) -> FoundationModels.GenerationGuide<Swift.Double>
  public static func range(_ range: Swift.ClosedRange<Swift.Double>) -> FoundationModels.GenerationGuide<Swift.Double>
extension FoundationModels.GenerationGuide {
  public static func minimumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]
  public static func maximumCount<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]
  public static func count<Element>(_ range: Swift.ClosedRange<Swift.Int>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]
  public static func count<Element>(_ count: Swift.Int) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]
  public static func element<Element>(_ guide: FoundationModels.GenerationGuide<Element>) -> FoundationModels.GenerationGuide<[Element]> where Value == [Element]
final public class LanguageModelSession {
  final public var transcript: FoundationModels.Transcript {
extension FoundationModels.LanguageModelSession : nonisolated Observation.Observable {
extension FoundationModels.LanguageModelSession {
  final public var isResponding: Swift.Bool {
  final public func prewarm(promptPrefix: FoundationModels.Prompt? = nil)
  public struct Response<Content> where Content : FoundationModels.Generable {
    public let content: Content
    public let rawContent: FoundationModels.GeneratedContent
    public let transcriptEntries: Swift.ArraySlice<FoundationModels.Transcript.Entry>
  final public func streamResponse(to prompt: FoundationModels.Prompt, schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>
extension FoundationModels.LanguageModelSession : @unchecked Swift.Sendable {
extension FoundationModels.LanguageModelSession {
  public enum GenerationError : Swift.Error, Foundation.LocalizedError {
    public struct Context : Swift.Sendable {
    public let debugDescription: Swift.String
    public init(debugDescription: Swift.String)
    public struct Refusal : Swift.Sendable {
    public init(transcriptEntries: [FoundationModels.Transcript.Entry])
    public var explanation: FoundationModels.LanguageModelSession.Response<Swift.String> {
    public var explanationStream: FoundationModels.LanguageModelSession.ResponseStream<Swift.String> {
    case exceededContextWindowSize(FoundationModels.LanguageModelSession.GenerationError.Context)
    case assetsUnavailable(FoundationModels.LanguageModelSession.GenerationError.Context)
    case guardrailViolation(FoundationModels.LanguageModelSession.GenerationError.Context)
    case unsupportedGuide(FoundationModels.LanguageModelSession.GenerationError.Context)
    case unsupportedLanguageOrLocale(FoundationModels.LanguageModelSession.GenerationError.Context)
    case decodingFailure(FoundationModels.LanguageModelSession.GenerationError.Context)
    case rateLimited(FoundationModels.LanguageModelSession.GenerationError.Context)
    case concurrentRequests(FoundationModels.LanguageModelSession.GenerationError.Context)
    case refusal(FoundationModels.LanguageModelSession.GenerationError.Refusal, FoundationModels.LanguageModelSession.GenerationError.Context)
    public var errorDescription: Swift.String? {
    public var recoverySuggestion: Swift.String? {
    public var failureReason: Swift.String? {
  public struct ToolCallError : Swift.Error, Foundation.LocalizedError {
    public var tool: any FoundationModels.Tool
    public var underlyingError: any Swift.Error
    public init(tool: any FoundationModels.Tool, underlyingError: any Swift.Error)
    public var errorDescription: Swift.String? {
extension FoundationModels.LanguageModelSession {
  public struct ResponseStream<Content> where Content : FoundationModels.Generable {
    public struct Snapshot {
    public var content: Content.PartiallyGenerated
    public var rawContent: FoundationModels.GeneratedContent
extension FoundationModels.LanguageModelSession.ResponseStream : _Concurrency.AsyncSequence {
  public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot
  public struct AsyncIterator : _Concurrency.AsyncIteratorProtocol {
    public mutating func next(isolation actor: isolated (any _Concurrency.Actor)? = #isolation) async throws -> FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot?
    public typealias Element = FoundationModels.LanguageModelSession.ResponseStream<Content>.Snapshot
  public func makeAsyncIterator() -> FoundationModels.LanguageModelSession.ResponseStream<Content>.AsyncIterator
extension FoundationModels.LanguageModelSession {
  final public func streamResponse(schema: FoundationModels.GenerationSchema, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<FoundationModels.GeneratedContent>
  final public func streamResponse<Content>(to prompt: FoundationModels.Prompt, generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable
  final public func streamResponse<Content>(generating type: Content.Type = Content.self, includeSchemaInPrompt: Swift.Bool = true, options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Content> where Content : FoundationModels.Generable
  final public func streamResponse(to prompt: FoundationModels.Prompt, options: FoundationModels.GenerationOptions = GenerationOptions()) -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>
  final public func streamResponse(options: FoundationModels.GenerationOptions = GenerationOptions(), @FoundationModels.PromptBuilder prompt: () throws -> FoundationModels.Prompt) rethrows -> sending FoundationModels.LanguageModelSession.ResponseStream<Swift.String>
final public class SystemLanguageModel : Swift.Sendable {
  final public var availability: FoundationModels.SystemLanguageModel.Availability {
  final public var isAvailable: Swift.Bool {
  public struct UseCase : Swift.Sendable, Swift.Equatable {
    public static let general: FoundationModels.SystemLanguageModel.UseCase
    public static let contentTagging: FoundationModels.SystemLanguageModel.UseCase
    public static func == (a: FoundationModels.SystemLanguageModel.UseCase, b: FoundationModels.SystemLanguageModel.UseCase) -> Swift.Bool
extension FoundationModels.SystemLanguageModel : nonisolated Observation.Observable {
extension FoundationModels.SystemLanguageModel {
  public struct Guardrails : Swift.Sendable {
    public static let `default`: FoundationModels.SystemLanguageModel.Guardrails
    public static let permissiveContentTransformations: FoundationModels.SystemLanguageModel.Guardrails
extension FoundationModels.SystemLanguageModel {
  @frozen public enum Availability : Swift.Equatable, Swift.Sendable {
    public enum UnavailableReason : Swift.Equatable, Swift.Sendable {
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    public static func == (a: FoundationModels.SystemLanguageModel.Availability.UnavailableReason, b: FoundationModels.SystemLanguageModel.Availability.UnavailableReason) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    case available
    case unavailable(FoundationModels.SystemLanguageModel.Availability.UnavailableReason)
    public static func == (a: FoundationModels.SystemLanguageModel.Availability, b: FoundationModels.SystemLanguageModel.Availability) -> Swift.Bool
  public static var `default`: FoundationModels.SystemLanguageModel {
  final public var supportedLanguages: Swift.Set<Foundation.Locale.Language> {
  final public func supportsLocale(_ locale: Foundation.Locale = Locale.current) -> Swift.Bool
extension FoundationModels.SystemLanguageModel {
extension FoundationModels.SystemLanguageModel {
  final public var contextSize: Swift.Int {
extension FoundationModels.SystemLanguageModel {
  public struct Adapter {
    public var creatorDefinedMetadata: [Swift.String : Any] {
extension FoundationModels.SystemLanguageModel.Adapter {
  public init(fileURL: Foundation.URL) throws
  public init(name: Swift.String) throws
  public static func compatibleAdapterIdentifiers(name: Swift.String) -> [Swift.String]
  public static func removeObsoleteAdapters() throws
extension FoundationModels.SystemLanguageModel.Adapter {
  public enum AssetError : Swift.Error, Foundation.LocalizedError {
    public struct Context : Swift.Sendable {
    public let debugDescription: Swift.String
    public init(debugDescription: Swift.String)
    case invalidAsset(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)
    case invalidAdapterName(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)
    case compatibleAdapterNotFound(FoundationModels.SystemLanguageModel.Adapter.AssetError.Context)
    public var errorDescription: Swift.String? {
    public var recoverySuggestion: Swift.String? {
public struct Transcript : Swift.Sendable, Swift.Equatable, Swift.RandomAccessCollection {
  public typealias Index = Swift.Int
  public subscript(index: FoundationModels.Transcript.Index) -> FoundationModels.Transcript.Entry {
  public var startIndex: Swift.Int {
  public var endIndex: Swift.Int {
  public init(entries: some Sequence<Entry> = [])
  public enum Entry : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    case instructions(FoundationModels.Transcript.Instructions)
    case prompt(FoundationModels.Transcript.Prompt)
    case toolCalls(FoundationModels.Transcript.ToolCalls)
    case toolOutput(FoundationModels.Transcript.ToolOutput)
    case response(FoundationModels.Transcript.Response)
    public var id: Swift.String {
    public static func == (a: FoundationModels.Transcript.Entry, b: FoundationModels.Transcript.Entry) -> Swift.Bool
    public typealias ID = Swift.String
  public enum Segment : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    case text(FoundationModels.Transcript.TextSegment)
    case structure(FoundationModels.Transcript.StructuredSegment)
    public var id: Swift.String {
    public static func == (a: FoundationModels.Transcript.Segment, b: FoundationModels.Transcript.Segment) -> Swift.Bool
    public typealias ID = Swift.String
  public struct TextSegment : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var content: Swift.String
    public init(id: Swift.String = UUID().uuidString, content: Swift.String)
    public static func == (a: FoundationModels.Transcript.TextSegment, b: FoundationModels.Transcript.TextSegment) -> Swift.Bool
    public typealias ID = Swift.String
  public struct StructuredSegment : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var source: Swift.String
    public var content: FoundationModels.GeneratedContent {
    public init(id: Swift.String = UUID().uuidString, source: Swift.String, content: FoundationModels.GeneratedContent)
    public static func == (a: FoundationModels.Transcript.StructuredSegment, b: FoundationModels.Transcript.StructuredSegment) -> Swift.Bool
    public typealias ID = Swift.String
  public struct Instructions : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var segments: [FoundationModels.Transcript.Segment]
    public var toolDefinitions: [FoundationModels.Transcript.ToolDefinition]
    public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], toolDefinitions: [FoundationModels.Transcript.ToolDefinition])
    public static func == (a: FoundationModels.Transcript.Instructions, b: FoundationModels.Transcript.Instructions) -> Swift.Bool
    public typealias ID = Swift.String
  public struct ToolDefinition : Swift.Sendable, Swift.Equatable {
    public var name: Swift.String
    public var description: Swift.String
    public init(name: Swift.String, description: Swift.String, parameters: FoundationModels.GenerationSchema)
    public init(tool: some Tool)
    public static func == (lhs: FoundationModels.Transcript.ToolDefinition, rhs: FoundationModels.Transcript.ToolDefinition) -> Swift.Bool
  public struct Prompt : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var segments: [FoundationModels.Transcript.Segment]
    public var options: FoundationModels.GenerationOptions
    public var responseFormat: FoundationModels.Transcript.ResponseFormat?
    public init(id: Swift.String = UUID().uuidString, segments: [FoundationModels.Transcript.Segment], options: FoundationModels.GenerationOptions = GenerationOptions(), responseFormat: FoundationModels.Transcript.ResponseFormat? = nil)
    public static func == (a: FoundationModels.Transcript.Prompt, b: FoundationModels.Transcript.Prompt) -> Swift.Bool
    public typealias ID = Swift.String
  public struct ResponseFormat : Swift.Sendable, Swift.Equatable {
    public var name: Swift.String {
    public init<Content>(type: Content.Type) where Content : FoundationModels.Generable
    public init(schema: FoundationModels.GenerationSchema)
    public static func == (a: FoundationModels.Transcript.ResponseFormat, b: FoundationModels.Transcript.ResponseFormat) -> Swift.Bool
  public struct ToolCalls : Swift.Sendable, Swift.Identifiable, Swift.Equatable, Swift.RandomAccessCollection {
    public var id: Swift.String
    public init<S>(id: Swift.String = UUID().uuidString, _ calls: S) where S : Swift.Sequence, S.Element == FoundationModels.Transcript.ToolCall
    public subscript(position: Swift.Int) -> FoundationModels.Transcript.ToolCall {
    public var startIndex: Swift.Int {
    public var endIndex: Swift.Int {
    public static func == (a: FoundationModels.Transcript.ToolCalls, b: FoundationModels.Transcript.ToolCalls) -> Swift.Bool
    public typealias Element = FoundationModels.Transcript.ToolCall
    public typealias ID = Swift.String
    public typealias Index = Swift.Int
    public typealias Indices = Swift.Range<Swift.Int>
    public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript.ToolCalls>
    public typealias SubSequence = Swift.Slice<FoundationModels.Transcript.ToolCalls>
  public struct ToolCall : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var toolName: Swift.String
    public var arguments: FoundationModels.GeneratedContent {
    public init(id: Swift.String, toolName: Swift.String, arguments: FoundationModels.GeneratedContent)
    public static func == (a: FoundationModels.Transcript.ToolCall, b: FoundationModels.Transcript.ToolCall) -> Swift.Bool
    public typealias ID = Swift.String
  public struct ToolOutput : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var toolName: Swift.String
    public var segments: [FoundationModels.Transcript.Segment]
    public init(id: Swift.String, toolName: Swift.String, segments: [FoundationModels.Transcript.Segment])
    public static func == (a: FoundationModels.Transcript.ToolOutput, b: FoundationModels.Transcript.ToolOutput) -> Swift.Bool
    public typealias ID = Swift.String
  public struct Response : Swift.Sendable, Swift.Identifiable, Swift.Equatable {
    public var id: Swift.String
    public var assetIDs: [Swift.String]
    public var segments: [FoundationModels.Transcript.Segment]
    public init(id: Swift.String = UUID().uuidString, assetIDs: [Swift.String], segments: [FoundationModels.Transcript.Segment])
    public static func == (a: FoundationModels.Transcript.Response, b: FoundationModels.Transcript.Response) -> Swift.Bool
    public typealias ID = Swift.String
  public static func == (a: FoundationModels.Transcript, b: FoundationModels.Transcript) -> Swift.Bool
  public typealias Element = FoundationModels.Transcript.Entry
  public typealias Indices = Swift.Range<FoundationModels.Transcript.Index>
  public typealias Iterator = Swift.IndexingIterator<FoundationModels.Transcript>
  public typealias SubSequence = Swift.Slice<FoundationModels.Transcript>
extension FoundationModels.Transcript : Swift.Codable {
  public init(from decoder: any Swift.Decoder) throws
  public func encode(to encoder: any Swift.Encoder) throws
extension FoundationModels.Transcript.Entry : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.TextSegment : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.StructuredSegment : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.Segment : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.Instructions : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.Prompt : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.ResponseFormat : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.ToolCalls : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.ToolCall : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.ToolOutput : Swift.CustomStringConvertible {
  public var description: Swift.String {
extension FoundationModels.Transcript.Response : Swift.CustomStringConvertible {
  public var description: Swift.String {
public struct Instructions : Swift.Sendable {
  public init(_ content: some InstructionsRepresentable)
public protocol InstructionsRepresentable {
extension FoundationModels.Instructions : FoundationModels.InstructionsRepresentable {
  public var instructionsRepresentation: FoundationModels.Instructions {
extension Swift.String : FoundationModels.InstructionsRepresentable {
  public var instructionsRepresentation: FoundationModels.Instructions {
extension Swift.Array : FoundationModels.InstructionsRepresentable where Element : FoundationModels.InstructionsRepresentable {
  public var instructionsRepresentation: FoundationModels.Instructions {
extension FoundationModels.Instructions {
  public init(@FoundationModels.InstructionsBuilder _ content: () throws -> FoundationModels.Instructions) rethrows
public struct Prompt : Swift.Sendable {
  public init(_ content: some PromptRepresentable)
public protocol PromptRepresentable {
extension FoundationModels.Prompt : FoundationModels.PromptRepresentable {
  public var promptRepresentation: FoundationModels.Prompt {
extension Swift.String : FoundationModels.PromptRepresentable {
  public var promptRepresentation: FoundationModels.Prompt {
extension Swift.Array : FoundationModels.PromptRepresentable where Element : FoundationModels.PromptRepresentable {
  public var promptRepresentation: FoundationModels.Prompt {
extension FoundationModels.Prompt {
  public init(@FoundationModels.PromptBuilder _ content: () throws -> FoundationModels.Prompt) rethrows
public protocol Tool<Arguments, Output> : Swift.Sendable {
extension FoundationModels.Tool {
  public var name: Swift.String {
  public var includesSchemaInInstructions: Swift.Bool {
extension FoundationModels.Tool where Self.Arguments : FoundationModels.Generable {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Swift.String {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Swift.Int {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Swift.Double {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Swift.Float {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Foundation.Decimal {
  public var parameters: FoundationModels.GenerationSchema {
extension FoundationModels.Tool where Self.Arguments == Swift.Bool {
  public var parameters: FoundationModels.GenerationSchema {
public struct DynamicGenerationSchema : Swift.Sendable {
  public static var null: FoundationModels.DynamicGenerationSchema {
  public init(name: Swift.String, description: Swift.String? = nil, properties: [FoundationModels.DynamicGenerationSchema.Property])
  public init(name: Swift.String, description: Swift.String? = nil, representNilExplicitlyInGeneratedContent explicitNil: Swift.Bool, properties: [FoundationModels.DynamicGenerationSchema.Property])
  public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [FoundationModels.DynamicGenerationSchema])
  public init(name: Swift.String, description: Swift.String? = nil, anyOf choices: [Swift.String])
  public init(arrayOf itemSchema: FoundationModels.DynamicGenerationSchema, minimumElements: Swift.Int? = nil, maximumElements: Swift.Int? = nil)
  public init<Value>(type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable
  public init(referenceTo name: Swift.String)
  public struct Property {
    public init(name: Swift.String, description: Swift.String? = nil, schema: FoundationModels.DynamicGenerationSchema, isOptional: Swift.Bool = false)
public struct GenerationID : Swift.Sendable, Swift.Hashable {
  public init()
  public static func == (a: FoundationModels.GenerationID, b: FoundationModels.GenerationID) -> Swift.Bool
  public func hash(into hasher: inout Swift.Hasher)
  public var hashValue: Swift.Int {
public struct GenerationOptions : Swift.Sendable, Swift.Equatable {
  public struct SamplingMode : Swift.Sendable, Swift.Equatable {
    public static var greedy: FoundationModels.GenerationOptions.SamplingMode {
    public static func random(top k: Swift.Int, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode
    public static func random(probabilityThreshold: Swift.Double, seed: Swift.UInt64? = nil) -> FoundationModels.GenerationOptions.SamplingMode
    public static func == (a: FoundationModels.GenerationOptions.SamplingMode, b: FoundationModels.GenerationOptions.SamplingMode) -> Swift.Bool
  public var sampling: FoundationModels.GenerationOptions.SamplingMode?
  public var temperature: Swift.Double?
  public var maximumResponseTokens: Swift.Int?
  public init(sampling: FoundationModels.GenerationOptions.SamplingMode? = nil, temperature: Swift.Double? = nil, maximumResponseTokens: Swift.Int? = nil)
  public static func == (a: FoundationModels.GenerationOptions, b: FoundationModels.GenerationOptions) -> Swift.Bool
public struct GenerationSchema : Swift.Sendable, Swift.Codable, Swift.CustomDebugStringConvertible {
  public struct Property : Swift.Sendable {
    public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable
    public init<Value>(name: Swift.String, description: Swift.String? = nil, type: Value?.Type, guides: [FoundationModels.GenerationGuide<Value>] = []) where Value : FoundationModels.Generable
    public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])
    public init<RegexOutput>(name: Swift.String, description: Swift.String? = nil, type: Swift.String?.Type, guides: [_StringProcessing.Regex<RegexOutput>] = [])
  public var debugDescription: Swift.String {
  public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, properties: [FoundationModels.GenerationSchema.Property])
  public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, representNilExplicitlyInGeneratedContent explicitNil: Swift.Bool, properties: [FoundationModels.GenerationSchema.Property])
  public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf choices: [Swift.String])
  public init(type: any FoundationModels.Generable.Type, description: Swift.String? = nil, anyOf types: [any FoundationModels.Generable.Type])
  public init(root: FoundationModels.DynamicGenerationSchema, dependencies: [FoundationModels.DynamicGenerationSchema]) throws
  public enum SchemaError : Swift.Error, Foundation.LocalizedError {
    public struct Context : Swift.Sendable {
    public let debugDescription: Swift.String
    public init(debugDescription: Swift.String)
    case duplicateType(schema: Swift.String?, type: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)
    case duplicateProperty(schema: Swift.String, property: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)
    case emptyTypeChoices(schema: Swift.String, context: FoundationModels.GenerationSchema.SchemaError.Context)
    case undefinedReferences(schema: Swift.String?, references: [Swift.String], context: FoundationModels.GenerationSchema.SchemaError.Context)
    public var errorDescription: Swift.String? {
    public var recoverySuggestion: Swift.String? {
  public init(from decoder: any Swift.Decoder) throws
  public func encode(to encoder: any Swift.Encoder) throws
public struct LanguageModelFeedback {
  public enum Sentiment : Swift.Sendable, Swift.CaseIterable {
    case positive
    case negative
    case neutral
    public static func == (a: FoundationModels.LanguageModelFeedback.Sentiment, b: FoundationModels.LanguageModelFeedback.Sentiment) -> Swift.Bool
    public typealias AllCases = [FoundationModels.LanguageModelFeedback.Sentiment]
    nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Sentiment] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public struct Issue : Swift.Sendable {
    public enum Category : Swift.Sendable, Swift.CaseIterable {
    case unhelpful
    case tooVerbose
    case didNotFollowInstructions
    case incorrect
    case stereotypeOrBias
    case suggestiveOrSexual
    case vulgarOrOffensive
    case triggeredGuardrailUnexpectedly
    public static func == (a: FoundationModels.LanguageModelFeedback.Issue.Category, b: FoundationModels.LanguageModelFeedback.Issue.Category) -> Swift.Bool
    public typealias AllCases = [FoundationModels.LanguageModelFeedback.Issue.Category]
    nonisolated public static var allCases: [FoundationModels.LanguageModelFeedback.Issue.Category] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    public init(category: FoundationModels.LanguageModelFeedback.Issue.Category, explanation: Swift.String? = nil)
extension FoundationModels.LanguageModelSession {
  final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredOutput: FoundationModels.Transcript.Entry? = nil) -> Foundation.Data
  final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseText: Swift.String?) -> Foundation.Data {
  final public func logFeedbackAttachment(sentiment: FoundationModels.LanguageModelFeedback.Sentiment?, issues: [FoundationModels.LanguageModelFeedback.Issue] = [], desiredResponseContent: (any FoundationModels.ConvertibleToGeneratedContent)?) -> Foundation.Data {
extension FoundationModels.SystemLanguageModel.Availability.UnavailableReason : Swift.Hashable {}
extension FoundationModels.LanguageModelFeedback.Sentiment : Swift.Equatable {}
extension FoundationModels.LanguageModelFeedback.Sentiment : Swift.Hashable {}
extension FoundationModels.LanguageModelFeedback.Issue.Category : Swift.Equatable {}
extension FoundationModels.LanguageModelFeedback.Issue.Category : Swift.Hashable {}
```

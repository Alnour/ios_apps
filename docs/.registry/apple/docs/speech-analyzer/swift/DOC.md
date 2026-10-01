---
name: speech-analyzer
description: "On-device speech-to-text with SpeechAnalyzer + SpeechTranscriber (Speech framework, iOS 26): asset install, file and live transcription, results stream"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,speech,transcription,speechanalyzer,on-device"
---

# On-device speech-to-text — SpeechAnalyzer / SpeechTranscriber (iOS 26)

The modern Speech API (replaces `SFSpeechRecognizer` for new code). Fully on device, no
per-request permission for speech, but the **microphone** needs `NSMicrophoneUsageDescription`
and `AVAudioApplication.requestRecordPermission()`.

## How our apps use it

- **File-based transcription after recording** (simplest, keeps the audio for playback):
  ```swift
  guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: .current) else { throw Unsupported() }
  let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)
  // REQUIRED: reserve the locale first, or asset requests fail with "<bundle id> is not subscribed to transcription.en"
  if await !AssetInventory.reservedLocales.contains(where: { $0.identifier == locale.identifier }) {
      _ = try await AssetInventory.reserve(locale: locale)
  }
  if await AssetInventory.status(forModules: [transcriber]) != .installed,
     let req = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
      try await req.downloadAndInstall()          // first run only; show progress
  }
  let analyzer = SpeechAnalyzer(modules: [transcriber])
  let collect = Task { var text = ""; for try await r in transcriber.results where r.isFinal { text += String(r.text.characters) }; return text }
  let file = try AVAudioFile(forReading: url)
  if let last = try await analyzer.analyzeSequence(from: file) { try await analyzer.finalizeAndFinish(through: last) }
  else { await analyzer.cancelAndFinishNow() }
  let transcript = try await collect.value
  ```
- Results arrive as `SpeechTranscriber.Result` with `text: AttributedString` and `isFinal`.
  Non-final results are volatile (may be revised) — only use them for live UI.
- Live mic transcription: `AVAudioEngine` input tap → `AnalyzerInputConverter(analyzerFormat:)`
  → `AsyncStream<AnalyzerInput>` → `analyzer.analyzeSequence(stream)`.
- The system limits concurrent analyzers; one at a time per app is the safe default.
- Audio format: ask `SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith:)` when converting
  yourself; `analyzeSequence(from: AVAudioFile)` converts for you.

## Reference (developer.apple.com, fetched 2026-10-01)

### SpeechAnalyzer  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/speechanalyzer.md>


Analyzes spoken audio content in various ways and manages the analysis session.

```
final actor SpeechAnalyzer
```

#### Overview

The Speech framework provides several modules that can be added to an analyzer to provide specific types of analysis and transcription. Many use cases only need a [`SpeechTranscriber`](/documentation/Speech/SpeechTranscriber) module, which performs speech-to-text transcriptions.

The `SpeechAnalyzer` class is responsible for:

- Holding associated modules
- Accepting audio speech input
- Controlling the overall analysis

Each module is responsible for:

- Providing guidance on acceptable input
- Providing its analysis or transcription output

Analysis is asynchronous. Input, output, and session control are decoupled and typically occur over several different tasks created by you or by the session. In particular, where an Objective-C API might use a delegate to provide results to you, the Swift API’s modules provides their results via an `AsyncSequence`. Similarly, you provide speech input to this API via an `AsyncSequence` you create and populate.

The analyzer can only analyze one input sequence at a time.

##### Perform analysis

To perform analysis on audio files and streams, follow these general steps:

1. Create and configure the necessary modules.
2. Ensure the relevant assets are installed or already present. See [`AssetInventory`](/documentation/Speech/AssetInventory).
3. Create an input sequence you can use to provide the spoken audio. See helper classes [`AssetInputSequenceProvider`](/documentation/Speech/AssetInputSequenceProvider) and [`CaptureInputSequenceProvider`](/documentation/Speech/CaptureInputSequenceProvider).
4. Create and configure the analyzer with the modules and input sequence.
5. Supply audio. See helper class [`AnalyzerInputConverter`](/documentation/Speech/AnalyzerInputConverter).
6. Start analysis.
7. Act on results.
8. Finish analysis when desired.

This example shows how you could perform an analysis that transcribes audio using the `SpeechTranscriber` module:

```swift
import Speech

// Step 1: Modules
guard let locale = SpeechTranscriber.supportedLocale(equivalentTo: Locale.current) else {
    /* Note unsupported language */
}
let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)

// Step 2: Assets
if let installationRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
    try await installationRequest.downloadAndInstall()
}

// Step 3: Input sequence
let (inputSequence, inputBuilder) = AsyncStream.makeStream(of: AnalyzerInput.self)

// Step 4: Analyzer
let audioFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
let analyzer = SpeechAnalyzer(modules: [transcriber])

// Step 5: Supply audio
let converter = AnalyzerInputConverter(analyzerFormat: audioFormat)
Task {
    while /* audio remains */ {
        let buffer = /* Get some audio */
        let inputs = try converter.convert(buffer, at: nil)
        for input in inputs {
            inputBuilder.yield(input)
        }
    }
    let inputs = try converter.flush()
    for input in inputs {
        inputBuilder.yield(input)
    }
    inputBuilder.finish()
}

// Step 7: Act on results
Task {
    do {
        for try await result in transcriber.results {
            let bestTranscription = result.text // an AttributedString
            let plainTextBestTranscription = String(bestTranscription.characters) // a String
            print(plainTextBestTranscription)
        }
    } catch {
        /* Handle error */
    }
}

// Step 6: Perform analysis
let lastSampleTime = try await analyzer.analyzeSequence(inputSequence)

// Step 8: Finish analysis
if let lastSampleTime {
    try await analyzer.finalizeAndFinish(through: lastSampleTime)
} else {
    try analyzer.cancelAndFinishNow()
}
```

##### Analyze audio from files or capture devices

To read audio from a file, asset, or capture device such as a microphone, create an [`AssetInputSequenceProvider`](/documentation/Speech/AssetInputSequenceProvider) or [`CaptureInputSequenceProvider`](/documentation/Speech/CaptureInputSequenceProvider) object.

Get the provider object’s [`analyzerInputs`](/documentation/Speech/AssetInputSequenceProvider/analyzerInputs) or [`analyzerInputs`](/documentation/Speech/CaptureInputSequenceProvider/analyzerInputs) property to convert the source’s audio to a supported format and obtain an asynchronous input sequence of the audio. Pass that sequence to [`analyzeSequence(_:)`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(_:)), [`start(inputSequence:)`](/documentation/Speech/SpeechAnalyzer/start(inputSequence:)), or a similar parameter of the analyzer’s initializer.

To end the analysis session after processing the audio track or captured audio, call one of the analyzer’s `finish` methods. Otherwise, by default, the analyzer won’t terminate its result streams and will wait for additional audio input sequences or buffers. See the “Finish analysis” section below for more details.

##### Analyze audio from audio buffers

You can analyze audio buffers directly without using [`AssetInputSequenceProvider`](/documentation/Speech/AssetInputSequenceProvider) or [`CaptureInputSequenceProvider`](/documentation/Speech/CaptureInputSequenceProvider).

To do this:

1. Create an asynchronous input sequence of [`AnalyzerInput`](/documentation/Speech/AnalyzerInput) elements that is appropriate for your use case.
2. Supply the input sequence to [`analyzeSequence(_:)`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(_:)), [`start(inputSequence:)`](/documentation/Speech/SpeechAnalyzer/start(inputSequence:)), or a similar parameter of the analyzer’s initializer.
3. Convert each audio buffer to a supported audio format, either on the fly or in advance.
4. Create [`AnalyzerInput`](/documentation/Speech/AnalyzerInput) objects for each buffer.
5. Add the `AnalyzerInput` objects to the input sequence.

To convert `AVAudioBuffer` audio buffers to a supported format as `AnalyzerInput` objects on the fly, use [`AnalyzerInputConverter`](/documentation/Speech/AnalyzerInputConverter).

To convert audio buffers to a supported format in advance or with some other technique:

1. Detemine the format to convert to by calling [`bestAvailableAudioFormat(compatibleWith:)`](/documentation/Speech/SpeechAnalyzer/bestAvailableAudioFormat(compatibleWith:)) or individual modules’ [`availableCompatibleAudioFormats`](/documentation/Speech/SpeechModule/availableCompatibleAudioFormats) methods
2. Convert the audio and create `AnalyzerInput` objects as necessary

To skip past part of an audio stream, omit the buffers you want to skip from the input sequence. You can resume with a later buffer.

When you resume analysis with a later `AVAudioPCMBuffer` buffer, you may need to supply the correct time-code to account for skipped audio. To do this, pass the time-code of the later buffer as the `bufferStartTime` parameter of the corresponding `AnalyzerInput` object.

##### Analyze autonomously

You can and usually should perform analysis using the [`analyzeSequence(_:)`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(_:)) or [`analyzeSequence(from:)`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(from:)) methods; those methods work well with Swift structured concurrency techniques. However, you may prefer that the analyzer proceed independently and perform its analysis autonomously as audio input becomes available in a task managed by the analyzer itself.

To use this capability, create the analyzer with one of the initializers that has an input sequence or file parameter, or call [`start(inputSequence:)`](/documentation/Speech/SpeechAnalyzer/start(inputSequence:)) or [`start(inputAudioFile:finishAfterFile:)`](/documentation/Speech/SpeechAnalyzer/start(inputAudioFile:finishAfterFile:)). To end the analysis of that input only and start analysis of different input, call one of the `start` methods again. To end the analysis session when the input ends, call [`finalizeAndFinishThroughEndOfInput()`](/documentation/Speech/SpeechAnalyzer/finalizeAndFinishThroughEndOfInput()).

##### Control processing and timing of results

Modules deliver results periodically, but you can manually synchronize their processing and delivery to outside cues.

To deliver a result for a particular time-code, call [`finalize(through:)`](/documentation/Speech/SpeechAnalyzer/finalize(through:)). To cancel processing of results that are no longer of interest, call [`cancelAnalysis(before:)`](/documentation/Speech/SpeechAnalyzer/cancelAnalysis(before:)).

##### Improve responsiveness

By default, the analyzer and modules load the system resources that they require lazily, and unload those resources when they’re deallocated.

To proactively load system resources and “preheat” the analyzer, call [`prepareToAnalyze(in:)`](/documentation/Speech/SpeechAnalyzer/prepareToAnalyze(in:)) after setting its modules. This may improve how quickly the modules return their first results.

To delay or prevent unloading an analyzer’s resources — caching them for later use by a different analyzer instance — you can select a [`SpeechAnalyzer.Options.ModelRetention`](/documentation/Speech/SpeechAnalyzer/Options/ModelRetention-swift.enum) option and create the analyzer with an appropriate [`SpeechAnalyzer.Options`](/documentation/Speech/SpeechAnalyzer/Options) object.

To set the priority of analysis work, create the analyzer with a [`SpeechAnalyzer.Options`](/documentation/Speech/SpeechAnalyzer/Options) object with the desired `priority` value.

Specific modules may also offer options that improve responsiveness.

##### Finish analysis

To end an analysis session, you must use one of the analyzer’s `finish` methods or parameters, or deallocate the analyzer.

When the analysis session transitions to the *finished* state:

- The analyzer won’t consume additional input from the input sequence (but note that it doesn’t drain or terminate the sequence)
- Most methods won’t do anything; in particular, the analyzer won’t accept different input sequences or modules
- Module result streams terminate and modules won’t publish additional results, though the app can continue to iterate over already-published results

> Note: While you can terminate the input sequence you created with a method such as `AsyncStream.Continuation.finish()`, terminating the input sequence does *not* generally finish the analysis session, and you can continue the session with a different input sequence. (See ``doc://com.apple.speech/documentation/Speech/SpeechAnalyzer/finalizeAndFinishThroughEndOfInput()`` for an exception.)

##### Respond to errors

When the analyzer or its modules’ result streams throw an error, the analysis session becomes finished as described above, and the same error (or a `CancellationError`) is thrown from all waiting methods and result streams.

When this happens, you may wish to terminate the input sequence, or create a new analyzer to continue working on the remaining (and any additional) input.

##### Manage simultaneous analyses

The system normally limits simultaneous analyses to a conservative number, considering hardware capabilities of different devices. If you exceed that number, the system throws an [`insufficientResources`](/documentation/Speech/SFSpeechError/Code/insufficientResources) error.

However, under certain use cases, the hardware may be able to accommodate additional simultaneous analyses; for example, several simultaneous transcription sessions may use the same language and settings, or only receive audio in an interleaved schedule. To support these use cases, you can override the system to ignore the predefined conservative system resource limits.

To override the normal limits, create an analyzer with a [`SpeechAnalyzer.Options`](/documentation/Speech/SpeechAnalyzer/Options) object with its [`ignoresResourceLimits`](/documentation/Speech/SpeechAnalyzer/Options/ignoresResourceLimits) value set to `true`. The system allows an unlimited number of analyzers configured with this option. However, the hardware requirements of numerous analyzers will eventually exceed the system’s actual capacity, and one or more of the analyzers will fail, throwing an unpredictable error.

> Warning: When using this option, test your app on a variety of devices under a variety of scenarios to experimentally determine how many analyzers you can reliably create and expect to function. Consider how to recover in the event one or more analyzers fail.

#### Topics

##### Creating an analyzer

[`convenience init(modules: [any SpeechModule], options: SpeechAnalyzer.Options?)`](/documentation/Speech/SpeechAnalyzer/init(modules:options:))

Creates an analyzer.

[`convenience init<InputSequence>(inputSequence: InputSequence, modules: [any SpeechModule], options: SpeechAnalyzer.Options?, analysisContext: AnalysisContext, volatileRangeChangedHandler: sending ((CMTimeRange, Bool, Bool) -> Void)?)`](/documentation/Speech/SpeechAnalyzer/init(inputSequence:modules:options:analysisContext:volatileRangeChangedHandler:))

Creates an analyzer and begins analysis.

[`convenience init(inputAudioFile: AVAudioFile, modules: [any SpeechModule], options: SpeechAnalyzer.Options?, analysisContext: AnalysisContext, finishAfterFile: Bool, volatileRangeChangedHandler: sending ((CMTimeRange, Bool, Bool) -> Void)?) async throws`](/documentation/Speech/SpeechAnalyzer/init(inputAudioFile:modules:options:analysisContext:finishAfterFile:volatileRangeChangedHandler:))

Creates an analyzer and begins analysis on an audio file.

[`struct Options`](/documentation/Speech/SpeechAnalyzer/Options)

Analysis processing options.

##### Managing modules

[`func setModules([any SpeechModule]) async throws`](/documentation/Speech/SpeechAnalyzer/setModules(_:))

Adds or removes modules.

[`var modules: [any SpeechModule]`](/documentation/Speech/SpeechAnalyzer/modules)

The modules performing analysis on the audio input.

##### Performing analysis

[`func analyzeSequence<InputSequence>(InputSequence) async throws -> CMTime?`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(_:))

Analyzes an input sequence, returning when the sequence terminates.

[`func analyzeSequence(from: AVAudioFile) async throws -> CMTime?`](/documentation/Speech/SpeechAnalyzer/analyzeSequence(from:))

Analyzes an input sequence created from an audio file, returning when the file has been read.

##### Performing autonomous analysis

[`func start<InputSequence>(inputSequence: InputSequence) async throws`](/documentation/Speech/SpeechAnalyzer/start(inputSequence:))

Starts analysis of an input sequence and returns immediately.

[`func start(inputAudioFile: AVAudioFile, finishAfterFile: Bool) async throws`](/documentation/Speech/SpeechAnalyzer/start(inputAudioFile:finishAfterFile:))

Starts analysis of an input sequence created from an audio file and returns immediately.

##### Finalizing and cancelling results

[`func cancelAnalysis(before: CMTime)`](/documentation/Speech/SpeechAnalyzer/cancelAnalysis(before:))

Stops analyzing audio predating the given time.

[`func finalize(through: CMTime?) async throws`](/documentation/Speech/SpeechAnalyzer/finalize(through:))

Finalizes the modules’ analyses.

##### Finishing analysis

[`func cancelAndFinishNow() async`](/documentation/Speech/SpeechAnalyzer/cancelAndFinishNow())

Finishes analysis immediately.

[`func finalizeAndFinishThroughEndOfInput() async throws`](/documentation/Speech/SpeechAnalyzer/finalizeAndFinishThroughEndOfInput())

Finishes analysis after an audio input sequence has been terminated and fully consumed and the modules’ results are finalized.

[`func finalizeAndFinish(through: CMTime) async throws`](/documentation/Speech/SpeechAnalyzer/finalizeAndFinish(through:))

Finishes analysis after finalizing results for a given time-code.

[`func finish(after: CMTime) async throws`](/documentation/Speech/SpeechAnalyzer/finish(after:))

Finishes analysis once input for a given time is consumed.

##### Determining audio formats

[`static func bestAvailableAudioFormat(compatibleWith: [any SpeechModule]) async -> AVAudioFormat?`](/documentation/Speech/SpeechAnalyzer/bestAvailableAudioFormat(compatibleWith:))

Retrieves the best-quality audio format that the specified modules can work with, from assets installed on the device.

[`static func bestAvailableAudioFormat(compatibleWith: [any SpeechModule], considering: AVAudioFormat?) async -> AVAudioFormat?`](/documentation/Speech/SpeechAnalyzer/bestAvailableAudioFormat(compatibleWith:considering:))

Retrieves the best-quality audio format that the specified modules can work with, taking into account the natural format of the audio and assets installed on the device.

##### Improving responsiveness

[`func prepareToAnalyze(in: AVAudioFormat?) async throws`](/documentation/Speech/SpeechAnalyzer/prepareToAnalyze(in:))

Prepares the analyzer to begin work with minimal startup delay.

[`func prepareToAnalyze(in: AVAudioFormat?, withProgressReadyHandler: sending ((Progress) -> Void)?) async throws`](/documentation/Speech/SpeechAnalyzer/prepareToAnalyze(in:withProgressReadyHandler:))

Prepares the analyzer to begin work with minimal startup delay, reporting the progress of that preparation.

##### Monitoring analysis

[`func setVolatileRangeChangedHandler(sending ((CMTimeRange, Bool, Bool) -> Void)?)`](/documentation/Speech/SpeechAnalyzer/setVolatileRangeChangedHandler(_:))

A closure that the analyzer calls when the volatile range changes.

[`var volatileRange: CMTimeRange?`](/documentation/Speech/SpeechAnalyzer/volatileRange)

The range of results that can change.

##### Managing contexts

[`func setContext(AnalysisContext) async throws`](/documentation/Speech/SpeechAnalyzer/setContext(_:))

Sets contextual information to improve or inform the analysis.

[`var context: AnalysisContext`](/documentation/Speech/SpeechAnalyzer/context)

An object containing contextual information.

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`Actor`](/documentation/Swift/Actor)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### SpeechTranscriber  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/speechtranscriber.md>


A speech-to-text transcription module that’s appropriate for normal conversation and general purposes.

```
final class SpeechTranscriber
```

#### Overview

Several transcriber instances can share the same backing engine instances and models, so long as the transcribers are configured similarly in certain respects.

##### Check device support

Use the [`isAvailable`](/documentation/Speech/SpeechTranscriber/isAvailable) or [`supportedLocales`](/documentation/Speech/SpeechTranscriber/supportedLocales) properties to see if the current device supports the speech-to-text models used by `SpeechTranscriber`. If it does not, consider disabling the feature or using [`DictationTranscriber`](/documentation/Speech/DictationTranscriber) instead.

#### Topics

##### Creating a transcriber

[`convenience init(locale: Locale, preset: SpeechTranscriber.Preset)`](/documentation/Speech/SpeechTranscriber/init(locale:preset:))

Creates a general-purpose transcriber according to a preset.

[`convenience init(locale: Locale, transcriptionOptions: Set<SpeechTranscriber.TranscriptionOption>, reportingOptions: Set<SpeechTranscriber.ReportingOption>, attributeOptions: Set<SpeechTranscriber.ResultAttributeOption>)`](/documentation/Speech/SpeechTranscriber/init(locale:transcriptionOptions:reportingOptions:attributeOptions:))

Creates a general-purpose transcriber.

[`struct Preset`](/documentation/Speech/SpeechTranscriber/Preset)

Predefined transcriber configurations.

##### Configuring transcription

[`enum ReportingOption`](/documentation/Speech/SpeechTranscriber/ReportingOption)

Options relating to the transcriber’s result delivery.

[`enum ResultAttributeOption`](/documentation/Speech/SpeechTranscriber/ResultAttributeOption)

Options relating to the attributes of the transcription.

[`enum TranscriptionOption`](/documentation/Speech/SpeechTranscriber/TranscriptionOption)

Options relating to the text of the transcription.

##### Checking device support

[`static var isAvailable: Bool`](/documentation/Speech/SpeechTranscriber/isAvailable)

A Boolean value that indicates whether this module is available given the device’s hardware and capabilities.

##### Checking locale support

[`static var installedLocales: [Locale]`](/documentation/Speech/SpeechTranscriber/installedLocales)

The locales that the transcriber can transcribe into, considering only locales that are installed on the device.

[`static var supportedLocales: [Locale]`](/documentation/Speech/SpeechTranscriber/supportedLocales)

The locales that the transcriber can transcribe into, including locales that may not be installed but are downloadable.

[`static func supportedLocale(equivalentTo: Locale) async -> Locale?`](/documentation/Speech/SpeechTranscriber/supportedLocale(equivalentTo:))

A locale from the module’s supported locales equivalent to the given locale.

##### Checking audio format support

##### Getting results

[`var results: some Sendable & AsyncSequence<SpeechTranscriber.Result, any Error>`](/documentation/Speech/SpeechTranscriber/results)

The asynchronous sequence of transcription results.

[`struct Result`](/documentation/Speech/SpeechTranscriber/Result)

A phrase or passage of transcribed speech. The phrases are sent in order.

##### Inspecting the transcriber

#### Relationships

##### Conforms To

[`SpeechModule`](/documentation/Speech/SpeechModule)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Sendable`](/documentation/Swift/Sendable)

[`LocaleDependentSpeechModule`](/documentation/Speech/LocaleDependentSpeechModule)

### AssetInventory  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/assetinventory.md>


Manages the assets that are necessary for transcription or other analyses.

```
final class AssetInventory
```

#### Overview

Before using the [`SpeechAnalyzer`](/documentation/Speech/SpeechAnalyzer) class, you must install assets required by the modules you plan to use. These assets are machine-learning models downloaded from Apple’s servers and managed by the system. Once you download, install, or use an asset, the system retains and updates it automatically, and shares it with other apps. The system makes a certain number of locale-specific asset reservations available to your app to limit storage space and network usage.

Your app does not work with assets directly. Instead, your app configures module objects. The system uses the modules’ configuration to determine what assets are relevant.

##### Install assets

Installing an asset is a four-step process:

1. Create analyzer modules in the configurations that you wish to use. These modules can be discarded when no longer needed; the system installs assets using the modules’ configuration, not their object identity.
2. Assign your app’s asset reservations to those locales. The class does this automatically if needed, but you can also call [`reserve(locale:)`](/documentation/Speech/AssetInventory/reserve(locale:)) to do this manually. This step is only necessary for modules with locale-specific assets; that is, modules conforming to [`LocaleDependentSpeechModule`](/documentation/Speech/LocaleDependentSpeechModule). You can skip this step for other modules.
3. Start downloading the required assets for the modules’ configuration. Call [`assetInstallationRequest(supporting:)`](/documentation/Speech/AssetInventory/assetInstallationRequest(supporting:)) to obtain an instance of [`AssetInstallationRequest`](/documentation/Speech/AssetInstallationRequest) and call its [`downloadAndInstall()`](/documentation/Speech/AssetInstallationRequest/downloadAndInstall()) method.
4. Wait for the download to finish. Note that the download may finish immediately; the assets may have already been downloaded if the assets were preinstalled on the system, another app already downloaded them, or a previous module configuration used the same assets.

Once assets are downloaded, they persist between app launches and are shared between apps. The system may unsubscribe your app from assets that haven’t been used in a while.

##### Manage assets

When your app no longer needs assets for a particular locale, call [`release(reservedLocale:)`](/documentation/Speech/AssetInventory/release(reservedLocale:)) to free up that reservation. The system will remove the assets at a later time.

#### Topics

##### Downloading and installing assets

[`static func assetInstallationRequest(supporting: [any SpeechModule]) async throws -> AssetInstallationRequest?`](/documentation/Speech/AssetInventory/assetInstallationRequest(supporting:))

Returns an installation request object, which is used to initiate the asset download and monitor its progress.

##### Managing allocations

[`static func reserve(locale: Locale) async throws -> Bool`](/documentation/Speech/AssetInventory/reserve(locale:))

Add an asset locale to the app’s current reservations.

[`static func release(reservedLocale: Locale) async -> Bool`](/documentation/Speech/AssetInventory/release(reservedLocale:))

Removes an asset locale reservation.

[`static var reservedLocales: [Locale]`](/documentation/Speech/AssetInventory/reservedLocales)

The app’s current asset locale reservations.

[`static var maximumReservedLocales: Int`](/documentation/Speech/AssetInventory/maximumReservedLocales)

The number of locale reservations permitted to an app.

##### Checking asset status

[`static func status(forModules: [any SpeechModule]) async -> AssetInventory.Status`](/documentation/Speech/AssetInventory/status(forModules:))

Returns the status for the list of modules.

[`enum Status`](/documentation/Speech/AssetInventory/Status)

### AnalyzerInput  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/analyzerinput.md>


Time-coded audio data.

```
struct AnalyzerInput
```

#### Overview

The audio data must have an audio format that is supported by the analyzer’s modules; the analyzer does not perform audio conversion. Call [`bestAvailableAudioFormat(compatibleWith:considering:)`](/documentation/Speech/SpeechAnalyzer/bestAvailableAudioFormat(compatibleWith:considering:)) (or its variants) to select an appropriate format to convert to.

The audio format may differ from one `AnalyzerInput` object to the next. If the new audio format is supported by the modules, the modules will be reconfigured as needed.

#### Topics

##### Creating an input element

[`init(buffer: CMReadySampleBuffer<CMReadOnlyDataBlockBuffer>)`](/documentation/Speech/AnalyzerInput/init(buffer:)-3nt02)

Creates an audio input object.

[`init(buffer: AVAudioPCMBuffer)`](/documentation/Speech/AnalyzerInput/init(buffer:)-2ysg3)

Creates an audio input object.

[`init(buffer: AVAudioPCMBuffer, bufferStartTime: CMTime?)`](/documentation/Speech/AnalyzerInput/init(buffer:bufferStartTime:))

Creates an audio input object for audio that may be discontiguous with previous input.

##### Inspecting an input element

[`let bufferStartTime: CMTime?`](/documentation/Speech/AnalyzerInput/bufferStartTime)

The time-code of this input.

[`let bufferDuration: CMTime`](/documentation/Speech/AnalyzerInput/bufferDuration)

The length of this input.

[`let bufferFormat: AVAudioFormat`](/documentation/Speech/AnalyzerInput/bufferFormat)

The audio format of this input.

[`var buffer: AVAudioPCMBuffer`](/documentation/Speech/AnalyzerInput/buffer)

A new copy of the audio data for this input.

#### Relationships

##### Conforms To

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

### AnalyzerInputConverter  
*iOS: 27.0.0 -* · <https://developer.apple.com/documentation/speech/analyzerinputconverter.md>


Converts audio buffers to a format suitable for analysis by a speech analyzer.

```
final class AnalyzerInputConverter
```

#### Topics

##### Creating a converter

[`static func converter(compatibleWith: [any SpeechModule]) async throws -> AnalyzerInputConverter`](/documentation/Speech/AnalyzerInputConverter/converter(compatibleWith:))

Returns an audio input converter compatible with the given modules.

[`init(analyzerFormat: AVAudioFormat, configurationHandler: ((AVAudioConverter) -> Void)?)`](/documentation/Speech/AnalyzerInputConverter/init(analyzerFormat:configurationHandler:))

Creates an audio input converter.

##### Converting a buffer

[`func convert(AVAudioBuffer, at: AVAudioTime?) throws -> [AnalyzerInput]`](/documentation/Speech/AnalyzerInputConverter/convert(_:at:))

Converts an audio buffer.

[`func flush() throws -> [AnalyzerInput]`](/documentation/Speech/AnalyzerInputConverter/flush())

Completes pending audio conversions.

### SpeechModule  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/speechmodule.md>


Protocol that all analyzer modules conform to.

```
protocol SpeechModule : AnyObject, Sendable
```

#### Topics

##### Checking audio format support

[`var availableCompatibleAudioFormats: [AVAudioFormat]`](/documentation/Speech/SpeechModule/availableCompatibleAudioFormats)

The audio formats that this module is able to analyze, given its configuration.

##### Getting results

[`var results: Self.Results`](/documentation/Speech/SpeechModule/results-swift.property)

An asynchronous sequence containing this module’s analysis results. Results are added to the sequence as they are created.

[`associatedtype Result : SpeechModuleResult, Sendable`](/documentation/Speech/SpeechModule/Result)

[`associatedtype Results : Sendable, AsyncSequence`](/documentation/Speech/SpeechModule/Results-swift.associatedtype)

#### Relationships

##### Inherits From

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Sendable`](/documentation/Swift/Sendable)

##### Conforming Types

[`SpeechTranscriber`](/documentation/Speech/SpeechTranscriber)

[`SpeechDetector`](/documentation/Speech/SpeechDetector)

[`DictationTranscriber`](/documentation/Speech/DictationTranscriber)

##### Inherited By

[`LocaleDependentSpeechModule`](/documentation/Speech/LocaleDependentSpeechModule)

### SpeechTranscriber.Result  
*iOS: 26.0.0 -* · <https://developer.apple.com/documentation/speech/speechtranscriber/result.md>


A phrase or passage of transcribed speech. The phrases are sent in order.

```
struct Result
```

#### Overview

If the transcriber is configured to send volatile results, each phrase is sent one or more times as the interpretation gets better and better until it is finalized.

#### Topics

##### Getting transcriptions

[`let alternatives: [AttributedString]`](/documentation/Speech/SpeechTranscriber/Result/alternatives)

All the alternative interpretations of the audio in this range. The interpretations are in descending order of likelihood.

[`var text: AttributedString`](/documentation/Speech/SpeechTranscriber/Result/text)

The most likely interpretation of the audio in this range.

##### Working with transcriptions

  <doc://com.apple.documentation/documentation/Foundation/AttributeScopes/SpeechAttributes/TimeRangeAttribute>

  <doc://com.apple.documentation/documentation/Foundation/AttributeScopes/SpeechAttributes/ConfidenceAttribute>

  <doc://com.apple.documentation/documentation/Foundation/AttributedString/rangeOfAudioTimeRangeAttributes(intersecting:)>

##### Getting audio range

[`var range: CMTimeRange`](/documentation/Speech/SpeechModuleResult/range)

The audio input range that this result applies to.

##### Getting finalization state

[`var isFinal: Bool`](/documentation/Speech/SpeechModuleResult/isFinal)

Whether this result is final at the time it is produced.

[`var resultsFinalizationTime: CMTime`](/documentation/Speech/SpeechModuleResult/resultsFinalizationTime)

The audio input time up to which results from this module have been finalized (after this result). The module’s results are final up to but not including this time.

#### Relationships

##### Conforms To

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Sendable`](/documentation/Swift/Sendable)

[`Hashable`](/documentation/Swift/Hashable)

[`Equatable`](/documentation/Swift/Equatable)

[`SpeechModuleResult`](/documentation/Speech/SpeechModuleResult)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)


## SDK signatures (Speech, iOS 26.5 swiftinterface — ground truth)

```swift
public import Swift
public import _Concurrency
public import _StringProcessing
public import _SwiftConcurrencyShims
final public class AssetInventory {
  public static var maximumReservedLocales: Swift.Int {
  public static var reservedLocales: [Foundation.Locale] {
  public static func reserve(locale: Foundation.Locale) async throws -> Swift.Bool
  public static func release(reservedLocale: Foundation.Locale) async -> Swift.Bool
  public enum Status : Swift.Comparable {
    case unsupported
    case supported
    case downloading
    case installed
    public static func < (a: Speech.AssetInventory.Status, b: Speech.AssetInventory.Status) -> Swift.Bool
    public static func == (a: Speech.AssetInventory.Status, b: Speech.AssetInventory.Status) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public static func status(forModules modules: [any Speech.SpeechModule]) async -> Speech.AssetInventory.Status
  public static func assetInstallationRequest(supporting modules: [any Speech.SpeechModule]) async throws -> Speech.AssetInstallationRequest?
public protocol LocaleDependentSpeechModule : Speech.SpeechModule {
final public class DictationTranscriber : Speech.SpeechModule, Speech.LocaleDependentSpeechModule {
  public struct Preset : Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public static let phrase: Speech.DictationTranscriber.Preset
    public static let shortDictation: Speech.DictationTranscriber.Preset
    public static let progressiveShortDictation: Speech.DictationTranscriber.Preset
    public static let longDictation: Speech.DictationTranscriber.Preset
    public static let progressiveLongDictation: Speech.DictationTranscriber.Preset
    public static let timeIndexedLongDictation: Speech.DictationTranscriber.Preset
    public init(contentHints: Swift.Set<Speech.DictationTranscriber.ContentHint>, transcriptionOptions: Swift.Set<Speech.DictationTranscriber.TranscriptionOption>, reportingOptions: Swift.Set<Speech.DictationTranscriber.ReportingOption>, attributeOptions: Swift.Set<Speech.DictationTranscriber.ResultAttributeOption>)
    public var contentHints: Swift.Set<Speech.DictationTranscriber.ContentHint>
    public var transcriptionOptions: Swift.Set<Speech.DictationTranscriber.TranscriptionOption>
    public var reportingOptions: Swift.Set<Speech.DictationTranscriber.ReportingOption>
    public var attributeOptions: Swift.Set<Speech.DictationTranscriber.ResultAttributeOption>
    public static func == (a: Speech.DictationTranscriber.Preset, b: Speech.DictationTranscriber.Preset) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public struct ContentHint : Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public static let shortForm: Speech.DictationTranscriber.ContentHint
    public static let farField: Speech.DictationTranscriber.ContentHint
    public static let atypicalSpeech: Speech.DictationTranscriber.ContentHint
    public static func customizedLanguage(modelConfiguration: Speech.SFSpeechLanguageModel.Configuration) -> Speech.DictationTranscriber.ContentHint
    public static func == (a: Speech.DictationTranscriber.ContentHint, b: Speech.DictationTranscriber.ContentHint) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum TranscriptionOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case punctuation
    case emoji
    case etiquetteReplacements
    public static func == (a: Speech.DictationTranscriber.TranscriptionOption, b: Speech.DictationTranscriber.TranscriptionOption) -> Swift.Bool
    public typealias AllCases = [Speech.DictationTranscriber.TranscriptionOption]
    nonisolated public static var allCases: [Speech.DictationTranscriber.TranscriptionOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum ReportingOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case volatileResults
    case alternativeTranscriptions
    case frequentFinalization
    public static func == (a: Speech.DictationTranscriber.ReportingOption, b: Speech.DictationTranscriber.ReportingOption) -> Swift.Bool
    public typealias AllCases = [Speech.DictationTranscriber.ReportingOption]
    nonisolated public static var allCases: [Speech.DictationTranscriber.ReportingOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum ResultAttributeOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case audioTimeRange
    case transcriptionConfidence
    public static func == (a: Speech.DictationTranscriber.ResultAttributeOption, b: Speech.DictationTranscriber.ResultAttributeOption) -> Swift.Bool
    public typealias AllCases = [Speech.DictationTranscriber.ResultAttributeOption]
    nonisolated public static var allCases: [Speech.DictationTranscriber.ResultAttributeOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public static var supportedLocales: [Foundation.Locale] {
  public static func supportedLocale(equivalentTo locale: Foundation.Locale) async -> Foundation.Locale?
  public static var installedLocales: [Foundation.Locale] {
  final public var selectedLocales: [Foundation.Locale] {
  final public var availableCompatibleAudioFormats: [AVFAudio.AVAudioFormat] {
  final public var results: some Swift.Sendable & _Concurrency.AsyncSequence<Speech.DictationTranscriber.Result, any Swift.Error> {
  public struct Result : Speech.SpeechModuleResult, Swift.Sendable, Swift.CustomStringConvertible, Swift.Equatable, Swift.Hashable {
    public let range: CoreMedia.CMTimeRange
    public let resultsFinalizationTime: CoreMedia.CMTime
    public var text: Foundation.AttributedString {
    public let alternatives: [Foundation.AttributedString]
    public var description: Swift.String {
    public static func == (a: Speech.DictationTranscriber.Result, b: Speech.DictationTranscriber.Result) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public typealias Results = @_opaqueReturnTypeOf("$s6Speech20DictationTranscriberC7resultsQrvp", 0) __
extension Foundation.AttributeScopes {
  public struct SpeechAttributes : Foundation.AttributeScope {
    public let transcriptionConfidence: Foundation.AttributeScopes.SpeechAttributes.ConfidenceAttribute
    public let audioTimeRange: Foundation.AttributeScopes.SpeechAttributes.TimeRangeAttribute
    public struct ConfidenceAttribute : Foundation.CodableAttributedStringKey {
    public static let name: Swift.String
    public typealias Value = Swift.Double
    public struct TimeRangeAttribute : Foundation.CodableAttributedStringKey {
    public static let name: Swift.String
    public typealias Value = CoreMedia.CMTimeRange
    public static func encode(_ value: Foundation.AttributeScopes.SpeechAttributes.TimeRangeAttribute.Value, to encoder: any Swift.Encoder) throws
    public static func decode(from decoder: any Swift.Decoder) throws -> Foundation.AttributeScopes.SpeechAttributes.TimeRangeAttribute.Value
    public typealias DecodingConfiguration = Foundation.AttributeScopeCodableConfiguration
    public typealias EncodingConfiguration = Foundation.AttributeScopeCodableConfiguration
extension Foundation.AttributeDynamicLookup {
  public subscript<T>(dynamicMember keyPath: Swift.KeyPath<Foundation.AttributeScopes.SpeechAttributes, T>) -> T where T : Foundation.AttributedStringKey {
extension Foundation.AttributedString {
  public func rangeOfAudioTimeRangeAttributes(intersecting timeRange: CoreMedia.CMTimeRange) -> Swift.Range<Foundation.AttributedString.Index>?
final public actor SpeechAnalyzer : Swift.Sendable {
  public convenience init(modules: [any Speech.SpeechModule], options: Speech.SpeechAnalyzer.Options? = nil)
  public convenience init<InputSequence>(inputSequence: InputSequence, modules: [any Speech.SpeechModule], options: Speech.SpeechAnalyzer.Options? = nil, analysisContext: Speech.AnalysisContext = .init(), volatileRangeChangedHandler: sending ((_ range: CoreMedia.CMTimeRange, _ changedStart: Swift.Bool, _ changedEnd: Swift.Bool) -> Swift.Void)? = nil) where InputSequence : Swift.Sendable, InputSequence : _Concurrency.AsyncSequence, InputSequence.Element == Speech.AnalyzerInput
  final public func prepareToAnalyze(in audioFormat: AVFAudio.AVAudioFormat?) async throws
  final public func prepareToAnalyze(in audioFormat: AVFAudio.AVAudioFormat?, withProgressReadyHandler progressReadyHandler: sending ((Foundation.Progress) -> Swift.Void)?) async throws
  final public var modules: [any Speech.SpeechModule] {
  final public func setModules(_ newModules: [any Speech.SpeechModule]) async throws
  final public func start<InputSequence>(inputSequence: InputSequence) async throws where InputSequence : Swift.Sendable, InputSequence : _Concurrency.AsyncSequence, InputSequence.Element == Speech.AnalyzerInput
  final public func analyzeSequence<InputSequence>(_ inputSequence: InputSequence) async throws -> CoreMedia.CMTime? where InputSequence : Swift.Sendable, InputSequence : _Concurrency.AsyncSequence, InputSequence.Element == Speech.AnalyzerInput
  final public func finalize(through: CoreMedia.CMTime?) async throws
  final public func finalizeAndFinishThroughEndOfInput() async throws
  final public func finalizeAndFinish(through: CoreMedia.CMTime) async throws
  final public func finish(after: CoreMedia.CMTime) async throws
  final public func cancelAnalysis(before: CoreMedia.CMTime)
  final public func cancelAndFinishNow() async
  final public var volatileRange: CoreMedia.CMTimeRange? {
  final public func setVolatileRangeChangedHandler(_ handler: sending ((_ range: CoreMedia.CMTimeRange, _ changedStart: Swift.Bool, _ changedEnd: Swift.Bool) -> Swift.Void)?)
  final public var context: Speech.AnalysisContext {
  final public func setContext(_ newContext: Speech.AnalysisContext) async throws
  public static func bestAvailableAudioFormat(compatibleWith modules: [any Speech.SpeechModule]) async -> AVFAudio.AVAudioFormat?
  public static func bestAvailableAudioFormat(compatibleWith modules: [any Speech.SpeechModule], considering naturalFormat: AVFAudio.AVAudioFormat?) async -> AVFAudio.AVAudioFormat?
public struct AnalyzerInput : @unchecked Swift.Sendable {
  public init(buffer: AVFAudio.AVAudioPCMBuffer)
  public init(buffer: AVFAudio.AVAudioPCMBuffer, bufferStartTime: CoreMedia.CMTime?)
  public let buffer: AVFAudio.AVAudioPCMBuffer
  public let bufferStartTime: CoreMedia.CMTime?
public enum SpeechModels {
  public static func endRetention() async
final public class SpeechDetector : Speech.SpeechModule {
  public init(detectionOptions: Speech.SpeechDetector.DetectionOptions, reportResults: Swift.Bool)
  public enum SensitivityLevel : Swift.Int, Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case low
    case medium
    case high
    public init?(rawValue: Swift.Int)
    public typealias AllCases = [Speech.SpeechDetector.SensitivityLevel]
    public typealias RawValue = Swift.Int
    nonisolated public static var allCases: [Speech.SpeechDetector.SensitivityLevel] {
    public var rawValue: Swift.Int {
  public struct DetectionOptions : Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public let sensitivityLevel: Speech.SpeechDetector.SensitivityLevel
    public init(sensitivityLevel: Speech.SpeechDetector.SensitivityLevel)
    public static func == (a: Speech.SpeechDetector.DetectionOptions, b: Speech.SpeechDetector.DetectionOptions) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  final public var results: some Swift.Sendable & _Concurrency.AsyncSequence<Speech.SpeechDetector.Result, any Swift.Error> {
  public struct Result : Speech.SpeechModuleResult, Swift.Sendable, Swift.CustomStringConvertible {
    public let range: CoreMedia.CMTimeRange
    public let resultsFinalizationTime: CoreMedia.CMTime
    public let speechDetected: Swift.Bool
    public var description: Swift.String {
  final public var availableCompatibleAudioFormats: [AVFAudio.AVAudioFormat] {
  public typealias Results = @_opaqueReturnTypeOf("$s6Speech0A8DetectorC7resultsQrvp", 0) __
public protocol SpeechModule : AnyObject, Swift.Sendable {
public protocol SpeechModuleResult {
extension Speech.SpeechModuleResult {
  public var isFinal: Swift.Bool {
extension Speech.SpeechAnalyzer {
  public convenience init(inputAudioFile: AVFAudio.AVAudioFile, modules: [any Speech.SpeechModule], options: Speech.SpeechAnalyzer.Options? = nil, analysisContext: Speech.AnalysisContext = .init(), finishAfterFile: Swift.Bool = false, volatileRangeChangedHandler: sending ((_ range: CoreMedia.CMTimeRange, _ changedStart: Swift.Bool, _ changedEnd: Swift.Bool) -> Swift.Void)? = nil) async throws
  final public func start(inputAudioFile audioFile: AVFAudio.AVAudioFile, finishAfterFile: Swift.Bool = false) async throws
  final public func analyzeSequence(from audioFile: AVFAudio.AVAudioFile) async throws -> CoreMedia.CMTime?
final public class SpeechTranscriber : Speech.SpeechModule, Speech.LocaleDependentSpeechModule {
  public struct Preset : Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public static let transcription: Speech.SpeechTranscriber.Preset
    public static let transcriptionWithAlternatives: Speech.SpeechTranscriber.Preset
    public static let timeIndexedTranscriptionWithAlternatives: Speech.SpeechTranscriber.Preset
    public static let progressiveTranscription: Speech.SpeechTranscriber.Preset
    public static let timeIndexedProgressiveTranscription: Speech.SpeechTranscriber.Preset
    public init(transcriptionOptions: Swift.Set<Speech.SpeechTranscriber.TranscriptionOption>, reportingOptions: Swift.Set<Speech.SpeechTranscriber.ReportingOption>, attributeOptions: Swift.Set<Speech.SpeechTranscriber.ResultAttributeOption>)
    public var transcriptionOptions: Swift.Set<Speech.SpeechTranscriber.TranscriptionOption>
    public var reportingOptions: Swift.Set<Speech.SpeechTranscriber.ReportingOption>
    public var attributeOptions: Swift.Set<Speech.SpeechTranscriber.ResultAttributeOption>
    public static func == (a: Speech.SpeechTranscriber.Preset, b: Speech.SpeechTranscriber.Preset) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum TranscriptionOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case etiquetteReplacements
    public static func == (a: Speech.SpeechTranscriber.TranscriptionOption, b: Speech.SpeechTranscriber.TranscriptionOption) -> Swift.Bool
    public typealias AllCases = [Speech.SpeechTranscriber.TranscriptionOption]
    nonisolated public static var allCases: [Speech.SpeechTranscriber.TranscriptionOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum ReportingOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case volatileResults
    case alternativeTranscriptions
    case fastResults
    public static func == (a: Speech.SpeechTranscriber.ReportingOption, b: Speech.SpeechTranscriber.ReportingOption) -> Swift.Bool
    public typealias AllCases = [Speech.SpeechTranscriber.ReportingOption]
    nonisolated public static var allCases: [Speech.SpeechTranscriber.ReportingOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public enum ResultAttributeOption : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case audioTimeRange
    case transcriptionConfidence
    public static func == (a: Speech.SpeechTranscriber.ResultAttributeOption, b: Speech.SpeechTranscriber.ResultAttributeOption) -> Swift.Bool
    public typealias AllCases = [Speech.SpeechTranscriber.ResultAttributeOption]
    nonisolated public static var allCases: [Speech.SpeechTranscriber.ResultAttributeOption] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public static var isAvailable: Swift.Bool {
  public static var supportedLocales: [Foundation.Locale] {
  public static func supportedLocale(equivalentTo locale: Foundation.Locale) async -> Foundation.Locale?
  public static var installedLocales: [Foundation.Locale] {
  final public var selectedLocales: [Foundation.Locale] {
  final public var availableCompatibleAudioFormats: [AVFAudio.AVAudioFormat] {
  final public var results: some Swift.Sendable & _Concurrency.AsyncSequence<Speech.SpeechTranscriber.Result, any Swift.Error> {
  public struct Result : Speech.SpeechModuleResult, Swift.Sendable, Swift.CustomStringConvertible, Swift.Equatable, Swift.Hashable {
    public let range: CoreMedia.CMTimeRange
    public let resultsFinalizationTime: CoreMedia.CMTime
    public var text: Foundation.AttributedString {
    public let alternatives: [Foundation.AttributedString]
    public var description: Swift.String {
    public static func == (a: Speech.SpeechTranscriber.Result, b: Speech.SpeechTranscriber.Result) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
  public typealias Results = @_opaqueReturnTypeOf("$s6Speech0A11TranscriberC7resultsQrvp", 0) __
extension Speech.SpeechAnalyzer {
  public struct Options : Swift.Sendable, Swift.Equatable {
    public let priority: _Concurrency.TaskPriority
    public let modelRetention: Speech.SpeechAnalyzer.Options.ModelRetention
    public enum ModelRetention : Swift.CaseIterable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    case whileInUse
    case lingering
    case processLifetime
    public static func == (a: Speech.SpeechAnalyzer.Options.ModelRetention, b: Speech.SpeechAnalyzer.Options.ModelRetention) -> Swift.Bool
    public typealias AllCases = [Speech.SpeechAnalyzer.Options.ModelRetention]
    nonisolated public static var allCases: [Speech.SpeechAnalyzer.Options.ModelRetention] {
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    public init(priority: _Concurrency.TaskPriority, modelRetention: Speech.SpeechAnalyzer.Options.ModelRetention)
    public static func == (a: Speech.SpeechAnalyzer.Options, b: Speech.SpeechAnalyzer.Options) -> Swift.Bool
final public class AnalysisContext : Swift.Sendable {
  final public var contextualStrings: [Speech.AnalysisContext.ContextualStringsTag : [Swift.String]] {
  final public var userData: [Speech.AnalysisContext.UserDataTag : any Swift.Sendable] {
  public struct ContextualStringsTag : Swift.RawRepresentable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public typealias RawValue = Swift.String
    public init(_ rawValue: Speech.AnalysisContext.ContextualStringsTag.RawValue)
    public init(rawValue: Speech.AnalysisContext.ContextualStringsTag.RawValue)
    public let rawValue: Speech.AnalysisContext.ContextualStringsTag.RawValue
    public static let general: Speech.AnalysisContext.ContextualStringsTag
  public struct UserDataTag : Swift.RawRepresentable, Swift.Sendable, Swift.Equatable, Swift.Hashable {
    public typealias RawValue = Swift.String
    public init(_ rawValue: Speech.AnalysisContext.UserDataTag.RawValue)
    public init(rawValue: Speech.AnalysisContext.UserDataTag.RawValue)
    public let rawValue: Speech.AnalysisContext.UserDataTag.RawValue
final public class AssetInstallationRequest : ObjectiveC.NSObject, Foundation.ProgressReporting, Swift.Sendable {
  final public func downloadAndInstall() async throws
public protocol DataInsertable {
public protocol TemplateInsertable {
public class SFCustomLanguageModelData : Swift.Hashable, Swift.Codable {
  public struct PhraseCount : Swift.Hashable, Swift.Sendable, Swift.CustomStringConvertible, Swift.Codable, Speech.DataInsertable {
    public let phrase: Swift.String
    public let count: Swift.Int
    public init(phrase: Swift.String, count: Swift.Int)
    public var description: Swift.String {
    public func insert(data: Speech.SFCustomLanguageModelData)
    public static func == (a: Speech.SFCustomLanguageModelData.PhraseCount, b: Speech.SFCustomLanguageModelData.PhraseCount) -> Swift.Bool
    public func encode(to encoder: any Swift.Encoder) throws
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    public init(from decoder: any Swift.Decoder) throws
  public struct CustomPronunciation : Swift.Hashable, Swift.Sendable, Swift.CustomStringConvertible, Swift.Codable, Speech.DataInsertable {
    public let grapheme: Swift.String
    public let phonemes: [Swift.String]
    public init(grapheme: Swift.String, phonemes: [Swift.String])
    public var description: Swift.String {
    public func insert(data: Speech.SFCustomLanguageModelData)
    public static func == (a: Speech.SFCustomLanguageModelData.CustomPronunciation, b: Speech.SFCustomLanguageModelData.CustomPronunciation) -> Swift.Bool
    public func encode(to encoder: any Swift.Encoder) throws
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    public init(from decoder: any Swift.Decoder) throws
    public static func buildBlock(_ components: any Speech.DataInsertable...) -> any Speech.DataInsertable
    public static func buildEither(first: any Speech.DataInsertable) -> any Speech.DataInsertable
    public static func buildEither(second: any Speech.DataInsertable) -> any Speech.DataInsertable
    public static func buildOptional(_ component: (any Speech.DataInsertable)?) -> any Speech.DataInsertable
    public static func buildArray(_ components: [any Speech.DataInsertable]) -> any Speech.DataInsertable
  public class PhraseCountGenerator : Swift.Hashable, Swift.Codable, _Concurrency.AsyncSequence, Speech.DataInsertable {
    public typealias AsyncIterator = Speech.SFCustomLanguageModelData.PhraseCountGenerator.Iterator
    public typealias Element = Speech.SFCustomLanguageModelData.PhraseCount
    public func makeAsyncIterator() -> Speech.SFCustomLanguageModelData.PhraseCountGenerator.Iterator
    public init()
    public typealias Element = Speech.SFCustomLanguageModelData.PhraseCount
    public func next() async throws -> Speech.SFCustomLanguageModelData.PhraseCount?
    public static func == (lhs: Speech.SFCustomLanguageModelData.PhraseCountGenerator, rhs: Speech.SFCustomLanguageModelData.PhraseCountGenerator) -> Swift.Bool
    public func hash(into hasher: inout Swift.Hasher)
    public func insert(data: Speech.SFCustomLanguageModelData)
    public func encode(to encoder: any Swift.Encoder) throws
    public var hashValue: Swift.Int {
    public struct Template : Swift.Hashable, Swift.Codable, Speech.TemplateInsertable {
    public let body: Swift.String
    public let count: Swift.Int
    public init(_ body: Swift.String, count: Swift.Int)
    public func insert(generator: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator)
    public static func == (a: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template, b: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template) -> Swift.Bool
    public func encode(to encoder: any Swift.Encoder) throws
    public func hash(into hasher: inout Swift.Hasher)
    public var hashValue: Swift.Int {
    public init(from decoder: any Swift.Decoder) throws
    public typealias Element = Speech.SFCustomLanguageModelData.PhraseCount
    public init(templates: [Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator.Template], templateClasses: [Swift.String : [Swift.String]])
    public func insert(template: Swift.String, count: Swift.Int)
    public func define(className: Swift.String, values: [Swift.String])
    public static func == (lhs: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator, rhs: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator) -> Swift.Bool
  public struct CompoundTemplate : Speech.TemplateInsertable {
    public init(_ components: [any Speech.TemplateInsertable])
    public func insert(generator: Speech.SFCustomLanguageModelData.TemplatePhraseCountGenerator)
    public static func buildBlock(_ components: any Speech.TemplateInsertable...) -> any Speech.TemplateInsertable
    public static func buildEither(first: any Speech.TemplateInsertable) -> any Speech.TemplateInsertable
    public static func buildEither(second: any Speech.TemplateInsertable) -> any Speech.TemplateInsertable
    public static func buildOptional(_ component: (any Speech.TemplateInsertable)?) -> any Speech.TemplateInsertable
    public static func buildArray(_ components: [any Speech.TemplateInsertable]) -> any Speech.TemplateInsertable
  public struct PhraseCountsFromTemplates : Speech.DataInsertable {
    public init(classes: [Swift.String : [Swift.String]], @Speech.SFCustomLanguageModelData.TemplateInsertableBuilder builder: () -> any Speech.TemplateInsertable)
    public func insert(data: Speech.SFCustomLanguageModelData)
  final public let locale: Foundation.Locale
  final public let identifier: Swift.String
  final public let version: Swift.String
  public static func supportedPhonemes(locale: Foundation.Locale) -> [Swift.String]
  public init(locale: Foundation.Locale, identifier: Swift.String, version: Swift.String)
  public func insert(phraseCount: Speech.SFCustomLanguageModelData.PhraseCount)
  public func insert(phraseCountGenerator: Speech.SFCustomLanguageModelData.PhraseCountGenerator)
  public func insert(term: Speech.SFCustomLanguageModelData.CustomPronunciation)
  public func export(to path: Foundation.URL) async throws
  public static func == (lhs: Speech.SFCustomLanguageModelData, rhs: Speech.SFCustomLanguageModelData) -> Swift.Bool
  public func hash(into hasher: inout Swift.Hasher)
  public func encode(to encoder: any Swift.Encoder) throws
  public var hashValue: Swift.Int {
extension Speech.SFAcousticFeature {
  public var acousticFeatureValuePerFrame: [Swift.Double] {
extension Speech.SFSpeechError.Code {
  public static var audioDisordered: Speech.SFSpeechError.Code {
  public static var unexpectedAudioFormat: Speech.SFSpeechError.Code {
  public static var noModel: Speech.SFSpeechError.Code {
  public static var assetLocaleNotAllocated: Speech.SFSpeechError.Code {
  public static var tooManyAssetLocalesAllocated: Speech.SFSpeechError.Code {
  public static var incompatibleAudioFormats: Speech.SFSpeechError.Code {
  public static var moduleOutputFailed: Speech.SFSpeechError.Code {
  public static var cannotAllocateUnsupportedLocale: Speech.SFSpeechError.Code {
  public static var insufficientResources: Speech.SFSpeechError.Code {
extension Speech.AssetInventory.Status : Swift.Hashable {}
extension Speech.SpeechDetector.SensitivityLevel : Swift.RawRepresentable {}
```

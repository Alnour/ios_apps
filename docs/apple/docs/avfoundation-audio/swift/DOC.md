---
name: avfoundation-audio
description: "AVFAudio recording and playback: AVAudioRecorder, AVAudioSession, AVAudioPlayer, AVAudioEngine"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,avfoundation,avfaudio,audio,recording"
---

# AVFAudio — recording & playback

## How our apps use it
- Session: `AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])`, `setActive(true)`.
- Permission: `await AVAudioApplication.requestRecordPermission()` (iOS 17+ API), plus `NSMicrophoneUsageDescription`.
- Record: `AVAudioRecorder(url:, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1])`,
  `isMeteringEnabled = true` → `updateMeters()` + `averagePower(forChannel: 0)` for a level meter.
- Play: `AVAudioPlayer(contentsOf:)`, `prepareToPlay()`, `play()`; observe `currentTime` with a timer.
- Store files under Application Support/Audio/<uuid>.m4a; exclude from backup if large.

## Reference (developer.apple.com, fetched 2026-10-01)

### AVAudioRecorder  
*iOS: 3.0.0 -* · <https://developer.apple.com/documentation/avfaudio/avaudiorecorder.md>


An object that records audio data to a file.

```
class AVAudioRecorder
```

#### Overview

Use an audio recorder to:

- Record audio from the system’s active input device
- Record for a specified duration or until the user stops recording
- Pause and resume a recording
- Access recording-level metering data

To record audio in iOS or tvOS, configure your audio session to use the [`record`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct/record) or [`playAndRecord`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct/playAndRecord) category.

> Important:
> For more advanced recording capabilities, like applying signal processing to recorded audio, use ``doc://com.apple.avfaudio/documentation/AVFAudio/AVAudioEngine`` instead.

#### Topics

##### Creating an audio recorder

[`init(url: URL, settings: [String : Any]) throws`](/documentation/AVFAudio/AVAudioRecorder/init(url:settings:)-5whyq)

Creates an audio recorder with settings.

[`init(url: URL, format: AVAudioFormat) throws`](/documentation/AVFAudio/AVAudioRecorder/init(url:format:)-7herw)

Creates an audio recorder with an audio format.

##### Controlling recording

[`func prepareToRecord() -> Bool`](/documentation/AVFAudio/AVAudioRecorder/prepareToRecord())

Creates an audio file and prepares the system for recording.

[`func record() -> Bool`](/documentation/AVFAudio/AVAudioRecorder/record())

Starts or resumes audio recording.

[`func record(atTime: TimeInterval) -> Bool`](/documentation/AVFAudio/AVAudioRecorder/record(atTime:))

Records audio starting at a specific time.

[`func record(forDuration: TimeInterval) -> Bool`](/documentation/AVFAudio/AVAudioRecorder/record(forDuration:))

Records audio for the indicated duration of time.

[`func record(atTime: TimeInterval, forDuration: TimeInterval) -> Bool`](/documentation/AVFAudio/AVAudioRecorder/record(atTime:forDuration:))

Records audio starting at a specific time for the indicated duration.

[`func pause()`](/documentation/AVFAudio/AVAudioRecorder/pause())

Pauses an audio recording.

[`func stop()`](/documentation/AVFAudio/AVAudioRecorder/stop())

Stops recording and closes the audio file.

[`var isRecording: Bool`](/documentation/AVFAudio/AVAudioRecorder/isRecording)

A Boolean value that indicates whether the audio recorder is recording.

[`func deleteRecording() -> Bool`](/documentation/AVFAudio/AVAudioRecorder/deleteRecording())

Deletes a recorded audio file.

##### Accessing recorder timing

[`var currentTime: TimeInterval`](/documentation/AVFAudio/AVAudioRecorder/currentTime)

The time, in seconds, since the beginning of the recording.

[`var deviceCurrentTime: TimeInterval`](/documentation/AVFAudio/AVAudioRecorder/deviceCurrentTime)

The time, in seconds, of the host audio device.

##### Managing audio channels

[`var channelAssignments: [AVAudioSessionChannelDescription]?`](/documentation/AVFAudio/AVAudioRecorder/channelAssignments)

An array of channel descriptions associated with the audio recorder.

##### Managing audio-level metering

[`var isMeteringEnabled: Bool`](/documentation/AVFAudio/AVAudioRecorder/isMeteringEnabled)

A Boolean value that indicates whether you’ve enabled the recorder to generate audio-level metering data.

[`func updateMeters()`](/documentation/AVFAudio/AVAudioRecorder/updateMeters())

Refreshes the average and peak power values for all channels of an audio recorder.

[`func averagePower(forChannel: Int) -> Float`](/documentation/AVFAudio/AVAudioRecorder/averagePower(forChannel:))

Returns the average power, in decibels full-scale (dBFS), for an audio channel.

[`func peakPower(forChannel: Int) -> Float`](/documentation/AVFAudio/AVAudioRecorder/peakPower(forChannel:))

Returns the peak power, in decibels full-scale (dBFS), for an audio channel.

##### Responding to recorder events

[`var delegate: (any AVAudioRecorderDelegate)?`](/documentation/AVFAudio/AVAudioRecorder/delegate)

The delegate object for the audio recorder.

[`protocol AVAudioRecorderDelegate`](/documentation/AVFAudio/AVAudioRecorderDelegate)

A protocol that defines the methods to respond to audio recording events and encoding errors.

##### Inspecting the audio data

[`var url: URL`](/documentation/AVFAudio/AVAudioRecorder/url)

The URL to which the recorder writes its data.

[`var format: AVAudioFormat`](/documentation/AVFAudio/AVAudioRecorder/format)

The format of the recorded audio.

[`var settings: [String : Any]`](/documentation/AVFAudio/AVAudioRecorder/settings)

The settings that describe the format of the recorded audio.

##### Initializers

[`init(URL: URL, format: AVAudioFormat) throws`](/documentation/AVFAudio/AVAudioRecorder/init(URL:format:)-hpsc)

[`init(URL: URL, settings: [String : Any]) throws`](/documentation/AVFAudio/AVAudioRecorder/init(URL:settings:)-9zay9)

#### Relationships

##### Conforms To

[`Equatable`](/documentation/Swift/Equatable)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Sendable`](/documentation/Swift/Sendable)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Hashable`](/documentation/Swift/Hashable)

[`CVarArg`](/documentation/Swift/CVarArg)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### AVAudioSession  
*iOS: 3.0.0 -* · <https://developer.apple.com/documentation/avfaudio/avaudiosession.md>


An object that communicates to the system how you intend to use audio in your app.

```
class AVAudioSession
```

#### Overview

An audio session acts as an intermediary between your app and the operating system — and, in turn, the underlying audio hardware. You use an audio session to communicate to the operating system the general nature of your app’s audio without detailing the specific behavior or required interactions with the audio hardware. You delegate the management of those details to the audio session, which ensures that the operating system can best manage the user’s audio experience.

All iOS, tvOS, and watchOS apps have a default audio session that comes preconfigured with the following behavior:

- It supports audio playback, but disallows audio recording.
- When the app plays audio, it silences any other background audio.
- In iOS, setting the Ring/Silent switch to silent mode silences any audio the app is playing.
- In iOS, locking a device silences the app’s audio.

Although the default audio session provides useful behavior, it generally doesn’t provide the audio behavior a media app needs. To change the default behavior, you configure your app’s audio session category.

There are six possible categories you can use, but [`playback`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct/playback) is the one that playback apps most commonly use. This category indicates that audio playback is a central feature of your app. When you specify this category, your app’s audio continues with the Ring/Silent switch set to silent mode (iOS only). Using this category, you can also play background audio if you’re using the Audio, AirPlay, and Picture in Picture background mode. For more information, see `Enabling Background Audio`.

You use an [`AVAudioSession`](/documentation/AVFAudio/AVAudioSession) object to configure your app’s audio session. This class is a singleton object used to set the audio session’s category, mode, and other configurations. You can interact with the audio session throughout your app’s life cycle, but it’s often useful to perform this configuration at app launch, as shown in the following example.

```swift
func configureAudioSession() {
    // Retrieve the shared audio session.
    let audioSession = AVAudioSession.sharedInstance()
    do {
        // Set the audio session category and mode.
        try audioSession.setCategory(.playback, mode: .moviePlayback)
    } catch {
        print("Failed to set the audio session configuration")
    }
}
```

The audio session uses this configuration when you activate the session using the [`setActive:error:`](/documentation/AVFAudio/AVAudioSession/setActive:error:), [`setActive(_:options:)`](/documentation/AVFAudio/AVAudioSession/setActive(_:options:)), or [`activate(options:completionHandler:)`](/documentation/AVFAudio/AVAudioSession/activate(options:completionHandler:)) method.

> Note:
> You can activate the audio session at any time after setting its category, but it’s generally preferable to defer this call until your app begins audio playback. Deferring the call ensures that you won’t prematurely interrupt any other background audio that may be in progress.

#### Topics

##### Accessing the shared audio session

[`class func sharedInstance() -> AVAudioSession`](/documentation/AVFAudio/AVAudioSession/sharedInstance())

Returns the shared audio session instance.

##### Configuring standard audio behaviors

[`func setCategory(AVAudioSession.Category, mode: AVAudioSession.Mode, policy: AVAudioSession.RouteSharingPolicy, options: AVAudioSession.CategoryOptions) throws`](/documentation/AVFAudio/AVAudioSession/setCategory(_:mode:policy:options:))

Sets the session category, mode, route-sharing policy, and options.

[`func setCategory(AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws`](/documentation/AVFAudio/AVAudioSession/setCategory(_:mode:options:))

Sets the audio session’s category, mode, and options.

[`func setCategory(AVAudioSession.Category, options: AVAudioSession.CategoryOptions) throws`](/documentation/AVFAudio/AVAudioSession/setCategory(_:options:))

Sets the audio session’s category with the specified options.

[`func setCategory(AVAudioSession.Category) throws`](/documentation/AVFAudio/AVAudioSession/setCategory(_:))

Sets the audio session’s category.

[`func setMode(AVAudioSession.Mode) throws`](/documentation/AVFAudio/AVAudioSession/setMode(_:))

Sets the audio session’s mode.

##### Configuring the spatial experience in visionOS

[`var intendedSpatialExperience: any AVAudioSessionSpatialExperience`](/documentation/AVFAudio/AVAudioSession/intendedSpatialExperience-1bpnq)

The spatial audio experience your app intends to provide the user.   

[`@property (nonatomic, readonly) AVAudioSessionSpatialExperience intendedSpatialExperience;`](/documentation/AVFAudio/AVAudioSession/intendedSpatialExperience-qlty)

The spatial audio experience your app intends to provide the user.

[`func setIntendedSpatialExperience(any AVAudioSessionSpatialExperience) throws`](/documentation/AVFAudio/AVAudioSession/setIntendedSpatialExperience(_:))

Sets the spatial audio experience your app intends to provide the user.

[`- (BOOL) setIntendedSpatialExperience:(AVAudioSessionSpatialExperience) intendedSpatialExperience options:(NSDictionary<NSString *,id> *) options error:(NSError **) error;`](/documentation/AVFAudio/AVAudioSession/setIntendedSpatialExperience:options:error:)

Sets the spatial audio experience your app intends to provide the user.

[`enum AVAudioSessionSpatialExperience : NSInteger;`](/documentation/AVFAudio/AVAudioSessionSpatialExperience-c.enum)

[`protocol AVAudioSessionSpatialExperience`](/documentation/AVFAudio/AVAudioSessionSpatialExperience-swift.protocol)

[`enum SoundStageSize`](/documentation/AVFAudio/AVAudioSession/SoundStageSize)

Constants that specify the perceived size of sounds the audio session plays.

[`enum AnchoringStrategy`](/documentation/AVFAudio/AVAudioSession/AnchoringStrategy)

Constants that specify how to set the origin of audio in a head-tracked spatial experience.

[`@property (nonatomic, readonly, nullable) NSDictionary<NSString *,id> * intendedSpatialExperienceOptions;`](/documentation/AVFAudio/AVAudioSession/intendedSpatialExperienceOptions)

A dictionary of options that customize the spatial experience.

[`typedef NSString * const AVAudioSessionSpatialExperienceOption;`](/documentation/AVFAudio/AVAudioSessionSpatialExperienceOption)

A key that configures one characteristic of a spatial experience, such as its sound stage size or anchoring.

[`var isNowPlayingCandidate: Bool`](/documentation/AVFAudio/AVAudioSession/isNowPlayingCandidate)

A Boolean value that indicates whether the audio session is a candidate to be the Now Playing session.

[`func setIsNowPlayingCandidate(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setIsNowPlayingCandidate(_:))

Sets a Boolean value that indicates whether the audio session is a candidate to be the Now Playing session.

##### Activating and deactivating the session

[`- (BOOL) setActive:(BOOL) active error:(NSError **) outError;`](/documentation/AVFAudio/AVAudioSession/setActive:error:)

Activates or deactivates your app’s audio session.

[`func setActive(Bool, options: AVAudioSession.SetActiveOptions) throws`](/documentation/AVFAudio/AVAudioSession/setActive(_:options:))

Activates or deactivates your app’s audio session using the specified options.

[`func activate(options: AVAudioSessionActivationOptions, completionHandler: (Bool, (any Error)?) -> Void)`](/documentation/AVFAudio/AVAudioSession/activate(options:completionHandler:))

Activates an audio session asynchronously.

[`func deactivate(options: AVAudioSessionDeactivationOptions, completionHandler: (Bool, (any Error)?) -> Void)`](/documentation/AVFAudio/AVAudioSession/deactivate(options:completionHandler:))

Deactivates the audio session asynchronously.

[`struct AVAudioSessionActivationOptions`](/documentation/AVFAudio/AVAudioSessionActivationOptions)

Constants that describe the options to pass when activating the audio session.

[`struct AVAudioSessionDeactivationOptions`](/documentation/AVFAudio/AVAudioSessionDeactivationOptions)

Options for deactivating an AVAudioSession

##### Observing activation lifecycle

[`class let didBecomeActiveNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/didBecomeActiveNotification)

Notification sent when the audio session becomes active.

[`class let didBecomeInactiveNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/didBecomeInactiveNotification)

Notification sent when the audio session becomes inactive.

[`class let resumptionRecommendationNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/resumptionRecommendationNotification)

Notification sent when the system provides a resumption recommendation.

[`class let deactivationContextKey: String`](/documentation/AVFAudio/AVAudioSession/deactivationContextKey)

Keys for [`didBecomeInactiveNotification`](/documentation/AVFAudio/AVAudioSession/didBecomeInactiveNotification)
Value is an [`AVAudioSession.DeactivationContext`](/documentation/AVFAudio/AVAudioSession/DeactivationContext) object describing the deactivation.

[`class let resumptionContextKey: String`](/documentation/AVFAudio/AVAudioSession/resumptionContextKey)

Keys for [`resumptionRecommendationNotification`](/documentation/AVFAudio/AVAudioSession/resumptionRecommendationNotification)
Value is an [`AVAudioSession.ResumptionContext`](/documentation/AVFAudio/AVAudioSession/ResumptionContext) describing the resumption recommendation.

##### Handling activation messages

[`struct DidBecomeActiveMessage`](/documentation/AVFAudio/AVAudioSession/DidBecomeActiveMessage)

[`struct DidBecomeInactiveMessage`](/documentation/AVFAudio/AVAudioSession/DidBecomeInactiveMessage)

[`struct ResumptionRecommendationMessage`](/documentation/AVFAudio/AVAudioSession/ResumptionRecommendationMessage)

[`enum DeactivationResult`](/documentation/AVFAudio/AVAudioSession/DeactivationResult)

Type-safe representation of audio session deactivation results.

##### Getting activation context details

[`class DeactivationContext`](/documentation/AVFAudio/AVAudioSession/DeactivationContext)

An object that describes why and how the audio session deactivated.

[`enum DeactivationSource`](/documentation/AVFAudio/AVAudioSession/DeactivationSource)

The source of the audio session deactivation.

[`class InterruptionContext`](/documentation/AVFAudio/AVAudioSession/InterruptionContext)

An object that provides context about an audio session interruption.

[`class ResumptionContext`](/documentation/AVFAudio/AVAudioSession/ResumptionContext)

An object that provides context when resumption becomes available.

[`enum ResumptionRecommendation`](/documentation/AVFAudio/AVAudioSession/ResumptionRecommendation)

The system’s recommendation on whether to resume playback.

##### Inspecting the category configuration

[`var category: AVAudioSession.Category`](/documentation/AVFAudio/AVAudioSession/category-swift.property)

The current audio session category.

[`var availableCategories: [AVAudioSession.Category]`](/documentation/AVFAudio/AVAudioSession/availableCategories)

The audio session categories available on the current device.

[`struct Category`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct)

Audio session category identifiers.

[`var categoryOptions: AVAudioSession.CategoryOptions`](/documentation/AVFAudio/AVAudioSession/categoryOptions-swift.property)

The set of options associated with the current audio session category.

[`struct CategoryOptions`](/documentation/AVFAudio/AVAudioSession/CategoryOptions-swift.struct)

Constants that specify optional audio behaviors.

[`static var farFieldInput: AVAudioSession.CategoryOptions`](/documentation/AVFAudio/AVAudioSession/CategoryOptions-swift.struct/farFieldInput)

This option should be used if a session prefers to use FarFieldInput when available.
This option is only valid with categories that support input -
[`playAndRecord`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct/playAndRecord), [`record`](/documentation/AVFAudio/AVAudioSession/Category-swift.struct/record), and `AVAudioSessionMultiRoute` with [`dualRoute`](/documentation/AVFAudio/AVAudioSession/Mode-swift.struct/dualRoute).

##### Inspecting mode configuration

[`var mode: AVAudioSession.Mode`](/documentation/AVFAudio/AVAudioSession/mode-swift.property)

The current audio session’s mode.

[`var availableModes: [AVAudioSession.Mode]`](/documentation/AVFAudio/AVAudioSession/availableModes)

The audio session modes available on the device.

[`struct Mode`](/documentation/AVFAudio/AVAudioSession/Mode-swift.struct)

Audio session mode identifiers.

##### Inspecting rendering mode and capabilities

[`var renderingMode: AVAudioSession.RenderingMode`](/documentation/AVFAudio/AVAudioSession/renderingMode-swift.property)

The current audio session’s rendering mode.

[`enum RenderingMode`](/documentation/AVFAudio/AVAudioSession/RenderingMode-swift.enum)

Audio session rendering mode identifiers.

[`class let renderingModeChangeNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/renderingModeChangeNotification)

A notification the system posts when the rendering mode changes.

[`var supportedOutputChannelLayouts: [AVAudioChannelLayout]`](/documentation/AVFAudio/AVAudioSession/supportedOutputChannelLayouts)

The array of channel layouts that the current route supports.

[`class let renderingCapabilitiesChangeNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/renderingCapabilitiesChangeNotification)

A notification the system posts when the rendering capabilities change.

##### Inspecting the route sharing policy

[`var routeSharingPolicy: AVAudioSession.RouteSharingPolicy`](/documentation/AVFAudio/AVAudioSession/routeSharingPolicy-swift.property)

The active route-sharing policy.

[`enum RouteSharingPolicy`](/documentation/AVFAudio/AVAudioSession/RouteSharingPolicy-swift.enum)

Cases that indicate the possible route-sharing policies for an audio session.

##### Mixing with other audio

[`var isOtherAudioPlaying: Bool`](/documentation/AVFAudio/AVAudioSession/isOtherAudioPlaying)

A Boolean value that indicates whether another app is playing audio.

[`var secondaryAudioShouldBeSilencedHint: Bool`](/documentation/AVFAudio/AVAudioSession/secondaryAudioShouldBeSilencedHint)

A Boolean value that indicates whether another app, with a nonmixable audio session, is playing audio.

[`class let silenceSecondaryAudioHintNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/silenceSecondaryAudioHintNotification)

A notification the system posts when the primary audio from other apps starts and stops.

[`var allowHapticsAndSystemSoundsDuringRecording: Bool`](/documentation/AVFAudio/AVAudioSession/allowHapticsAndSystemSoundsDuringRecording)

A Boolean value that indicates whether system sounds and haptics play while recording from audio input.

[`func setAllowHapticsAndSystemSoundsDuringRecording(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setAllowHapticsAndSystemSoundsDuringRecording(_:))

Sets a Boolean value that indicates whether system sounds and haptics play while recording from audio input.

##### Managing audio routing

[Audio routing](/documentation/AVFAudio/audio-routing)

Inspect and configure audio routes, ports, and data sources.

##### Preparing for long-form video playback

[`func prepareRouteSelectionForPlayback(completionHandler: (Bool, AVAudioSession.RouteSelection) -> Void)`](/documentation/AVFAudio/AVAudioSession/prepareRouteSelectionForPlayback(completionHandler:))

Prepares the route selection for long-form video playback.

[`enum RouteSelection`](/documentation/AVFAudio/AVAudioSession/RouteSelection)

Constants used to define the active route selection.

  <doc://com.apple.documentation/documentation/AVKit/AVAudioSessionRouteSelection>

##### Handling interruptions

[`var prefersNoInterruptionsFromSystemAlerts: Bool`](/documentation/AVFAudio/AVAudioSession/prefersNoInterruptionsFromSystemAlerts)

A Boolean value that indicates a preference for not interrupting the session with system alerts.

[`func setPrefersNoInterruptionsFromSystemAlerts(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setPrefersNoInterruptionsFromSystemAlerts(_:))

Sets the preference for not interrupting the audio session with system alerts.

[`var prefersInterruptionOnRouteDisconnect: Bool`](/documentation/AVFAudio/AVAudioSession/prefersInterruptionOnRouteDisconnect)

A Boolean value that indicates whether the system interrupts the audio session when the active route disconnects.

[`func setPrefersInterruptionOnRouteDisconnect(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setPrefersInterruptionOnRouteDisconnect(_:))

Sets a preference to interrupt the audio session when the active route disconnects.

[`class let interruptionNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/interruptionNotification)

A notification the system posts when an audio interruption occurs.

##### Monitoring spatial capabilities

[`class let spatialPlaybackCapabilitiesChangedNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/spatialPlaybackCapabilitiesChangedNotification)

A notification the system posts when its spatial playback capabilities change.

##### Inspecting the audio prompt style

[`var promptStyle: AVAudioSession.PromptStyle`](/documentation/AVFAudio/AVAudioSession/promptStyle-swift.property)

A hint to audio sessions that use voice prompt mode to alter the type of prompts they issue in response to other system audio, such as Siri and phone calls.

[`enum PromptStyle`](/documentation/AVFAudio/AVAudioSession/PromptStyle-swift.enum)

Constants that indicate the prompt style to use.

##### Enabling stereo recording

[`var inputOrientation: AVAudioSession.StereoOrientation`](/documentation/AVFAudio/AVAudioSession/inputOrientation)

An orientation value that dictates which directions represent left and right when capturing audio from a built-in microphone configured for stereo recording.

[`var preferredInputOrientation: AVAudioSession.StereoOrientation`](/documentation/AVFAudio/AVAudioSession/preferredInputOrientation)

The audio session’s preferred stereo input orientation.

[`func setPreferredInputOrientation(AVAudioSession.StereoOrientation) throws`](/documentation/AVFAudio/AVAudioSession/setPreferredInputOrientation(_:))

Sets the audio session’s preferred stereo input orientation.

[`enum StereoOrientation`](/documentation/AVFAudio/AVAudioSession/StereoOrientation)

Constants that define the supported stereo orientations.

##### Enabling adding audio to calls

[`var isMicrophoneInjectionAvailable: Bool`](/documentation/AVFAudio/AVAudioSession/isMicrophoneInjectionAvailable)

A Boolean value that indicates whether microphone injection is available.

[`var preferredMicrophoneInjectionMode: AVAudioSession.MicrophoneInjectionMode`](/documentation/AVFAudio/AVAudioSession/preferredMicrophoneInjectionMode)

The preferred mode of injecting audio into another app’s input stream.

[`func setPreferredMicrophoneInjectionMode(AVAudioSession.MicrophoneInjectionMode) throws`](/documentation/AVFAudio/AVAudioSession/setPreferredMicrophoneInjectionMode(_:))

Sets the preferred mode of injecting audio into another app’s input stream.

[`enum MicrophoneInjectionMode`](/documentation/AVFAudio/AVAudioSession/MicrophoneInjectionMode)

The modes of injecting audio into another app’s input stream.

[`class let microphoneInjectionCapabilitiesChangeNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/microphoneInjectionCapabilitiesChangeNotification)

A notification the system posts when its capability to inject audio into an input stream changes.

##### Configuring echo cancellation

[`var isEchoCancelledInputAvailable: Bool`](/documentation/AVFAudio/AVAudioSession/isEchoCancelledInputAvailable)

A Boolean value that indicates whether the built-in microphone and speaker route supports echo cancellation.

[`var isEchoCancelledInputEnabled: Bool`](/documentation/AVFAudio/AVAudioSession/isEchoCancelledInputEnabled)

A Boolean value that indicates whether an echo-canceled input is in an enabled state.

[`func setPrefersEchoCancelledInput(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setPrefersEchoCancelledInput(_:))

Sets a preference to enable echo-canceled input on supported hardware.

[`var prefersEchoCancelledInput: Bool`](/documentation/AVFAudio/AVAudioSession/prefersEchoCancelledInput)

A Boolean value that indicates the audio session’s preference for using an echo-canceled input.

##### Configuring audio muting

[`var isOutputMuted: Bool`](/documentation/AVFAudio/AVAudioSession/isOutputMuted)

A Boolean value that indicates whether audio output is in a muted state.

[`func setOutputMuted(Bool) throws`](/documentation/AVFAudio/AVAudioSession/setOutputMuted(_:))

Sets a Boolean value to inform the system to mute the session’s output audio. The default value is false (unmuted).

[`class let outputMuteStateChangeNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/outputMuteStateChangeNotification)

Notification sent to registered listeners when session’s output mute state changes.

[`class let muteStateKey: String`](/documentation/AVFAudio/AVAudioSession/muteStateKey)

Keys for [`outputMuteStateChangeNotification`](/documentation/AVFAudio/AVAudioSession/outputMuteStateChangeNotification)
Value is `NSNumber` type with boolean value 0 for unmuted or value 1 for muted (samples zeroed out)

[`class let userIntentToUnmuteOutputNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/userIntentToUnmuteOutputNotification)

Notification sent to registered listeners when the application’s output is muted and user hints to unmute.

[`class let userIntentToUnmuteOutputNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/userIntentToUnmuteOutputNotification)

Notification sent to registered listeners when the application’s output is muted and user hints to unmute.

[`class let muteStateKey: String`](/documentation/AVFAudio/AVAudioSession/muteStateKey)

Keys for [`outputMuteStateChangeNotification`](/documentation/AVFAudio/AVAudioSession/outputMuteStateChangeNotification)
Value is `NSNumber` type with boolean value 0 for unmuted or value 1 for muted (samples zeroed out)

##### Configuring device settings

[Audio hardware](/documentation/AVFAudio/audio-hardware)

Inspect and configure audio device settings including input gain, sample rate, and channel counts.

##### Setting the aggregated I/O preference

[`func setAggregatedIOPreference(AVAudioSession.IOType) throws`](/documentation/AVFAudio/AVAudioSession/setAggregatedIOPreference(_:))

Sets the audio session’s aggregated I/O configuration preference.

[`enum IOType`](/documentation/AVFAudio/AVAudioSession/IOType)

Constant values used to specify the audio session’s aggregated I/O behavior.

##### Handling a change of media services

[`class let mediaServicesWereResetNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/mediaServicesWereResetNotification)

A notification the system posts when the media server restarts.

[`class let mediaServicesWereLostNotification: NSNotification.Name`](/documentation/AVFAudio/AVAudioSession/mediaServicesWereLostNotification)

A notification the system posts when it terminates the media server.

##### Errors

  <doc://com.apple.documentation/documentation/CoreAudioTypes/AVAudioSession/ErrorCode>

##### Deprecated

[Deprecated Symbols](/documentation/AVFAudio/deprecated-symbols)

Review unsupported symbols and their replacements.

##### Structures

[`struct BypassedSpatialExperience`](/documentation/AVFAudio/AVAudioSession/BypassedSpatialExperience)

An experience that bypasses system-provided audio spatialization.

[`struct FixedSpatialExperience`](/documentation/AVFAudio/AVAudioSession/FixedSpatialExperience)

An experience where the sound has a size dictated by its sound stage and is head-locked relative to the user.

[`struct HeadTrackedSpatialExperience`](/documentation/AVFAudio/AVAudioSession/HeadTrackedSpatialExperience)

An experience where the sound a size dictated by its sound stage and location dictated by its anchoring strategy.

#### Relationships

##### Conforms To

[`CVarArg`](/documentation/Swift/CVarArg)

[`Hashable`](/documentation/Swift/Hashable)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Equatable`](/documentation/Swift/Equatable)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`Sendable`](/documentation/Swift/Sendable)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### AVAudioPlayer  
*iOS: 2.2.0 -* · <https://developer.apple.com/documentation/avfaudio/avaudioplayer.md>


An object that plays audio data from a file or buffer.

```
class AVAudioPlayer
```

#### Overview

Use an audio player to:

- Play audio of any duration from a file or buffer
- Control the volume, panning, rate, and looping behavior of the played audio
- Access playback-level metering data
- Play multiple sounds simultaneously by synchronizing the playback of multiple players

For more information about preparing your app to play audio, see <doc://com.apple.documentation/documentation/AVFoundation/configuring-your-app-for-media-playback>.

> Important:
> For more advanced playback capabilities, like playing streaming or positional audio, use ``doc://com.apple.avfaudio/documentation/AVFAudio/AVAudioEngine`` instead.

#### Topics

##### Creating an audio player

[`init(contentsOf: URL) throws`](/documentation/AVFAudio/AVAudioPlayer/init(contentsOf:))

Creates a player to play audio from a file.

[`init(contentsOf: URL, fileTypeHint: String?) throws`](/documentation/AVFAudio/AVAudioPlayer/init(contentsOf:fileTypeHint:))

Creates a player to play audio from a file of a particular type.

[`init(data: Data) throws`](/documentation/AVFAudio/AVAudioPlayer/init(data:))

Creates a player to play in-memory audio data.

[`init(data: Data, fileTypeHint: String?) throws`](/documentation/AVFAudio/AVAudioPlayer/init(data:fileTypeHint:))

Creates a player to play in-memory audio data of a particular type.

##### Controlling playback

[`func prepareToPlay() -> Bool`](/documentation/AVFAudio/AVAudioPlayer/prepareToPlay())

Prepares the player for audio playback.

[`func play() -> Bool`](/documentation/AVFAudio/AVAudioPlayer/play())

Plays audio asynchronously.

[`func play(atTime: TimeInterval) -> Bool`](/documentation/AVFAudio/AVAudioPlayer/play(atTime:))

Plays audio asynchronously, starting at a specified point in the audio output device’s timeline.

[`func pause()`](/documentation/AVFAudio/AVAudioPlayer/pause())

Pauses audio playback.

[`func stop()`](/documentation/AVFAudio/AVAudioPlayer/stop())

Stops playback and undoes the setup the system requires for playback.

[`var isPlaying: Bool`](/documentation/AVFAudio/AVAudioPlayer/isPlaying)

A Boolean value that indicates whether the player is currently playing audio.

##### Configuring playback settings

[`var volume: Float`](/documentation/AVFAudio/AVAudioPlayer/volume)

The audio player’s volume relative to other audio output.

[`func setVolume(Float, fadeDuration: TimeInterval)`](/documentation/AVFAudio/AVAudioPlayer/setVolume(_:fadeDuration:))

Changes the audio player’s volume over a duration of time.

[`var pan: Float`](/documentation/AVFAudio/AVAudioPlayer/pan)

The audio player’s stereo pan position.

[`var enableRate: Bool`](/documentation/AVFAudio/AVAudioPlayer/enableRate)

A Boolean value that indicates whether you can adjust the playback rate of the audio player.

[`var rate: Float`](/documentation/AVFAudio/AVAudioPlayer/rate)

The audio player’s playback rate.

[`var numberOfLoops: Int`](/documentation/AVFAudio/AVAudioPlayer/numberOfLoops)

The number of times the audio repeats playback.

##### Accessing player timing

[`var currentTime: TimeInterval`](/documentation/AVFAudio/AVAudioPlayer/currentTime)

The current playback time, in seconds, within the audio timeline.

[`var duration: TimeInterval`](/documentation/AVFAudio/AVAudioPlayer/duration)

The total duration, in seconds, of the player’s audio.

##### Configuring the Spatial Audio experience

[`var intendedSpatialExperience: any SpatialAudioExperience`](/documentation/AVFAudio/AVAudioPlayer/intendedSpatialExperience-27klj)

The intended spatial experience for this player.   

[`@property (copy, nonnull) CASpatialAudioExperience * intendedSpatialExperience;`](/documentation/AVFAudio/AVAudioPlayer/intendedSpatialExperience-6py9z)

The intended spatial experience for this player.   

##### Managing audio channels

[`var numberOfChannels: Int`](/documentation/AVFAudio/AVAudioPlayer/numberOfChannels)

The number of audio channels in the player’s audio.

[`var channelAssignments: [AVAudioSessionChannelDescription]?`](/documentation/AVFAudio/AVAudioPlayer/channelAssignments)

An array of channel descriptions for the audio player.

##### Managing audio-level metering

[`var isMeteringEnabled: Bool`](/documentation/AVFAudio/AVAudioPlayer/isMeteringEnabled)

A Boolean value that indicates whether the player is able to generate audio-level metering data.

[`func updateMeters()`](/documentation/AVFAudio/AVAudioPlayer/updateMeters())

Refreshes the average and peak power values for all channels of an audio player.

[`func averagePower(forChannel: Int) -> Float`](/documentation/AVFAudio/AVAudioPlayer/averagePower(forChannel:))

Returns the average power, in decibels full-scale (dBFS), for an audio channel.

[`func peakPower(forChannel: Int) -> Float`](/documentation/AVFAudio/AVAudioPlayer/peakPower(forChannel:))

Returns the peak power, in decibels full-scale (dBFS), for an audio channel.

##### Responding to player events

[`var delegate: (any AVAudioPlayerDelegate)?`](/documentation/AVFAudio/AVAudioPlayer/delegate)

The delegate object for the audio player.

[`protocol AVAudioPlayerDelegate`](/documentation/AVFAudio/AVAudioPlayerDelegate)

A protocol that defines the methods to respond to audio playback events and decoding errors.

##### Inspecting the audio data

[`var url: URL?`](/documentation/AVFAudio/AVAudioPlayer/url)

The URL of the audio file.

[`var data: Data?`](/documentation/AVFAudio/AVAudioPlayer/data)

The audio data associated with the player.

[`var format: AVAudioFormat`](/documentation/AVFAudio/AVAudioPlayer/format)

The format of the player’s audio data.

[`var settings: [String : Any]`](/documentation/AVFAudio/AVAudioPlayer/settings)

A dictionary that provides information about the player’s audio data.

##### Accessing device information

[`var currentDevice: String?`](/documentation/AVFAudio/AVAudioPlayer/currentDevice)

The unique identifier of the current audio player.

[`var deviceCurrentTime: TimeInterval`](/documentation/AVFAudio/AVAudioPlayer/deviceCurrentTime)

The time value, in seconds, of the audio output device’s clock.

##### Initializers

[`init(contentsOfURL: URL) throws`](/documentation/AVFAudio/AVAudioPlayer/init(contentsOfURL:))

[`init(contentsOfURL: URL, fileTypeHint: String?) throws`](/documentation/AVFAudio/AVAudioPlayer/init(contentsOfURL:fileTypeHint:))

#### Relationships

##### Conforms To

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Equatable`](/documentation/Swift/Equatable)

[`Sendable`](/documentation/Swift/Sendable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`CVarArg`](/documentation/Swift/CVarArg)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Hashable`](/documentation/Swift/Hashable)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### AVAudioEngine  
*iOS: 8.0.0 -* · <https://developer.apple.com/documentation/avfaudio/avaudioengine.md>


An object that manages a graph of audio nodes, controls playback, and configures real-time rendering constraints.

```
class AVAudioEngine
```

#### Overview

An audio engine object contains a group of [`AVAudioNode`](/documentation/AVFAudio/AVAudioNode) instances that you attach to form an audio processing chain.

![A flow diagram that shows an app using an audio engine in a real time context. The audio flows from the source file in the app to a player node, a mixer node, and an output node before reaching the device’s speaker or connected headphones.](images/com.apple.avfaudio/media-3901205@2x.png)

You can connect, disconnect, and remove audio nodes during runtime with minor limitations. Removing an audio node that has differing channel counts, or that’s a mixer, can break the graph. Reconnect audio nodes only when they’re upstream of a mixer.

By default, Audio Engine renders to a connected audio device in real time. You can configure the engine to operate in manual rendering mode when you need to render at, or faster than, real time. In that mode, the engine disconnects from audio devices and your app drives the rendering.

##### Create an Engine for Audio File Playback

To play an audio file, you create an [`AVAudioFile`](/documentation/AVFAudio/AVAudioFile) with a file that’s open for reading. Create an audio engine object and an [`AVAudioPlayerNode`](/documentation/AVFAudio/AVAudioPlayerNode) instance, and then attach the player node to the engine. Next, connect the player node to the audio engine’s output node. The engine performs audio output through an output node, which is a singleton that the engine creates the first time you access it.

```swift
let audioFile = /* An AVAudioFile instance that points to file that's open for reading. */
let audioEngine = AVAudioEngine()
let playerNode = AVAudioPlayerNode()

// Attach the player node to the audio engine.
audioEngine.attach(playerNode)

// Connect the player node to the output node.
audioEngine.connect(playerNode, 
                    to: audioEngine.outputNode, 
                    format: audioFile.processingFormat)
```

Then schedule the audio file for full playback. The callback notifies your app when playback completes.

```swift
playerNode.scheduleFile(audioFile, 
                        at: nil, 
                        completionCallbackType: .dataPlayedBack) { _ in
    /* Handle any work that's necessary after playback. */
}
```

Before you play the audio, start the engine.

```swift
do {
    try audioEngine.start()
    playerNode.play()
} catch {
    /* Handle the error. */
}
```

When you’re done, stop the player and the engine.

```swift
playerNode.stop()
audioEngine.stop()
```

#### Topics

##### Creating an Audio Engine

[`init()`](/documentation/AVFAudio/AVAudioEngine/init())

Creates an audio engine instance for rendering in real time.

##### Attaching and Detaching Audio Nodes

[`func attach(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/attach(_:))

Attaches an audio node to the audio engine.

[`func detach(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/detach(_:))

Detaches an audio node from the audio engine.

[`var attachedNodes: Set<AVAudioNode>`](/documentation/AVFAudio/AVAudioEngine/attachedNodes)

A read-only set that contains the nodes you attach to the audio engine.

##### Getting the Input, Output, and Main Mixer Nodes

[`var inputNode: AVAudioInputNode`](/documentation/AVFAudio/AVAudioEngine/inputNode)

The audio engine’s singleton input audio node.

[`var outputNode: AVAudioOutputNode`](/documentation/AVFAudio/AVAudioEngine/outputNode)

The audio engine’s singleton output audio node.

[`var mainMixerNode: AVAudioMixerNode`](/documentation/AVFAudio/AVAudioEngine/mainMixerNode)

The audio engine’s optional singleton main mixer node.

##### Connecting and Disconnecting Audio Nodes

[`func connectNode(AVAudioNode, to: AVAudioNode, format: AVAudioFormat?) throws`](/documentation/AVFAudio/AVAudioEngine/connectNode(_:to:format:))

[`func connectNode(AVAudioNode, to: AVAudioNode, fromBus: AVAudioNodeBus, toBus: AVAudioNodeBus, format: AVAudioFormat?) throws`](/documentation/AVFAudio/AVAudioEngine/connectNode(_:to:fromBus:toBus:format:))

[`func connectNode(AVAudioNode, to: [AVAudioConnectionPoint], fromBus: AVAudioNodeBus, format: AVAudioFormat?) throws`](/documentation/AVFAudio/AVAudioEngine/connectNode(_:to:fromBus:format:))

[`func connect(AVAudioNode, to: AVAudioNode, format: AVAudioFormat?)`](/documentation/AVFAudio/AVAudioEngine/connect(_:to:format:))

Establishes a connection between two nodes.

[`func connect(AVAudioNode, to: AVAudioNode, fromBus: AVAudioNodeBus, toBus: AVAudioNodeBus, format: AVAudioFormat?)`](/documentation/AVFAudio/AVAudioEngine/connect(_:to:fromBus:toBus:format:))

Establishes a connection between two nodes, specifying the input and output busses.

[`func disconnectNodeInput(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/disconnectNodeInput(_:))

Removes all input connections of the node.

[`func disconnectNodeInput(AVAudioNode, bus: AVAudioNodeBus)`](/documentation/AVFAudio/AVAudioEngine/disconnectNodeInput(_:bus:))

Removes the input connection of a node on the specified bus.

[`func disconnectNodeOutput(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/disconnectNodeOutput(_:))

Removes all output connections of a node.

[`func disconnectNodeOutput(AVAudioNode, bus: AVAudioNodeBus)`](/documentation/AVFAudio/AVAudioEngine/disconnectNodeOutput(_:bus:))

Removes the output connection of a node on the specified bus.

##### Managing MIDI Nodes

[`func connectMIDI(AVAudioNode, to: AVAudioNode, format: AVAudioFormat?, eventListProvider: AVMIDIEventListBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:eventListProvider:)-8tmk8)

[`func connectMIDI(AVAudioNode, to: [AVAudioNode], format: AVAudioFormat?, eventListProvider: AVMIDIEventListBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:eventListProvider:)-35k1c)

[`func connectMIDI(AVAudioNode, to: AVAudioNode, format: AVAudioFormat?, eventListBlock: AUMIDIEventListBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:eventListBlock:)-73cd1)

Establishes a MIDI connection between two nodes.

[`func connectMIDI(AVAudioNode, to: [AVAudioNode], format: AVAudioFormat?, eventListBlock: AUMIDIEventListBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:eventListBlock:)-7qtd5)

Establishes a MIDI connection between a source node and multiple destination nodes.

[`func disconnectMIDI(AVAudioNode, from: AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/disconnectMIDI(_:from:)-1kssy)

Removes a MIDI connection between two nodes.

[`func disconnectMIDI(AVAudioNode, from: [AVAudioNode])`](/documentation/AVFAudio/AVAudioEngine/disconnectMIDI(_:from:)-7oaab)

Removes a MIDI connection between one source node and multiple destination nodes.

[`func disconnectMIDIInput(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/disconnectMIDIInput(_:))

Disconnects all input MIDI connections from a node.

[`func disconnectMIDIOutput(AVAudioNode)`](/documentation/AVFAudio/AVAudioEngine/disconnectMIDIOutput(_:))

Disconnects all output MIDI connections from a node.

[`func connectMIDI(AVAudioNode, to: AVAudioNode, format: AVAudioFormat?, block: AUMIDIOutputEventBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:block:)-3bc13)

Establishes a MIDI-only connection between two nodes.

[`func connectMIDI(AVAudioNode, to: [AVAudioNode], format: AVAudioFormat?, block: AUMIDIOutputEventBlock?)`](/documentation/AVFAudio/AVAudioEngine/connectMIDI(_:to:format:block:)-666bc)

Establishes a MIDI-only connection between a source node and multiple destination nodes.

##### Playing Audio

[`func prepare()`](/documentation/AVFAudio/AVAudioEngine/prepare())

Prepares the audio engine for starting.

[`func start() throws`](/documentation/AVFAudio/AVAudioEngine/start())

Starts the audio engine.

[`var isRunning: Bool`](/documentation/AVFAudio/AVAudioEngine/isRunning)

A Boolean value that indicates whether the audio engine is running.

[`func pause()`](/documentation/AVFAudio/AVAudioEngine/pause())

Pauses the audio engine.

[`func stop()`](/documentation/AVFAudio/AVAudioEngine/stop())

Stops the audio engine and releases any previously prepared resources.

[`func reset()`](/documentation/AVFAudio/AVAudioEngine/reset())

Resets all audio nodes in the audio engine.

[`func withMusicSequence<R, E>((borrowing MusicSequence?) throws(E) -> R) throws(E) -> R`](/documentation/AVFAudio/AVAudioEngine/withMusicSequence(_:))

Provides scoped access to the AVAudioEngine’s MusicSequence

##### Manually Rendering an Audio Engine

[`func enableManualRenderingMode(AVAudioEngineManualRenderingMode, format: AVAudioFormat, maximumFrameCount: AVAudioFrameCount) throws`](/documentation/AVFAudio/AVAudioEngine/enableManualRenderingMode(_:format:maximumFrameCount:))

Sets the engine to operate in manual rendering mode with the render format and maximum frame count you specify.

[`func disableManualRenderingMode()`](/documentation/AVFAudio/AVAudioEngine/disableManualRenderingMode())

Sets the engine to render to or from an audio device.

[`func renderOffline(AVAudioFrameCount, to: AVAudioPCMBuffer) throws -> AVAudioEngineManualRenderingStatus`](/documentation/AVFAudio/AVAudioEngine/renderOffline(_:to:))

Makes a render call to the engine operating in the offline manual rendering mode.

##### Getting Manual Rendering Properties

[`typealias AVAudioEngineManualRenderingBlock`](/documentation/AVFAudio/AVAudioEngineManualRenderingBlock)

The type that represents a block that renders the engine when operating in manual rendering mode.

[`var manualRenderingBlock: AVAudioEngineManualRenderingBlock`](/documentation/AVFAudio/AVAudioEngine/manualRenderingBlock)

The block that renders the engine when operating in manual rendering mode.

[`var manualRenderingFormat: AVAudioFormat`](/documentation/AVFAudio/AVAudioEngine/manualRenderingFormat)

The render format of the engine in manual rendering mode.

[`var manualRenderingMaximumFrameCount: AVAudioFrameCount`](/documentation/AVFAudio/AVAudioEngine/manualRenderingMaximumFrameCount)

The maximum number of PCM sample frames the engine produces in any single render call in manual rendering mode.

[`var manualRenderingMode: AVAudioEngineManualRenderingMode`](/documentation/AVFAudio/AVAudioEngine/manualRenderingMode)

The manual rendering mode configured on the engine.

[`var manualRenderingSampleTime: AVAudioFramePosition`](/documentation/AVFAudio/AVAudioEngine/manualRenderingSampleTime)

An indication of where the engine is on its render timeline in manual rendering mode.

[`var isAutoShutdownEnabled: Bool`](/documentation/AVFAudio/AVAudioEngine/isAutoShutdownEnabled)

A Boolean value that indicates whether autoshutdown is in an enabled state.

[`var isInManualRenderingMode: Bool`](/documentation/AVFAudio/AVAudioEngine/isInManualRenderingMode)

A Boolean value that indicates whether the engine is operating in manual rendering mode.

##### Using Connection Points

[`class AVAudioConnectionPoint`](/documentation/AVFAudio/AVAudioConnectionPoint)

A representation of either a source or destination connection point in the audio engine.

[`func connect(AVAudioNode, to: [AVAudioConnectionPoint], fromBus: AVAudioNodeBus, format: AVAudioFormat?)`](/documentation/AVFAudio/AVAudioEngine/connect(_:to:fromBus:format:))

Establishes a connection between a source node and multiple destination nodes.

[`func inputConnectionPoint(for: AVAudioNode, inputBus: AVAudioNodeBus) -> AVAudioConnectionPoint?`](/documentation/AVFAudio/AVAudioEngine/inputConnectionPoint(for:inputBus:))

Returns connection information about a node’s input bus.

[`func outputConnectionPoints(for: AVAudioNode, outputBus: AVAudioNodeBus) -> [AVAudioConnectionPoint]`](/documentation/AVFAudio/AVAudioEngine/outputConnectionPoints(for:outputBus:))

Returns connection information about a node’s output bus.

##### Notifications

[`extern NSString * const AVAudioEngineConfigurationChangeNotification;`](/documentation/AVFAudio/AVAudioEngineConfigurationChangeNotification)

A notification the framework posts when the audio engine configuration changes.

##### Constants

[`enum AVAudioEngineManualRenderingError`](/documentation/AVFAudio/AVAudioEngineManualRenderingError)

Constants that describe error codes that the framework returns from manual rendering mode methods.

[`enum AVAudioEngineManualRenderingMode`](/documentation/AVFAudio/AVAudioEngineManualRenderingMode)

The two modes for manual rendering.

[`enum AVAudioEngineManualRenderingStatus`](/documentation/AVFAudio/AVAudioEngineManualRenderingStatus)

Status codes that return from the render call to the engine operating in manual rendering mode.

##### Instance Properties

[`var musicSequence: MusicSequence?`](/documentation/AVFAudio/AVAudioEngine/musicSequence-1z47z)

#### Relationships

##### Conforms To

[`Equatable`](/documentation/Swift/Equatable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`Sendable`](/documentation/Swift/Sendable)

[`SendableMetatype`](/documentation/Swift/SendableMetatype)

[`Hashable`](/documentation/Swift/Hashable)

[`CVarArg`](/documentation/Swift/CVarArg)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

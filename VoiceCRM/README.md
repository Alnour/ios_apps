# VoiceCRM

A voice-first CRM for iPhone that runs entirely on the device. Each customer is one record,
imported from Contacts. You record a voice note about them; the note is transcribed on device
(SpeechAnalyzer) and Apple Intelligence (Foundation Models) turns it into facts, follow-ups
and a short "where we stand" overview. Facts accumulate into a per-customer knowledge graph
that feeds search and drafted emails/messages. Sending and scheduling hand off to Mail,
Messages, WhatsApp and the system Calendar editor.

Requirements: iOS 26, Apple Intelligence enabled (iPhone 15 Pro or later; or the simulator on
a Mac with Apple Intelligence on). Without Apple Intelligence the app still records,
transcribes, stores facts entered by hand, and sends messages.

## Run

```sh
make run          # build + launch on "iPhone 17 Pro" (SIM="iPhone 17" make run for another)
make test         # unit tests
make screenshot
# exercise the pipeline from the terminal (debug builds only):
say -v Samantha -o /tmp/n.aiff "Met Kate, her budget is fifty thousand, call her next Tuesday."
afconvert /tmp/n.aiff -f m4af -d aac /tmp/n.m4a
../tools/run.sh VoiceCRM -- -seed-audio /tmp/n.m4a \
    -seed-transcript "Met Kate, her budget is fifty thousand, call her next Tuesday." \
    -ask "What do I know about Kate Bell?"
```

`-seed-audio` creates a sample customer (Kate Bell) with that recording and runs the pipeline;
`-seed-transcript` supplies the transcript directly because **the iOS Simulator cannot run either
speech engine** (SpeechAnalyzer asset downloads and SFSpeechRecognizer both fail there). Speech
works on a real iPhone, and the same SpeechAnalyzer code was verified natively on macOS 26.
`-ask` runs the assistant and prints its linked answer. `-tab customers|followUps|assistant` picks the
starting tab and `-open-seeded` opens the sample customer's page (handy for screenshots).

## Run on an iPhone

```sh
make run-device                 # first available iPhone (USB or paired wireless)
DEVICE="iPhone" make run-device # by name or UDID
```

One-time on the phone: Settings › Privacy & Security › Developer Mode → on (restarts), unlock,
plug into the Mac and tap Trust. Apple Intelligence must be on (Settings › Apple Intelligence &
Siri) for extraction, overviews, drafts and the assistant. Signing is automatic with the
`DEVELOPMENT_TEAM` in `project.yml` (paid developer account, so no 7-day expiry).

The Xcode project is generated from `project.yml` (xcodegen); Info.plist keys live there.

## Layout

| Folder | What |
|---|---|
| `VoiceCRM/Models` | SwiftData: `Customer`, `VoiceNote`, `Fact` (knowledge-graph edge), `FollowUp` |
| `VoiceCRM/Services` | `AudioRecorder`, `Transcriber` (SpeechAnalyzer), `Intelligence` (Foundation Models), `NotePipeline`, `Outreach` |
| `VoiceCRM/Support` | Pure helpers: audio file store, phone normalisation, transcript chunking, due-date parsing, debug seed |
| `VoiceCRM/Views` | Customers list/detail, record + note screens, draft-message sheet, follow-ups, assistant chat, UIKit bridges |
| `VoiceCRMTests` | Unit tests for the pure helpers |
| `docs` → `../docs/apple/docs` | Local copies of the Apple framework docs (also via `chub get apple/<id> --lang swift`) |

## How the AI part is kept inside the 4096-token window

One fresh `LanguageModelSession` per task. Long transcripts are chunked by sentence (~2500
tokens each) and extracted per chunk with the previous chunk's summary carried along. The
overview and message drafts are generated from the stored facts and the last few note
summaries, never from raw transcripts. On a context-size error the input is halved and
retried once.

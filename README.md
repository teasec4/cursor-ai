# Cursor Assistant

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![macOS](https://img.shields.io/badge/macOS-26.4%2B-blue.svg)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple.svg)
![SwiftData](https://img.shields.io/badge/Storage-SwiftData-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-lightgrey.svg)

Cursor Assistant is a small macOS writing assistant that corrects selected text through an OpenAI-compatible chat completions API.

The current MVP focuses on one fast flow: select text anywhere on macOS, press a global shortcut, get the corrected text in a floating overlay, then paste it manually from the clipboard.

## Current MVP

- Global shortcut: `Control + Option + Space`
- Copies selected text with Accessibility permission
- Sends text to a configured OpenAI-compatible model
- Shows corrected text in a floating overlay
- Copies the corrected result to the clipboard
- Stores model configuration with SwiftData
- Stores API keys in Keychain
- Keeps the app available in the Dock and running in the background after closing the main window

## Setup

1. Open `cursorAI.xcodeproj` in Xcode.
2. Build and run the `cursorAI` scheme.
3. Open `Settings`.
4. Add an OpenAI-compatible model:
   - Name: any local label, for example `OpenAI`
   - Endpoint: for example `https://api.openai.com/v1/chat/completions`
   - Model: for example `gpt-4.1-mini`
   - API key: your provider key
5. Allow Cursor Assistant in:
   `System Settings > Privacy & Security > Accessibility`

No API key is hardcoded in the project.

## Usage

1. Select text in any macOS app.
2. Press `Control + Option + Space`.
3. Wait for the correction overlay.
4. Press `Command + V` to paste the corrected text.

The app intentionally does not auto-replace text yet. Manual paste keeps the MVP predictable across different macOS apps.

## Project Structure

```text
cursorAI/
  API/                         OpenAI-compatible request and response client
  App/                         App wiring and dependency setup
  Features/GrammarAssistant/   Help, settings, overlay UI, view models
  Platform/                    macOS-specific services
    Accessibility/
    Clipboard/
    Keyboard/
    Overlay/
    Security/
    Selection/
    Window/
  Shared/                      Shared models, settings, app errors
  Storage/                     SwiftData model storage
```

## Architecture

The project keeps the MVP small, but separates the pieces that matter:

- SwiftUI for app UI
- AppKit only for macOS-specific window/overlay behavior
- Observation framework for state
- MVVM for settings and assistant UI
- Protocol-based services for API, storage, clipboard, keyboard shortcut, selection copy, and Keychain
- Swift Concurrency for async API calls

## Notes

- The overlay position is currently based on mouse position, not the exact text cursor.
- Selected text capture depends on macOS Accessibility permission and app-specific copy behavior.
- The API client expects OpenAI-compatible chat completions responses.
- Streaming is not enabled yet, but the API layer is isolated so it can be added later.

## Roadmap

- Improve overlay positioning near the real text cursor
- Add provider/model validation
- Add safer retry and cancellation UI
- Add optional automatic paste/replace mode
- Add translation and chat modes
- Add OCR and screen-aware context later

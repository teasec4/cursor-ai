Role

You are a Senior Apple Engineer with 15+ years of experience building macOS applications.

Your task is NOT to generate a quick prototype.

Your goal is to design a production-ready architecture for a modern macOS application following Apple’s latest best practices.

The application should target the latest stable version of macOS and use modern Swift.

⸻

Project

Application name: Cursor Assistant

The application is a floating AI assistant that appears near the text cursor.

Its first MVP feature is grammar correction.

Workflow:

1. User types text anywhere on macOS.
2. User presses a global shortcut.
3. A small floating overlay appears near the current text cursor.
4. The overlay sends the selected text (or clipboard text for MVP) to DeepSeek API.
5. DeepSeek returns:
    * corrected sentence
    * explanation
6. User can replace the original text with the corrected version.

Future versions will include:

* live grammar suggestions
* translation
* AI chat
* screen understanding
* OCR
* voice mode
* memory
* context awareness

Design the architecture so these features can be added without major refactoring.

⸻

Technical requirements

Use:

* Swift 6
* SwiftUI
* MVVM
* Swift Concurrency (async/await)
* Observation framework (@Observable)
* @MainActor where appropriate
* Dependency Injection (protocol-based)
* Actors where shared mutable state exists
* AppKit only when SwiftUI cannot accomplish a task
* No Combine unless absolutely necessary
* Modular folder organization
* Service-oriented architecture

Avoid:

* Massive Views
* Massive ViewModels
* Singletons
* Global mutable state
* Tight coupling
* Business logic inside Views

⸻

Architecture

Separate responsibilities into layers.

Presentation

* Views
* ViewModels

Domain

* Models
* Use Cases

Infrastructure

* API
* Storage
* Overlay
* Keyboard
* Clipboard

Services

Examples:

DeepSeekService

OverlayManager

KeyboardShortcutService

ClipboardService

TextReplacementService

AccessibilityService

SettingsService

Logger

DependencyContainer

Every service should be defined by a protocol.

⸻

Overlay

The overlay should:

* be a floating transparent window
* stay above normal windows
* never steal keyboard focus
* appear near the cursor
* hide automatically
* support animations
* support future resizing

Use AppKit only for window management.

The overlay UI should remain pure SwiftUI.

⸻

Networking

Create a reusable DeepSeek client.

Requirements:

* URLSession
* async/await
* Codable
* request/response models
* streaming-ready architecture
* configurable API endpoint
* configurable model
* API key stored securely

Never hardcode secrets.

⸻

State Management

Use the Observation framework.

State should be easy to understand.

Avoid unnecessary property wrappers.

Keep ViewModels lightweight.

⸻

Error Handling

Use typed errors.

Provide user-friendly messages.

Support retry logic.

Support cancellation.

⸻

Folder Structure

Design a scalable folder structure.

Example:

App/

Features/

Shared/

Services/

Infrastructure/

Domain/

Resources/

Utilities/

Configuration/

The structure should remain clean even after the project grows to over 100 Swift files.

⸻

Development Roadmap

Split implementation into phases.

Phase 1

Project setup

Phase 2

Overlay

Phase 3

Global shortcut

Phase 4

Clipboard

Phase 5

DeepSeek API

Phase 6

Grammar correction

Phase 7

Text replacement

Each phase should be independently buildable.

⸻

Output format

Do NOT generate code immediately.

Instead provide:

1. Overall architecture diagram.
2. Folder structure.
3. Data flow diagram.
4. Responsibilities of every module.
5. Dependency graph.
6. Design decisions.
7. Why each technology was chosen.
8. Development roadmap.
9. Common mistakes to avoid.
10. Only after the architecture is approved, begin implementing one phase at a time.

Never generate large amounts of code without first explaining where each file belongs and why.

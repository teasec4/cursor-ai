import AppKit

protocol SelectionCopyServicing {
    func copySelectedText() async throws -> String
}

struct SelectionCopyService: SelectionCopyServicing {
    func copySelectedText() async throws -> String {
        guard AXIsProcessTrusted() else {
            promptForAccessibilityPermission()
            throw AppError.accessibilityPermissionMissing
        }

        let pasteboard = NSPasteboard.general
        let previousChangeCount = pasteboard.changeCount

        try await Task.sleep(nanoseconds: 180_000_000)
        sendCopyShortcut()

        for _ in 0..<24 {
            try await Task.sleep(nanoseconds: 75_000_000)

            guard pasteboard.changeCount != previousChangeCount else {
                continue
            }

            guard let text = pasteboard.string(forType: .string)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !text.isEmpty else {
                throw AppError.selectedTextIsEmpty
            }

            return text
        }

        throw AppError.selectedTextIsEmpty
    }

    private func sendCopyShortcut() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)

        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func promptForAccessibilityPermission() {
        let options = [
            "AXTrustedCheckOptionPrompt": true
        ] as CFDictionary

        AXIsProcessTrustedWithOptions(options)
    }
}

struct PreviewSelectionCopyService: SelectionCopyServicing {
    func copySelectedText() async throws -> String {
        "This are selected text with mistake."
    }
}

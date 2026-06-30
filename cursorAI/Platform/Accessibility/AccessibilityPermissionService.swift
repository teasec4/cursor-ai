import AppKit

enum AccessibilityPermissionService {
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    static func requestPermission() {
        let options = [
            "AXTrustedCheckOptionPrompt": true
        ] as CFDictionary

        AXIsProcessTrustedWithOptions(options)
    }

    static func openSystemSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

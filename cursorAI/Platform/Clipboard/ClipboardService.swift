import AppKit

protocol ClipboardServiceProtocol {
    func readText() throws -> String
    func writeText(_ text: String)
}

struct ClipboardService: ClipboardServiceProtocol {
    func readText() throws -> String {
        guard let text = NSPasteboard.general.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        else {
            throw AppError.clipboardIsEmpty
        }

        return text
    }

    func writeText(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

struct PreviewClipboardService: ClipboardServiceProtocol {
    func readText() throws -> String {
        "This are a small sentence with mistake."
    }

    func writeText(_ text: String) {}
}

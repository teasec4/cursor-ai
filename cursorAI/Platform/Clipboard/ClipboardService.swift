import AppKit

protocol ClipboardServiceProtocol {
    func readText() throws -> String
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
}

struct PreviewClipboardService: ClipboardServiceProtocol {
    func readText() throws -> String {
        "This are a small sentence with mistake."
    }
}

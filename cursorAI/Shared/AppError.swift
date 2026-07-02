import Foundation

enum AppError: LocalizedError, Equatable {
    case clipboardIsEmpty
    case selectedTextIsEmpty
    case accessibilityPermissionMissing
    case aiModelMissing
    case invalidModelConfiguration
    case apiKeyMissing
    case invalidResponse
    case requestFailed(String)
    case unsupportedForMVP

    var errorDescription: String? {
        switch self {
        case .clipboardIsEmpty:
            "Clipboard does not contain text."
        case .selectedTextIsEmpty:
            "Select text first, then press the shortcut."
        case .accessibilityPermissionMissing:
            "Allow Cursor Assistant in System Settings > Privacy & Security > Accessibility."
        case .aiModelMissing:
            "Add and select an AI model in Settings first."
        case .invalidModelConfiguration:
            "Check the selected model endpoint in Settings."
        case .apiKeyMissing:
            "Add an API key for the selected model in Settings."
        case .invalidResponse:
            "The AI provider returned an unexpected response."
        case let .requestFailed(message):
            message
        case .unsupportedForMVP:
            "This feature is not available in the MVP yet."
        }
    }
}

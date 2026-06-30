import Foundation

enum AppError: LocalizedError, Equatable {
    case clipboardIsEmpty
    case selectedTextIsEmpty
    case accessibilityPermissionMissing
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
        case .apiKeyMissing:
            "Set DEEPSEEK_API_KEY before using grammar correction."
        case .invalidResponse:
            "DeepSeek returned an unexpected response."
        case let .requestFailed(message):
            message
        case .unsupportedForMVP:
            "This feature is not available in the MVP yet."
        }
    }
}

import Foundation

enum AppError: LocalizedError, Equatable {
    case clipboardIsEmpty
    case apiKeyMissing
    case invalidResponse
    case requestFailed(String)
    case replacementFailed
    case unsupportedForMVP

    var errorDescription: String? {
        switch self {
        case .clipboardIsEmpty:
            "Clipboard does not contain text."
        case .apiKeyMissing:
            "Set DEEPSEEK_API_KEY before using grammar correction."
        case .invalidResponse:
            "DeepSeek returned an unexpected response."
        case let .requestFailed(message):
            message
        case .replacementFailed:
            "Could not replace the original text."
        case .unsupportedForMVP:
            "This feature is not available in the MVP yet."
        }
    }
}

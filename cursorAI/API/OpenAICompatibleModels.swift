import Foundation

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: ChatMessage
    }

    let choices: [Choice]
}

struct ChatCompletionErrorResponse: Codable {
    struct APIError: Codable {
        let message: String
    }

    let error: APIError
}

struct GrammarCorrectionPayload: Codable {
    let corrected: String
}

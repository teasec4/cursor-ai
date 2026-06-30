import Foundation

struct DeepSeekMessage: Codable {
    let role: String
    let content: String
}

struct DeepSeekChatRequest: Codable {
    let model: String
    let messages: [DeepSeekMessage]
    let temperature: Double
}

struct DeepSeekChatResponse: Codable {
    struct Choice: Codable {
        let message: DeepSeekMessage
    }

    let choices: [Choice]
}

struct DeepSeekErrorResponse: Codable {
    struct APIError: Codable {
        let message: String
    }

    let error: APIError
}

struct GrammarCorrectionPayload: Codable {
    let corrected: String
}

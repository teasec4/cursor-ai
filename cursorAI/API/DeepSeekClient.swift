import Foundation

protocol DeepSeekClientProtocol {
    func correctGrammar(text: String) async throws -> GrammarCorrectionResult
}

struct DeepSeekClient: DeepSeekClientProtocol {
    private let settings: AppSettings
    private let apiKeyStore: APIKeyStoring
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(
        settings: AppSettings,
        apiKeyStore: APIKeyStoring,
        session: URLSession = .shared
    ) {
        self.settings = settings
        self.apiKeyStore = apiKeyStore
        self.session = session
    }

    func correctGrammar(text: String) async throws -> GrammarCorrectionResult {
        guard let apiKey = try apiKeyStore.loadAPIKey() else {
            throw AppError.apiKeyMissing
        }

        let provider = settings.selectedProvider

        var request = URLRequest(url: provider.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(chatRequest(for: text, model: provider.model))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = decodeAPIError(from: data) ?? "DeepSeek request failed with status \(httpResponse.statusCode)."
            throw AppError.requestFailed(message)
        }

        let chatResponse = try decoder.decode(DeepSeekChatResponse.self, from: data)

        guard let content = chatResponse.choices.first?.message.content else {
            throw AppError.invalidResponse
        }

        let payload = try decodeCorrectionPayload(from: content)
        return GrammarCorrectionResult(
            originalText: text,
            correctedText: payload.corrected
        )
    }

    private func chatRequest(for text: String, model: String) -> DeepSeekChatRequest {
        DeepSeekChatRequest(
            model: model,
            messages: [
                DeepSeekMessage(
                    role: "system",
                    content: settings.systemPrompt
                ),
                DeepSeekMessage(
                    role: "user",
                    content: text
                )
            ],
            temperature: 0.2
        )
    }

    private func decodeCorrectionPayload(from content: String) throws -> GrammarCorrectionPayload {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else {
            throw AppError.invalidResponse
        }

        do {
            return try decoder.decode(GrammarCorrectionPayload.self, from: data)
        } catch {
            throw AppError.invalidResponse
        }
    }

    private func decodeAPIError(from data: Data) -> String? {
        try? decoder.decode(DeepSeekErrorResponse.self, from: data).error.message
    }
}

struct PreviewDeepSeekClient: DeepSeekClientProtocol {
    func correctGrammar(text: String) async throws -> GrammarCorrectionResult {
        GrammarCorrectionResult(
            originalText: text,
            correctedText: "This is a small sentence with a mistake."
        )
    }
}

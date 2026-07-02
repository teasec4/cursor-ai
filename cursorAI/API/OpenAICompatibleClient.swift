import Foundation

protocol AITextCorrectionClientProtocol {
    func correctGrammar(text: String) async throws -> GrammarCorrectionResult
}

struct OpenAICompatibleClient: AITextCorrectionClientProtocol {
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
        guard let model = settings.selectedAIModel else {
            throw AppError.aiModelMissing
        }

        guard let endpoint = model.endpointURL else {
            throw AppError.invalidModelConfiguration
        }

        guard let apiKey = try apiKeyStore.loadAPIKey(for: model.id) else {
            throw AppError.apiKeyMissing
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(chatRequest(for: text, modelName: model.modelName))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = decodeAPIError(from: data) ?? "AI request failed with status \(httpResponse.statusCode)."
            throw AppError.requestFailed(message)
        }

        let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)

        guard let content = chatResponse.choices.first?.message.content else {
            throw AppError.invalidResponse
        }

        let payload = try decodeCorrectionPayload(from: content)
        return GrammarCorrectionResult(
            originalText: text,
            correctedText: payload.corrected
        )
    }

    private func chatRequest(for text: String, modelName: String) -> ChatCompletionRequest {
        ChatCompletionRequest(
            model: modelName,
            messages: [
                ChatMessage(role: "system", content: settings.systemPrompt),
                ChatMessage(role: "user", content: text)
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
        try? decoder.decode(ChatCompletionErrorResponse.self, from: data).error.message
    }
}

struct PreviewAITextCorrectionClient: AITextCorrectionClientProtocol {
    func correctGrammar(text: String) async throws -> GrammarCorrectionResult {
        GrammarCorrectionResult(
            originalText: text,
            correctedText: "This is a small sentence with a mistake."
        )
    }
}

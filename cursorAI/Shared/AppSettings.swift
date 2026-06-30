import Foundation

@Observable
final class AppSettings {
    var providers: [AIProvider] = [.deepSeek]
    var selectedProviderID = AIProvider.deepSeek.id
    var overlayAutoHideDelay: TimeInterval = 12
    var correctionPersonality: CorrectionPersonality = .balanced
    var correctionStrength: CorrectionStrength = .standard

    var selectedProvider: AIProvider {
        providers.first { $0.id == selectedProviderID } ?? providers[0]
    }

    func addCustomProvider() {
        let provider = AIProvider(
            id: UUID().uuidString,
            name: "Custom Provider",
            endpoint: URL(string: "https://api.example.com/chat/completions")!,
            model: "model-name",
            isBuiltIn: false
        )

        providers.append(provider)
        selectedProviderID = provider.id
    }

    func removeSelectedCustomProvider() {
        guard let index = providers.firstIndex(where: { $0.id == selectedProviderID }),
              providers[index].isBuiltIn == false else {
            return
        }

        providers.remove(at: index)
        selectedProviderID = providers.first?.id ?? AIProvider.deepSeek.id
    }

    func updateSelectedProvider(_ update: (inout AIProvider) -> Void) {
        guard let index = providers.firstIndex(where: { $0.id == selectedProviderID }) else {
            return
        }

        update(&providers[index])
    }

    var systemPrompt: String {
        """
        You are a writing correction assistant.
        \(correctionPersonality.promptInstruction)
        \(correctionStrength.promptInstruction)
        Preserve the original language and core meaning.
        Keep the same language mix as the original text.
        Do not translate unless the user explicitly asks for translation.
        Return only compact JSON with the key "corrected". No explanation. No Markdown.
        """
    }
}

struct AIProvider: Identifiable, Equatable {
    let id: String
    var name: String
    var endpoint: URL
    var model: String
    var isBuiltIn: Bool

    static let deepSeek = AIProvider(
        id: "deepseek",
        name: "DeepSeek",
        endpoint: URL(string: "https://api.deepseek.com/chat/completions")!,
        model: "deepseek-chat",
        isBuiltIn: true
    )
}

enum CorrectionPersonality: String, CaseIterable, Identifiable {
    case neutral
    case balanced
    case friendly
    case professional
    case concise

    var id: String { rawValue }

    var title: String {
        switch self {
        case .neutral:
            "Neutral"
        case .balanced:
            "Balanced"
        case .friendly:
            "Friendly"
        case .professional:
            "Professional"
        case .concise:
            "Concise"
        }
    }

    var subtitle: String {
        switch self {
        case .neutral:
            "Fixes text without adding style."
        case .balanced:
            "Natural, clean, and lightly polished."
        case .friendly:
            "Softer and warmer phrasing."
        case .professional:
            "Clearer business-style writing."
        case .concise:
            "Shorter, tighter wording."
        }
    }

    var promptInstruction: String {
        switch self {
        case .neutral:
            "Use a neutral tone. Do not add personality or flourish."
        case .balanced:
            "Use a natural balanced tone. Improve clarity without making the text feel rewritten."
        case .friendly:
            "Use a friendly tone. Make phrasing warm and approachable without becoming informal."
        case .professional:
            "Use a professional tone. Make the text clear, polished, and suitable for work."
        case .concise:
            "Use a concise tone. Prefer shorter phrasing and remove unnecessary words."
        }
    }
}

enum CorrectionStrength: String, CaseIterable, Identifiable {
    case light
    case standard
    case strong

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light:
            "Light"
        case .standard:
            "Standard"
        case .strong:
            "Strong"
        }
    }

    var subtitle: String {
        switch self {
        case .light:
            "Grammar and typos only."
        case .standard:
            "Grammar plus readability."
        case .strong:
            "More confident rewrite."
        }
    }

    var promptInstruction: String {
        switch self {
        case .light:
            "Make minimal corrections only: grammar, spelling, punctuation, and obvious typos."
        case .standard:
            "Correct grammar, spelling, punctuation, and improve readability when it is clearly helpful."
        case .strong:
            "Correct the text and rewrite awkward phrasing more actively while preserving the author's intent."
        }
    }
}

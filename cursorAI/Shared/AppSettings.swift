import Foundation

@Observable
final class AppSettings {
    var aiModels: [AIModelConfiguration] = []
    var selectedAIModelID: String?
    var overlayAutoHideDelay: TimeInterval = 12
    var correctionPersonality: CorrectionPersonality = .balanced
    var correctionStrength: CorrectionStrength = .standard

    var selectedAIModel: AIModelConfiguration? {
        guard let selectedAIModelID else {
            return nil
        }

        return aiModels.first { $0.id == selectedAIModelID }
    }

    var systemPrompt: String {
        """
        You are a writing correction assistant.
        \(correctionPersonality.promptInstruction)
        \(correctionStrength.promptInstruction)
        Fix grammar, spelling, punctuation, word choice, tense, aspect, and unnatural phrasing.
        Preserve the original language, core meaning, and factual claims.
        If a sentence is grammatically possible but sounds unnatural, misleading, or logically awkward, make it natural and clear.
        Do not invent missing facts or add new details.
        Keep the same language mix as the original text.
        Do not translate unless the user explicitly asks for translation.
        Return only compact JSON with the key "corrected". No explanation. No Markdown.
        """
    }
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
            "Make minimal corrections only: grammar, spelling, punctuation, obvious typos, and clearly wrong tense or aspect."
        case .standard:
            "Correct grammar, spelling, punctuation, tense, aspect, word choice, and improve naturalness/readability when helpful."
        case .strong:
            "Correct the text and rewrite awkward, unnatural, or logically unclear phrasing more actively while preserving the author's intent."
        }
    }
}

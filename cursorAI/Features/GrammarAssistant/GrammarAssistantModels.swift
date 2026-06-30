import Foundation

struct GrammarCorrectionResult: Equatable {
    let originalText: String
    let correctedText: String
}

enum GrammarAssistantState: Equatable {
    case idle
    case loadedClipboard(String)
    case correcting(String)
    case result(GrammarCorrectionResult)
    case failed(String)
}

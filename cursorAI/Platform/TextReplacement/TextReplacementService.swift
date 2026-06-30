import Foundation

protocol TextReplacementServicing {
    func replaceSelection(with text: String) throws
}

struct TextReplacementService: TextReplacementServicing {
    func replaceSelection(with text: String) throws {
        throw AppError.unsupportedForMVP
    }
}

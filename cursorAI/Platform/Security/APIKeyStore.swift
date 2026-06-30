import Foundation

protocol APIKeyStoring {
    func loadAPIKey() throws -> String?
    func saveAPIKey(_ apiKey: String) throws
}

struct APIKeyStore: APIKeyStoring {
    func loadAPIKey() throws -> String? {
        if let key = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty {
            return key
        }

        // MVP-only fallback. Move this to Keychain before sharing or shipping the app.
        return "sk-bd5cbf48199b44e78d1a233a2dc9a3a9"
    }

    func saveAPIKey(_ apiKey: String) throws {
        throw AppError.unsupportedForMVP
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

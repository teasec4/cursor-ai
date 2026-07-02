import Foundation
import Security

protocol APIKeyStoring {
    func loadAPIKey(for modelID: String) throws -> String?
    func saveAPIKey(_ apiKey: String, for modelID: String) throws
    func deleteAPIKey(for modelID: String) throws
}

struct APIKeyStore: APIKeyStoring {
    private let service = "CursorAssistant.APIKeys"

    func loadAPIKey(for modelID: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: modelID,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw AppError.requestFailed("Could not read API key from Keychain.")
        }

        guard let data = item as? Data,
              let key = String(data: data, encoding: .utf8),
              key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return nil
        }

        return key
    }

    func saveAPIKey(_ apiKey: String, for modelID: String) throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedKey.isEmpty == false else {
            try deleteAPIKey(for: modelID)
            return
        }

        let data = Data(trimmedKey.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: modelID
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw AppError.requestFailed("Could not update API key in Keychain.")
        }

        var insertQuery = query
        insertQuery[kSecValueData as String] = data

        let insertStatus = SecItemAdd(insertQuery as CFDictionary, nil)
        guard insertStatus == errSecSuccess else {
            throw AppError.requestFailed("Could not save API key to Keychain.")
        }
    }

    func deleteAPIKey(for modelID: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: modelID
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.requestFailed("Could not delete API key from Keychain.")
        }
    }
}
